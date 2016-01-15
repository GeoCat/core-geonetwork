# language: nl
Functionaliteit: Upload dataset met een thumbnail via de API
  Als As a user I want to upload metadata, thumbnail and dataset in one call.

  Scenario: Upload dataset, icon and metadata with valid metadata.
    Given a file stream containing the bytes from "NW_PDOK_2015_04_13.zip", an icon stream containing the "rdinfo-stations.png" and the following metadata.
    """
<?xml version="1.0" encoding="UTF-8"?>
<gmd:MD_Metadata xmlns:gml="http://www.opengis.net/gml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd">
	<gmd:fileIdentifier>
		<gco:CharacterString>60bb2696-2090-4649-9695-19f4e9a0a52e</gco:CharacterString>
	</gmd:fileIdentifier>
	<gmd:language>
		<gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="dut">Nederlands</gmd:LanguageCode>
	</gmd:language>
	<gmd:characterSet>
		<gmd:MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8"/>
	</gmd:characterSet>
	<gmd:hierarchyLevel>
		<gmd:MD_ScopeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset"/>
	</gmd:hierarchyLevel>
	<gmd:contact>
		<gmd:CI_ResponsibleParty>
			<gmd:organisationName>
				<gco:CharacterString>Beheer PDOK</gco:CharacterString>
			</gmd:organisationName>
			<gmd:contactInfo>
				<gmd:CI_Contact>
					<gmd:address>
						<gmd:CI_Address>
							<gmd:electronicMailAddress>
								<gco:CharacterString>beheerPDOK@kadaster.nl</gco:CharacterString>
							</gmd:electronicMailAddress>
						</gmd:CI_Address>
					</gmd:address>
				</gmd:CI_Contact>
			</gmd:contactInfo>
			<gmd:role>
				<gmd:CI_RoleCode codeListValue="pointOfContact" codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"/>
			</gmd:role>
		</gmd:CI_ResponsibleParty>
	</gmd:contact>
	<gmd:dateStamp>
		<gco:Date>2015-07-17</gco:Date>
	</gmd:dateStamp>
	<gmd:metadataStandardName>
		<gco:CharacterString>ISO 19115</gco:CharacterString>
	</gmd:metadataStandardName>
	<gmd:metadataStandardVersion>
		<gco:CharacterString>Nederlands metadata profiel op ISO 19115 voor geografie 1.3</gco:CharacterString>
	</gmd:metadataStandardVersion>
	<gmd:referenceSystemInfo>
		<gmd:MD_ReferenceSystem>
			<gmd:referenceSystemIdentifier>
				<gmd:RS_Identifier>
					<gmd:code>
						<gco:CharacterString>28992</gco:CharacterString>
					</gmd:code>
					<gmd:codeSpace>
						<gco:CharacterString>EPSG</gco:CharacterString>
					</gmd:codeSpace>
				</gmd:RS_Identifier>
			</gmd:referenceSystemIdentifier>
		</gmd:MD_ReferenceSystem>
	</gmd:referenceSystemInfo>
	<gmd:identificationInfo>
		<gmd:MD_DataIdentification>
			<gmd:citation>
				<gmd:CI_Citation>
					<gmd:title>
						<gco:CharacterString>RD-punten WMS</gco:CharacterString>
					</gmd:title>
					<gmd:date>
						<gmd:CI_Date>
							<gmd:date>
								<gco:Date>2012-12-06</gco:Date>
							</gmd:date>
							<gmd:dateType>
								<gmd:CI_DateTypeCode codeListValue="publication" codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"/>
							</gmd:dateType>
						</gmd:CI_Date>
					</gmd:date>
					<gmd:date>
						<gmd:CI_Date>
							<gmd:date>
								<gco:Date>2000-12-13</gco:Date>
							</gmd:date>
							<gmd:dateType>
								<gmd:CI_DateTypeCode codeListValue="creation" codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"/>
							</gmd:dateType>
						</gmd:CI_Date>
					</gmd:date>
					<gmd:identifier>
						<gmd:MD_Identifier>
							<gmd:code>
								<!-- Unieke identifier van de dataset, deze kan men zelf maken en beheren. Dit is niet hetzelfde als de metadata identifier van dit document -->
								<gco:CharacterString>http://geodatastore.pdok.nl/id/dataset/60bb2696-2090-4649-9695-19f4e9a0a52e</gco:CharacterString>
							</gmd:code>
						</gmd:MD_Identifier>
					</gmd:identifier>
				</gmd:CI_Citation>
			</gmd:citation>
			<gmd:abstract>
				<gco:CharacterString>Overzicht van de ligging van de RD-punten, GNSS-referentiestations en GNSS-kernnetpunten in Nederland met de bijbehorende omschrijvingen en coordinaten in het stelsel van de Rijksdriehoeksmeting (RD) en het Europese stelsel ETRS-89.

Op http://www.kadaster.nl/web/artikel/download/Beschrijving-velden-RDinfo-PDOK-1.htm is uitleg beschikbaar over de inhoud van de velden van deze dataset.</gco:CharacterString>
			</gmd:abstract>
			<gmd:status>
				<gmd:MD_ProgressCode codeListValue="completed" codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ProgressCode"/>
			</gmd:status>
			<gmd:pointOfContact>
				<gmd:CI_ResponsibleParty>
					<gmd:organisationName>
						<gco:CharacterString>Beheer PDOK</gco:CharacterString>
					</gmd:organisationName>
					<gmd:contactInfo>
						<gmd:CI_Contact>
							<gmd:address>
								<gmd:CI_Address>
									<gmd:electronicMailAddress>
										<gco:CharacterString>beheerPDOK@kadaster.nl</gco:CharacterString>
									</gmd:electronicMailAddress>
								</gmd:CI_Address>
							</gmd:address>
						</gmd:CI_Contact>
					</gmd:contactInfo>
					<gmd:role>
						<gmd:CI_RoleCode codeListValue="pointOfContact" codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"/>
					</gmd:role>
				</gmd:CI_ResponsibleParty>
			</gmd:pointOfContact>
			<gmd:graphicOverview>
				<gmd:MD_BrowseGraphic>
					<gmd:fileName>
						<gco:CharacterString>http://geodatastore.pdok.nl/id/thumbnail/60bb2696-2090-4649-9695-19f4e9a0a52e</gco:CharacterString>
					</gmd:fileName>
				</gmd:MD_BrowseGraphic>
			</gmd:graphicOverview>
			<gmd:descriptiveKeywords>
				<gmd:MD_Keywords>
					<gmd:keyword>
						<gco:CharacterString>RD-punten</gco:CharacterString>
					</gmd:keyword>
				</gmd:MD_Keywords>
			</gmd:descriptiveKeywords>
			<gmd:resourceConstraints>
				<gmd:MD_Constraints>
					<gmd:useLimitation>
						<gco:CharacterString>Geen beperkingen</gco:CharacterString>
					</gmd:useLimitation>
				</gmd:MD_Constraints>
			</gmd:resourceConstraints>
			<gmd:resourceConstraints>
				<gmd:MD_LegalConstraints>
					<gmd:useLimitation>
						<gco:CharacterString>Geen beperkingen</gco:CharacterString>
					</gmd:useLimitation>
					<gmd:accessConstraints>
						<gmd:MD_RestrictionCode codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_RestrictionCode" codeListValue="otherRestrictions"/>
					</gmd:accessConstraints>
					<gmd:otherConstraints>
						<gco:CharacterString> Geen beperkingen </gco:CharacterString>
					</gmd:otherConstraints>
					<gmd:otherConstraints>
						<gco:CharacterString>http://creativecommons.org/publicdomain/mark/1.0/deed.nl</gco:CharacterString>
					</gmd:otherConstraints>
				</gmd:MD_LegalConstraints>
			</gmd:resourceConstraints>
			<gmd:spatialResolution>
				<gmd:MD_Resolution>
					<gmd:equivalentScale>
						<gmd:MD_RepresentativeFraction>
							<gmd:denominator>
								<gco:Integer>1</gco:Integer>
							</gmd:denominator>
						</gmd:MD_RepresentativeFraction>
					</gmd:equivalentScale>
				</gmd:MD_Resolution>
			</gmd:spatialResolution>
			<gmd:language>
				<gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="eng"/>
			</gmd:language>
			<gmd:characterSet>
				<gmd:MD_CharacterSetCode codeListValue="utf8" codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode"/>
			</gmd:characterSet>
			<gmd:topicCategory>
				<gmd:MD_TopicCategoryCode>planningCadastre</gmd:MD_TopicCategoryCode>
			</gmd:topicCategory>
			<gmd:extent>
				<gmd:EX_Extent>
					<gmd:geographicElement>
						<gmd:EX_GeographicDescription>
							<gmd:extentTypeCode>
								<gco:Boolean>true</gco:Boolean>
							</gmd:extentTypeCode>
							<gmd:geographicIdentifier>
								<gmd:RS_Identifier uuid="http://gazetteer_pdok_nl#Nederland_country">
									<gmd:code>
										<gco:CharacterString>Nederland</gco:CharacterString>
									</gmd:code>
									<gmd:codeSpace>
										<gco:CharacterString>PDOK Gazeteer</gco:CharacterString>
									</gmd:codeSpace>
								</gmd:RS_Identifier>
							</gmd:geographicIdentifier>
						</gmd:EX_GeographicDescription>
					</gmd:geographicElement>
					<gmd:geographicElement>
						<gmd:EX_GeographicBoundingBox>
							<gmd:westBoundLongitude>
								<gco:Decimal>3.30794</gco:Decimal>
							</gmd:westBoundLongitude>
							<gmd:eastBoundLongitude>
								<gco:Decimal>7.2275</gco:Decimal>
							</gmd:eastBoundLongitude>
							<gmd:southBoundLatitude>
								<gco:Decimal>50.75037</gco:Decimal>
							</gmd:southBoundLatitude>
							<gmd:northBoundLatitude>
								<gco:Decimal>53.57642</gco:Decimal>
							</gmd:northBoundLatitude>
						</gmd:EX_GeographicBoundingBox>
					</gmd:geographicElement>
				</gmd:EX_Extent>
			</gmd:extent>
		</gmd:MD_DataIdentification>
	</gmd:identificationInfo>
	<gmd:distributionInfo>
		<gmd:MD_Distribution>
			<gmd:distributionFormat>
				<gmd:MD_Format>
					<gmd:name>
						<gco:CharacterString>Coordinate Reference Systems GML application schema</gco:CharacterString>
					</gmd:name>
					<gmd:version>
						<gco:CharacterString/>
					</gmd:version>
				</gmd:MD_Format>
			</gmd:distributionFormat>
			<gmd:distributor>
				<gmd:MD_Distributor>
					<gmd:distributorContact>
						<gmd:CI_ResponsibleParty>
							<gmd:organisationName>
								<gco:CharacterString>Kadaster en Openbare Registers</gco:CharacterString>
							</gmd:organisationName>
							<gmd:contactInfo>
								<gmd:CI_Contact>
									<gmd:address>
										<gmd:CI_Address>
											<gmd:electronicMailAddress>
												<gco:CharacterString>kcc@kadaster.nl</gco:CharacterString>
											</gmd:electronicMailAddress>
										</gmd:CI_Address>
									</gmd:address>
								</gmd:CI_Contact>
							</gmd:contactInfo>
							<gmd:role>
								<gmd:CI_RoleCode codeListValue="pointOfContact" codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"/>
							</gmd:role>
						</gmd:CI_ResponsibleParty>
					</gmd:distributorContact>
				</gmd:MD_Distributor>
			</gmd:distributor>
			<gmd:transferOptions>
				<gmd:MD_DigitalTransferOptions>
					<gmd:onLine>
						<gmd:CI_OnlineResource>
							<gmd:linkage>
								<gmd:URL>http://geodatastore.pdok.nl/id/dataset/60bb2696-2090-4649-9695-19f4e9a0a52e</gmd:URL>
							</gmd:linkage>
							<gmd:protocol>
								<gco:CharacterString>download</gco:CharacterString>
							</gmd:protocol>
							<gmd:name>
								<gco:CharacterString>NW_PDOK_2015-04_13.zip</gco:CharacterString>
							</gmd:name>
						</gmd:CI_OnlineResource>
					</gmd:onLine>
				</gmd:MD_DigitalTransferOptions>
			</gmd:transferOptions>
		</gmd:MD_Distribution>
	</gmd:distributionInfo>
	<gmd:dataQualityInfo>
		<gmd:DQ_DataQuality>
			<gmd:scope>
				<gmd:DQ_Scope>
					<gmd:level>
						<gmd:MD_ScopeCode codeListValue="dataset" codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode"/>
					</gmd:level>
				</gmd:DQ_Scope>
			</gmd:scope>
			<gmd:lineage>
				<gmd:LI_Lineage>
					<gmd:statement>
						<gco:CharacterString>Afkomstig uit de Basisregistratie Kadaster</gco:CharacterString>
					</gmd:statement>
				</gmd:LI_Lineage>
			</gmd:lineage>
		</gmd:DQ_DataQuality>
	</gmd:dataQualityInfo>
</gmd:MD_Metadata>
    """
	And there is a usersession.
    And the metadata is validated against the "http://validatie-dataspecificaties.geostandaarden.nl/genericvalidator/standaard/ISO_19115_v13_2014" validation.
    When the data is uploaded through the API.
    Then the dataset is published.