<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
	<sch:ns uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
	<sch:ns uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
    <sch:ns uri="http://www.isotc211.org/2005/srv" prefix="srv"/>
    <sch:ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
    <sch:ns uri="http://www.opengis.net/gml" prefix="gml"/>
	<sch:ns uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
	
	<sch:let name="lowercase" value="'abcdefghijklmnopqrstuvwxyz'"/>
	<sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<sch:pattern id="DutchMetadataCoreSetForServices">
		<sch:title>Validatie tegen het Nederlands metadata profiel op ISO 19119 voor services v 1.2.1</sch:title>
		<!-- INSPIRE Thesaurus en Conformiteit-->
		<sch:let name="thesaurus1" value="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[1]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>	
		<sch:let name="thesaurus2" value="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[2]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>	
		<sch:let name="thesaurus3" value="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[3]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>		
		<sch:let name="thesaurus4" value="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[4]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>	
		<sch:let name="thesaurus" value="concat(string($thesaurus1),string($thesaurus2),string($thesaurus3),string($thesaurus4))"/>
		<sch:let name="thesaurus_INSPIRE_Exsists" value="contains($thesaurus,'GEMET - INSPIRE themes, version 1.0')"/>
		<sch:let name="conformity_Spec_Title1" value="normalize-space(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report[1]/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>	
		<sch:let name="conformity_Spec_Title2" value="normalize-space(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report[2]/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
		<sch:let name="conformity_Spec_Title3" value="normalize-space(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report[3]/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
		<sch:let name="conformity_Spec_Title4" value="normalize-space(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report[4]/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
		<sch:let name="conformity_Spec_Title_All" value="concat(string($conformity_Spec_Title1),string($conformity_Spec_Title2),string($conformity_Spec_Title3),string($conformity_Spec_Title4))"/>
		<sch:let name="conformity_Spec_Title_Exsists" value="contains($conformity_Spec_Title_All,'VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens')"/>
		
		
		<sch:rule context="/gmd:MD_Metadata">
		
		<!-- schemalocatie controleren, overeenkomstig inspire en nl profiel -->
	
		<!-- apiso bevat al het juiste gmd schema, niet apart meer nodig
			<sch:assert test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd')">Het ISO 19139 XML document mist een verplichte schema locatie. De schema locatie http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd moet aanwezig zijn.
			</sch:assert>
			<sch:report test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd')">Het ISO 19139 XML document bevat de schema locatie http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd
			</sch:report>
		-->
			<sch:assert test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd')">Het ISO 19139 XML document mist een verplichte schema locatie. De schema locatie http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd moet aanwezig zijn.
		    	</sch:assert>
			<sch:report test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd')">Het ISO 19139 XML document bevat de schema locatie http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd
			</sch:report>
		<!--  fileIdentifier -->
			<sch:let name="fileIdentifier" value="normalize-space(gmd:fileIdentifier/gco:CharacterString)"/>
       		 <!-- Metadata taal -->
 			<sch:let name="mdLanguage" value="(gmd:language/*/@codeListValue = 'dut' or gmd:language/*/@codeListValue = 'eng')"/>
            <sch:let name="mdLanguage_value" value="string(gmd:language/*/@codeListValue)"/>
		<!-- Metadata hiërarchieniveau -->
			<sch:let name="hierarchyLevel" value="gmd:hierarchyLevel[1]/*/@codeListValue = 'service'"/>
			<sch:let name="hierarchyLevel_value" value="string(gmd:hierarchyLevel[1]/*/@codeListValue)"/>
        <!-- Metadata verantwoordelijke organisatie (name) -->
			<sch:let name="mdResponsibleParty_Organisation" value="normalize-space(gmd:contact[1]/*/gmd:organisationName/gco:CharacterString)"/>
		<!-- Metadata verantwoordelijke organisatie (role) INSPIRE in combi met INSPIRE specificatie-->
			<sch:let name="mdResponsibleParty_Role_INSPIRE" value="gmd:contact[1]/*/gmd:role/*/@codeListValue = 'pointOfContact' "/>
			 
		<!-- Metadata verantwoordelijke organisatie (role) NL profiel -->
			<sch:let name="mdResponsibleParty_Role" value="gmd:contact[1]/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'resourceProvider' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'custodian' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'owner' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'user' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'distributor' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'owner' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'originator' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'pointOfContact' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'principalInvestigator' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'processor' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'publisher' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'author'"/>
			
		<!-- Metadata verantwoordelijke organisatie (url) -->
			<sch:let name="mdResponsibleParty_Mail" value="normalize-space(gmd:contact[1]/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress[1]/gco:CharacterString)"/>
         <!-- Metadata datum -->
			<sch:let name="dateStamp" value="normalize-space(string(gmd:dateStamp/gco:Date))"/>
		<!-- Metadatastandaard naam -->
			<sch:let name="metadataStandardName" value="translate(normalize-space(gmd:metadataStandardName/gco:CharacterString), $lowercase, $uppercase)"/>
		<!-- Versie metadatastandaard naam -->
			<sch:let name="metadataStandardVersion" value="translate(normalize-space(gmd:metadataStandardVersion/gco:CharacterString), $lowercase, $uppercase)"/>
		<!-- Metadata karakterset -->
			<sch:let name="metadataCharacterset" value="string(gmd:characterSet/*/@codeListValue)"/>
			<sch:let name="metadataCharacterset_value" value="gmd:characterSet/*[@codeListValue ='ucs2' or @codeListValue ='ucs4' or @codeListValue ='utf7' or @codeListValue ='utf8' or @codeListValue ='utf16' or @codeListValue ='8859part1' or @codeListValue ='8859part2' or @codeListValue ='8859part3' or @codeListValue ='8859part4' or @codeListValue ='8859part5' or @codeListValue ='8859part6' or @codeListValue ='8859part7' or @codeListValue ='8859part8' or @codeListValue ='8859part9' or @codeListValue ='8859part10' or @codeListValue ='8859part11' or  @codeListValue ='8859part12' or @codeListValue ='8859part13' or @codeListValue ='8859part14' or @codeListValue ='8859part15' or @codeListValue ='8859part16' or @codeListValue ='jis' or @codeListValue ='shiftJIS' or @codeListValue ='eucJP' or @codeListValue ='usAscii' or @codeListValue ='ebcdic' or @codeListValue ='eucKR' or @codeListValue ='big5' or @codeListValue ='GB2312']"/>
			
		
	
		<!-- rules and assertions -->
			<sch:assert test="$fileIdentifier">Metadata ID (ISO nr. 2) ontbreekt of heeft een verkeerde waarde.</sch:assert>
			<sch:report test="$fileIdentifier">Metadata ID: <sch:value-of select="$fileIdentifier"/>
			</sch:report>
			<sch:assert test="$mdLanguage">De metadata taal (ISO nr. 3) ontbreekt of heeft een verkeerde waarde. Dit hoort een waarde en verwijzing naar de codelijst te zijn.</sch:assert>
			<sch:report test="$mdLanguage">Metadata taal (ISO nr. 3) voldoet 
			</sch:report>
			<sch:assert test="$hierarchyLevel">Resource type (ISO nr. 6) ontbreekt of heeft een verkeerde waarde</sch:assert>
			<sch:report test="$hierarchyLevel">Resource type (ISO nr. 6) voldoet
			</sch:report>
			<sch:assert test="$mdResponsibleParty_Organisation">Naam organisatie metadata (ISO nr. 376) ontbreekt</sch:assert>
			<sch:report test="$mdResponsibleParty_Organisation">Naam organisatie metadata (ISO nr. 376): <sch:value-of select="$mdResponsibleParty_Organisation"/>
			</sch:report>
			<sch:assert test="$mdResponsibleParty_Role">Rol organisatie metadata (ISO nr. 379) ontbreekt of heeft een verkeerde waarde</sch:assert>
			<sch:report test="$mdResponsibleParty_Role">Rol organisatie metadata (ISO nr. 379)  <sch:value-of select="$mdResponsibleParty_Role"/>
			</sch:report>
			<!-- INSPIRE in combi met specificatie INSPIRE -->
			<sch:assert test="not($conformity_Spec_Title_Exsists) or ($conformity_Spec_Title_Exsists and $mdResponsibleParty_Role_INSPIRE)">Rol organisatie metadata (ISO nr. 379) ontbreekt of heeft een verkeerde waarde, deze dient voor INSPIRE contactpunt te zijn</sch:assert>
			<!-- eind INSPIRE in combi met specificatie INSPIRE -->
			<sch:assert test="$mdResponsibleParty_Mail">E-mail organisatie metadata (ISO nr. 386) ontbreekt</sch:assert>
			<sch:report test="$mdResponsibleParty_Mail">E-mail organisatie metadata (ISO nr. 386): <sch:value-of select="$mdResponsibleParty_Mail"/>
			</sch:report>
			<sch:assert test="((number(substring(substring-before($dateStamp,'-'),1,4)) &gt; 1000 ))">Metadata datum (ISO nr. 9) ontbreekt of heeft het verkeerde formaat (YYYY-MM-DD)</sch:assert>
			<sch:report test="$dateStamp">Metadata datum (ISO nr. 9): <sch:value-of select="$dateStamp"/>
			</sch:report>
			<sch:assert test="contains($metadataStandardName, 'ISO 19119')">Metadatastandaard naam (ISO nr. 10) is niet correct ingevuld, Metadatastandaard naam dient de waarde 'ISO 19119' te hebben</sch:assert>
			<sch:report test="$metadataStandardName">Metadatastandaard naam (ISO nr. 10): <sch:value-of select="$metadataStandardName"/>
			</sch:report>
			<sch:assert test="contains($metadataStandardVersion, 'PROFIEL OP ISO 19119')">Versie metadatastandaard  (ISO nr. 11) is niet correct ingevuld, Metadatastandaard versie dient de waarde 'Nederlands metadata profiel op ISO 19119 voor services 1.2' te bevatten</sch:assert>
			<sch:report test="contains($metadataStandardVersion, 'PROFIEL OP ISO 19119')">Versie metadatastandaard  (ISO nr. 11): <sch:value-of select="$metadataStandardVersion"/>
			</sch:report>
			
			<sch:assert test="not($metadataCharacterset) or $metadataCharacterset_value">Metadata karakterset (ISO nr. 4) ontbreekt of heeft een verkeerde waarde</sch:assert>
			<sch:report test="not($metadataCharacterset) or $metadataCharacterset_value">Metadata karakterset (ISO nr. 4) voldoet</sch:report>
	
	 	<!-- alle regels over elementen binnen gmd:identificationInfo -->
		<!-- service titel -->
			<sch:let name="serviceTitle" value="normalize-space(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:title/gco:CharacterString)"/>
		 <!-- Service referentie datum -->
			
			<sch:let name="publicationDateString" value="string(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/gco:Date)"/>
			<sch:let name="creationDateString" value="string(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/gco:Date)"/>
			<sch:let name="revisionDateString" value="string(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/gco:Date)"/>
			<sch:let name="publicationDate" value="((number(substring(substring-before($publicationDateString,'-'),1,4)) &gt; 1000 ))"/>
			<sch:let name="creationDate" value="((number(substring(substring-before($creationDateString,'-'),1,4)) &gt; 1000 ))"/>
			<sch:let name="revisionDate" value="((number(substring(substring-before($revisionDateString,'-'),1,4)) &gt; 1000 ))"/>
		
		<!-- Samenvatting -->
			<sch:let name="abstract" value="normalize-space(gmd:identificationInfo[1]/*/gmd:abstract/gco:CharacterString)"/>
		 <!--  Verantwoordelijke organisatie bron -->
			<sch:let name="responsibleParty_Organisation" value="normalize-space(gmd:identificationInfo[1]/*/gmd:pointOfContact[1]/*/gmd:organisationName/gco:CharacterString)"/>
		 <!-- Verantwoordelijke organisatie bron: role -->
			<sch:let name="responsibleParty_Role" value="gmd:identificationInfo[1]/*/gmd:pointOfContact[1]/*/gmd:role/*/@codeListValue[. = 'resourceProvider' or . = 'custodian' or . = 'owner' or . = 'user' or . = 'distributor' or . = 'owner' or . = 'originator' or . = 'pointOfContact' or . = 'principalInvestigator' or . = 'processor' or . = 'publisher' or . = 'author']"/>
		 <!-- verantwoordelijke organisatie mail -->
			<sch:let name="responsibleParty_Mail" value="normalize-space(gmd:identificationInfo[1]/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:address[1]/*/gmd:electronicMailAddress[1]/gco:CharacterString)"/>
		 <!-- Trefwoorden  voor INSPIRE -->
			<sch:let name="keyword_INSPIRE" value="normalize-space(gmd:identificationInfo[1]/*/gmd:descriptiveKeywords/*/gmd:keyword/gco:CharacterString
			[text() = 'infoFeatureAccessService'
 
			or text() = 'infoMapAccessService'
 
			or text() = 'humanGeographicViewer'
			or text() = 'infoCoverageAccessService'])"/>
    
 		<!-- eind Trefwoorden  voor INSPIRE-->

		<!-- Trefwoorden NL profie -->

			<sch:let name="keyword" value="normalize-space(gmd:identificationInfo[1]/*/gmd:descriptiveKeywords[1]/*/gmd:keyword[1]/gco:CharacterString)"/>
		        
		<!-- eind Trefwoorden NL profie  -->
		<!-- Als  de GEMET INSPIRE themes thesaurus voorkomt, is verwijzing naar inspire specificatie verplicht -->
			
			<sch:assert test="not($thesaurus_INSPIRE_Exsists) or ($thesaurus_INSPIRE_Exsists and $conformity_Spec_Title_Exsists)">Specificatie (ISO nr. 360) mist de verplichte waarde voor INSPIRE services, Als dit geen INSPIRE service is verwijder dan de thesaurus GEMET -INSPIRE themes, voor INSPIRE service in specificatie opnemen; VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</sch:assert>
			
		<!-- eind	-->	
		        
		<!-- Unieke Identifier van de bron -->
			<sch:let name="identifier" value="normalize-space(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString)"/>
		<!-- Gebruiksbeperkingen -->
			<sch:let name="useLimitation" value="normalize-space(gmd:identificationInfo[1]/*/gmd:resourceConstraints[1]/gmd:MD_Constraints/gmd:useLimitation[1]/gco:CharacterString)"/>
		<!-- Overige beperkingen -->
			<sch:let name="otherConstraint1" value="normalize-space(gmd:identificationInfo[1]/*/gmd:resourceConstraints[2]/gmd:MD_LegalConstraints/gmd:otherConstraints[1]/gco:CharacterString)"/>
			<sch:let name="otherConstraint2" value="normalize-space(gmd:identificationInfo[1]/*/gmd:resourceConstraints[2]/gmd:MD_LegalConstraints/gmd:otherConstraints[2]/gco:CharacterString)"/>
				
			<sch:let name="otherConstraints" value="concat($otherConstraint1,$otherConstraint2)"/>
	
			<!-- Veiligheidsrestricties aanscherping  -->
			<!--   	 <sch:let name="classification_value" value="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:classification/*/@codeListValue[. = 'unclassified' or . = 'restricted' or . = 'confidential' or . = 'secret' or . = 'topSecret']"/>
			-->
		<!-- (Juridische) toegangsrestricties  -->
			<!-- aanscherping om public domein CC0 of Geogedeelt te gebruiken -->
			<!-- waarde moet in dat geval otherRestrictions zijn-->
			<sch:let name="accessConstraints_value" value="normalize-space(gmd:identificationInfo[1]/*/gmd:resourceConstraints[2]/*/gmd:accessConstraints/*/@codeListValue[ . = 'otherRestrictions'])"/>
		<!-- Locatie algemeen -->
			<sch:let name="geographicLocation" value="normalize-space(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement)"/>
		<!-- Omgrenzende rechthoek -->
			<sch:let name="west" value="number(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:westBoundLongitude/gco:Decimal)"/>
			<sch:let name="east" value="number(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:eastBoundLongitude/gco:Decimal)"/>
			<sch:let name="north" value="number(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:northBoundLatitude/gco:Decimal)"/>
			<sch:let name="south" value="number(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:southBoundLatitude/gco:Decimal)"/>
		<!-- Temporele dekking begin -->
			<sch:let name="begin_beginPosition" value="normalize-space(gmd:identificationInfo/*/srv:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:beginPosition)"/>
			<sch:let name="begin_begintimePosition" value="normalize-space(gmd:identificationInfo/*/srv:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:begin/*/gml:timePosition)"/>
			<sch:let name="begin_timePosition" value="normalize-space(gmd:identificationInfo/*/srv:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:timePosition)"/>
			<sch:let name="begin" value="$begin_beginPosition or $begin_begintimePosition or $begin_timePosition"/>
		
		<!-- rules and assertions -->

			<sch:assert test="$serviceTitle">Resource titel (ISO nr. 360) ontbreekt</sch:assert>
		    	<sch:report test="$serviceTitle">Resource titel (ISO nr. 360): <sch:value-of select="$serviceTitle"/>
		    	</sch:report>
		    	<sch:assert test="($publicationDate or $creationDate or $revisionDate or $begin) ">Temporal reference date (ISO nr. 394) ontbreekt of heeft het verkeerde formaat (YYYY-MM-DD)</sch:assert>
		    	<sch:report test="($publicationDate or $creationDate or $revisionDate or $begin) ">Tenminste 1 Temporal reference (ISO nr. 394) is gevonden
		    	</sch:report>
		    	<sch:assert test="$abstract">Resource abstract (ISO nr. 25) ontbreekt</sch:assert>
		    	<sch:report test="$abstract">Resource abstract (ISO nr. 25): <sch:value-of select="$abstract"/>
		    	</sch:report>
		    	<sch:assert test="$responsibleParty_Organisation">Responsible party (ISO nr. 376) ontbreekt</sch:assert>
		    	<sch:report test="$responsibleParty_Organisation">Responsible party (ISO nr. 376): <sch:value-of select="$responsibleParty_Organisation"/>
		   	 </sch:report>
		    	<sch:assert test="$responsibleParty_Role">Responsible party role (ISO nr. 379) ontbreekt of heeft een verkeerde waarde</sch:assert>
		    	<sch:report test="$responsibleParty_Role">Responsible party role (ISO nr. 379) voldoet
		    	</sch:report>
		    	<sch:assert test="$responsibleParty_Mail">Responsible party e-mail (ISO nr. 386) ontbreekt of heeft een verkeerde waarde</sch:assert>
		    	<sch:report test="$responsibleParty_Mail">Responsible party e-mail (ISO nr. 386): <sch:value-of select="$responsibleParty_Mail"/>
		    	</sch:report>
		    	<sch:assert test="$keyword">Keyword (ISO nr. 53)  ontbreekt of heeft de verkeerde waarde</sch:assert>
		    	<sch:report test="$keyword">Tenminste 1 keyword (ISO nr. 53) is gevonden
		    	</sch:report>
			<!-- INSPIRE -->
			<!--
				<sch:assert test="$keyword_INSPIRE">Keyword (ISO nr. 53)  voor INSPIRE servicetype ontbreekt of heeft de verkeerde waarde</sch:assert>
		    -->
		    <!-- eind INSPIRE -->	
				<sch:assert test="$useLimitation">Use limitations (ISO nr. 68) ontbreken</sch:assert>
		   	 	<sch:report test="$useLimitation">Use limitations (ISO nr. 68): <sch:value-of select="$useLimitation"/>
		   	 </sch:report>
		<!-- toegangsrestricties -->
			<sch:assert test="$accessConstraints_value and $otherConstraints">(Juridische) toegangsrestricties (ISO nr. 70) en Overige beperkingen (ISO nr 72) dient ingevuld te zijn</sch:assert>
			<sch:assert test="$accessConstraints_value">(Juridische) toegangsrestricties (ISO nr. 70) dient de waarde 'anders' te hebben in combinatie met een publiek domein, CC0 of geogedeelt licentie bij overige beperkingen (ISO nr. 72)</sch:assert>
			<sch:assert test="not($accessConstraints_value = 'otherRestrictions') or ($accessConstraints_value = 'otherRestrictions' and $otherConstraints)">Het element overige beperkingen (ISO nr. 72) dient een URL naar de publiek domein, CC0 of geogedeelt licentie te hebben als (juridische) toegangsrestricties (ISO nr. 70) de waarde 'anders' heeft</sch:assert>
			<sch:assert test="not($accessConstraints_value = 'otherRestrictions') or ($accessConstraints_value = 'otherRestrictions' and $otherConstraint1 and $otherConstraint2)">Het element overige beperkingen (ISO nr. 72) dient twee maal binnen dezelfde toegangsrestricties voor te komen; één met de beschrijving en één met de URL naar de publiek domein, CC0 of geogedeelt licentie,als (juridische) toegangsrestricties (ISO nr. 70) de waarde 'anders' heeft</sch:assert>
			<sch:report test="$otherConstraint1">Overige beperkingen (ISO nr 72) 1: <sch:value-of select="$otherConstraint1"/>
			</sch:report>
			<sch:report test="$otherConstraint2">Overige beperkingen (ISO nr 72) 2: <sch:value-of select="$otherConstraint2"/>
			</sch:report>
			<sch:report test="$accessConstraints_value">(Juridische) toegangsrestricties (ISO nr. 70) voldoet: <sch:value-of select="$accessConstraints_value"/>
			</sch:report>
				

		<!--service --> 
			<sch:let name="dcp_value" value="normalize-space(string(gmd:identificationInfo[1]/*/srv:containsOperations[1]/*/srv:DCP/*/@codeListValue))"/>
			<sch:let name="operationName" value="normalize-space(gmd:identificationInfo[1]/*/srv:containsOperations[1]/*/srv:operationName/gco:CharacterString)"/>
			<sch:let name="connectPointString" value="normalize-space(gmd:identificationInfo[1]/*/srv:containsOperations[1]/*/srv:connectPoint/*/gmd:linkage/gmd:URL)"/>
			<sch:let name="resourceLocatorString" value="normalize-space(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL)"/>
			<sch:let name="connectPoint" value="normalize-space(substring-before($connectPointString,'?'))"/>
			<sch:let name="resourceLocator" value="normalize-space(substring-before($resourceLocatorString,'?'))"/>
			
		<!-- Protocol -->
			<sch:let name="transferOptions_Protocol" value="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:protocol/*[text() = 'OGC:CSW' or text() = 'OGC:WMS' or text() = 'OGC:WFS' or text() = 'OGC:WCS' or text() = 'OGC:WCTS' or text() = 'OGC:WPS' or text() = 'UKST' or text() = 'OGC:WMC' or text() = 'OGC:KML' or text() = 'OGC:GML' or text() = 'OGC:WFS-G' or text() = 'OGC:SOS' or text() = 'OGC:SPS' or text() = 'OGC:SAS' or text() = 'OGC:WNS' or text() = 'OGC:ODS' or text() = 'OGC:OGS' or text() = 'OGC:OUS' or text() = 'OGC:OPS' or text() = 'OGC:ORS'  or text() = 'OGC:WMTS' or text() = 'INSPIRE Atom']"/>
			<sch:let name="transferOptions_Protocol_isOGCService" value="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:protocol/*[text() = 'OGC:WMS' or text() = 'OGC:WFS' or text() = 'OGC:WCS']"/>
			
		   	<sch:let name="serviceType_value" value="gmd:identificationInfo[1]/*/srv:serviceType/*/text()"/>
		   	<sch:let name="serviceType" value="gmd:identificationInfo[1]/*/srv:serviceType/*[text() = 'view'
		   	or text() = 'download'
		   	or text() = 'discovery'
		   	or text() = 'transformation'
		   	 or text() = 'invoke'
		   	 or text() = 'other'
]"/>
			<sch:let name="serviceTypeVersion" value="normalize-space(gmd:identificationInfo[1]/*/srv:serviceTypeVersion/gco:CharacterString)"/>
	
		   	<sch:let name="couplingType_value" value="string(gmd:identificationInfo[1]/*/srv:couplingType/*/@codeListValue)"/>            
		    <sch:let name="couplingType" value="gmd:identificationInfo[1]/*/srv:couplingType/*/@codeListValue[. ='tight' or . ='mixed' or . ='loose']"/>           
    
			<sch:let name="coupledResouceXlink" value= "normalize-space(string(gmd:identificationInfo[1]/srv:SV_ServiceIdentification/srv:operatesOn[1]/@xlink:href))"  />        
			<sch:let name="coupledResouceUUID" value= "normalize-space(string(gmd:identificationInfo[1]/srv:SV_ServiceIdentification/srv:operatesOn[1]/@uuidref))"  />        
			
			

		<!-- assertions and reports -->
		<!-- dcp -->
		    	<sch:assert test="$dcp_value = 'WebServices'"> DCP ontbreekt  of heeft de verkeerde waarde </sch:assert>
		    	<sch:report test="$dcp_value">DCP: <sch:value-of select="$dcp_value"/></sch:report>
		<!-- operationName -->
		    	<sch:assert test="$operationName">Operation name ontbreekt of heeft de verkeerde waarde.</sch:assert>
		    	<sch:report test="$operationName">Operation name: <sch:value-of select="$operationName"/></sch:report>
		<!-- connectPoint -->
			<sch:assert test="$connectPointString"> Connect point linkage ontbreekt of heeft de verkeerde waarde </sch:assert>
			<sch:report test="$connectPointString">Connect point linkage: <sch:value-of select="$connectPointString"/></sch:report>
		
		 <!-- resourceLocator -->		
				
			<sch:assert test="not((not($connectPoint) and not($resourceLocator)) and not($resourceLocatorString=$connectPointString))">Resource locator heeft niet dezelfde waarde als connectpoint Linkage</sch:assert>
			<sch:assert test="not(($connectPoint and not($resourceLocator)) and not($resourceLocatorString=$connectPoint))">Resource locator heeft niet dezelfde waarde als connectpoint Linkage</sch:assert>
			<sch:assert test="not(($resourceLocator and not($connectPoint)) and not($resourceLocator=$connectPointString))">Resource locator  heeft niet dezelfde waarde als connectpoint Linkage</sch:assert>
			<sch:assert test="not(($connectPoint and $resourceLocator) and not($resourceLocator=$connectPoint))">Resource locator  heeft niet dezelfde waarde als connectpoint Linkage</sch:assert>
					
			<sch:assert test="$resourceLocatorString">Resource locator is verplicht als er een link is naar de service</sch:assert>
			<sch:report test="$resourceLocatorString"> Resource locator: <sch:value-of select="$resourceLocatorString"/>
			</sch:report>
	   	 <!-- protocol -->
			<sch:assert test="not($resourceLocatorString) or ($resourceLocatorString and $transferOptions_Protocol)">Protocol (ISO nr. 398) is verplicht als Resource locator is ingevuld.</sch:assert>
			<sch:report test="$transferOptions_Protocol">Protocol (ISO nr. 398): <sch:value-of select="normalize-space(gmd:identificationInfo[1]/*/gmd:transferOptions[1]/*/gmd:onLine/*/gmd:protocol/*/text())"/>
			</sch:report>

		<!-- service type -->
		    	<sch:assert test="$serviceType">Service type ontbreekt of heeft de verkeerde waarde</sch:assert>
		   	<sch:report test="$serviceType">Service type: <sch:value-of select="$serviceType_value"/></sch:report>
		
		<!-- couplingType -->
		    	<sch:assert test="$couplingType">Coupling type ontbreekt of heeft de verkeerde waarde</sch:assert>
		   	<sch:report test="$couplingType">Coupling type: <sch:value-of select="$couplingType_value"/>
		   	</sch:report>
	
		
		<!-- coupling type is niet nodig
		    	<sch:assert test="not($couplingType_value='loose')">'coupling type' heeft de verkeerde waarde; loose is alleen mogelijk als er geen data aan de service gekoppeld is</sch:assert>
		    	<sch:report test="not($couplingType_value='loose')">'coupling type' : <sch:value-of select="$couplingType_value"/>
		    	</sch:report>	
		-->
		
		<!-- Coupled resource afhankelijk van data koppeling -->
			<sch:assert test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and  ($coupledResouceXlink and $coupledResouceUUID))">CoupledResouce met xlink en uuidref is verplicht indien data aan de service is gekoppeld (coupled resource 'tight' of 'mixed').</sch:assert>
		
		
	
		
<!-- extent -->
			<sch:assert test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and $geographicLocation)">Geographic location is verplicht indien data aan de service is gekoppeld (coupled resource 'tight' of 'mixed').</sch:assert>
			<sch:report test="($couplingType_value='tight' or $couplingType_value='mixed') and $geographicLocation">Geographic location: <sch:value-of select="$geographicLocation"/>
			</sch:report>
		   	 <sch:assert test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and (-180.00 &lt; $west) and ( $west &lt; 180.00) or ( $west = 0.00 ) or ( $west = -180.00 ) or ( $west = 180.00 ))">Minimum x-coördinaat (ISO nr. 344) ontbreekt of heeft een verkeerde waarde</sch:assert>
		    	<sch:report test="(-180.00 &lt; $west) and ( $west &lt; 180.00) or ( $west = 0.00 ) or ( $west = -180.00 ) or ( $west = 180.00 )">Minimum x-coördinaat (ISO nr. 344): <sch:value-of select="$west"/>
		    	</sch:report>
		    	<sch:assert test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and (-180.00 &lt; $east) and ($east &lt; 180.00) or ( $east = 0.00 ) or ( $east = -180.00 ) or ( $east = 180.00 ))">Maximum x-coördinaat (ISO nr. 345) ontbreekt of heeft een verkeerde waarde</sch:assert>
		    	<sch:report test="(-180.00 &lt; $east) and ($east &lt; 180.00) or ( $east = 0.00 ) or ( $east = -180.00 ) or ( $east = 180.00 )">Maximum x-coördinaat (ISO nr. 345): <sch:value-of select="$east"/>
		    	</sch:report>
		    	<sch:assert test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and (-90.00 &lt; $south) and ($south &lt; $north) or (-90.00 = $south) or ($south = $north))">Minimum y-coördinaat (ISO nr. 346) ontbreekt of heeft een verkeerde waarde</sch:assert>
		    	<sch:report test="(-90.00 &lt; $south) and ($south &lt; $north) or (-90.00 = $south) or ($south = $north)">Minimum y-coördinaat (ISO nr. 346): <sch:value-of select="$south"/>
		    	</sch:report>
		    	<sch:assert test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and ($south &lt; $north) and ($north &lt; 90.00) or ($south = $north) or ($north = 90.00))">Maximum y-coördinaat (ISO nr. 347) ontbreekt of heeft een verkeerde waarde</sch:assert>
		    	<sch:report test="($south &lt; $north) and ($north &lt; 90.00) or ($south = $north) or ($north = 90.00)">Maximum y-coördinaat (ISO nr. 347): <sch:value-of select="$north"/>
		    	</sch:report>


			

		<!-- alle regels over elementen binnen gmd:dataQualityInfo -->
			<sch:let name="dataQualityInfo" value="gmd:dataQualityInfo/gmd:DQ_DataQuality"/>
			<sch:let name="level" value="string($dataQualityInfo/gmd:scope/gmd:DQ_Scope/gmd:level/*/@codeListValue[. = 'service'])"/>
		<!-- rules and assertions -->
			
			<sch:assert test="$level">Niveau kwaliteitsbeschrijving (ISO nr.139) ontbreekt of heeft een verkeerde waarde. Alleen 'service' is toegestaan</sch:assert>
			<sch:report test="$level">Niveau kwaliteitsbeschrijving (ISO nr.139): <sch:value-of select="$level"/>
			</sch:report>
		</sch:rule>
		
		<!--  Conformiteitindicatie meerdere specificaties -->                                 
		<sch:rule context="//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult">
			
		<!-- Specificatie title -->
			<sch:let name="conformity_SpecTitle" value="normalize-space(gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
			<sch:let name="conformity_Explanation" value="normalize-space(gmd:explanation/gco:CharacterString)"/>
		<!-- Specificatie date -->
			<sch:let name="conformity_DateString" value="string(gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date)"/>
			<sch:let name="conformity_Date" value="((number(substring(substring-before($conformity_DateString,'-'),1,4)) &gt; 1000 ))"/>	
			
			<sch:let name="conformity_Datetype" value="gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType/*[@codeListValue='creation' or @codeListValue='publication' or @codeListValue='revision']"/>
			<sch:let name="conformity_SpecCreationDate" value="gmd:specification/gmd:CI_Citation/gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/gco:Date"/>
			<sch:let name="conformity_SpecPublicationDate" value="gmd:specification/gmd:CI_Citation/gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/gco:Date"/>
			<sch:let name="conformity_SpecRevisionDate" value="gmd:specification/gmd:CI_Citation/gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/gco:Date"/>
			<sch:let name="conformity_Pass" value="normalize-space(gmd:pass/gco:Boolean)"/>
			
		<!-- Specificatie alleen voor INSPIRE-->
		<!--
			<sch:assert test="$conformity_SpecTitle">Specificatie (ISO nr. 360 ) ontbreekt.</sch:assert>
			<sch:assert test="$conformity_Explanation">Verklaring (ISO nr. 131) ontbreekt.</sch:assert>
			<sch:assert test="$conformity_Date">Specificatie datum (ISO nr. 394) ontbreekt.</sch:assert>
			<sch:assert test="$conformity_Datetype">Specificatiedatum type (ISO nr. 395) ontbreekt.</sch:assert>
			<sch:assert test="$conformity_Pass">Conformiteitindicatie met de specificatie  (ISO nr. 132) ontbreekt.</sch:assert>
		-->
		<!-- eind Specificatie alleen voor INSPIRE-->
		
			
			<!-- als title is ingevuld, moeten date, datetype, explanation en pass ingevuld zijn -->
			
			<sch:assert test="not($conformity_SpecTitle) or ($conformity_SpecTitle and $conformity_Explanation)">Verklaring (ISO nr. 131) is verplicht als een specificatie is opgegeven.</sch:assert>
			<sch:assert test="not($conformity_SpecTitle and not($conformity_Date))">Datum (ISO nr. 394) is verplicht als een specificatie is opgegeven. </sch:assert>
			<sch:assert test="not($conformity_SpecTitle and not($conformity_Datetype))">Datumtype (ISO nr. 395) is verplicht als een specificatie is opgegeven. </sch:assert>
			<sch:assert test="not($conformity_SpecTitle) or ($conformity_SpecTitle and $conformity_Pass)">Conformiteit (ISO nr. 132) is verplicht als een specificatie is opgegeven.</sch:assert>
		
		<!-- als er geen titel is ingevuld, moeten date, dattype explanation en pass leeg zijn -->
		
			<sch:assert test="not($conformity_Explanation) or ($conformity_Explanation and $conformity_SpecTitle)">Verklaring (ISO nr. 131) hoort leeg als geen specificatie is opgegeven</sch:assert>
			<sch:assert test="not($conformity_Date and not($conformity_SpecTitle))">Datum (ISO nr. 394)  hoort leeg als geen specificatie is opgegeven.. </sch:assert>
			<sch:assert test="not($conformity_Datetype and not($conformity_SpecTitle))">Datumtype (ISO nr. 395) hoort leeg als geen specificatie is opgegeven.. </sch:assert>
			<sch:assert test="not($conformity_Pass) or ($conformity_Pass and $conformity_SpecTitle)">Conformiteit (ISO nr. 132) hoort leeg als geen specificatie is opgegeven..</sch:assert>
				
			<sch:report test="$conformity_SpecTitle">Specificatie (ISO nr. 360): <sch:value-of select="$conformity_SpecTitle"/>
			</sch:report>
			<sch:report test="$conformity_SpecCreationDate or $conformity_SpecPublicationDate or $conformity_SpecRevisionDate">Datum (ISO nr. 394) en datum type (ISO nr. 395) is aanwezig voor specificatie.</sch:report>
			
			<sch:report test="$conformity_Explanation">Verklaring (ISO nr. 131): <sch:value-of select="$conformity_Explanation"/>
			</sch:report>
			<sch:report test="$conformity_Pass">Conformiteitindicatie met de specificatie (ISO nr. 132): <sch:value-of select="$conformity_Pass"/>
			</sch:report>
		
		</sch:rule>
		
		<!-- INSPIRE specification titel -->
		<!--
			<sch:rule context="//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation">
            			
		    <sch:let name="all_conformity_Spec_Titles" value="ancestor::gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title"/>	
			<sch:let name="INSPIRE_conformity_Spec_Title" value="normalize-space(gmd:title/gco:CharacterString)"/>
				
			<sch:assert test="$all_conformity_Spec_Titles[normalize-space(*/text()) =  'VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens']">Specificatie (ISO nr. 360) ontbreekt of heeft de verkeerde waarde,verwijzen naar de VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</sch:assert>
			
			<sch:assert test="$all_conformity_Spec_Titles[normalize-space(*/text()) =  'VERORDENING (EG) Nr. 976/2009 VAN DE COMMISSIE van 19 oktober 2009 tot uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad wat betreft de netwerkdiensten']">Specificatie (ISO nr. 360) ontbreekt of heeft de verkeerde waarde,verwijzen naar de VERORDENING (EG) Nr. 976/2009 VAN DE COMMISSIE van 19 oktober 2009 tot uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad wat betreft de netwerkdiensten</sch:assert>
					
		</sch:rule>	
		-->
		<!-- eind INSPIRE specification titel -->
		
		<!-- Operates on-->
		<sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn">
							
		    	<sch:assert test="string(normalize-space(@uuidref))">Coupled resource heeft geen uuidref attribuut bij het element operatesOn </sch:assert>
		    	<sch:assert test="string(normalize-space(@xlink:href)) ">Coupled resource heeft geen xlink:href attribuut bij het element operatesOn</sch:assert>

		</sch:rule>
		
        		<!-- Controlled originating vocabulary -->
       	
		
		<sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords/*/gmd:thesaurusName/gmd:CI_Citation">
         <!--Thesaurus title -->
			<sch:let name="thesaurus_Title" value="normalize-space(gmd:title/gco:CharacterString)"/>

        			
         <!--Thesaurus date -->
			<sch:let name="thesaurus_publicationDateSring" value="string(gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/gco:Date)"/>
			<sch:let name="thesaurus_creationDateString" value="string(gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/gco:Date)"/>
			<sch:let name="thesaurus_revisionDateString" value="string(gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/gco:Date)"/>
			<sch:let name="thesaurus_PublicationDate" value="((number(substring(substring-before($thesaurus_publicationDateSring,'-'),1,4)) &gt; 1000 ))"/>
			<sch:let name="thesaurus_CreationDate" value="((number(substring(substring-before($thesaurus_creationDateString,'-'),1,4)) &gt; 1000 ))"/>
			<sch:let name="thesaurus_RevisionDate" value="((number(substring(substring-before($thesaurus_revisionDateString,'-'),1,4)) &gt; 1000 ))"/>
			
			<sch:report test="$thesaurus_Title">Thesaurus title (ISO nr. 360) is: <sch:value-of select="$thesaurus_Title"/></sch:report>
        	<sch:assert test="not($thesaurus_Title) or ($thesaurus_Title and ($thesaurus_CreationDate or $thesaurus_PublicationDate or $thesaurus_RevisionDate))">Als er gebruik wordt gemaakt van een thesaurus dient de datum (ISO nr.394) en datumtype (ISO nr. 395) opgegeven te worden. Datum formaat moet YYYY-MM-DD zijn.</sch:assert>
            <sch:report test="$thesaurus_CreationDate or $thesaurus_PublicationDate or $thesaurus_RevisionDate">Thesaurus Date (ISO nr. 394) en thesaurus date type (ISO nr. 395) zijn aanwezig</sch:report>
       </sch:rule>
        		
        	
        		<!-- Controlled originating vocabulary -   -->
		<sch:rule context="//gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:descriptiveKeywords
			[normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title) = 'GEMET - INSPIRE themes, version 1.0']
			/gmd:MD_Keywords/gmd:keyword">
			
			<sch:let name="quote" value="&quot;'&quot;"/>
			     
	            		<sch:assert test="((normalize-space(current())='Administratieve eenheden'
)
		        or (normalize-space(current())='Adressen'
)
		        or (normalize-space(current())='Atmosferische omstandigheden'
)
		        or (normalize-space(current())='Beschermde gebieden'
)
		        or (normalize-space(current())='Biogeografische gebieden'
)
		        or (normalize-space(current())='Bodem')
		         or (normalize-space(current())='Bodemgebruik')
		         or (normalize-space(current())='Energiebronnen')
		         or (normalize-space(current())='Faciliteiten voor landbouw en aquacultuur')
		         or (normalize-space(current())='Faciliteiten voor productie en industrie')
		         or (normalize-space(current())=concat('Gebieden met natuurrisico',$quote,'s'))
		         or (normalize-space(current())='Gebiedsbeheer, gebieden waar beperkingen gelden, gereguleerde gebieden en rapportage-eenheden')
		         or (normalize-space(current())='Gebouwen')
		         or (normalize-space(current())='Geografisch rastersysteem')
		         or (normalize-space(current())='Geografische namen')
		         or (normalize-space(current())='Geologie')
		         or (normalize-space(current())='Habitats en biotopen')
		         or (normalize-space(current())='Hoogte')
		         or (normalize-space(current())='Hydrografie')
		         or (normalize-space(current())='Kadastrale percelen')
		         or (normalize-space(current())='Landgebruik')
		         or (normalize-space(current())='Menselijke gezondheid en veiligheid')
		         or (normalize-space(current())='Meteorologische geografische kenmerken')
		         or (normalize-space(current())='Milieubewakingsvoorzieningen')
		         or (normalize-space(current())='Minerale bronnen')
		         or (normalize-space(current())='Nutsdiensten en overheidsdiensten')
		         or (normalize-space(current())='Oceanografische geografische kenmerken')
		         or (normalize-space(current())='Orthobeeldvorming')
		         or (normalize-space(current())='Spreiding van de bevolking — demografie')
		         or (normalize-space(current())='Spreiding van soorten')
		         or (normalize-space(current())='Statistische eenheden')
		         or (normalize-space(current())='Systemen voor verwijzing door middel van coördinaten')
		         or (normalize-space(current())='Vervoersnetwerken')
		         or (normalize-space(current())='Zeegebieden'))">
Deze keywords  komen niet overeen met GEMET- INSPIRE themes thesaurus. gevonden keywords: <sch:value-of select="."/></sch:assert>
		<!--eind  Controlled originating vocabulary   -->
	     
		       <!--  voor externe thesaurus
			<sch:assert test="$gemet-nl//skos:prefLabel[normalize-space(text()) = normalize-space(current())]">Keywords [<sch:value-of select="$gemet-nl//skos:prefLabel "/>]   moeten uit GEMET- INSPIRE themes thesaurus komen. gevonden keywords: <sch:value-of select="."/></sch:assert>
		          -->
		</sch:rule>

        		
		
	</sch:pattern>
</sch:schema>
