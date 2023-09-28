import argparse
import sys
from pathlib import Path

import polars as pl

parser = argparse.ArgumentParser()

parser.add_argument('-i', '--input',
                    required=True,
                    type=Path,
                    help='[REQUIRED] Input CSV file to be updated to new schema')

parser.add_argument('-o', '--output',
                    required=False,
                    default=Path('.').absolute(),
                    type=Path,
                    help='[OPTIONAL] Output path.  Will default to current directory')

args = parser.parse_args()

def check_input(input_file: Path):
    # Check input file exists and is CSV
    if input_file.exists():
        if input_file.suffix.lower() == '.csv':
            print(f'Input file is good:  {input_file.absolute()}')
        else:
            print(f'Input file does not appear to be a CSV file: {input_file.absolute()}')
            print('Exiting...')
            sys.exit()
    else:
        print(f'Input file does not exist.  {input_file.absolute()}')
        print('Exiting...')
        sys.exit()

def check_output(output_fld: Path):
    # Check input file exists and is CSV
    if output_fld.exists():
        if output_fld.is_dir():
            print(f'Output path is good: {output_fld.absolute()}')
        else:
            print(f'Output path does not appear to be a folder: {output_fld.absolute()}')
            print('Exiting...')
            sys.exit()
    else:
        print(f'Output path does not exist.  {output_fld.absolute()}')
        print('Exiting...')
        sys.exit()

# Before we continue - check input/output are good
check_input(args.input)
check_output(args.output)

cols_to_keep = [
    'zipFilename',
    'format',
    'access',
    'title',
    'alternativeTitle',
    'date',
    'originator',
    'descriptionAppend',
    'description',
    'language',
    'publisher',
    'subject',
    'keyword',
    'collectionTitle',
    'spatialSubject',
    'rights',
    'license',
    'rightsHolder',
    'type',
    'isPartOf',
    'source',
    'replaces',
    'isReplacedBy',
    'isVersionOf',
    'relation',
    'dateIssued',
    'temporalCoverage',
]

# To always put the columns in an expected order.  And how we want them.
order_columns = [
                'source_identifier','model', 'parents', 'use:PreservationFile','use:ServiceFile','format_geo',
                'visibility','title','title_alternative_geo','date_index_geo','creator_geo','description_geo',
                'description','language_geo','publisher_geo','subject_topic_geo','subject_keyword_geo','collectionTitle',
                'subject_spatial_geo','rights_note_geo','license_geo','rights_holder_geo','resource_class_geo',
                'resource_type_geo','isPartOf','source_geo','replaces_geo','is_replaced_by_geo',
                'is_version_of_geo','relation_geo','date_issued_geo','subject_temporal_geo',
                ]

# Used to extend:
# col_to_keep & order_columns
# If source has bounding data
bound_box = [
    'bounding_box_west',
    'bounding_box_east',
    'bounding_box_north',
    'bounding_box_south',
]

# Rename columns old to new
col_rename_map = {
    'zipFilename': 'use:PreservationFile',
    'format': 'format_geo',
    'access': 'visibility',
    'alternativeTitle': 'title_alternative_geo',
    'date': 'date_index_geo',
    'originator': 'creator_geo',
    'descriptionAppend': 'description_geo',
    'language': 'language_geo',
    'publisher': 'publisher_geo',
    'subject': 'subject_topic_geo',
    'keyword': 'subject_keyword_geo',
    'spatialSubject': 'subject_spatial_geo',
    'rights': 'rights_note_geo',
    'license': 'license_geo',
    'rightsHolder': 'rights_holder_geo',
    'type': 'resource_class_geo',
    'source': 'source_geo',
    'replaces': 'replaces_geo',
    'isReplacedBy': 'is_replaced_by_geo',
    'isVersionOf': 'is_version_of_geo',
    'relation': 'relation_geo',
    'dateIssued': 'date_issued_geo',
    'temporalCoverage': 'subject_temporal_geo'
}

input_csv = args.input.absolute()
output_path = args.output.absolute()
output_file = output_path.joinpath('IngestQCm3.csv')

# Pre-checking headers to see if we have boudning box data
headers_in_source = [x.lower() for x in pl.scan_csv(input_csv).columns]

# If source has bounding box data, extend both our lists with those columns
# cols_to_keep - the list of columns to keep from the source csv
# order_columns - the final order of the columns
if all([col in headers_in_source for col in bound_box]):
    print('Extending list...')
    cols_to_keep.extend(bound_box)
    order_columns.extend(bound_box)
else:
    print('\nNo bounding box data in source.  Countinuing without...')

text_to_remove = 'The following metadata was provided by the data creators:  '
df = (pl.read_csv(input_csv, columns=cols_to_keep)
       .rename(col_rename_map)
       .with_columns(
          [
            (pl.lit('')).alias('source_identifier'),
            (pl.lit('')).alias('parents'),
            (pl.lit('GeospatialObject')).alias('model'),
            (pl.lit('')).alias('resource_type_geo'),
            ('geodata/' + pl.col('use:PreservationFile').str.split('.').list.first() + '-d.zip').alias('use:ServiceFile'),
            ('geodata/' + pl.col('use:PreservationFile').str.split('.').list.first() + '-a.zip').alias('use:PreservationFile'),
            (pl.lit('open')).alias('visibility'),
            (pl.lit('Datasets')).alias('resource_class_geo'),
            (pl.col('description_geo').str.strip_chars_start(text_to_remove)),
          ]
      ).select(order_columns)
)

if not set(bound_box).issubset([x.lower() for x in df.columns]):
    # bounding box data not in dataframe.  Adding empty columns
    print('Adding bounding box columns...')
    df = df.with_columns(
            [
                pl.lit('').alias('bounding_box_west_geo'),
                pl.lit('').alias('bounding_box_east_geo'),
                pl.lit('').alias('bounding_box_north_geo'),
                pl.lit('').alias('bounding_box_south_geo'), # add _geo to bounding boxes AW
            ]
        )

df.write_csv(output_file)

print(f'\nCreated the following output file: {output_file.absolute()}\n')
