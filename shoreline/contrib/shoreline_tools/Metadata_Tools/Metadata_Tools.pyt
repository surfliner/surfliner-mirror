import arcpy
import os
import xml.etree.ElementTree as ET
import csv
import re
import traceback


class Toolbox(object):
    def __init__(self):
        """Define the toolbox (the name of the toolbox is the name of the .pyt file)"""
        self.label = "Metadata Tools"
        self.alias = ""

        # List of tool classes associated with this toolbox
        self.tools = [Extract_Metadata_to_CSV, Create_Derivative_Files, Upgrade_and_Validate_Files]


def remove_HTML_Tags(text):
	#Strip embedded html tags from parameter text	
    tags = re.compile('<.*?>')
    return re.sub(tags, '', text)

		
class Extract_Metadata_to_CSV(object):
    def __init__(self):
        #Define the tool (tool name is the name of the class).
		
        self.label = "2. Extract Metadata to CSV"
        self.description = "For each shapefile or TIFF in a user-selected folder(and subfolders), upgrade metadata (if necessary) and export specific metadata values to a CSV file. View results window for shapefile issues."
        self.canRunInBackground = False

    def getParameterInfo(self):
		#Define parameter definitions	

		# First parameter
		param0 = arcpy.Parameter(
			displayName="Input Workspace",
			name="in_workspace",
			datatype="Workspace",
			parameterType="Required",
			direction="Input")

		# Second parameter

		params = [param0]
		return params


    def execute(self, parameters, messages):
        """The source code of the tool."""

	# Dictionary of constraint categories
	constraint = {'000': 'Empty','001': 'Copyright','002': 'Patent','003': 'Patent Pending','004': 'Trademark','005': 'License','006': 'Intellectual Property Rights', '007': 'Restricted','008' : 'Other Restrictions'}
	
 	try:
		# arcpy environments
		arcpy.env.overwriteOutput = "True"

		# Set the input workspace
		arcpy.env.workspace = parameters[0].valueAsText

		# install location
		installDir = arcpy.GetInstallInfo("desktop")["InstallDir"] 

		# create new csv output file
		csvFile = os.path.join(parameters[0].valueAsText, "Metadata_Extract.csv") 

		csvWriter = csv.writer(open(csvFile, 'wb'))
		
		# create header list
		row = ["xmlFile", "zipFilename", "filename", "format1", "format", "callNumber", "access", "provenance", "title1", "title", "alternativeTitle", "date1", "date",
		"originatorName", "originatorOrg", "originator", "description", "language", "publisherName", "publisherOrg", "publisher", "subject1", "subject", "keyword",
		"collectionTitle1", "collectionTitle", "spatialCoverage1", "spatialCoverage", "useLimitation1", "useLimitation2", "accessConst", "useConst", "otherConst", "rights", "license",
		"rightsHolder", "type", "isPartOf", "source", "replaces", "isReplacedBy", "isVersionOf", "relation", "dateIssued", "temporalCoverage", "schemaVersion", "suppressed",
		"west", "east", "north", "south", "references"]

		# write header to csv file
		csvWriter.writerow([v.encode("UTF-8") for v in row])


		# Step through the user-selected folder and extract metadata values
		for dirPath, dirNames, fileNames in os.walk(arcpy.env.workspace):
			dirNames.sort()
			for file in fileNames:
				if file.lower().endswith(".shp.xml") or file.lower().endswith(".tif.xml"):
					formatText = titleText = dateText = originatorNameText = originatorOrgText = descriptionText = languageText = publisherNameText = publisherOrgText = ""
					subjectText = collectionTitleText = spatialCoverageText = useLimitationText1 = useLimitationText2 = accessConstText = useConstText = otherConstText = ""
					westText = eastText = northText = southText = ""
					arcpy.AddMessage("******************************************")

					# read in XML
					tree = ET.parse(os.path.join(dirPath, file))
					root = tree.getroot()

					# upgrade FGDC metadata content to ArcGIS metadata format
					metadataUpgradeNeeded = True
					EsriElt = root.find('Esri')
					if ET.iselement(EsriElt):
						ArcGISFormatElt = EsriElt.find('ArcGISFormat')
						if ET.iselement(ArcGISFormatElt):
							arcpy.AddMessage(file + ": metadata is already in ArcGIS format.")
							metadataUpgradeNeeded = False

					if metadataUpgradeNeeded:
						arcpy.AddMessage(file + ": metadata is being upgraded to ArcGIS format...")
						result = arcpy.UpgradeMetadata_conversion(os.path.join(dirPath, file), "FGDC_TO_ARCGIS")
						#arcpy.AddMessage(result.getMessages())

						# reload xml tree after upgrade
						tree = ET.parse(os.path.join(dirPath, file))
						root = tree.getroot()


					crucialEltsFound = True
					dataIdInfoElt = root.find('dataIdInfo')
					if ET.iselement(dataIdInfoElt):
						idCitationElt = dataIdInfoElt.find('idCitation')
						if not ET.iselement(idCitationElt): crucialEltsFound = False
					else: crucialEltsFound = False
					
					if crucialEltsFound == False:
						arcpy.AddMessage("*********************************************************************************************************************************")
						arcpy.AddMessage(file + ": CRUCIAL METADATA ELEMENTS MISSING! OPEN METADATA FOR THIS FILE IN ARCCATALOG TO UPDATE, THEN RERUN THIS TOOL.")
						arcpy.AddMessage("*********************************************************************************************************************************")
						continue



					##################################################################################################
					# Extract format from XML file

					distInfoElt = root.find('distInfo')
					if ET.iselement(distInfoElt):
						distFormatElt = distInfoElt.find('distFormat')
						if ET.iselement(distFormatElt):
							formatNameElt = distFormatElt.find('formatName')
							if ET.iselement(formatNameElt):
								formatText = formatNameElt.text

					##################################################################################################
					# Extract description from XML file
					 
					idAbsElt = dataIdInfoElt.find('idAbs')
					if ET.iselement(idAbsElt):
						descriptionText = remove_HTML_Tags(idAbsElt.text)

					"""
						if descriptionText1:
							descriptionText1 = "The following metadata was provided by the data creators:  " + descriptionText1
						else: arcpy.AddMessage(file + ": note - no description found")

					descriptionText2 = 'This [geom] shapefile represents [topic] in [place] for [date]. This file was obtained [date] by UCSB Library staff. It was originally available via [source].'
					"""
					
					##################################################################################################
					# Extract language from XML file

					dataLangElt = dataIdInfoElt.find('dataLang')
					if ET.iselement(dataLangElt):
						languageCodeElt = dataLangElt.find('languageCode')
						if ET.iselement(languageCodeElt):
							languageText = languageCodeElt.get('value')
							
					if not languageText: arcpy.AddMessage(file + ": note - no data language found")

					##################################################################################################
					# Extract theme and place keywords from XML file
					
					for child1 in dataIdInfoElt:
						if child1.tag == 'themeKeys':
							for child2 in child1:
								if child2.tag == 'keyword':
									subjectText = subjectText + "|" + child2.text.rstrip()

					subjectText = subjectText[1:len(subjectText)]
							
					for child1 in dataIdInfoElt:
						if child1.tag == 'placeKeys':
							for child2 in child1:
								if child2.tag == 'keyword':
									spatialCoverageText = spatialCoverageText + "|" + child2.text.rstrip()

					spatialCoverageText = spatialCoverageText[1:len(spatialCoverageText)]
					if not spatialCoverageText: arcpy.AddMessage(file + ": note - no spatial coverage keywords found")

					##################################################################################################
					# Extract general constraints from XML file

					for child in dataIdInfoElt:
						if child.tag == 'resConst':
							constsElt = child.find('Consts')
							if ET.iselement(constsElt):
								useLimitElt = constsElt.find('useLimit')
								if ET.iselement(useLimitElt):
									useLimitationText1 = remove_HTML_Tags(useLimitElt.text)

					if not useLimitationText1: arcpy.AddMessage(file + ": note - no general use limitation found")

					##################################################################################################
					# Extract legal constraints from XML file

					for child in dataIdInfoElt:
						if child.tag == 'resConst':
							legConstsElt = child.find('LegConsts')
							if ET.iselement(legConstsElt):
								firstPass = True
								for subElt in legConstsElt:
									if subElt.tag == 'accessConsts':
										restrictCdElt = subElt.find('RestrictCd')
										if ET.iselement(restrictCdElt):
											#e.g. <RestrictCd value="001"/>
											listValue = constraint[restrictCdElt.get('value')]
											if firstPass:
												accessConstText = listValue
												firstPass = False
											else:
												accessConstText = accessConstText + "|" + listValue
									elif subElt.tag == 'useLimit':
										useLimitationText2 = subElt.text
									elif subElt.tag == 'othConsts':
										otherConstText = subElt.text

					if not accessConstText: arcpy.AddMessage(file + ": note - no legal access constraint found")
					if not useLimitationText2: arcpy.AddMessage(file + ": note - no legal use limitation found")
					if not otherConstText: arcpy.AddMessage(file + ": note - no legal other constraint found")

					##################################################################################################
					# Extract legal use constraints from XML file

					for child in dataIdInfoElt:
						if child.tag == 'resConst':
							legConstsElt = child.find('LegConsts')
							if ET.iselement(legConstsElt):
								firstPass = True
								for subElt in legConstsElt:
									if subElt.tag == 'useConsts':
										restrictCdElt = subElt.find('RestrictCd')
										if ET.iselement(restrictCdElt):
											#e.g. <RestrictCd value="001"/>
											listValue = constraint[restrictCdElt.get('value')]
											if firstPass:
												useConstText = listValue
												firstPass = False
											else:
												useConstText = useConstText + "|" + listValue

					if not useConstText: arcpy.AddMessage(file + ": note - no legal use constraints found")
						
					##################################################################################################
					# Extract bounding box extent values from XML file

					for child in dataIdInfoElt:
						if child.tag == 'dataExt':
							geoEleElt = child.find('geoEle')
							if not ET.iselement(geoEleElt): continue
							GeoBndBoxElt = geoEleElt.find('GeoBndBox')
							if not ET.iselement(GeoBndBoxElt): continue
							if GeoBndBoxElt.get('esriExtentType') <> 'search': continue
							westBLElt = GeoBndBoxElt.find('westBL')
							if ET.iselement(westBLElt): westText = westBLElt.text
							eastBLElt = GeoBndBoxElt.find('eastBL')
							if ET.iselement(eastBLElt): eastText = eastBLElt.text
							northBLElt = GeoBndBoxElt.find('northBL')
							if ET.iselement(northBLElt): northText = northBLElt.text
							southBLElt = GeoBndBoxElt.find('southBL')
							if ET.iselement(southBLElt): southText = southBLElt.text
							
					##################################################################################################
					# Extract title from XML file

					resTitleElt = idCitationElt.find('resTitle')
					if ET.iselement(resTitleElt): titleText = resTitleElt.text
					if not titleText:
						idinfoElt = root.find('idinfo')
						if ET.iselement(idinfoElt):
							citationElt = idinfoElt.find('citation')
							if ET.iselement(citationElt):
								citeinfoElt = citationElt.find('citeinfo')
								if ET.iselement(citeinfoElt):
									titleElt = citeinfoElt.find('title')
									if ET.iselement(titleElt):
										titleText = titleElt.text

					if not titleText: arcpy.AddMessage(file + ": note - no title found")

					##################################################################################################
					# Extract originator from XML file

					firstPassInd = True
					firstPassOrg = True
					for child in idCitationElt:
						if child.tag == 'citRespParty':
							roleElt = child.find('role')
							if ET.iselement(roleElt):
								roleCdElt = roleElt.find('RoleCd')
								if ET.iselement(roleCdElt):
									if roleCdElt.get('value') == '006':
										rpIndNameElt = child.find('rpIndName')
										if ET.iselement(rpIndNameElt):
											if firstPassInd:
												originatorNameText = rpIndNameElt.text
												firstPassInd = False
											else:
												originatorNameText = originatorNameText + "|" + rpIndNameElt.text

										rpOrgNameElt = child.find('rpOrgName')
										if ET.iselement(rpOrgNameElt):
											if firstPassOrg:
												originatorOrgText = rpOrgNameElt.text
												firstPassOrg = False
											else:
												originatorOrgText = originatorOrgText + "|" + rpOrgNameElt.text

					if not originatorNameText: arcpy.AddMessage(file + ": note - no originator name found")
					if not originatorOrgText: arcpy.AddMessage(file + ": note - no originator organization found")
					
					##################################################################################################
					# Extract publisher from XML file

					firstPassInd = True
					firstPassOrg = True
					for child in idCitationElt:
						if child.tag == 'citRespParty':
							roleElt = child.find('role')
							if ET.iselement(roleElt):
								roleCdElt = roleElt.find('RoleCd')
								if ET.iselement(roleCdElt):
									if roleCdElt.get('value') == '010':
										rpIndNameElt = child.find('rpIndName')
										if ET.iselement(rpIndNameElt):
											if firstPassInd:
												publisherNameText = rpIndNameElt.text
												firstPassInd = False
											else:
												publisherNameText = publisherNameText + "|" + rpIndNameElt.text

										rpOrgNameElt = child.find('rpOrgName')
										if ET.iselement(rpOrgNameElt):
											if firstPassOrg:
												publisherOrgText = rpOrgNameElt.text
												firstPassOrg = False
											else:
												publisherOrgText = publisherOrgText + "|" + rpOrgNameElt.text

					if not publisherNameText: arcpy.AddMessage(file + ": note - no publisher name found")
					if not publisherOrgText: arcpy.AddMessage(file + ": note - no publisher organization found")
					
					##################################################################################################
					# Extract collection title from XML file

					collTitleElt = idCitationElt.find('collTitle')
					if ET.iselement(collTitleElt):
						collectionTitleText = collTitleElt.text

					if not collectionTitleText: arcpy.AddMessage(file + ": note - no collection title found")

					##################################################################################################
					# Extract published date from XML file

					dateElt = idCitationElt.find('date')
					if ET.iselement(dateElt):
						pubDateElt = dateElt.find('pubDate')
						if ET.iselement(pubDateElt):
							dateText = pubDateElt.text
							if dateText:
								if dateText.find("T"):
									temp = pubDateElt.text.split("T")
									dateText = temp[0]

					if not dateText:
						arcpy.AddMessage(file + ": note - no published date found")
						dateText = ""

					##################################################################################################								
					# Save zip file name and shapefile path

					if file.lower().endswith(".shp.xml"):
						fileExt = ".shp.xml"
					elif file.lower().endswith(".tif.xml"):
						fileExt = ".tif.xml"
					
					baseFileName = file.replace(fileExt, "")
					#isoFileText = baseFileName + '-ISO.xml'
					zipFilenameText = baseFileName + '.zip'
					callNumberText = baseFileName.replace("_", " ").replace("-", ".")						
					filenameText = os.path.join(dirPath, file.replace(".xml", ""))


					# Write extracted data to CSV file
					row = [file, zipFilenameText, filenameText, formatText, "", callNumberText, 'Public', 'UC Santa Barbara', titleText, "", "", dateText, "",
					originatorNameText, originatorOrgText, "", descriptionText, languageText, publisherNameText, publisherOrgText, "", subjectText, "", "",
					collectionTitleText, "", spatialCoverageText, "",useLimitationText1, useLimitationText2, accessConstText, useConstText, otherConstText,
					"", "", "", "", "", "", "", "", "", "", "", "", "", "", westText, eastText, northText, southText]

					csvWriter.writerow([v.encode("UTF-8") for v in row])
		
		del csvFile
		del csvWriter
		del tree
		del root

	except Exception as err:
      		arcpy.AddMessage(arcpy.GetMessages(2))
      		print (arcpy.GetMessages(2))
		arcpy.AddMessage(traceback.format_exc())
  		raise arcpy.ExecuteError
        return
		
    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True
    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return
    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return


####################################################################################################################################################################################################
####################################################################################################################################################################################################

class Create_Derivative_Files(object):
    def __init__(self):
        #Define the tool (tool name is the name of the class).

        self.label = "3. Create WGS 1984 Derivatives"
        self.description = "For each shapefile or GeoTIFF in a user-selected folder (and subfolders), create a copy with spatial reference 'WGS 1984'. \
							The original file is renamed with suffix '-a', and the derivative is named with suffix '-d'. \
							Note - if the projection for an original file is undefined, the derivative is not created."
        self.canRunInBackground = False

    def getParameterInfo(self):
		#Define parameter definitions	

		# First parameter
		param0 = arcpy.Parameter(
			displayName="Input Workspace",
			name="in_workspace",
			datatype="Workspace",
			parameterType="Required",
			direction="Input")
								
		params = [param0]
		return params


    def execute(self, parameters, messages):
        """The source code of the tool."""

 	try:
		# arcpy environments
		arcpy.env.overwriteOutput = "True"

		# Set the input workspace
		arcpy.env.workspace = parameters[0].valueAsText
		arcpy.AddMessage("workspace = " + arcpy.env.workspace)

		arcpy.AddMessage("****************************")
		arcpy.AddMessage("Checking files for undefined coordinate systems")

		# Step through the user-selected folder, and rename file if coordinate system defined
		for (dirPath, dirNames, fileNames) in os.walk(arcpy.env.workspace):
			for file in fileNames:
				if file.endswith('.shp') or file.endswith('.tif'):
					dsc = arcpy.Describe(os.path.join(dirPath, file))
					coordSys = dsc.spatialReference
					if coordSys.Name <> "Unknown":
						if file.endswith('.shp'): newFilename = file.replace(".shp", "-a.shp")
						elif file.endswith('.tif'): newFilename = file.replace(".tif", "-a.tif")
						arcpy.Rename_management(os.path.join(dirPath, file), os.path.join(dirPath, newFilename))
					else:
						arcpy.AddMessage("Coord Sys: " + coordSys.Name)
						arcpy.AddMessage("*****************************************************************************************************************")
						arcpy.AddMessage(file + ": COORDINATE SYSTEM UNDEFINED! RUN DEFINE PROJECTION TOOL ON THIS FILE, THEN REPROJECT TO WGS 1984 MANUALLY.")
						arcpy.AddMessage("*****************************************************************************************************************")
				
		# Step through the user-selected folder and reproject shapefiles
		for (dirPath, dirNames, fileNames) in os.walk(arcpy.env.workspace):
			for file in fileNames:
				if file.endswith('-a.shp') or file.endswith('-a.tif'):
					# set output coordinate system (EPSG 4326)
					spatialRef = arcpy.SpatialReference("WGS 1984")
					
					filePath = os.path.join(dirPath, file)
					if file.endswith('-a.shp'): newFilename = file.replace("-a.shp", "-d.shp")
					elif file.endswith('-a.tif'): newFilename = file.replace("-a.tif", "-d.tif")
					fileProject = os.path.join(dirPath, newFilename)
					
					arcpy.AddMessage("**************")
					arcpy.AddMessage("Reprojecting file: " + newFilename)
					
					# run project tool
					if file.endswith('.shp'): arcpy.Project_management(filePath, fileProject, spatialRef)
					elif file.endswith('.tif'): arcpy.ProjectRaster_management(filePath, fileProject, spatialRef)
					
					# run synchronize metadata tool   C:\_Test_Data\GeoTIFFs_2\AMI-SD-76_East_data.tif
					arcpy.SynchronizeMetadata_conversion(fileProject, "SELECTIVE")
				
		del file
		del filePath
		del fileProject

	except Exception as err:
      		arcpy.AddMessage(arcpy.GetMessages(2))
      		print (arcpy.GetMessages(2))
		arcpy.AddMessage(traceback.format_exc())
  		raise arcpy.ExecuteError
        return
		
    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True
    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return
    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return

####################################################################################################################################################################################################
####################################################################################################################################################################################################

class Upgrade_and_Validate_Files(object):
    def __init__(self):
        #Define the tool (tool name is the name of the class).

        self.label = "1. Upgrade and Validate Files"
        self.description = "Upgrades metadata (if necessary) and checks each shapefile and TIFF in a user-selected folder (and subfolders) for undefined projection and missing crucial metadata elements."
        self.canRunInBackground = False

    def getParameterInfo(self):
		#Define parameter definitions	

		# First parameter
		param0 = arcpy.Parameter(
			displayName="Input Workspace",
			name="in_workspace",
			datatype="Workspace",
			parameterType="Required",
			direction="Input")
								
		# Second parameter
		param1 = arcpy.Parameter(
			displayName="Rename each shapefile or TIFF file to match its parent folder name (do not select if more than one file per folder)",
			name="rename_shapefiles",
			datatype="boolean",
			parameterType="Required",
			direction="Input")
		param1.value = 0

		params = [param0, param1]
		return params


    def execute(self, parameters, messages):
        """The source code of the tool."""

 	try:
		# arcpy environments
		arcpy.env.overwriteOutput = "True"

		# Set the input workspace
		arcpy.env.workspace = parameters[0].valueAsText
		arcpy.AddMessage("workspace = " + arcpy.env.workspace)

		# Rename each shapefile or TIFF to match its parent folder name
		if parameters[1].valueAsText == "true":
			arcpy.AddMessage("****************************")
			arcpy.AddMessage("Renaming each shapefile/TIFF to match its parent folder name")
			arcpy.AddMessage("****************************")

			for dirPath, dirNames, fileNames in os.walk(arcpy.env.workspace):
				for file in fileNames:
					if file.lower().endswith(".shp"):
						newFilename = os.path.basename(dirPath) + ".shp"
						if file <> newFilename:
							arcpy.Rename_management(os.path.join(dirPath, file), os.path.join(dirPath, newFilename))
					elif file.lower().endswith(".tif"):
						newFilename = os.path.basename(dirPath) + ".tif"
						if file <> newFilename:
							arcpy.Rename_management(os.path.join(dirPath, file), os.path.join(dirPath, newFilename))
						
		arcpy.AddMessage("****************************")
		arcpy.AddMessage("Checking shapefiles and TIFFs for undefined coordinate systems")

		#for dirPath, dirNames, fileNames in arcpy.da.Walk(arcpy.env.workspace, datatype="FeatureClass"):
		for dirPath, dirNames, fileNames in os.walk(arcpy.env.workspace):
			for file in fileNames:
				if file.lower().endswith(".shp") or file.lower().endswith(".tif"):
					if arcpy.Exists(os.path.join(dirPath, file) + ".xml") == False:
						arcpy.AddMessage("*****************************************************************************************************************")
						arcpy.AddMessage(file + ": METADATA FILE MISSING! OPEN METADATA FOR THIS FILE IN ARCCATALOG TO CREATE FILE, THEN RERUN THIS TOOL.")
						arcpy.AddMessage("*****************************************************************************************************************")

					dsc = arcpy.Describe(os.path.join(dirPath, file))
					coordSys = dsc.spatialReference
					if coordSys.Name == "Unknown":
						arcpy.AddMessage("Coord Sys: " + coordSys.Name)
						arcpy.AddMessage("*****************************************************************************************************************")
						arcpy.AddMessage(file + ": COORDINATE SYSTEM UNDEFINED! RUN DEFINE PROJECTION TOOL ON THIS FILE.")
						arcpy.AddMessage("*****************************************************************************************************************")

				
		# Step through the user-selected folder and check for missing metadata values
		for dirPath, dirNames, fileNames in os.walk(arcpy.env.workspace):
			dirNames.sort()
			for file in fileNames:
				if file.lower().endswith(".shp.xml") or file.lower().endswith(".tif.xml"):
					# read in XML
					tree = ET.parse(os.path.join(dirPath, file))
					root = tree.getroot()

					# upgrade FGDC metadata content to ArcGIS metadata format
					metadataUpgradeNeeded = True
					EsriElt = root.find('Esri')
					if ET.iselement(EsriElt):
						ArcGISFormatElt = EsriElt.find('ArcGISFormat')
						if ET.iselement(ArcGISFormatElt):
							arcpy.AddMessage(file + ": metadata is already in ArcGIS format.")
							metadataUpgradeNeeded = False

					if metadataUpgradeNeeded:
						arcpy.AddMessage(file + ": metadata is being upgraded to ArcGIS format...")
						result = arcpy.UpgradeMetadata_conversion(os.path.join(dirPath, file), "FGDC_TO_ARCGIS")
						#arcpy.AddMessage(result.getMessages())

						# reload xml tree after upgrade
						tree = ET.parse(os.path.join(dirPath, file))
						root = tree.getroot()

					# read in XML
					tree = ET.parse(os.path.join(dirPath, file))
					root = tree.getroot()

					crucialEltsFound = True
					dataIdInfoElt = root.find('dataIdInfo')
					if ET.iselement(dataIdInfoElt):
						idCitationElt = dataIdInfoElt.find('idCitation')
						if not ET.iselement(idCitationElt): crucialEltsFound = False
					else: crucialEltsFound = False
					
					if crucialEltsFound == False:
						arcpy.AddMessage("*********************************************************************************************************************************")
						arcpy.AddMessage(file + ": CRUCIAL METADATA ELEMENTS MISSING! OPEN METADATA FOR THIS FILE IN ARCCATALOG TO UPDATE.")
						arcpy.AddMessage("*********************************************************************************************************************************")
						#continue
				
		del file
		
	except Exception as err:
      		arcpy.AddMessage(arcpy.GetMessages(2))
      		print (arcpy.GetMessages(2))
		arcpy.AddMessage(traceback.format_exc())
  		raise arcpy.ExecuteError
        return
		
    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True
    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return
    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return




####################################################################################################################################################################################################
####################################################################################################################################################################################################
#
# NOTE: THE FOLLOWING CLASSES ARE NO LONGER REFERENCED IN THE ABOVE CODE
####################################################################################################################################################################################################
####################################################################################################################################################################################################

class ISO_Metadata_from_CSV(object):
    def __init__(self):
        #Define the tool (tool name is the name of the class).
		
        self.label = "3. ISO Metadata from CSV"
        self.description = "For each shapefile or TIFF in a user-selected folder(and subfolders), create an ISO 19139 standard metadata file containing metadata values from a user-selected CSV file (generated by the Extract Metadata to CSV tool). \
							NOTE: each row in the CSV file should map to only one uniquely-named shapefile or TIFF in the user-selected folder."
        self.canRunInBackground = False

    def getParameterInfo(self):
		#Define parameter definitions	

		# First parameter
		param0 = arcpy.Parameter(
			displayName="Input Workspace",
			name="in_workspace",
			datatype="Workspace",
			parameterType="Required",
			direction="Input")

		# Second parameter
		param1 = arcpy.Parameter(
			displayName="Metadata CSV File",
			name="metadata_file",
			datatype="DEFile",
			parameterType="Required",
			direction="Input")

		# Third parameter
		param2 = arcpy.Parameter(
			displayName="Add UCSB Library as custodian under Citation Contacts",
			name="custodian_citation",
			datatype="boolean",
			parameterType="Required",
			direction="Input")
		param2.value = 1
			
		# Fourth parameter
		param3 = arcpy.Parameter(
			displayName="Add UCSB Library as processor under Metadata Contacts",
			name="processor_metadata",
			datatype="boolean",
			parameterType="Required",
			direction="Input")
		param3.value = 1

		# Fifth parameter
		param4 = arcpy.Parameter(
			displayName="Add UCSB as custodian under Distribution Contacts",
			name="distribution_contact",
			datatype="boolean",
			parameterType="Required",
			direction="Input")
		param4.value = 1

		params = [param0, param1, param2, param3, param4]
		return params


    def execute(self, parameters, messages):
        """The source code of the tool."""

	##################################################################################################
	# Dictionary of constraint categories
	constraint = {'000': 'Empty','001': 'Copyright','002': 'Patent','003': 'Patent Pending','004': 'Trademark','005': 'License','006': 'Intellectual Property Rights', '007': 'Restricted','008' : 'Other Restrictions'}

	# Dictionary of ISO Topic Categories
	isoTopics = {'farming': '001','biota': '002','boundaries': '003','climatologyMeteorologyAtmosphere' : '004','economy' : '005','elevation' : '006','environment': '007','geoscientificInformation' : '008','health' : '009', \
	'imageryBaseMapsEarthCover': '010','intelligenceMilitary': '011','inlandWaters': '012','location': '013','oceans': '014','planningCadastre': '015','society': '016','structure': '017','transportation': '018','utilitiesCommunication': '019'}
	
	# String constants 
	orgName = "University of California, Santa Barbara. Library"
	delPointText1 = "UCSB Library"
	delPointText2 = "University of California"
	cityText = "Santa Barbara"
	adminAreaText = "CA"
	postCodeText = "93106-9010"
	countryText = "US"
	##################################################################################################

 	try:
		# Set the input workspace
		arcpy.env.workspace = parameters[0].valueAsText

		# arcpy environments
		arcpy.env.overwriteOutput = "True"

		# install location
		installDir = arcpy.GetInstallInfo("desktop")["InstallDir"] 

		# stylesheet to use in conversion of metadata to a temp XML file
		copy_xslt = os.path.join(installDir,"Metadata\\Stylesheets\\gpTools\\exact copy of.xslt")

		# Create dictionary from user-selected CSV file
		metadataDict = {}
		csvFile = open(parameters[1].valueAsText, 'r')
		csvReader = csv.DictReader(csvFile)

		"""
		CSV file header:
		['isoFile', 'zipFilename', 'filename', 'format1', 'format', 'callNumber', 'access', 'provenance', 'title1', 'title', 'alternativeTitle ', 'date1', 'date', 'originatorName', 'originatorOrg', 'originator', 'description1', 'description', 
		'language', 'publisherName', 'publisherOrg', 'publisher', 'subject1', 'subject', 'keyword', 'collectionTitle1', 'collectionTitle', 'spatialSubject1', 'spatialSubject', 'useLimitation1', 'useLimitation2', 'accessConst', 
		'useConst', 'otherConst', 'rights', 'license', 'rightsHolder', 'type', 'isPartOf', 'source', 'replaces', 'isReplacedBy', 'isVersionOf', 'relation', 'dateIssued', 'temporalCoverage', 'schemaVersion', 'suppressed']
		"""
		for row in csvReader:
			metadataDict[row['isoFile']] = row['format'], row['title'], row['date'], row['originator'], row['descriptionAppend'], row['description'], row['publisher'], row['subject'], row['collectionTitle'], row['spatialSubject']
		
		
		#Step through the user-selected directory and create a copy of the XML file for each shapefile or GeoTIFF.
		for (dirPath, dirNames, fileNames) in os.walk(arcpy.env.workspace):
			for fileName in fileNames:
				if fileName.endswith('.shp') or fileName.endswith('.tif'):
					# run synchronize metadata tool
					result = arcpy.SynchronizeMetadata_conversion(os.path.join(dirPath, fileName), "SELECTIVE")
					arcpy.AddMessage(result.getMessages())

					baseName = os.path.basename(fileName)
					if baseName.endswith('.shp'):
						fileExt = ".shp"
					elif baseName.endswith('.tif'):
						fileExt = ".tif"
					newFile = os.path.join(dirPath, baseName.replace(fileExt, "")) + '-ISO.xml'

					# save metadata to new XML file, using XSLT stylesheet 
					result = arcpy.XSLTransform_conversion(os.path.join(dirPath, fileName), copy_xslt, newFile, "")
					
		#Step through the user-selected directory and add metadata from the CSV file to each new XML file.
		for (dirPath, dirNames, fileNames) in os.walk(arcpy.env.workspace):
			for fileName in fileNames:
				if fileName.endswith("-ISO.xml"):
					for k, v in metadataDict.items():
						if k == fileName:
							formatText = v[0].decode("UTF-8")
							titleText = v[1].decode("UTF-8")
							pubDate = v[2]
							originatorText = v[3].decode("UTF-8")
							descriptionText = v[5].decode("UTF-8") + "\n\n" + v[4].decode("UTF-8")
							publisherText = v[6].decode("UTF-8")
							subjectText = v[7].decode("UTF-8")
							collectionTitleText = v[8].decode("UTF-8")
							spatialSubjectText = v[9].decode("UTF-8")
							
							filePath = os.path.join(dirPath, fileName)
							tree = ET.parse(filePath)
							root = tree.getroot()
							
							crucialEltsFound = True
							dataIdInfoElt = root.find('dataIdInfo')
							if ET.iselement(dataIdInfoElt):
								idCitationElt = dataIdInfoElt.find('idCitation')
								if not ET.iselement(idCitationElt): crucialEltsFound = False
							else: crucialEltsFound = False
							
							if crucialEltsFound == False:
								arcpy.AddMessage("**************************************************************************************************************************")
								arcpy.AddMessage(fileName + ": CRUCIAL METADATA ELEMENTS MISSING! OPEN METADATA FOR THIS FILE IN ARCCATALOG TO UPDATE, THEN RERUN THIS TOOL.")
								arcpy.AddMessage("**************************************************************************************************************************")
								continue

							# save format to XML
							if formatText:
								distInfoElt = root.find('distInfo')
								if ET.iselement(distInfoElt):
									distFormatElt = distInfoElt.find('distFormat')
									if ET.iselement(distFormatElt):
										formatNameElt = distFormatElt.find('formatName')
										if ET.iselement(formatNameElt):
											formatNameElt.text = formatText

							# save title to XML
							if titleText:
								resTitleElt = idCitationElt.find('resTitle')
								if not ET.iselement(resTitleElt): resTitleElt = ET.SubElement(idCitationElt,"resTitle")
								resTitleElt.text = titleText
								
							# save publication date to XML
							if pubDate:
								dateElt = idCitationElt.find('date')
								if not ET.iselement(dateElt): dateElt = ET.SubElement(idCitationElt,"date")
								pubDateElt = dateElt.find('pubDate')
								if not ET.iselement(pubDateElt): pubDateElt = ET.SubElement(dateElt,"pubDate")
								pubDateElt.text = pubDate

							# save originator and publisher to XML - first remove all existing citation contacts
							for citRespParty in idCitationElt.findall('citRespParty'):
							   idCitationElt.remove(citRespParty)
							
							if originatorText:
								citRespPartyElt = ET.SubElement(idCitationElt,"citRespParty", attrib={"xmlns": ""})
								rpOrgNameElt = ET.SubElement(citRespPartyElt,"rpOrgName")
								rpOrgNameElt.text = originatorText
								roleElt = ET.SubElement(citRespPartyElt,"role")
								roleCdElt = ET.SubElement(roleElt, "RoleCd", attrib={"value": "006"})
							
							if publisherText:
								citRespPartyElt = ET.SubElement(idCitationElt,"citRespParty", attrib={"xmlns": ""})
								rpOrgNameElt = ET.SubElement(citRespPartyElt,"rpOrgName")
								rpOrgNameElt.text = publisherText
								roleElt = ET.SubElement(citRespPartyElt,"role")
								roleCdElt = ET.SubElement(roleElt, "RoleCd", attrib={"value": "010"})

							# save description to XML
							if descriptionText:
								idAbsElt = dataIdInfoElt.find('idAbs')
								if not ET.iselement(idAbsElt): idAbsElt = ET.SubElement(dataIdInfoElt,"idAbs")
								idAbsElt.text = descriptionText

							# save theme keywords and lcsh as thesaurus citation to XML - first remove all existing theme keywords
							for themeKey in dataIdInfoElt.findall('themeKeys'):
							   dataIdInfoElt.remove(themeKey)
							
							if subjectText:
								themeKeysElt = ET.SubElement(dataIdInfoElt,"themeKeys",attrib={"xmlns": ""})
								thesaNameElt = ET.SubElement(themeKeysElt,"thesaName", attrib={"xmlns": ""})
								resTitleElt = ET.SubElement(thesaNameElt,"resTitle")
								resTitleElt.text = "lcsh"

								subjectTextSplit = subjectText.split('|')
								for index, theme in enumerate(subjectTextSplit):
									keywordElt = ET.SubElement(themeKeysElt,"keyword")
									keywordElt.text = theme

							# save collection title to XML
							if collectionTitleText:
								collTitleElt = idCitationElt.find('collTitle')
								if not ET.iselement(collTitleElt): collTitleElt = ET.SubElement(idCitationElt,"collTitle")
								collTitleElt.text = collectionTitleText

							# save place keywords and geonames as thesaurus citation to XML - first remove all existing place keywords
							for placeKey in dataIdInfoElt.findall('placeKeys'):
							   dataIdInfoElt.remove(placeKey)
							
							if spatialSubjectText:
								placeKeysElt = ET.SubElement(dataIdInfoElt,"placeKeys",attrib={"xmlns": ""})
								thesaNameElt = ET.SubElement(placeKeysElt,"thesaName", attrib={"xmlns": ""})
								resTitleElt = ET.SubElement(thesaNameElt,"resTitle")
								resTitleElt.text = "geonames"
								
								spatialSubjectTextSplit = spatialSubjectText.split('|')
								for index, place in enumerate(spatialSubjectTextSplit):
									keywordElt = ET.SubElement(placeKeysElt,"keyword")
									keywordElt.text = place

							# add UCSB as custodian under Citation Contacts
							if parameters[2].valueAsText == "true":		
								citRespPartyElt = ET.SubElement(idCitationElt,"citRespParty", attrib={"xmlns": ""})
								rpOrgNameElt = ET.SubElement(citRespPartyElt,"rpOrgName")
								rpOrgNameElt.text = orgName
								
								#roleAttributes = {"value": "002"}
								roleElt = ET.SubElement(citRespPartyElt, "role")
								RoleCdElt = ET.SubElement(roleElt, "RoleCd", attrib={"value": "002"})
								
								rpCntInfoElt = ET.SubElement(citRespPartyElt, "rpCntInfo", attrib={"xmlns": ""})
								cntAddressElt = ET.SubElement(rpCntInfoElt, "cntAddress", attrib={"addressType": "both"})
								delPoint = ET.SubElement(cntAddressElt, "delPoint")
								delPoint.text = delPointText1
								city = ET.SubElement(cntAddressElt, "city")
								city.text = cityText
								adminArea = ET.SubElement(cntAddressElt, "adminArea")
								adminArea.text = adminAreaText
								postCode = ET.SubElement(cntAddressElt, "postCode")
								postCode.text = postCodeText
								country = ET.SubElement(cntAddressElt, "country")
								country.text = countryText
								delPoint = ET.SubElement(cntAddressElt, "delPoint")
								delPoint.text = delPointText2

							# Add UCSB as processor under Metadata Contacts
							if parameters[3].valueAsText == "true":		
								mdContactElt = ET.SubElement(root,"mdContact", attrib={"xmlns": ""})
								rpOrgNameElt = ET.SubElement(mdContactElt,"rpOrgName")
								rpOrgNameElt.text = orgName
								
								#roleAttributes = {"value": "009"}
								roleElt = ET.SubElement(mdContactElt, "role")
								RoleCdElt = ET.SubElement(roleElt, "RoleCd", attrib={"value": "009"})
								
								rpCntInfoElt = ET.SubElement(mdContactElt, "rpCntInfo", attrib={"xmlns": ""})
								cntAddressElt = ET.SubElement(rpCntInfoElt, "cntAddress", attrib={"addressType": "both"})
								delPoint = ET.SubElement(cntAddressElt, "delPoint")
								delPoint.text = delPointText1
								city = ET.SubElement(cntAddressElt, "city")
								city.text = cityText
								adminArea = ET.SubElement(cntAddressElt, "adminArea")
								adminArea.text = adminAreaText
								postCode = ET.SubElement(cntAddressElt, "postCode")
								postCode.text = postCodeText
								country = ET.SubElement(cntAddressElt, "country")
								country.text = countryText
								delPoint = ET.SubElement(cntAddressElt, "delPoint")
								delPoint.text = delPointText2

								displayNameElt = ET.SubElement(mdContactElt, "displayName")
								displayNameElt.text = orgName

							# Add UCSB as custodian under Distribution Information
							if parameters[4].valueAsText == "true":		
								distInfoElt = root.find('distInfo')
								if ET.iselement(distInfoElt):
									distributorElt = ET.SubElement(distInfoElt,"distributor", attrib={"xmlns": ""})
									distorContElt = ET.SubElement(distributorElt,"distorCont", attrib={"xmlns": ""})
									rpOrgNameElt = ET.SubElement(distorContElt,"rpOrgName")
									rpOrgNameElt.text = orgName
											
									#roleAttributes = {"value": "002"}
									roleElt = ET.SubElement(distorContElt, "role")
									RoleCdElt = ET.SubElement(roleElt, "RoleCd", attrib={"value": "002"})
											
									rpCntInfoElt = ET.SubElement(distorContElt, "rpCntInfo", attrib={"xmlns": ""})
									cntAddressElt = ET.SubElement(rpCntInfoElt, "cntAddress", attrib={"addressType": "both"})
									delPoint = ET.SubElement(cntAddressElt, "delPoint")
									delPoint.text = delPointText1
									city = ET.SubElement(cntAddressElt, "city")
									city.text = cityText
									adminArea = ET.SubElement(cntAddressElt, "adminArea")
									adminArea.text = adminAreaText
									postCode = ET.SubElement(cntAddressElt, "postCode")
									postCode.text = postCodeText
									country = ET.SubElement(cntAddressElt, "country")
									country.text = countryText
									delPoint = ET.SubElement(cntAddressElt, "delPoint")
									delPoint.text = delPointText2

									displayNameElt = ET.SubElement(distorContElt, "displayName")
									displayNameElt.text = orgName

							tree.write(filePath)

							arcpy.AddMessage("**************")
							arcpy.AddMessage("Creating ISO standard XML file: " + fileName)
							translator = os.path.join(installDir,"Metadata\\Translator\\ArcGIS2ISO19139.xml")
							result = arcpy.ExportMetadata_conversion (filePath, translator, filePath)					
							#arcpy.AddMessage(result.getMessages())
		
		del copy_xslt
		csvFile.close
		del csvFile
		del csvReader
		del tree
		del root

	except Exception as err:
      		arcpy.AddMessage(arcpy.GetMessages(2))
      		print (arcpy.GetMessages(2))
		arcpy.AddMessage(traceback.format_exc())
  		raise arcpy.ExecuteError
        return
		
    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True
    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return
    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return


####################################################################################################################################################################################################
####################################################################################################################################################################################################

class Delete_Old_Files(object):
    def __init__(self):
        #Define the tool (tool name is the name of the class).

        self.label = "5. Delete _OLD Files"
        self.description = "Deletes each shapefile or TIFF with the suffix '_OLD' in a user-selected folder (and subfolders)."
        self.canRunInBackground = False

    def getParameterInfo(self):
		#Define parameter definitions	

		# First parameter
		param0 = arcpy.Parameter(
			displayName="Input Workspace",
			name="in_workspace",
			datatype="Workspace",
			parameterType="Required",
			direction="Input")
								
		params = [param0]
		return params


    def execute(self, parameters, messages):
        """The source code of the tool."""

 	try:
		# arcpy environments
		arcpy.env.overwriteOutput = "True"

		# Set the input workspace
		arcpy.env.workspace = parameters[0].valueAsText
		arcpy.AddMessage("workspace = " + arcpy.env.workspace)

		# Step through the user-selected folder
		#for dirPath, dirNames, fileNames in arcpy.da.Walk(arcpy.env.workspace, datatype="FeatureClass"):
		for (dirPath, dirNames, fileNames) in os.walk(arcpy.env.workspace):
			#for fc in fileNames:
			#	if fc.endswith("_OLD.shp"):
			for file in fileNames:
				if file.endswith('_OLD.shp') or file.endswith('_OLD.tif'):
					arcpy.AddMessage("**************")
					arcpy.AddMessage("Deleting: " + file)
					arcpy.Delete_management(os.path.join(dirPath, file))
				
		del file

	except Exception as err:
      		arcpy.AddMessage(arcpy.GetMessages(2))
      		print (arcpy.GetMessages(2))
		arcpy.AddMessage(traceback.format_exc())
  		raise arcpy.ExecuteError
        return
		
    def isLicensed(self):
        """Set whether tool is licensed to execute."""
        return True
    def updateParameters(self, parameters):
        """Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed."""
        return
    def updateMessages(self, parameters):
        """Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation."""
        return


####################################################################################################################################################################################################
####################################################################################################################################################################################################

