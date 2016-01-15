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
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
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
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/srv" prefix="srv"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml" prefix="gml"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">DutchMetadataCoreSetForServices</xsl:attribute>
            <xsl:attribute name="name">Validatie tegen het Nederlands metadata profiel op ISO 19119 voor services v 1.2.1</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<xsl:param name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
   <xsl:param name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

   <!--PATTERN DutchMetadataCoreSetForServicesValidatie tegen het Nederlands metadata profiel op ISO 19119 voor services v 1.2.1-->
<svrl:text xmlns:geonet="http://www.fao.org/geonetwork"
              xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Validatie tegen het Nederlands metadata profiel op ISO 19119 voor services v 1.2.1</svrl:text>
   <xsl:variable name="thesaurus1"
                 select="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[1]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="thesaurus2"
                 select="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[2]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="thesaurus3"
                 select="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[3]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
   <xsl:variable name="thesaurus4"
                 select="normalize-space(/gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords[4]/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
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
<xsl:template match="/gmd:MD_Metadata" priority="1004" mode="M8">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/gmd:MD_Metadata"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Het ISO 19139 XML document mist een verplichte schema locatie. De schema locatie http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd moet aanwezig zijn.
		    	</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd')">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="contains(normalize-space(@xsi:schemaLocation), 'http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd')">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Het ISO 19139 XML document bevat de schema locatie http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd
			</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:variable name="fileIdentifier"
                    select="normalize-space(gmd:fileIdentifier/gco:CharacterString)"/>
      <xsl:variable name="mdLanguage"
                    select="(gmd:language/*/@codeListValue = 'dut' or gmd:language/*/@codeListValue = 'eng')"/>
      <xsl:variable name="mdLanguage_value" select="string(gmd:language/*/@codeListValue)"/>
      <xsl:variable name="hierarchyLevel"
                    select="gmd:hierarchyLevel[1]/*/@codeListValue = 'service'"/>
      <xsl:variable name="hierarchyLevel_value"
                    select="string(gmd:hierarchyLevel[1]/*/@codeListValue)"/>
      <xsl:variable name="mdResponsibleParty_Organisation"
                    select="normalize-space(gmd:contact[1]/*/gmd:organisationName/gco:CharacterString)"/>
      <xsl:variable name="mdResponsibleParty_Role_INSPIRE"
                    select="gmd:contact[1]/*/gmd:role/*/@codeListValue = 'pointOfContact' "/>
      <xsl:variable name="mdResponsibleParty_Role"
                    select="gmd:contact[1]/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'resourceProvider' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'custodian' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'owner' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'user' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'distributor' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'owner' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'originator' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'pointOfContact' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'principalInvestigator' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'processor' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'publisher' or gmd:contact/gmd:CI_ResponsibleParty/gmd:role/*/@codeListValue = 'author'"/>
      <xsl:variable name="mdResponsibleParty_Mail"
                    select="normalize-space(gmd:contact[1]/*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress[1]/gco:CharacterString)"/>
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
               <svrl:text>Metadata ID (ISO nr. 2) ontbreekt of heeft een verkeerde waarde.</svrl:text>
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
               <svrl:text>Resource type (ISO nr. 6) ontbreekt of heeft een verkeerde waarde</svrl:text>
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
            <svrl:text>Resource type (ISO nr. 6) voldoet
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
            <svrl:text>Rol organisatie metadata (ISO nr. 379)  <xsl:text/>
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
         <xsl:when test="contains($metadataStandardName, 'ISO 19119')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="contains($metadataStandardName, 'ISO 19119')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Metadatastandaard naam (ISO nr. 10) is niet correct ingevuld, Metadatastandaard naam dient de waarde 'ISO 19119' te hebben</svrl:text>
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
         <xsl:when test="contains($metadataStandardVersion, 'PROFIEL OP ISO 19119')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="contains($metadataStandardVersion, 'PROFIEL OP ISO 19119')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Versie metadatastandaard  (ISO nr. 11) is niet correct ingevuld, Metadatastandaard versie dient de waarde 'Nederlands metadata profiel op ISO 19119 voor services 1.2' te bevatten</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="contains($metadataStandardVersion, 'PROFIEL OP ISO 19119')">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="contains($metadataStandardVersion, 'PROFIEL OP ISO 19119')">
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
      <xsl:variable name="serviceTitle"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:title/gco:CharacterString)"/>
      <xsl:variable name="publicationDateString"
                    select="string(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='publication']/*/gmd:date/gco:Date)"/>
      <xsl:variable name="creationDateString"
                    select="string(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='creation']/*/gmd:date/gco:Date)"/>
      <xsl:variable name="revisionDateString"
                    select="string(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:date[./*/gmd:dateType/*/@codeListValue='revision']/*/gmd:date/gco:Date)"/>
      <xsl:variable name="publicationDate"
                    select="((number(substring(substring-before($publicationDateString,'-'),1,4)) &gt; 1000 ))"/>
      <xsl:variable name="creationDate"
                    select="((number(substring(substring-before($creationDateString,'-'),1,4)) &gt; 1000 ))"/>
      <xsl:variable name="revisionDate"
                    select="((number(substring(substring-before($revisionDateString,'-'),1,4)) &gt; 1000 ))"/>
      <xsl:variable name="abstract"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:abstract/gco:CharacterString)"/>
      <xsl:variable name="responsibleParty_Organisation"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:pointOfContact[1]/*/gmd:organisationName/gco:CharacterString)"/>
      <xsl:variable name="responsibleParty_Role"
                    select="gmd:identificationInfo[1]/*/gmd:pointOfContact[1]/*/gmd:role/*/@codeListValue[. = 'resourceProvider' or . = 'custodian' or . = 'owner' or . = 'user' or . = 'distributor' or . = 'owner' or . = 'originator' or . = 'pointOfContact' or . = 'principalInvestigator' or . = 'processor' or . = 'publisher' or . = 'author']"/>
      <xsl:variable name="responsibleParty_Mail"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:pointOfContact[1]/*/gmd:contactInfo/*/gmd:address[1]/*/gmd:electronicMailAddress[1]/gco:CharacterString)"/>
      <xsl:variable name="keyword_INSPIRE"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:descriptiveKeywords/*/gmd:keyword/gco:CharacterString    [text() = 'infoFeatureAccessService'      or text() = 'infoMapAccessService'      or text() = 'humanGeographicViewer'    or text() = 'infoCoverageAccessService'])"/>
      <xsl:variable name="keyword"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:descriptiveKeywords[1]/*/gmd:keyword[1]/gco:CharacterString)"/>

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
               <svrl:text>Specificatie (ISO nr. 360) mist de verplichte waarde voor INSPIRE services, Als dit geen INSPIRE service is verwijder dan de thesaurus GEMET -INSPIRE themes, voor INSPIRE service in specificatie opnemen; VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="identifier"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString)"/>
      <xsl:variable name="useLimitation"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:resourceConstraints[1]/gmd:MD_Constraints/gmd:useLimitation[1]/gco:CharacterString)"/>
      <xsl:variable name="otherConstraint1"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:resourceConstraints[2]/gmd:MD_LegalConstraints/gmd:otherConstraints[1]/gco:CharacterString)"/>
      <xsl:variable name="otherConstraint2"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:resourceConstraints[2]/gmd:MD_LegalConstraints/gmd:otherConstraints[2]/gco:CharacterString)"/>
      <xsl:variable name="otherConstraints" select="concat($otherConstraint1,$otherConstraint2)"/>
      <xsl:variable name="accessConstraints_value"
                    select="normalize-space(gmd:identificationInfo[1]/*/gmd:resourceConstraints[2]/*/gmd:accessConstraints/*/@codeListValue[ . = 'otherRestrictions'])"/>
      <xsl:variable name="geographicLocation"
                    select="normalize-space(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement)"/>
      <xsl:variable name="west"
                    select="number(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:westBoundLongitude/gco:Decimal)"/>
      <xsl:variable name="east"
                    select="number(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:eastBoundLongitude/gco:Decimal)"/>
      <xsl:variable name="north"
                    select="number(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:northBoundLatitude/gco:Decimal)"/>
      <xsl:variable name="south"
                    select="number(gmd:identificationInfo[1]/*/srv:extent/*/gmd:geographicElement/*/gmd:southBoundLatitude/gco:Decimal)"/>
      <xsl:variable name="begin_beginPosition"
                    select="normalize-space(gmd:identificationInfo/*/srv:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:beginPosition)"/>
      <xsl:variable name="begin_begintimePosition"
                    select="normalize-space(gmd:identificationInfo/*/srv:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:begin/*/gml:timePosition)"/>
      <xsl:variable name="begin_timePosition"
                    select="normalize-space(gmd:identificationInfo/*/srv:extent/*/gmd:temporalElement/*/gmd:extent/*/gml:timePosition)"/>
      <xsl:variable name="begin"
                    select="$begin_beginPosition or $begin_begintimePosition or $begin_timePosition"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$serviceTitle"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$serviceTitle">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Resource titel (ISO nr. 360) ontbreekt</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$serviceTitle">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$serviceTitle">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Resource titel (ISO nr. 360): <xsl:text/>
               <xsl:copy-of select="$serviceTitle"/>
               <xsl:text/>
		    	     </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="($publicationDate or $creationDate or $revisionDate or $begin) "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="($publicationDate or $creationDate or $revisionDate or $begin)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Temporal reference date (ISO nr. 394) ontbreekt of heeft het verkeerde formaat (YYYY-MM-DD)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="($publicationDate or $creationDate or $revisionDate or $begin) ">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="($publicationDate or $creationDate or $revisionDate or $begin)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Tenminste 1 Temporal reference (ISO nr. 394) is gevonden
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
               <svrl:text>Resource abstract (ISO nr. 25) ontbreekt</svrl:text>
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
            <svrl:text>Resource abstract (ISO nr. 25): <xsl:text/>
               <xsl:copy-of select="$abstract"/>
               <xsl:text/>
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
               <svrl:text>Responsible party (ISO nr. 376) ontbreekt</svrl:text>
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
            <svrl:text>Responsible party (ISO nr. 376): <xsl:text/>
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
               <svrl:text>Responsible party role (ISO nr. 379) ontbreekt of heeft een verkeerde waarde</svrl:text>
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
            <svrl:text>Responsible party role (ISO nr. 379) voldoet
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
               <svrl:text>Responsible party e-mail (ISO nr. 386) ontbreekt of heeft een verkeerde waarde</svrl:text>
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
            <svrl:text>Responsible party e-mail (ISO nr. 386): <xsl:text/>
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
               <svrl:text>Keyword (ISO nr. 53)  ontbreekt of heeft de verkeerde waarde</svrl:text>
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
            <svrl:text>Tenminste 1 keyword (ISO nr. 53) is gevonden
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
               <svrl:text>Use limitations (ISO nr. 68) ontbreken</svrl:text>
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
            <svrl:text>Use limitations (ISO nr. 68): <xsl:text/>
               <xsl:copy-of select="$useLimitation"/>
               <xsl:text/>
		   	      </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$accessConstraints_value and $otherConstraints"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$accessConstraints_value and $otherConstraints">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>(Juridische) toegangsrestricties (ISO nr. 70) en Overige beperkingen (ISO nr 72) dient ingevuld te zijn</svrl:text>
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
         <xsl:when test="not($accessConstraints_value = 'otherRestrictions') or ($accessConstraints_value = 'otherRestrictions' and $otherConstraints)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($accessConstraints_value = 'otherRestrictions') or ($accessConstraints_value = 'otherRestrictions' and $otherConstraints)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Het element overige beperkingen (ISO nr. 72) dient een URL naar de publiek domein, CC0 of geogedeelt licentie te hebben als (juridische) toegangsrestricties (ISO nr. 70) de waarde 'anders' heeft</svrl:text>
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
      <xsl:variable name="dcp_value"
                    select="normalize-space(string(gmd:identificationInfo[1]/*/srv:containsOperations[1]/*/srv:DCP/*/@codeListValue))"/>
      <xsl:variable name="operationName"
                    select="normalize-space(gmd:identificationInfo[1]/*/srv:containsOperations[1]/*/srv:operationName/gco:CharacterString)"/>
      <xsl:variable name="connectPointString"
                    select="normalize-space(gmd:identificationInfo[1]/*/srv:containsOperations[1]/*/srv:connectPoint/*/gmd:linkage/gmd:URL)"/>
      <xsl:variable name="resourceLocatorString"
                    select="normalize-space(gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:linkage/gmd:URL)"/>
      <xsl:variable name="connectPoint"
                    select="normalize-space(substring-before($connectPointString,'?'))"/>
      <xsl:variable name="resourceLocator"
                    select="normalize-space(substring-before($resourceLocatorString,'?'))"/>
      <xsl:variable name="transferOptions_Protocol"
                    select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:protocol/*[text() = 'OGC:CSW' or text() = 'OGC:WMS' or text() = 'OGC:WFS' or text() = 'OGC:WCS' or text() = 'OGC:WCTS' or text() = 'OGC:WPS' or text() = 'UKST' or text() = 'OGC:WMC' or text() = 'OGC:KML' or text() = 'OGC:GML' or text() = 'OGC:WFS-G' or text() = 'OGC:SOS' or text() = 'OGC:SPS' or text() = 'OGC:SAS' or text() = 'OGC:WNS' or text() = 'OGC:ODS' or text() = 'OGC:OGS' or text() = 'OGC:OUS' or text() = 'OGC:OPS' or text() = 'OGC:ORS'  or text() = 'OGC:WMTS' or text() = 'INSPIRE Atom']"/>
      <xsl:variable name="transferOptions_Protocol_isOGCService"
                    select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[1]/gmd:CI_OnlineResource/gmd:protocol/*[text() = 'OGC:WMS' or text() = 'OGC:WFS' or text() = 'OGC:WCS']"/>
      <xsl:variable name="serviceType_value"
                    select="gmd:identificationInfo[1]/*/srv:serviceType/*/text()"/>
      <xsl:variable name="serviceType"
                    select="gmd:identificationInfo[1]/*/srv:serviceType/*[text() = 'view'       or text() = 'download'       or text() = 'discovery'       or text() = 'transformation'        or text() = 'invoke'        or text() = 'other' ]"/>
      <xsl:variable name="serviceTypeVersion"
                    select="normalize-space(gmd:identificationInfo[1]/*/srv:serviceTypeVersion/gco:CharacterString)"/>
      <xsl:variable name="couplingType_value"
                    select="string(gmd:identificationInfo[1]/*/srv:couplingType/*/@codeListValue)"/>
      <xsl:variable name="couplingType"
                    select="gmd:identificationInfo[1]/*/srv:couplingType/*/@codeListValue[. ='tight' or . ='mixed' or . ='loose']"/>
      <xsl:variable name="coupledResouceXlink"
                    select="normalize-space(string(gmd:identificationInfo[1]/srv:SV_ServiceIdentification/srv:operatesOn[1]/@xlink:href))"/>
      <xsl:variable name="coupledResouceUUID"
                    select="normalize-space(string(gmd:identificationInfo[1]/srv:SV_ServiceIdentification/srv:operatesOn[1]/@uuidref))"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$dcp_value = 'WebServices'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$dcp_value = 'WebServices'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> DCP ontbreekt  of heeft de verkeerde waarde </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$dcp_value">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$dcp_value">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>DCP: <xsl:text/>
               <xsl:copy-of select="$dcp_value"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$operationName"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$operationName">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Operation name ontbreekt of heeft de verkeerde waarde.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$operationName">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$operationName">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Operation name: <xsl:text/>
               <xsl:copy-of select="$operationName"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$connectPointString"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$connectPointString">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> Connect point linkage ontbreekt of heeft de verkeerde waarde </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$connectPointString">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$connectPointString">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Connect point linkage: <xsl:text/>
               <xsl:copy-of select="$connectPointString"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not((not($connectPoint) and not($resourceLocator)) and not($resourceLocatorString=$connectPointString))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not((not($connectPoint) and not($resourceLocator)) and not($resourceLocatorString=$connectPointString))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Resource locator heeft niet dezelfde waarde als connectpoint Linkage</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(($connectPoint and not($resourceLocator)) and not($resourceLocatorString=$connectPoint))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not(($connectPoint and not($resourceLocator)) and not($resourceLocatorString=$connectPoint))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Resource locator heeft niet dezelfde waarde als connectpoint Linkage</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(($resourceLocator and not($connectPoint)) and not($resourceLocator=$connectPointString))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not(($resourceLocator and not($connectPoint)) and not($resourceLocator=$connectPointString))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Resource locator  heeft niet dezelfde waarde als connectpoint Linkage</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(($connectPoint and $resourceLocator) and not($resourceLocator=$connectPoint))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not(($connectPoint and $resourceLocator) and not($resourceLocator=$connectPoint))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Resource locator  heeft niet dezelfde waarde als connectpoint Linkage</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$resourceLocatorString"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$resourceLocatorString">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Resource locator is verplicht als er een link is naar de service</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$resourceLocatorString">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$resourceLocatorString">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text> Resource locator: <xsl:text/>
               <xsl:copy-of select="$resourceLocatorString"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($resourceLocatorString) or ($resourceLocatorString and $transferOptions_Protocol)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($resourceLocatorString) or ($resourceLocatorString and $transferOptions_Protocol)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Protocol (ISO nr. 398) is verplicht als Resource locator is ingevuld.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

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
               <xsl:copy-of select="normalize-space(gmd:identificationInfo[1]/*/gmd:transferOptions[1]/*/gmd:onLine/*/gmd:protocol/*/text())"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$serviceType"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$serviceType">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Service type ontbreekt of heeft de verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$serviceType">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$serviceType">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Service type: <xsl:text/>
               <xsl:copy-of select="$serviceType_value"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$couplingType"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="$couplingType">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Coupling type ontbreekt of heeft de verkeerde waarde</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$couplingType">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$couplingType">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Coupling type: <xsl:text/>
               <xsl:copy-of select="$couplingType_value"/>
               <xsl:text/>
		   	      </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and  ($coupledResouceXlink and $coupledResouceUUID))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and ($coupledResouceXlink and $coupledResouceUUID))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>CoupledResouce met xlink en uuidref is verplicht indien data aan de service is gekoppeld (coupled resource 'tight' of 'mixed').</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and $geographicLocation)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and $geographicLocation)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Geographic location is verplicht indien data aan de service is gekoppeld (coupled resource 'tight' of 'mixed').</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="($couplingType_value='tight' or $couplingType_value='mixed') and $geographicLocation">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="($couplingType_value='tight' or $couplingType_value='mixed') and $geographicLocation">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Geographic location: <xsl:text/>
               <xsl:copy-of select="$geographicLocation"/>
               <xsl:text/>
			         </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and (-180.00 &lt; $west) and ( $west &lt; 180.00) or ( $west = 0.00 ) or ( $west = -180.00 ) or ( $west = 180.00 ))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and (-180.00 &lt; $west) and ( $west &lt; 180.00) or ( $west = 0.00 ) or ( $west = -180.00 ) or ( $west = 180.00 ))">
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
         <xsl:when test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and (-180.00 &lt; $east) and ($east &lt; 180.00) or ( $east = 0.00 ) or ( $east = -180.00 ) or ( $east = 180.00 ))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and (-180.00 &lt; $east) and ($east &lt; 180.00) or ( $east = 0.00 ) or ( $east = -180.00 ) or ( $east = 180.00 ))">
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
         <xsl:when test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and (-90.00 &lt; $south) and ($south &lt; $north) or (-90.00 = $south) or ($south = $north))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and (-90.00 &lt; $south) and ($south &lt; $north) or (-90.00 = $south) or ($south = $north))">
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
         <xsl:when test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and ($south &lt; $north) and ($north &lt; 90.00) or ($south = $north) or ($north = 90.00))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($couplingType_value='tight' or $couplingType_value='mixed') or (($couplingType_value='tight' or $couplingType_value='mixed') and ($south &lt; $north) and ($north &lt; 90.00) or ($south = $north) or ($north = 90.00))">
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
      <xsl:variable name="dataQualityInfo" select="gmd:dataQualityInfo/gmd:DQ_DataQuality"/>
      <xsl:variable name="level"
                    select="string($dataQualityInfo/gmd:scope/gmd:DQ_Scope/gmd:level/*/@codeListValue[. = 'service'])"/>

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
               <svrl:text>Niveau kwaliteitsbeschrijving (ISO nr.139) ontbreekt of heeft een verkeerde waarde. Alleen 'service' is toegestaan</svrl:text>
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
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult"
                 priority="1003"
                 mode="M8">
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
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn"
                 priority="1002"
                 mode="M8">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string(normalize-space(@uuidref))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="string(normalize-space(@uuidref))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Coupled resource heeft geen uuidref attribuut bij het element operatesOn </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string(normalize-space(@xlink:href)) "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="string(normalize-space(@xlink:href))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Coupled resource heeft geen xlink:href attribuut bij het element operatesOn</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords/*/gmd:thesaurusName/gmd:CI_Citation"
                 priority="1001"
                 mode="M8">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:identificationInfo/*/gmd:descriptiveKeywords/*/gmd:thesaurusName/gmd:CI_Citation"/>
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
         <xsl:when test="not($thesaurus_Title) or ($thesaurus_Title and ($thesaurus_CreationDate or $thesaurus_PublicationDate or $thesaurus_RevisionDate))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="not($thesaurus_Title) or ($thesaurus_Title and ($thesaurus_CreationDate or $thesaurus_PublicationDate or $thesaurus_RevisionDate))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Als er gebruik wordt gemaakt van een thesaurus dient de datum (ISO nr.394) en datumtype (ISO nr. 395) opgegeven te worden. Datum formaat moet YYYY-MM-DD zijn.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="$thesaurus_CreationDate or $thesaurus_PublicationDate or $thesaurus_RevisionDate">
         <svrl:successful-report xmlns:geonet="http://www.fao.org/geonetwork"
                                 xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 ref="#_{geonet:element/@ref}"
                                 test="$thesaurus_CreationDate or $thesaurus_PublicationDate or $thesaurus_RevisionDate">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Thesaurus Date (ISO nr. 394) en thesaurus date type (ISO nr. 395) zijn aanwezig</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="//gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:descriptiveKeywords    [normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title) = 'GEMET - INSPIRE themes, version 1.0']    /gmd:MD_Keywords/gmd:keyword"
                 priority="1000"
                 mode="M8">
      <svrl:fired-rule xmlns:geonet="http://www.fao.org/geonetwork"
                       xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:descriptiveKeywords    [normalize-space(gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title) = 'GEMET - INSPIRE themes, version 1.0']    /gmd:MD_Keywords/gmd:keyword"/>
      <xsl:variable name="quote" select="&#34;'&#34;"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="((normalize-space(current())='Administratieve eenheden' )           or (normalize-space(current())='Adressen' )           or (normalize-space(current())='Atmosferische omstandigheden' )           or (normalize-space(current())='Beschermde gebieden' )           or (normalize-space(current())='Biogeografische gebieden' )           or (normalize-space(current())='Bodem')            or (normalize-space(current())='Bodemgebruik')            or (normalize-space(current())='Energiebronnen')            or (normalize-space(current())='Faciliteiten voor landbouw en aquacultuur')            or (normalize-space(current())='Faciliteiten voor productie en industrie')            or (normalize-space(current())=concat('Gebieden met natuurrisico',$quote,'s'))            or (normalize-space(current())='Gebiedsbeheer, gebieden waar beperkingen gelden, gereguleerde gebieden en rapportage-eenheden')            or (normalize-space(current())='Gebouwen')            or (normalize-space(current())='Geografisch rastersysteem')            or (normalize-space(current())='Geografische namen')            or (normalize-space(current())='Geologie')            or (normalize-space(current())='Habitats en biotopen')            or (normalize-space(current())='Hoogte')            or (normalize-space(current())='Hydrografie')            or (normalize-space(current())='Kadastrale percelen')            or (normalize-space(current())='Landgebruik')            or (normalize-space(current())='Menselijke gezondheid en veiligheid')            or (normalize-space(current())='Meteorologische geografische kenmerken')            or (normalize-space(current())='Milieubewakingsvoorzieningen')            or (normalize-space(current())='Minerale bronnen')            or (normalize-space(current())='Nutsdiensten en overheidsdiensten')            or (normalize-space(current())='Oceanografische geografische kenmerken')            or (normalize-space(current())='Orthobeeldvorming')            or (normalize-space(current())='Spreiding van de bevolking — demografie')            or (normalize-space(current())='Spreiding van soorten')            or (normalize-space(current())='Statistische eenheden')            or (normalize-space(current())='Systemen voor verwijzing door middel van coördinaten')            or (normalize-space(current())='Vervoersnetwerken')            or (normalize-space(current())='Zeegebieden'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:geonet="http://www.fao.org/geonetwork"
                                xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                ref="#_{geonet:element/@ref}"
                                test="((normalize-space(current())='Administratieve eenheden' ) or (normalize-space(current())='Adressen' ) or (normalize-space(current())='Atmosferische omstandigheden' ) or (normalize-space(current())='Beschermde gebieden' ) or (normalize-space(current())='Biogeografische gebieden' ) or (normalize-space(current())='Bodem') or (normalize-space(current())='Bodemgebruik') or (normalize-space(current())='Energiebronnen') or (normalize-space(current())='Faciliteiten voor landbouw en aquacultuur') or (normalize-space(current())='Faciliteiten voor productie en industrie') or (normalize-space(current())=concat('Gebieden met natuurrisico',$quote,'s')) or (normalize-space(current())='Gebiedsbeheer, gebieden waar beperkingen gelden, gereguleerde gebieden en rapportage-eenheden') or (normalize-space(current())='Gebouwen') or (normalize-space(current())='Geografisch rastersysteem') or (normalize-space(current())='Geografische namen') or (normalize-space(current())='Geologie') or (normalize-space(current())='Habitats en biotopen') or (normalize-space(current())='Hoogte') or (normalize-space(current())='Hydrografie') or (normalize-space(current())='Kadastrale percelen') or (normalize-space(current())='Landgebruik') or (normalize-space(current())='Menselijke gezondheid en veiligheid') or (normalize-space(current())='Meteorologische geografische kenmerken') or (normalize-space(current())='Milieubewakingsvoorzieningen') or (normalize-space(current())='Minerale bronnen') or (normalize-space(current())='Nutsdiensten en overheidsdiensten') or (normalize-space(current())='Oceanografische geografische kenmerken') or (normalize-space(current())='Orthobeeldvorming') or (normalize-space(current())='Spreiding van de bevolking — demografie') or (normalize-space(current())='Spreiding van soorten') or (normalize-space(current())='Statistische eenheden') or (normalize-space(current())='Systemen voor verwijzing door middel van coördinaten') or (normalize-space(current())='Vervoersnetwerken') or (normalize-space(current())='Zeegebieden'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
Deze keywords  komen niet overeen met GEMET- INSPIRE themes thesaurus. gevonden keywords: <xsl:text/>
                  <xsl:copy-of select="."/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
</xsl:stylesheet>