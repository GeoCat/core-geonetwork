<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:adms="http://www.w3.org/ns/adms#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                exclude-result-prefixes="#all">

  <xsl:variable name="europaPublicationStatus" select="concat($europaPublicationBaseUri,'dataset-status/')"/>

  <!--
  RDF Property:	adms:status
  Definition:	The status of the resource in the context of a particular workflow process [VOCAB-ADMS].
  Range:	skos:Concept
  Usage note:
  DCAT does not prescribe the use of any specific set of life-cycle statuses, but refers to existing standards and community practices fit for the relevant application scenario.
  https://www.w3.org/TR/vocab-adms/#adms-status
  -->

  <xsl:variable name="isoStatusToDublinCore"
                as="node()*">
    <entry key="completed">COMPLETED</entry>
    <entry key="deprecated">DEPRECATED</entry>
    <entry key="underDevelopment">DEVELOP</entry>
    <entry key="obsolete">DISCONT</entry>
    <!--<entry key="">OP_DATPRO</entry>-->
    <entry key="withdrawn">WITHDRAWN</entry>
  </xsl:variable>


  <xsl:template mode="iso19115-3-to-dcat"
                match="mri:status">

    <xsl:variable name="dcStatus"
                  as="xs:string?"
                  select="$isoStatusToDublinCore[@key = current()/*/@codeListValue]"/>

    <adms:status>
      <skos:Concept rdf:about="{concat($europaPublicationStatus, $dcStatus)}">
        <xsl:variable name="codelistKey"
                      select="*/@codeListValue"/>
        <xsl:variable name="parentName"
                      select="local-name(*)"/>

        <xsl:for-each select="$languages/@iso3code">
          <xsl:variable name="codelistTranslation"
                        select="tr:codelist-value-label(tr:create('iso19115-3.2018', current()), $parentName, $codelistKey)"/>

          <skos:prefLabel xml:lang="{current()}"><xsl:value-of select="$codelistTranslation"/></skos:prefLabel>
        </xsl:for-each>
      </skos:Concept>
    </adms:status>
  </xsl:template>

</xsl:stylesheet>
