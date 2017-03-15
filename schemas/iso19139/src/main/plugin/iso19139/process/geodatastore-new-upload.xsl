<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                exclude-result-prefixes="xs"
                version="2.0">
  <xsl:variable name="defaultConstant" select="'XXXX_nullValue_XXXX'"/>
  <xsl:param name="organisationName" select="$defaultConstant"/>
  <xsl:param name="organisationEmail" select="$defaultConstant"/>
  <xsl:param name="metadataModifiedDate" select="$defaultConstant"/>
  <xsl:param name="lineage" select="$defaultConstant"/>
  <xsl:param name="title" select="$defaultConstant"/>
  <xsl:param name="publicationDate" select="$defaultConstant"/>
  <xsl:param name="revisionDate" select="$defaultConstant"/>
  <xsl:param name="uuid" select="$defaultConstant"/>
  <xsl:param name="abstract" select="$defaultConstant"/>
  <xsl:param name="thumbnailUri" select="$defaultConstant"/>
  <xsl:param name="keywords" select="$defaultConstant"/>
  <xsl:param name="keywordSeparator" select="$defaultConstant"/>
  <xsl:param name="resolution" select="$defaultConstant"/>
  <xsl:param name="topics" select="$defaultConstant"/>
  <xsl:param name="topicSeparator" select="$defaultConstant"/>
  <xsl:param name="geographicIdentifier" select="$defaultConstant"/>
  <xsl:param name="locationUri" select="$defaultConstant" />
  <xsl:param name="bboxWestLongitude" select="$defaultConstant"/>
  <xsl:param name="bboxEastLongitude" select="$defaultConstant"/>
  <xsl:param name="bboxSouthLatitude" select="$defaultConstant"/>
  <xsl:param name="bboxNorthLatitude" select="$defaultConstant"/>
  <xsl:param name="format" select="$defaultConstant"/>
  <xsl:param name="downloadUri" select="$defaultConstant"/>
  <xsl:param name="fileName" select="$defaultConstant"/>
  <xsl:param name="license" select="$defaultConstant"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()" name="identity">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="defaultCharacterStringTemplate">
    <xsl:param name="fieldValue" />
    <xsl:param name="defaultValue" />

    <xsl:choose>
      <xsl:when test="$fieldValue != $defaultValue">
        <gco:CharacterString><xsl:value-of select="$fieldValue" /></gco:CharacterString>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="gco:CharacterString"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="defaultDecimalTemplate">
    <xsl:param name="fieldValue" />
    <xsl:param name="defaultValue" />

    <xsl:choose>
      <xsl:when test="$fieldValue != $defaultValue">
        <gco:Decimal><xsl:value-of select="$fieldValue" /></gco:Decimal>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="gco:Decimal"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="defaultIntegerTemplate">
    <xsl:param name="fieldValue" />
    <xsl:param name="defaultValue" />

    <xsl:choose>
      <xsl:when test="$fieldValue != $defaultValue">
        <gco:Integer><xsl:value-of select="$fieldValue" /></gco:Integer>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="gco:Integer"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="defaultDateTemplate">
    <xsl:param name="fieldValue" />
    <xsl:param name="defaultValue" />

	<!-- todo: check if the fieldvalue has format yyyy-mm-dd, else skip element -->
	
    <xsl:choose>
      <xsl:when test="$fieldValue != $defaultValue">
        <gco:Date><xsl:value-of select="$fieldValue" /></gco:Date>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="gco:Date"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- UUID -->
  <xsl:template match="/gmd:MD_Metadata/gmd:fileIdentifier">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="$uuid"/>
        <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Organisation name -->
  <xsl:template match="/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="$organisationName"/>
        <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Organisation email -->
  <xsl:template match="/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="$organisationEmail"/>
        <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Metadata modified date -->
  <xsl:template match="/gmd:MD_Metadata/gmd:dateStamp">
    <xsl:copy>
      <xsl:variable name="metadataModifiedDateOnly" select="tokenize($metadataModifiedDate,'T')[1]" />
      <xsl:call-template name="defaultDateTemplate">
        <xsl:with-param name="fieldValue" select="$metadataModifiedDateOnly" />
        <xsl:with-param name="defaultValue" select="$defaultConstant"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Title -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="$title"/>
        <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Alternate title 
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:alternateTitle">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="$title"/>
        <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>-->

  <!-- Publication date -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date[../gmd:dateType/gmd:CI_DateTypeCode[@codeListValue='publication']]">
    <xsl:copy>
      <xsl:comment>
        Datum waarop de dataset is gepubliceerd
      </xsl:comment>
      <xsl:call-template name="defaultDateTemplate">
        <xsl:with-param name="fieldValue" select="$publicationDate" />
        <xsl:with-param name="defaultValue" select="$defaultConstant"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Creation date -->
  <!--<xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date[../gmd:dateType/gmd:CI_DateTypeCode[@codeListValue='creation']]">
    <xsl:copy>
      <xsl:comment>
        Datum waarop de dataset is aangemaakt
      </xsl:comment>
      <xsl:call-template name="defaultDateTemplate">
        <xsl:with-param name="fieldValue" select="$publicationDate" />
        <xsl:with-param name="defaultValue" select="$defaultConstant"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>-->

  <!-- Revision date -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date[../gmd:dateType/gmd:CI_DateTypeCode[@codeListValue='revision']]">
    <xsl:copy>
      <xsl:comment>
        Datum waarop de dataset is bijgewerkt
      </xsl:comment>
      <xsl:call-template name="defaultDateTemplate">
        <xsl:with-param name="fieldValue" select="$revisionDate" />
        <xsl:with-param name="defaultValue" select="$defaultConstant"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- identifier -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="concat('http://geodatastore.pdok.nl/id/dataset/', $uuid)"/>
        <xsl:with-param name="defaultValue" select="concat('http://geodatastore.pdok.nl/id/dataset/', $defaultConstant)"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Abstract -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="$abstract"/>
        <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Organisation name Identification Info -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:organisationName">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="$organisationName"/>
        <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Organisation email Identification Info -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="$organisationEmail"/>
        <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <!-- Thumbnail URI -->
  <!--  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName">
      <xsl:copy>
        <xsl:call-template name="defaultCharacterStringTemplate">
            <xsl:with-param name="fieldValue" select="$thumbnailUri"/>
            <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
        </xsl:call-template>
      </xsl:copy>
    </xsl:template>-->

  <!-- Descriptive keywords -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords">
    <xsl:copy>
      <xsl:variable name="keywordList" select="tokenize($keywords, $keywordSeparator)"/>
      <xsl:choose>
        <xsl:when test="$keywords = $defaultConstant">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:when>
        <xsl:when test="count($keywordList) = 0">
          <gmd:keyword></gmd:keyword>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$keywordList">
            <gmd:keyword>
              <gco:CharacterString><xsl:value-of select="." /></gco:CharacterString>
            </gmd:keyword>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints[gmd:MD_Constraints]">
	<xsl:copy>
		<gmd:MD_Constraints>
			<gmd:useLimitation>
				<gco:CharacterString>Geen beperkingen</gco:CharacterString>
			</gmd:useLimitation>					
		</gmd:MD_Constraints>
	</xsl:copy>
  </xsl:template>
  
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints[gmd:MD_LegalConstraints]">
    <xsl:copy>
      <gmd:MD_LegalConstraints>
        <gmd:accessConstraints>
          <gmd:MD_RestrictionCode codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_RestrictionCode"
                                  codeListValue="otherRestrictions"/>
        </gmd:accessConstraints>
        <gmd:otherConstraints>
          <gco:CharacterString>
		    <xsl:choose>
					<xsl:when test="$license='http://creativecommons.org/publicdomain/mark/1.0/deed.nl'">Geen beperkingen</xsl:when>
					<xsl:when test="$license='http://creativecommons.org/publicdomain/zero/1.0/'">Geen beperkingen</xsl:when>
					<xsl:when test="$license='http://creativecommons.org/licenses/by/3.0/nl/'">Naamsvermelding verplicht, <xsl:value-of select="$organisationName"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$license"/></xsl:otherwise>
				</xsl:choose>
		  </gco:CharacterString>
        </gmd:otherConstraints>
        <gmd:otherConstraints>
          <xsl:call-template name="defaultCharacterStringTemplate">
            <xsl:with-param name="fieldValue" select="$license"/>
            <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
          </xsl:call-template>
        </gmd:otherConstraints>
       <!-- <xsl:choose>
          <xsl:when test="$license != $defaultConstant and contains(lower-case($license), 'by')">
            <gmd:otherConstraints>
              <xsl:call-template name="defaultCharacterStringTemplate">
                <xsl:with-param name="fieldValue" select="concat('Naamsvermelding verplicht, ', $organisationName)"/>
                <xsl:with-param name="defaultValue" select="concat('Naamsvermelding verplicht, ', $defaultConstant)" />
              </xsl:call-template>
            </gmd:otherConstraints>
          </xsl:when>
          <xsl:when test="$license = $defaultConstant and contains(lower-case(gmd:otherConstraints/gco:CharacterString/text()), 'by')">
            <gmd:otherConstraints>
              <xsl:call-template name="defaultCharacterStringTemplate">
                <xsl:with-param name="fieldValue" select="concat('Naamsvermelding verplicht, ', $organisationName)"/>
                <xsl:with-param name="defaultValue" select="concat('Naamsvermelding verplicht, ', $defaultConstant)" />
              </xsl:call-template>
            </gmd:otherConstraints>
          </xsl:when>
        </xsl:choose> -->
      </gmd:MD_LegalConstraints>
    </xsl:copy>
  </xsl:template>

  <!-- Resolution -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialResolution">
    <xsl:copy>
      <gmd:MD_Resolution>
        <gmd:equivalentScale>
          <gmd:MD_RepresentativeFraction>
            <gmd:denominator>
              <xsl:call-template name="defaultIntegerTemplate">
                <xsl:with-param name="fieldValue" select="$resolution" />
                <xsl:with-param name="defaultValue" select="$defaultConstant" />
              </xsl:call-template>
            </gmd:denominator>
          </gmd:MD_RepresentativeFraction>
        </gmd:equivalentScale>
      </gmd:MD_Resolution>
    </xsl:copy>
  </xsl:template>

  <!-- Topic categories -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:characterSet">
    <xsl:call-template name="identity" />
    <xsl:if test="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification[not(gmd:topicCategory)]">
      <xsl:variable name="topicList" select="tokenize($topics, $topicSeparator)"/>
      <xsl:choose>
        <xsl:when test="$topics = $defaultConstant">
          <gmd:topicCategory/>
        </xsl:when>
        <xsl:when test="count($topicList) = 0">
          <gmd:topicCategory/>
          <!-- do not add any topic category -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$topicList">
            <gmd:topicCategory>
              <gmd:MD_TopicCategoryCode><xsl:value-of select="." /></gmd:MD_TopicCategoryCode>
            </gmd:topicCategory>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="topicListTemplate" match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory">
    <xsl:variable name="topicList" select="tokenize($topics, $topicSeparator)"/>

    <xsl:choose>
      <xsl:when test="$topics = $defaultConstant">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="count($topicList) = 0">
        <gmd:topicCategory/>
        <!-- do not add any topic category -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$topicList">
          <gmd:topicCategory>
            <gmd:MD_TopicCategoryCode><xsl:value-of select="." /></gmd:MD_TopicCategoryCode>
          </gmd:topicCategory>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Geographic Identifier -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier">
    <xsl:choose>
      <xsl:when test="$geographicIdentifier = $defaultConstant">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <gmd:RS_Identifier>
            <xsl:choose>
              <xsl:when test="$locationUri != $defaultConstant">
                <xsl:attribute name="uuid" select="$locationUri" />
              </xsl:when>
            </xsl:choose>
            <gmd:code>
              <xsl:call-template name="defaultCharacterStringTemplate">
                <xsl:with-param name="fieldValue" select="$geographicIdentifier"/>
                <xsl:with-param name="defaultValue" select="$defaultConstant" />
              </xsl:call-template>
            </gmd:code>
            <gmd:codeSpace>
              <gco:CharacterString>PDOK</gco:CharacterString>
            </gmd:codeSpace>
          </gmd:RS_Identifier>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Bounding Box -->
  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
    <xsl:copy>
      <gmd:westBoundLongitude>
        <xsl:call-template name="defaultDecimalTemplate">
          <xsl:with-param name="fieldValue" select="$bboxWestLongitude" />
          <xsl:with-param name="defaultValue" select="$defaultConstant" />
        </xsl:call-template>
      </gmd:westBoundLongitude>
      <gmd:eastBoundLongitude>
        <xsl:call-template name="defaultDecimalTemplate">
          <xsl:with-param name="fieldValue" select="$bboxEastLongitude" />
          <xsl:with-param name="defaultValue" select="$defaultConstant" />
        </xsl:call-template>
      </gmd:eastBoundLongitude>
      <gmd:southBoundLatitude>
        <xsl:call-template name="defaultDecimalTemplate">
          <xsl:with-param name="fieldValue" select="$bboxSouthLatitude" />
          <xsl:with-param name="defaultValue" select="$defaultConstant" />
        </xsl:call-template>
      </gmd:southBoundLatitude>
      <gmd:northBoundLatitude>
        <xsl:call-template name="defaultDecimalTemplate">
          <xsl:with-param name="fieldValue" select="$bboxNorthLatitude" />
          <xsl:with-param name="defaultValue" select="$defaultConstant" />
        </xsl:call-template>
      </gmd:northBoundLatitude>
    </xsl:copy>
  </xsl:template>

  <!-- Format -->
  <xsl:template match="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format">
    <xsl:copy>
      <gmd:name>
        <xsl:comment>
          Voor geharmoniseerde INSPIRE data naar het applicatie schema verwijzen, juiste benaming zie hoofdstuk 9.x in de dataspecificaties
        </xsl:comment>
        <xsl:call-template name="defaultCharacterStringTemplate">
          <xsl:with-param name="fieldValue" select="$format"/>
          <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
        </xsl:call-template>
      </gmd:name>
      <gmd:version>
        <gco:CharacterString/>
      </gmd:version>
    </xsl:copy>
  </xsl:template>

  <!-- CI_OnlineResource -->
  <!--  <xsl:template match="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource">
      <xsl:copy>
        <gmd:linkage>
          <gmd:URL><xsl:value-of select="$downloadUri"></xsl:value-of></gmd:URL>
        </gmd:linkage>
        <gmd:protocol>
          <gco:CharacterString>download</gco:CharacterString>
        </gmd:protocol>
        <gmd:name>
          <gco:CharacterString><xsl:value-of select="$fileName" /></gco:CharacterString>
        </gmd:name>
      </xsl:copy>
    </xsl:template>-->

  <!-- lineage -->
  <xsl:template match="/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:statement">
    <xsl:copy>
      <xsl:call-template name="defaultCharacterStringTemplate">
        <xsl:with-param name="fieldValue" select="$lineage"/>
        <xsl:with-param name="defaultValue" select="$defaultConstant"></xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>
