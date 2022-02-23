# import csv
# import shapefile
# from rich import print
import pandas as pd
from pydantic import BaseModel, HttpUrl, ValidationError
import config
from pathlib import Path
import os
import sys
import tkinter as tk
from tkinter import filedialog

class MyModel(BaseModel):
    url: HttpUrl

# Make sure the root of the file name matches across files
def files_match(row):
    iso = row['isoFile'].split('.')[0].rstrip('-ISO').replace('_', '')
    filezip = row['zipFilename'].split('.')[0].replace('_', '')
    callnum = row['callNumber'].replace(' ', '')
    if iso == filezip and iso == callnum:
        pass
    else:
        print(f"Files don't match: \n\tISO: {iso}\n\tZIP: {filezip}\n\tCALL: {callnum}")

def check_iso_name(row):
    iso = None
    full_iso_name = None

    try:
        full_iso_name = row['isoFile']
    except:
        print(f'Unable to locate ISO file in row.  Expecting column name to "isoFile"')
        return

    filename = full_iso_name.split('.')[0]
    ext = full_iso_name.split('.')[1]
    
    filename_list = filename.split('-')
    if len(filename_list) == 2:
        bare_filename = filename.split('-')[0] # Remove the ISO from the filename to more easily check date
        iso = filename.split('-')[1] # All ISO files should have ISO in the name
        check_filename_date(bare_filename)
    else:
        print(f'When splitting the ISO filename, there seemed to be something wrong with the "-" character.  Too many/few?')

    # Last part of the ISO filename should be ISO
    try:
        iso == 'ISO'
        # print(f'ISO is in the right place')
    except:
        print(f'Something appears to be wrong with the name of the ISO file.  Expecting it to end with: -ISO.xml')
    
    if ext == 'xml':
        pass
        # print('ISO file extension is correct')
    else:
        print("ISO file extension should be xml, it doesn't appear to be.")

def check_zip_name(row):
    filename = row['zipFilename'].split('.')[0]
    ext = row['zipFilename'].split('.')[1]

    check_filename_date(filename)

    if ext == 'zip':
        pass
        # print(f'ZIP file extension appears correct.')
    else:
        print(f'Please correct the extension of the zipfile.  It should be .zip')

def check_file_exists(row):
    # The name of the zip file, but with the .shp extension
    filename = row['zipFilename'].split('.')[0]
    shpfile = Path(f'{folder_path}/{filename}.shp')
    if shpfile.is_file():
        # Do nothing, File exists
        pass
    else:
        print(f"File doesn't exist: {shpfile}")

def check_filename_date(bare_filename):
    if bare_filename != None:
        if len(bare_filename.split('_')[-1]) == 4: # is it only the 4 digit year?
            year = bare_filename.split('_')[-1]
            try:
                int(year)
            except:
                print(f'Year does not appear to be a valid number: {year}')
        elif len(bare_filename.split('_')[-1]) == 2: # month?
            month = bare_filename.split('_')[-1]
            year =  bare_filename.split('_')[-2]
            try:
                int(month)
                int(year)
            except:
                print(f'File has year and month, but one one does not appear to be a valid number: {year}_{month}')
        else:
            print(f'Unable to find a valid date format on file')

def check_format(row):
    frmt = row['format'].strip()
    if frmt in frmt_list:
        pass
        # print('Format is correct')
    else:
        if frmt.capitalize() in frmt_list:
            # In case the format is "public" - let's keep it consistent - Capitalized
            print('Please capitalize the format') # Let's do this automatically in the future?
        else:
            print(f'The format looks incorrect: {frmt}')

def check_access(row):
    access = row['access'].strip()
    if access in access_list:
        pass
        # print('Access is correct')
    else:
        if access.capitalize() in access_list:
            # In case the access is "shapefile" - let's keep it consistent - Capitalized
            print('Please capitalize the access field') # Let's do this automatically in the future?
        else:
            print(f'The access field looks incorrect: {access}')

def check_provenance(row):
    provenance = row['provenance'].strip()
    if provenance in prov_list:
        pass
        # print('Provenance is correct')
    else:
        prov_split = provenance.split()
        if len(prov_split) >= 2 and len(prov_split) <= 3:
            if prov_split[0] != 'UC':
                print(f'Provenance should start with capitalized "UC"')
            if not prov_split[1][0].isupper():
                print(f'Campus name should be capitalized: {provenance}')
            # There might not be a second word
            try:
                if not prov_split[2][0].isupper():
                    print(f'Campus name should be capitalized: {provenance}')
            except IndexError:
                pass # Probably Davis or Merced, etc. with no 3rd item in the name
        else:
            print(f'Unexpected provenance: {provenance}')

# This needs work
def check_title(row):
    # Not sure how to check this yet.
    # Spaces in place of underscores? 
    pass

# This needs work
def check_desc(row):
    pass

def check_date(row) -> str:
    # For now, we're going to assume date and dateIssued should be the same
    # temporalDate will potentially be different - but probably still a 4 digit year
    # This should be YYYY
    row_date = row['date']
    date_issued = row['dateIssued']
    if row_date != date_issued:
        print(f'The date and dateIssued should probably be the same, you may want to check them:')
        print(f'\t      Date: {row_date}')
        print(f'\tdateIssued: {date_issued}')
        return "Date Error"
    else:
        # The dates should also be numbers
        try:
            int(row_date)
        except ValueError:
            print(f"The date column has a date that doesn't appear to be a number: {row_date}")
            return "Date Error"

        try:
            int(date_issued)
            return date_issued
        except ValueError:
            print(f"The issueDate column has a date that doesn't appear to be a number: {date_issued}")
            return "Date Error"

def create_lang_table():
    # Create a Dataframe of language codes to what language they represent
    langs_df = pd.read_html('https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes', flavor='bs4')
    cols = ['639-2[1]', 'Language name(s) from ISO 639-2[1]']
    return (langs_df[0]
            [cols]
            .rename(columns={'639-2[1]': 'lang_code', 'Language name(s) from ISO 639-2[1]': 'lang'})
            .set_index('lang_code')
    )

def check_lang(row):
    try:
        language = lang_dict[row['language']]
    except KeyError:
        print(f"Unable to find Language: {row['language']}")

# def get_geom(row) -> str:
#     shpfile = row['zipFilename'].split('.')[0] + '.shp'
#     with shapefile.Reader(shpfile) as shp:
#         return(shp.shapeTypeName)

def verify_originator(row):
    originator = row['originator']
    if originator in valid_publishers:
        pass
        # print('Valid originator')
    else:
        print(f'Unable to find originator: {originator}')

def verify_publisher(row):
    publisher = row['publisher']
    if publisher in valid_publishers:
        pass
        # print('Valid Publisher')
    else:
        print(f'Unable to find publisher: {publisher}')

def verify_collection(row):
    collection = row['collectionTitle']
    if collection in valid_collections:
        pass
        # print('Valid Collection')
    else:
        print(f'Unable to find collectionTitle: {collection}')

def verify_subject(row):
    subject = row['subject']
    subject_items = subject.split('|')
    for item in subject_items:
        if item != '':
            if item in valid_topics:
                pass # subject is valid
            else:
                print(f'Invalid subject found: {item}')

def verify_spatialSubject(row):
    spatialsubject = row['spatialSubject']
    subject_items = spatialsubject.split('|')
    for item in subject_items:
        if item != '':
            if item in valid_topics or item in valid_places:
                pass # SpatialSubject is from either the topics or places
            else:
                print(f'Invalid spatialSubject: {item}')

def verify_license(row):
    lic = row['license']

    try:
        MyModel(url=lic)
    except ValidationError:
        print(f'Invalid URL for license.')

def verify_descriptionAppend(row):
    dAppend = row['descriptionAppend']
    if not dAppend[-1] == '.':
        print('descriptionAppend field does not end with a period.')

# Creating dataframes from Google Sheets
def create_df(worksheetname):
    start_url = f"https://docs.google.com/spreadsheets/d/{googleSheetId}/gviz/tq?tqx=out:csv&sheet={worksheetname}"
    url = start_url.replace(" ","")
    df = pd.read_csv(url).iloc[:, :2]
    return df

def number_of_files(working_dir: Path, df: pd.DataFrame):
    file_count = 0
    for item in working_dir.iterdir():
        if item.is_file():
            if item.suffix == '.shp':
                file_count += 1
    print(f'Number of shapefiles in directory: {file_count}')
    df_rec_count = df.shape[0]
    print(f'Number of records in Excel file: {df_rec_count}')

    if file_count != df_rec_count:
        print('\n**WARNING: File counts are different.**')


if __name__ == '__main__':
    root = tk.Tk()
    root.withdraw()
    
    ingest_file = Path(filedialog.askopenfilename(defaultextension='.xlsx'))
    
    if ingest_file.is_file():
        if ingest_file.suffix == '.xlsx':
            print(f'Found Ingest file.')
        else:
            print(f'Ingest file should be an Excel XLSX.  Selected Ingest file has extension: {ingest_file.suffix}\n')
            sys.exit()
    else:
        print(f'Selected item does not appear to be a file.\n')
        sys.exit()

    folder_path = ingest_file.parent # Used to look for shapefiles in same folder
    googleSheetId = config.googleSheetID
    worksheetNames = ['Topic-Theme','Place_Keywords', 'Publisher-Author', 'Collection_Names', 'NameAuthority-Other', 'Uncontrolled_Keywords']
    print(f'Getting Google Sheet data...')
    dataframes = {f"{ws_name}": create_df(ws_name) for ws_name in worksheetNames} # Create a dictionary with all dataframes
    place_df = dataframes['Place_Keywords']
    valid_places = list(place_df['GeoNames term'].values)
    topic_df = dataframes['Topic-Theme']
    valid_topics = list(topic_df['LCSH Term'].values)
    publisher_df = dataframes['Publisher-Author']
    valid_publishers = list(publisher_df['LCNAF Term'].values) # We're only verifying if the originator is valid
    collection_df = dataframes['Collection_Names']
    valid_collections = list(collection_df['Collection Name'].values) # We're only verifying if the originator is valid
    try:
        city_file = Path(f'us_cities_states_counties.csv')
        if city_file.is_file():
            cities_df = pd.read_csv('us_cities_states_counties.csv', delimiter='|')
            cities_df.dropna(how='all', inplace=True)
    except:
        # No city file data, just skip it for now
        pass

    access_list = ['Public', 'Restricted']
    frmt_list = ['Shapefile'] # At some point, when supported, we'll add other formats
    prov_list = ['UC Berkeley','UC Davis','UC Irvine','UC Los Angeles','UC Merced','UC Riverside','UC San Diego','UC Santa Cruz','UC Santa Barbara'] # At some point, when supported, we'll add other provenances. Is it just UCs?

    print(f'Creating language lookup table...')
    lang_lookup = create_lang_table()
    lang_dict = pd.Series(lang_lookup.lang.values, index=lang_lookup.index).to_dict() # Convert dataframe to python dict for simpler lookup

    print(f'Begin file processing...')
    print()

    os.chdir(folder_path)
    print(f'Current working directory: {folder_path}\n')

    df = pd.read_excel(str(ingest_file))
    src_list = df.to_dict(orient='records')

    for row in src_list:
        print(f'Row: {row["isoFile"]}')
        files_match(row)
        check_iso_name(row)
        check_zip_name(row)
        check_file_exists(row)
        check_format(row)
        check_access(row)
        check_provenance(row)
        check_lang(row)
        issued_date = check_date(row)
        verify_originator(row)
        verify_publisher(row)
        verify_collection(row)
        verify_subject(row)
        verify_spatialSubject(row)
        verify_license(row)
        verify_descriptionAppend(row)
        print()

    print('\nSummary counts:')
    number_of_files(folder_path, df)

        # geometry = get_geom(row)  # This will only work once we have proper paths for the shp file
        # description = f'This {geometry.lower()} shapefile represents [topic] in [place] for [date].' \
        #               f'This file was obtained {issued_date} by UCSB Library staff. It was originally available via [source].'
        # print(description)
    print()

