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
		row = ["isoFile", "zipFilename", "filename", "format1", "format", "callNumber", "access", "provenance", "title1", "title", "alternativeTitle", "date1", "date",
		"originatorName", "originatorOrg", "originator", "descriptionAppend", "description", "language", "publisherName", "publisherOrg", "publisher", "subject1", "subject", "keyword",
		"collectionTitle1", "collectionTitle", "spatialSubject1", "spatialSubject", "useLimitation1", "useLimitation2", "accessConst", "useConst", "otherConst", "rights", "license",
		"rightsHolder", "type", "isPartOf", "source", "replaces", "isReplacedBy", "isVersionOf", "relation", "dateIssued", "temporalCoverage", "schemaVersion", "suppressed"]
		
		# write header to csv file
		csvWriter.writerow([v.encode("UTF-8") for v in row])


		# Step through the user-selected folder and extract metadata values
		for dirPath, dirNames, fileNames in os.walk(arcpy.env.workspace):
			dirNames.sort()
			for file in fileNames:
				if file.lower().endswith(".shp.xml") or file.lower().endswith(".tif.xml"):
					formatText = titleText = dateText = originatorNameText = originatorOrgText = descriptionText1 = descriptionText2 = languageText = publisherNameText = publisherOrgText = ""
					subjectText = collectionTitleText = spatialSubjectText = useLimitationText1 = useLimitationText2 = accessConstText = useConstText = otherConstText = ""
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
						descriptionText1 = remove_HTML_Tags(idAbsElt.text)

						if descriptionText1:
							descriptionText1 = "The following metadata was provided by the data creators:  " + descriptionText1
						else: arcpy.AddMessage(file + ": note - no description found")

					descriptionText2 = 'This [geom] shapefile represents [topic] in [place] for [date]. This file was obtained [date] by UCSD Library staff. It was originally available via [source].'

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
									spatialSubjectText = spatialSubjectText + "|" + child2.text.rstrip()

					spatialSubjectText = spatialSubjectText[1:len(spatialSubjectText)]
					if not spatialSubjectText: arcpy.AddMessage(file + ": note - no spatial subject keywords found")

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
					isoFileText = baseFileName + '-ISO.xml'
					zipFilenameText = baseFileName + '.zip'
					callNumberText = baseFileName.replace("_", " ").replace("-", ".")						
					filenameText = os.path.join(dirPath, file.replace(".xml", ""))


					# Write extracted data to CSV file
					row = [isoFileText, zipFilenameText, filenameText, formatText, "", callNumberText, 'Public', 'UC San Diego', titleText, "", "", dateText, "",
					originatorNameText, originatorOrgText, "", descriptionText1, descriptionText2, languageText, publisherNameText, publisherOrgText, "", subjectText, "", "",
					collectionTitleText, "", spatialSubjectText, "",useLimitationText1, useLimitationText2, accessConstText, useConstText, otherConstText]

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
