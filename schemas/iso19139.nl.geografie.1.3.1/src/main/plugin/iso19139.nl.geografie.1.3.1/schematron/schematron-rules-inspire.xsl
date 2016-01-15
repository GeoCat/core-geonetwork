<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:geonet="http://www.fao.org/geonetwork"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <xsl:include xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                href="../../../xsl/utils-fn.xsl"/>
   <xsl:param xmlns:geonet="http://www.fao.org/geonetwork"
              xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
              name="lang"/>
   <xsl:param xmlns:geonet="http://www.fao.org/geonetwork"
              xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
              name="thesaurusDir"/>
   <xsl:param xmlns:geonet="http://www.fao.org/geonetwork"
              xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
              name="rule"/>
   <xsl:variable xmlns:geonet="http://www.fao.org/geonetwork"
                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                 name="loc"
                 select="document(concat('../loc/', $lang, '/', substring-before($rule, '.xsl'), '.xml'))"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:geonet="http://www.fao.org/geonetwork"
                              xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title=""
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml" prefix="gml"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2004/02/skos/core#" prefix="skos"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DutchMetadataCoreSet</xsl:attribute>
            <xsl:attribute name="name">Validatie tegen het Nederlands profiel en INSPIRE op ISO 19115 voor geografie v 1.3.1</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<xsl:param name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
   <xsl:param name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

   <!--PATTERN DutchMetadataCoreSetValidatie tegen het Nederlands profiel en INSPIRE op ISO 19115 voor geografie v 1.3.1-->
<svrl:text xmlns:geonet="http://www.fao.org/geonetwork"
              xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Validatie tegen het Nederlands profiel en INSPIRE op ISO 19115 voor geografie v 1.3.1</svrl:text>
   <xsl:variable name="thesaurus1"
                 select="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords[1]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="thesaurus2"
                 select="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords[2]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="thesaurus3"
                 select="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords[3]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="thesaurus4"
                 select="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords[4]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="thesaurus"
                 select="concat(string($thesaurus1),string($thesaurus2),string($thesaurus3),string($thesaurus4))"/>
   <xsl:variable name="thesaurus_INSPIRE_Exsists"
                 select="contains($thesaurus,'GEMET - INSPIRE themes, version 1.0')"/>
   <xsl:variable name="conformity_Spec_Title1"
                 select="normalize-space(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report[1]/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="conformity_Spec_Title2"
                 select="normalize-space(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report[2]/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="conformity_Spec_Title3"
                 select="normalize-space(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report[3]/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="conformity_Spec_Title4"
                 select="normalize-space(//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report[4]/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="conformity_Spec_Title_All"
                 select="concat(string($conformity_Spec_Title1),string($conformity_Spec_Title2),string($conformity_Spec_Title3),string($conformity_Spec_Title4))"/>
   <xsl:variable name="conformity_Spec_Title_Exsists"
                 select="contains($conformity_Spec_Title_All,'VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens')"/>

	  <!--RULE -->
<xsl:template match="/gmd:MD_Metadata" priority="1010" mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/gmd:MD_Metadata"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Het ISO 19139 XML document mist een verplichte schema locatie. De schema locatie http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd moet aanwezig zijn.
			</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd')">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd')">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Het ISO 19139 XML document bevat de schema locatie http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:variable name="fileIdentifier"
                    select="normalize-space(gmd:fileIdentifier/gco:CharacterString)"/>
      <xsl:variable name="mdLanguage"
                    select="(gmd:language/*/@codeListValue = 'dut' or gmd:language/*/@codeListValue = 'eng')"/>
      <xsl:variable name="mdLanguage_value" select="string(gmd:language/*/@codeListValue)"/>
      <xsl:variable name="hierarchyLevel"
                    select="(gmd:hierarchyLevel[1]/*/@codeListValue = 'dataset' or gmd:hierarchyLevel[1]/*/@codeListValue = 'series')"/>
      <xsl:variable name="hierarchyLevel_value"
                    select="string(gmd:hierarchyLevel[1]/*/@codeListValue)"/>
      <xsl:variable name="hierarchyLevelName"
                    select="normalize-space(gmd:hierarchyLevelName[1]/gco:CharacterString)"/>
      <xsl:variable name="mdResponsibleParty_Organisation"
                    select="normalize-space(gmd:contact[1]/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString)"/>
      <xsl:variable name="mdResponsibleParty_Role"
                    select="gmd:contact[1]/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'resourceProvider' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'custodian' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'owner' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'user' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'distributor' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'owner' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'originator' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'pointOfContact' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'principalInvestigator' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'processor' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'publisher' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'author'"/>
      <xsl:variable name="mdResponsibleParty_Role_INSPIRE"
                    select="gmd:contact[1]/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'pointOfContact' "/>
      <xsl:variable name="mdResponsibleParty_Mail"
                    select="normalize-space(gmd:contact[1]/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress[1]/gco:CharacterString)"/>
      <xsl:variable name="dateStamp" select="normalize-space(string(gmd:dateStamp/gco:Date))"/>
      <xsl:variable name="metadataStandardName"
                    select="translate(normalize-space(gmd:metadataStandardName/gco:CharacterString), $lowercase, $uppercase)"/>
      <xsl:variable name="metadataStandardVersion"
                    select="translate(normalize-space(gmd:metadataStandardVersion/gco:CharacterString), $lowercase, $uppercase)"/>
      <xsl:variable name="metadataCharacterset" select="string(gmd:characterSet/*/@codeListValue)"/>
      <xsl:variable name="metadataCharacterset_value"
                    select="gmd:characterSet/*[@codeListValue ='ucs2' or @codeListValue ='ucs4' or @codeListValue ='utf7' or @codeListValue ='utf8' or @codeListValue ='utf16' or @codeListValue ='8859part1' or @codeListValue ='8859part2' or @codeListValue ='8859part3' or @codeListValue ='8859part4' or @codeListValue ='8859part5' or @codeListValue ='8859part6' or @codeListValue ='8859part7' or @codeListValue ='8859part8' or @codeListValue ='8859part9' or @codeListValue ='8859part10' or @codeListValue ='8859part11' or  @codeListValue ='8859part12' or @codeListValue ='8859part13' or @codeListValue ='8859part14' or @codeListValue ='8859part15' or @codeListValue ='8859part16' or @codeListValue ='jis' or @codeListValue ='shiftJIS' or @codeListValue ='eucJP' or @codeListValue ='usAscii' or @codeListValue ='ebcdic' or @codeListValue ='eucKR' or @codeListValue ='big5' or @codeListValue ='GB2312']"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$fileIdentifier"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$fileIdentifier">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Er is geen Metadata ID (ISO nr. 2) opgegeven.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$fileIdentifier">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$fileIdentifier">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Metadata ID: <xsl:text/>
               <xsl:copy-of select="$fileIdentifier"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$mdLanguage"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$mdLanguage">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>De metadata taal (ISO nr. 3) ontbreekt of heeft een verkeerde waarde. Dit hoort een waarde en verwijzing naar de codelijst te zijn.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$mdLanguage">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$mdLanguage">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Metadata taal (ISO nr. 3) voldoet
			 </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$hierarchyLevel"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$hierarchyLevel">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Metadata hierarchieniveau (ISO nr. 6) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$hierarchyLevel">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$hierarchyLevel">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Metadata hierarchieniveau (ISO nr. 6) voldoet</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($hierarchyLevel_value = 'series' and not($hierarchyLevelName))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($hierarchyLevel_value = 'series' and not($hierarchyLevelName))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Beschrijving hierarchisch niveau (ISO nr. 7) ontbreekt. Dit is verplicht als hierarchieniveau = 'series'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$hierarchyLevelName">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$hierarchyLevelName">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Tenminste 1 beschrijving hierarchisch niveau (ISO nr. 7) is gevonden
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$mdResponsibleParty_Organisation"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$mdResponsibleParty_Organisation">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Naam organisatie metadata (ISO nr. 376) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$mdResponsibleParty_Organisation">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$mdResponsibleParty_Organisation">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Naam organisatie metadata (ISO nr. 376): <xsl:text/>
               <xsl:copy-of select="$mdResponsibleParty_Organisation"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$mdResponsibleParty_Role"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$mdResponsibleParty_Role">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Rol organisatie metadata (ISO nr. 379) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$mdResponsibleParty_Role">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$mdResponsibleParty_Role">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Rol organisatie metadata (ISO nr. 379): <xsl:text/>
               <xsl:copy-of select="$mdResponsibleParty_Role"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_Spec_Title_Exsists) or ($conformity_Spec_Title_Exsists and $mdResponsibleParty_Role_INSPIRE)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_Spec_Title_Exsists) or ($conformity_Spec_Title_Exsists and $mdResponsibleParty_Role_INSPIRE)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Rol organisatie metadata (ISO nr. 379) ontbreekt of heeft een verkeerde waarde, deze dient voor INSPIRE contactpunt te zijn</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$mdResponsibleParty_Mail"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$mdResponsibleParty_Mail">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>E-mail organisatie metadata (ISO nr. 386) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$mdResponsibleParty_Mail">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$mdResponsibleParty_Mail">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>E-mail organisatie metadata (ISO nr. 386): <xsl:text/>
               <xsl:copy-of select="$mdResponsibleParty_Mail"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="((number(substring(substring-before($dateStamp,'-'),1,4)) &gt; 1000 ))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="((number(substring(substring-before($dateStamp,'-'),1,4)) &gt; 1000 ))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Metadata datum (ISO nr. 9) ontbreekt of heeft het verkeerde formaat (YYYY-MM-DD)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$dateStamp">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$dateStamp">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Metadata datum (ISO nr. 9): <xsl:text/>
               <xsl:copy-of select="$dateStamp"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$metadataStandardName = 'ISO 19115'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$metadataStandardName = 'ISO 19115'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Metadatastandaard naam (ISO nr. 10) ontbreekt of is niet correct ingevuld, Metadatastandaard naam dient de waarde 'ISO 19115' te hebben</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$metadataStandardName">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$metadataStandardName">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Metadatastandaard naam (ISO nr. 10): <xsl:text/>
               <xsl:copy-of select="$metadataStandardName"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains($metadataStandardVersion, 'PROFIEL OP ISO 19115')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="contains($metadataStandardVersion, 'PROFIEL OP ISO 19115')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Versie metadatastandaard  (ISO nr. 11) ontbreekt of is niet correct ingevuld, Metadatastandaard versie dient de waarde 'Nederlands metadata profiel op ISO 19115 voor geografie 1.3' te bevatten</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$metadataStandardVersion">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$metadataStandardVersion">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Versie metadatastandaard  (ISO nr. 11): <xsl:text/>
               <xsl:copy-of select="$metadataStandardVersion"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($metadataCharacterset) or $metadataCharacterset_value"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($metadataCharacterset) or $metadataCharacterset_value">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Metadata karakterset (ISO nr. 4) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="not($metadataCharacterset) or $metadataCharacterset_value">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="not($metadataCharacterset) or $metadataCharacterset_value">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Metadata karakterset (ISO nr. 4) voldoet</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:variable name="datasetTitle"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
      <xsl:variable name="publicationDateString"
                    select="string(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/*[./gmd:CI_Date/gmd:dateType/*/@codeListValue='publication']/gmd:CI_Date/gmd:date/gco:Date)"/>
      <xsl:variable name="creationDateString"
                    select="string(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/*[./gmd:CI_Date/gmd:dateType/*/@codeListValue='creation']/gmd:CI_Date/gmd:date/gco:Date)"/>
      <xsl:variable name="revisionDateString"
                    select="string(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/*[./gmd:CI_Date/gmd:dateType/*/@codeListValue='revision']/gmd:CI_Date/gmd:date/gco:Date)"/>
      <xsl:variable name="publicationDate"
                    select="((number(substring(substring-before($publicationDateString,'-'),1,4)) &gt; 1000 ))"/>
      <xsl:variable name="creationDate"
                    select="((number(substring(substring-before($creationDateString,'-'),1,4)) &gt; 1000 ))"/>
      <xsl:variable name="revisionDate"
                    select="((number(substring(substring-before($revisionDateString,'-'),1,4)) &gt; 1000 ))"/>
      <xsl:variable name="abstract"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString)"/>
      <xsl:variable name="status"
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:status/*[@codeListValue = 'completed' or @codeListValue = 'historicalArchive' or @codeListValue = 'obsolete' or @codeListValue = 'onGoing' or @codeListValue = 'planned' or @codeListValue = 'required' or @codeListValue = 'underDevelopment']"/>
      <xsl:variable name="responsibleParty_Organisation"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString)"/>
      <xsl:variable name="responsibleParty_Role"
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty/gmd:role/*[@codeListValue = 'resourceProvider' or @codeListValue = 'custodian' or @codeListValue = 'owner' or @codeListValue = 'user' or @codeListValue = 'distributor' or @codeListValue = 'owner' or @codeListValue = 'originator' or @codeListValue = 'pointOfContact' or @codeListValue = 'principalInvestigator' or @codeListValue = 'processor' or @codeListValue = 'publisher' or @codeListValue = 'author']"/>
      <xsl:variable name="responsibleParty_Mail"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact[1]/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address[1]/gmd:CI_Address/gmd:electronicMailAddress[1]/gco:CharacterString)"/>
      <xsl:variable name="keyword"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords[1]/gmd:MD_Keywords/gmd:keyword[1]/gco:CharacterString)"/>
      <xsl:variable name="identifier"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString)"/>
      <xsl:variable name="spatialRepresentationType"
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialRepresentationType/*[@codeListValue='vector' or @codeListValue='grid' or @codeListValue='textTable' or @codeListValue='tin' or @codeListValue='stereoModel' or @codeListValue='video']"/>
      <xsl:variable name="language"
                    select="(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language/*/@codeListValue = 'dut' or gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language/*/@codeListValue = 'eng')"/>
      <xsl:variable name="language_value"
                    select="string(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language/*/@codeListValue)"/>
      <xsl:variable name="characterset"
                    select="string(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:characterSet/*/@codeListValue)"/>
      <xsl:variable name="characterset_value"
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:characterSet/*[@codeListValue ='ucs2' or @codeListValue ='ucs4' or @codeListValue ='utf7' or @codeListValue ='utf8' or @codeListValue ='utf16' or @codeListValue ='8859part1' or @codeListValue ='8859part2' or @codeListValue ='8859part3' or @codeListValue ='8859part4' or @codeListValue ='8859part5' or @codeListValue ='8859part6' or @codeListValue ='8859part7' or @codeListValue ='8859part8' or @codeListValue ='8859part9' or @codeListValue ='8859part10' or @codeListValue ='8859part11' or  @codeListValue ='8859part12' or @codeListValue ='8859part13' or @codeListValue ='8859part14' or @codeListValue ='8859part15' or @codeListValue ='8859part16' or @codeListValue ='jis' or @codeListValue ='shiftJIS' or @codeListValue ='eucJP' or @codeListValue ='usAscii' or @codeListValue ='ebcdic' or @codeListValue ='eucKR' or @codeListValue ='big5' or @codeListValue ='GB2312']"/>
      <xsl:variable name="topicCategory"
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/*[text() = 'farming' or text() = 'biota' or text() = 'boundaries' or text() = 'climatologyMeteorologyAtmosphere' or text() = 'economy' or text() = 'elevation' or text() = 'environment' or text() = 'geoscientificInformation' or text() = 'health' or text() = 'imageryBaseMapsEarthCover' or text() = 'intelligenceMilitary' or text() = 'inlandWaters' or text() = 'location' or text() = 'oceans' or text() = 'planningCadastre' or text() = 'society' or text() = 'structure' or text() = 'transportation' or text() = 'utilitiesCommunication']"/>
      <xsl:variable name="useLimitation"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints[1]/gmd:MD_Constraints/gmd:useLimitation[1]/gco:CharacterString)"/>
      <xsl:variable name="otherConstraint1"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints[2]/gmd:MD_LegalConstraints/gmd:otherConstraints[1]/gco:CharacterString)"/>
      <xsl:variable name="otherConstraint2"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints[2]/gmd:MD_LegalConstraints/gmd:otherConstraints[2]/gco:CharacterString)"/>
      <xsl:variable name="otherConstraints" select="concat($otherConstraint1,$otherConstraint2)"/>
      <xsl:variable name="accessConstraints_value"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints[2]/gmd:MD_LegalConstraints/gmd:accessConstraints/*[@codeListValue = 'otherRestrictions']/@codeListValue)"/>
      <xsl:variable name="west"
                    select="number(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement[1]/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal)"/>
      <xsl:variable name="east"
                    select="number(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement[1]/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal)"/>
      <xsl:variable name="north"
                    select="number(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement[1]/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal)"/>
      <xsl:variable name="south"
                    select="number(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement[1]/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal)"/>
      <xsl:variable name="begin_beginPosition"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/*/gml:beginPosition)"/>
      <xsl:variable name="begin_begintimePosition"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/*/gml:begin/*/gml:timePosition)"/>
      <xsl:variable name="begin_timePosition"
                    select="normalize-space(gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/*/gml:timePosition)"/>
      <xsl:variable name="spatialResolution"
                    select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialResolution"/>
      <xsl:variable name="referenceSystemInfo" select="gmd:referenceSystemInfo"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$datasetTitle"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$datasetTitle">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Dataset titel (ISO nr. 360) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$datasetTitle">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$datasetTitle">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Dataset titel (ISO nr. 360): <xsl:text/>
               <xsl:copy-of select="$datasetTitle"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$publicationDate or $creationDate or $revisionDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$publicationDate or $creationDate or $revisionDate">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Datum van de bron(ISO nr. 394) of Datatype (ISO nr.395) ontbreken of heeft het verkeerde formaat (YYYY-MM-DD)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$publicationDate or $creationDate or $revisionDate">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$publicationDate or $creationDate or $revisionDate">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Tenminste 1 datum van de bron  (ISO nr. 394) is gevonden
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$abstract"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$abstract">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Samenvatting (ISO nr. 25) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$abstract">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$abstract">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Samenvatting (ISO nr. 25): <xsl:text/>
               <xsl:copy-of select="$abstract"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$status"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$status">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Status (ISO nr. 28) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$status">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$status">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Status (ISO nr. 28) voldoet
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$responsibleParty_Organisation"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$responsibleParty_Organisation">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Verantwoordelijke organisatie bron (ISO nr. 376) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$responsibleParty_Organisation">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$responsibleParty_Organisation">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Verantwoordelijke organisatie bron (ISO nr. 376): <xsl:text/>
               <xsl:copy-of select="$responsibleParty_Organisation"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$responsibleParty_Role"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$responsibleParty_Role">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Rol verantwoordelijke organisatie bron (ISO nr. 379) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$responsibleParty_Role">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$responsibleParty_Role">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Rol verantwoordelijke organisatie bron (ISO nr. 379) voldoet
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$responsibleParty_Mail"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$responsibleParty_Mail">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>E-mail verantwoordelijke organisatie bron (ISO nr. 386) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$responsibleParty_Mail">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$responsibleParty_Mail">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>E-mail verantwoordelijke organisatie bron (ISO nr. 386): <xsl:text/>
               <xsl:copy-of select="$responsibleParty_Mail"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$keyword"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$keyword">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Trefwoorden (ISO nr. 53) ontbreken</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$keyword">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$keyword">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Tenminste 1 trefwoord (ISO nr. 53) is gevonden
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$thesaurus_INSPIRE_Exsists"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$thesaurus_INSPIRE_Exsists">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Thesaurus (ISO nr. 360), datum en datumtype ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($thesaurus_INSPIRE_Exsists) or ($thesaurus_INSPIRE_Exsists and $conformity_Spec_Title_Exsists)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($thesaurus_INSPIRE_Exsists) or ($thesaurus_INSPIRE_Exsists and $conformity_Spec_Title_Exsists)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Specificatie (ISO nr. 360) mist de verplichte waarde voor INSPIRE datasets, Als dit geen INSPIRE dataset is verwijder dan de thesaurus GEMET -INSPIRE themes, voor INSPIRE datasets in specificatie opnemen; VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$identifier"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$identifier">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Unieke Identifier van de bron (ISO nr. 207) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$identifier">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$identifier">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Unieke Identifier van de bron (ISO nr. 207): <xsl:text/>
               <xsl:copy-of select="$identifier"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="$language">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$language">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Dataset taal (ISO nr. 39): <xsl:text/>
               <xsl:copy-of select="$language"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($characterset) or $characterset_value"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($characterset) or $characterset_value">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Dataset karakterset (ISO nr. 40) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$characterset_value">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$characterset_value">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Dataset karakterset (ISO nr. 40) voldoet
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$topicCategory"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$topicCategory">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Onderwerp(ISO nr. 41) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$topicCategory">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$topicCategory">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Onderwerp (ISO nr. 41) voldoet
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(-180.00 &lt; $west) and ( $west &lt; 180.00) or ( $west = 0.00 ) or ( $west = -180.00 ) or ( $west = 180.00 )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="(-180.00 &lt; $west) and ( $west &lt; 180.00) or ( $west = 0.00 ) or ( $west = -180.00 ) or ( $west = 180.00 )">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Minimum x-coördinaat (ISO nr. 344) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="(-180.00 &lt; $west) and ( $west &lt; 180.00) or ( $west = 0.00 ) or ( $west = -180.00 ) or ( $west = 180.00 )">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="(-180.00 &lt; $west) and ( $west &lt; 180.00) or ( $west = 0.00 ) or ( $west = -180.00 ) or ( $west = 180.00 )">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Minimum x-coördinaat (ISO nr. 344): <xsl:text/>
               <xsl:copy-of select="$west"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(-180.00 &lt; $east) and ($east &lt; 180.00) or ( $east = 0.00 ) or ( $east = -180.00 ) or ( $east = 180.00 )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="(-180.00 &lt; $east) and ($east &lt; 180.00) or ( $east = 0.00 ) or ( $east = -180.00 ) or ( $east = 180.00 )">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Maximum x-coördinaat (ISO nr. 345) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="(-180.00 &lt; $east) and ($east &lt; 180.00) or ( $east = 0.00 ) or ( $east = -180.00 ) or ( $east = 180.00 )">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="(-180.00 &lt; $east) and ($east &lt; 180.00) or ( $east = 0.00 ) or ( $east = -180.00 ) or ( $east = 180.00 )">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Maximum x-coördinaat (ISO nr. 345): <xsl:text/>
               <xsl:copy-of select="$east"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(-90.00 &lt; $south) and ($south &lt; $north) or (-90.00 = $south) or ($south = $north)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="(-90.00 &lt; $south) and ($south &lt; $north) or (-90.00 = $south) or ($south = $north)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Minimum y-coördinaat (ISO nr. 346) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="(-90.00 &lt; $south) and ($south &lt; $north) or (-90.00 = $south) or ($south = $north)">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="(-90.00 &lt; $south) and ($south &lt; $north) or (-90.00 = $south) or ($south = $north)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Minimum y-coördinaat (ISO nr. 346): <xsl:text/>
               <xsl:copy-of select="$south"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="($south &lt; $north) and ($north &lt; 90.00) or ($south = $north) or ($north = 90.00)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="($south &lt; $north) and ($north &lt; 90.00) or ($south = $north) or ($north = 90.00)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Maximum y-coördinaat (ISO nr. 347) ontbreekt of heeft een verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="($south &lt; $north) and ($north &lt; 90.00) or ($south = $north) or ($north = 90.00)">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="($south &lt; $north) and ($north &lt; 90.00) or ($south = $north) or ($north = 90.00)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Maximum y-coördinaat (ISO nr. 347): <xsl:text/>
               <xsl:copy-of select="$north"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$useLimitation"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$useLimitation">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Gebruiksbeperkingen (ISO nr. 68) ontbreken</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$useLimitation">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$useLimitation">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Gebruiksbeperkingen (ISO nr. 68): <xsl:text/>
               <xsl:copy-of select="$useLimitation"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$accessConstraints_value and $otherConstraints "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$accessConstraints_value and $otherConstraints">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>(Juridische) toegangsrestricties (ISO nr. 70)en Overige beperkingen (ISO nr 72)  dient ingevuld te zijn</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$accessConstraints_value"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$accessConstraints_value">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>(Juridische) toegangsrestricties (ISO nr. 70) dient de waarde 'anders' te hebben in combinatie met een publiek domein, CC0 of geogedeelt licentie bij overige beperkingen (ISO nr. 72)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($accessConstraints_value = 'otherRestrictions') or ($accessConstraints_value = 'otherRestrictions' and $otherConstraint1 and $otherConstraint2)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($accessConstraints_value = 'otherRestrictions') or ($accessConstraints_value = 'otherRestrictions' and $otherConstraint1 and $otherConstraint2)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Het element overige beperkingen (ISO nr. 72) dient twee maal binnen dezelfde toegangsrestricties voor te komen; één met de beschrijving en één met de URL naar de publiek domein, CC0 of geogedeelt licentie,als (juridische) toegangsrestricties (ISO nr. 70) de waarde 'anders' heeft</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$otherConstraint1">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$otherConstraint1">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Overige beperkingen (ISO nr 72) 1: <xsl:text/>
               <xsl:copy-of select="$otherConstraint1"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="$otherConstraint2">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$otherConstraint2">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Overige beperkingen (ISO nr 72) 2: <xsl:text/>
               <xsl:copy-of select="$otherConstraint2"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="$accessConstraints_value">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$accessConstraints_value">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>(Juridische) toegangsrestricties (ISO nr. 70) voldoet: <xsl:text/>
               <xsl:copy-of select="$accessConstraints_value"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$spatialResolution"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$spatialResolution">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Toepassingsschaal (ISO nr. 57) of Resolutie (ISO nr. 61) is verplicht als hij gespecificeerd kan worden. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$referenceSystemInfo"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$referenceSystemInfo">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Code referentiesysteem (ISO nr. 207) ontbreekt en verantwoordelijke organisatie voor namespace referentiesysteem (ISO nr. 208.1) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="distributionFormatName"
                    select="normalize-space(gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString)"/>
      <xsl:variable name="distributionFormatVersion"
                    select="normalize-space(gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:version/gco:CharacterString)"/>
      <xsl:variable name="distributionFormatSpecification"
                    select="normalize-space(gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:specification/gco:CharacterString)"/>
      <xsl:variable name="dataQualityInfo" select="gmd:dataQualityInfo/gmd:DQ_DataQuality"/>
      <xsl:variable name="statement"
                    select="normalize-space($dataQualityInfo/gmd:lineage/gmd:LI_Lineage/gmd:statement/gco:CharacterString)"/>
      <xsl:variable name="level"
                    select="string($dataQualityInfo/gmd:scope/gmd:DQ_Scope/gmd:level/*/@codeListValue[. = 'dataset' or . = 'series' or . = 'featureType'])"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$statement"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$statement">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Algemene beschrijving herkomst (ISO nr. 83) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$statement">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$statement">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Algemene beschrijving herkomst (ISO nr. 83): <xsl:text/>
               <xsl:copy-of select="$statement"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$level"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$level">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Niveau kwaliteitsbeschrijving (ISO nr.139) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$level">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$level">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Niveau kwaliteitsbeschrijving (ISO nr.139): <xsl:text/>
               <xsl:copy-of select="$level"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource"
                 priority="1009"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource"/>
      <xsl:variable name="all_transferOptions_URL"
                    select="ancestor::gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_Spec_Title_Exsists) or ($conformity_Spec_Title_Exsists and $all_transferOptions_URL[normalize-space(*/text())])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_Spec_Title_Exsists) or ($conformity_Spec_Title_Exsists and $all_transferOptions_URL[normalize-space(*/text())])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>URL (ISO nr. 397) onbreekt, voor INSPIRE is de link naar de gerelateerde services (view en download) verplicht.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine"
                 priority="1008"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine"/>
      <xsl:variable name="transferOptions_URL"
                    select="normalize-space(gmd:CI_OnlineResource/gmd:linkage/gmd:URL)"/>
      <xsl:variable name="transferOptions_Protocol"
                    select="gmd:CI_OnlineResource/gmd:protocol/*[text() = 'OGC:CSW' or text() = 'OGC:WMS' or text() = 'OGC:WFS' or text() = 'OGC:WCS' or text() = 'OGC:WCTS' or text() = 'OGC:WPS' or text() = 'UKST' or text() = 'OGC:WMC' or text() = 'OGC:KML' or text() = 'OGC:GML' or text() = 'OGC:WFS-G' or text() = 'OGC:SOS' or text() = 'OGC:SPS' or text() = 'OGC:SAS' or text() = 'OGC:WNS' or text() = 'OGC:ODS' or text() = 'OGC:OGS' or text() = 'OGC:OUS' or text() = 'OGC:OPS' or text() = 'OGC:ORS' or text() = 'website' or text() = 'OGC:WMTS' or text() = 'dataset' or text() = 'download' or text() = 'INSPIRE Atom']"/>
      <xsl:variable name="transferOptions_Protocol_isOGCService"
                    select="gmd:CI_OnlineResource/gmd:protocol/*[text() = 'OGC:WMS' or text() = 'OGC:WFS' or text() = 'OGC:WCS']"/>
      <xsl:variable name="transferOptions_Name"
                    select="normalize-space(gmd:CI_OnlineResource/gmd:name/gco:CharacterString)"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($transferOptions_URL) or ($transferOptions_URL and $transferOptions_Protocol)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($transferOptions_URL) or ($transferOptions_URL and $transferOptions_Protocol)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Protocol (ISO nr. 398) is verplicht als URL (ISO nr. 397) is ingevuld.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($transferOptions_Protocol) or ($transferOptions_Protocol and $transferOptions_URL)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($transferOptions_Protocol) or ($transferOptions_Protocol and $transferOptions_URL)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Protocol (ISO nr. 398) alleen opnemen als URL (ISO nr. 397) is ingevuld.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$transferOptions_URL">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$transferOptions_URL">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text> URL (ISO nr. 397): <xsl:text/>
               <xsl:copy-of select="$transferOptions_URL"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="$transferOptions_Protocol">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$transferOptions_Protocol">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Protocol (ISO nr. 398): <xsl:text/>
               <xsl:copy-of select="gmd:CI_OnlineResource/gmd:protocol/*/text()"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($transferOptions_Protocol_isOGCService) or ($transferOptions_Protocol_isOGCService and $transferOptions_Name)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($transferOptions_Protocol_isOGCService) or ($transferOptions_Protocol_isOGCService and $transferOptions_Name)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Naam (ISO nr. 400) is verplicht als  Protocol (ISO nr. 398) de waarde OGC:WMS, OGC:WFS of OGC:WCS heeft.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$transferOptions_Name">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$transferOptions_Name">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Naam (ISO nr. 400) is : <xsl:text/>
               <xsl:copy-of select="$transferOptions_Name"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult"
                 priority="1007"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult"/>
      <xsl:variable name="conformity_SpecTitle"
                    select="normalize-space(gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
      <xsl:variable name="conformity_Explanation"
                    select="normalize-space(gmd:explanation/gco:CharacterString)"/>
      <xsl:variable name="conformity_DateString"
                    select="string(gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date)"/>
      <xsl:variable name="conformity_Date"
                    select="((number(substring(substring-before($conformity_DateString,'-'),1,4)) &gt; 1000 ))"/>
      <xsl:variable name="conformity_Datetype"
                    select="gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType/*[@codeListValue='creation' or @codeListValue='publication' or @codeListValue='revision']"/>
      <xsl:variable name="conformity_SpecCreationDate"
                    select="gmd:specification/gmd:CI_Citation/gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/gco:Date"/>
      <xsl:variable name="conformity_SpecPublicationDate"
                    select="gmd:specification/gmd:CI_Citation/gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/gco:Date"/>
      <xsl:variable name="conformity_SpecRevisionDate"
                    select="gmd:specification/gmd:CI_Citation/gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/gco:Date"/>
      <xsl:variable name="conformity_Pass" select="normalize-space(gmd:pass/gco:Boolean)"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$conformity_SpecTitle"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$conformity_SpecTitle">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Specificatie (ISO nr. 360 ) ontbreekt.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$conformity_Explanation"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$conformity_Explanation">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Verklaring (ISO nr. 131) ontbreekt.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$conformity_Date"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$conformity_Date">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Specificatie datum (ISO nr. 394) ontbreekt.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$conformity_Datetype"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$conformity_Datetype">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Specificatiedatum type (ISO nr. 395) ontbreekt.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$conformity_Pass"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$conformity_Pass">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conformiteitindicatie met de specificatie  (ISO nr. 132) ontbreekt.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_SpecTitle) or ($conformity_SpecTitle and $conformity_Explanation)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_SpecTitle) or ($conformity_SpecTitle and $conformity_Explanation)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Verklaring (ISO nr. 131) is verplicht als een specificatie is opgegeven.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_SpecTitle and not($conformity_Date))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_SpecTitle and not($conformity_Date))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Datum (ISO nr. 394) is verplicht als een specificatie is opgegeven. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_SpecTitle and not($conformity_Datetype))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_SpecTitle and not($conformity_Datetype))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Datumtype (ISO nr. 395) is verplicht als een specificatie is opgegeven. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_SpecTitle) or ($conformity_SpecTitle and $conformity_Pass)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_SpecTitle) or ($conformity_SpecTitle and $conformity_Pass)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conformiteit (ISO nr. 132) is verplicht als een specificatie is opgegeven.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_Explanation) or ($conformity_Explanation and $conformity_SpecTitle)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_Explanation) or ($conformity_Explanation and $conformity_SpecTitle)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Verklaring (ISO nr. 131) hoort leeg als geen specificatie is opgegeven</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_Date and not($conformity_SpecTitle))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_Date and not($conformity_SpecTitle))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Datum (ISO nr. 394)  hoort leeg als geen specificatie is opgegeven.. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_Datetype and not($conformity_SpecTitle))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_Datetype and not($conformity_SpecTitle))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Datumtype (ISO nr. 395) hoort leeg als geen specificatie is opgegeven.. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($conformity_Pass) or ($conformity_Pass and $conformity_SpecTitle)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($conformity_Pass) or ($conformity_Pass and $conformity_SpecTitle)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Conformiteit (ISO nr. 132) hoort leeg als geen specificatie is opgegeven..</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$conformity_Explanation">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$conformity_Explanation">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Verklaring (ISO nr. 131): <xsl:text/>
               <xsl:copy-of select="$conformity_Explanation"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="$conformity_Pass">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$conformity_Pass">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Conformiteitindicatie met de specificatie (ISO nr. 132): <xsl:text/>
               <xsl:copy-of select="$conformity_Pass"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="$conformity_SpecTitle">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$conformity_SpecTitle">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Specificatie (ISO nr. 360): <xsl:text/>
               <xsl:copy-of select="$conformity_SpecTitle"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="$conformity_SpecCreationDate or $conformity_SpecPublicationDate or $conformity_SpecRevisionDate">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$conformity_SpecCreationDate or $conformity_SpecPublicationDate or $conformity_SpecRevisionDate">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Datum (ISO nr. 394) en datum type (ISO nr. 395) is aanwezig voor specificatie.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation"
                 priority="1006"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation"/>
      <xsl:variable name="all_conformity_Spec_Titles"
                    select="ancestor::gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title"/>
      <xsl:variable name="INSPIRE_conformity_Spec_Title"
                    select="normalize-space(gmd:title/gco:CharacterString)"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$all_conformity_Spec_Titles[normalize-space(*/text()) =  'VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$all_conformity_Spec_Titles[normalize-space(*/text()) = 'VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens']">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Specificatie (ISO nr. 360) verwijst niet naar de VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$INSPIRE_conformity_Spec_Title">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$INSPIRE_conformity_Spec_Title">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Specificatie titel (ISO nr. 360) is: <xsl:text/>
               <xsl:copy-of select="$INSPIRE_conformity_Spec_Title"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:identificationInfo/gmd:MD_DataIdentification" priority="1005"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:identificationInfo/gmd:MD_DataIdentification"/>
      <xsl:variable name="distance"
                    select="gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/*/text()"/>
      <xsl:variable name="denominator"
                    select="gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/*/text()"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$denominator or $distance "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$denominator or $distance">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Toepassingsschaal (ISO nr. 57) of Resolutie (ISO nr. 61) ontbreekt, vul een van deze in</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($denominator and  $distance) "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($denominator and $distance)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Toepassingsschaal (ISO nr. 57) of Resolutie (ISO nr. 61) invullen, niet beide</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer"
                 priority="1004"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer"/>
      <xsl:variable name="denominator" select="text()"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(string(number($denominator))='NaN')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not(string(number($denominator))='NaN')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Toepassingsschaal (ISO nr. 57) heeft een verkeerde waarde, toepassingsschaal is niet numeriek of is leeg.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$denominator">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$denominator">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Toepassingsschaal (ISO nr. 57): <xsl:text/>
               <xsl:copy-of select="$denominator"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance"
                 priority="1003"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance"/>
      <xsl:variable name="distance" select="text()"/>
      <xsl:variable name="distance_UOM" select="@uom= 'meters' "/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(string(number($distance))='NaN')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not(string(number($distance))='NaN')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Resolutie (ISO nr. 61) heeft een verkeerde waarde, resolutie is niet numeriek of is leeg</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$distance">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$distance">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Resolutie (ISO nr. 61) is: <xsl:text/>
               <xsl:copy-of select="$distance"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$distance_UOM"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$distance_UOM">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Resolutie (ISO nr. 61) heeft geen of een verkeerde waarde voor Unit of measure, de waarde moet meters zijn.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$distance_UOM">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$distance_UOM">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Unit of measure voor Resolutie (ISO nr. 61): <xsl:text/>
               <xsl:copy-of select="$distance_UOM"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem"
                 priority="1002"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem"/>
      <xsl:variable name="referenceSystemInfo_Code"
                    select="normalize-space(gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code/gco:CharacterString)"/>
      <xsl:variable name="referenceSystemInfo_Organisation"
                    select="normalize-space(gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:codeSpace/gco:CharacterString)"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$referenceSystemInfo_Code"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$referenceSystemInfo_Code">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Code referentiesysteem (ISO nr. 207) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$referenceSystemInfo_Code">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$referenceSystemInfo_Code">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Code referentiesysteem (ISO nr. 207): <xsl:text/>
               <xsl:copy-of select="$referenceSystemInfo_Code"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$referenceSystemInfo_Organisation"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$referenceSystemInfo_Organisation">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Verantwoordelijke organisatie voor namespace referentiesysteem (ISO nr. 208.1) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$referenceSystemInfo_Organisation">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$referenceSystemInfo_Organisation">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Verantwoordelijke organisatie voor namespace referentiesysteem (ISO nr. 208.1): <xsl:text/>
               <xsl:copy-of select="$referenceSystemInfo_Organisation"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation"
                 priority="1001"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation"/>
      <xsl:variable name="all_thesaurus_Titles"
                    select="ancestor::gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title"/>
      <xsl:variable name="thesaurus_Title" select="normalize-space(gmd:title/gco:CharacterString)"/>
      <xsl:variable name="thesaurus_publicationDateSring"
                    select="string(gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/gco:Date)"/>
      <xsl:variable name="thesaurus_creationDateString"
                    select="string(gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/gco:Date)"/>
      <xsl:variable name="thesaurus_revisionDateString"
                    select="string(gmd:date[./gmd:CI_Date/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/gco:Date)"/>
      <xsl:variable name="thesaurus_PublicationDate"
                    select="((number(substring(substring-before($thesaurus_publicationDateSring,'-'),1,4)) &gt; 1000 ))"/>
      <xsl:variable name="thesaurus_CreationDate"
                    select="((number(substring(substring-before($thesaurus_creationDateString,'-'),1,4)) &gt; 1000 ))"/>
      <xsl:variable name="thesaurus_RevisionDate"
                    select="((number(substring(substring-before($thesaurus_revisionDateString,'-'),1,4)) &gt; 1000 ))"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$all_thesaurus_Titles[normalize-space(*/text()) = 'GEMET - INSPIRE themes, version 1.0']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$all_thesaurus_Titles[normalize-space(*/text()) = 'GEMET - INSPIRE themes, version 1.0']">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Thesaurus title (ISO nr. 360) ontbreekt of heeft de verkeerde waarde. Eén Thesaurus titel dient de waarde 'GEMET - INSPIRE themes, version 1.0 ' te bevatten.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$thesaurus_Title">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$thesaurus_Title">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Thesaurus title (ISO nr. 360) is: <xsl:text/>
               <xsl:copy-of select="$thesaurus_Title"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($thesaurus_Title and not($thesaurus_CreationDate or $thesaurus_PublicationDate or $thesaurus_RevisionDate))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($thesaurus_Title and not($thesaurus_CreationDate or $thesaurus_PublicationDate or $thesaurus_RevisionDate))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Een thesaurus datum (ISO nr.394) en datumtype (ISO nr. 395) is verplicht alsThesaurus title (ISO nr. 360) is opgegeven. Datum formaat moet YYYY-MM-DD zijn. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords    [normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title) = 'GEMET - INSPIRE themes, version 1.0']    /gmd:MD_Keywords/gmd:keyword"
                 priority="1000"
                 mode="M7">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords    [normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title) = 'GEMET - INSPIRE themes, version 1.0']    /gmd:MD_Keywords/gmd:keyword"/>
      <xsl:variable name="quote" select="&#34;'&#34;"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="((normalize-space(current())='Administratieve eenheden' )           or (normalize-space(current())='Adressen' )           or (normalize-space(current())='Atmosferische omstandigheden' )           or (normalize-space(current())='Beschermde gebieden' )           or (normalize-space(current())='Biogeografische gebieden' )           or (normalize-space(current())='Bodem')            or (normalize-space(current())='Bodemgebruik')            or (normalize-space(current())='Energiebronnen')            or (normalize-space(current())='Faciliteiten voor landbouw en aquacultuur')            or (normalize-space(current())='Faciliteiten voor productie en industrie')           or (normalize-space(current())=concat('Gebieden met natuurrisico',$quote,'s'))            or (normalize-space(current())='Gebiedsbeheer, gebieden waar beperkingen gelden, gereguleerde gebieden en rapportage-eenheden')            or (normalize-space(current())='Gebouwen')            or (normalize-space(current())='Geografisch rastersysteem')            or (normalize-space(current())='Geografische namen')            or (normalize-space(current())='Geologie')            or (normalize-space(current())='Habitats en biotopen')            or (normalize-space(current())='Hoogte')            or (normalize-space(current())='Hydrografie')            or (normalize-space(current())='Kadastrale percelen')            or (normalize-space(current())='Landgebruik')            or (normalize-space(current())='Menselijke gezondheid en veiligheid')            or (normalize-space(current())='Meteorologische geografische kenmerken')            or (normalize-space(current())='Milieubewakingsvoorzieningen')            or (normalize-space(current())='Minerale bronnen')            or (normalize-space(current())='Nutsdiensten en overheidsdiensten')            or (normalize-space(current())='Oceanografische geografische kenmerken')            or (normalize-space(current())='Orthobeeldvorming')            or (normalize-space(current())='Spreiding van de bevolking — demografie')            or (normalize-space(current())='Spreiding van soorten')            or (normalize-space(current())='Statistische eenheden')            or (normalize-space(current())='Systemen voor verwijzing door middel van coördinaten')            or (normalize-space(current())='Vervoersnetwerken')            or (normalize-space(current())='Zeegebieden'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="((normalize-space(current())='Administratieve eenheden' ) or (normalize-space(current())='Adressen' ) or (normalize-space(current())='Atmosferische omstandigheden' ) or (normalize-space(current())='Beschermde gebieden' ) or (normalize-space(current())='Biogeografische gebieden' ) or (normalize-space(current())='Bodem') or (normalize-space(current())='Bodemgebruik') or (normalize-space(current())='Energiebronnen') or (normalize-space(current())='Faciliteiten voor landbouw en aquacultuur') or (normalize-space(current())='Faciliteiten voor productie en industrie') or (normalize-space(current())=concat('Gebieden met natuurrisico',$quote,'s')) or (normalize-space(current())='Gebiedsbeheer, gebieden waar beperkingen gelden, gereguleerde gebieden en rapportage-eenheden') or (normalize-space(current())='Gebouwen') or (normalize-space(current())='Geografisch rastersysteem') or (normalize-space(current())='Geografische namen') or (normalize-space(current())='Geologie') or (normalize-space(current())='Habitats en biotopen') or (normalize-space(current())='Hoogte') or (normalize-space(current())='Hydrografie') or (normalize-space(current())='Kadastrale percelen') or (normalize-space(current())='Landgebruik') or (normalize-space(current())='Menselijke gezondheid en veiligheid') or (normalize-space(current())='Meteorologische geografische kenmerken') or (normalize-space(current())='Milieubewakingsvoorzieningen') or (normalize-space(current())='Minerale bronnen') or (normalize-space(current())='Nutsdiensten en overheidsdiensten') or (normalize-space(current())='Oceanografische geografische kenmerken') or (normalize-space(current())='Orthobeeldvorming') or (normalize-space(current())='Spreiding van de bevolking — demografie') or (normalize-space(current())='Spreiding van soorten') or (normalize-space(current())='Statistische eenheden') or (normalize-space(current())='Systemen voor verwijzing door middel van coördinaten') or (normalize-space(current())='Vervoersnetwerken') or (normalize-space(current())='Zeegebieden'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
Deze keywords  moeten uit GEMET- INSPIRE themes thesaurus komen. gevonden keywords: <xsl:text/>
                  <xsl:copy-of select="."/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
</xsl:stylesheet>