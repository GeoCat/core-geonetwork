<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/2.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dct="http://purl.org/dc/terms/"
                exclude-result-prefixes="#all">

  <xsl:import href="./dcat-ap-nl-utils.xsl" />
  <xsl:import href="../eu-geodcat-ap/eu-geodcat-ap-core.xsl"/>
  <xsl:import href="../eu-dcat-ap-hvd/eu-dcat-ap-hvd-core.xsl"/>
  <xsl:import href="./dcat-ap-nl-core-access-and-use.xsl"/>
  <xsl:import href="./dcat-ap-nl-core-lineage.xsl"/>
  <xsl:import href="./dcat-ap-nl-core-distribution.xsl"/>
  <xsl:import href="./dcat-ap-nl-core-contact.xsl"/>

  <xsl:variable name="isMappingResourceConstraintsToEuVocabulary"
                as="xs:boolean"
                select="false()"/>

  <xsl:variable name="languageMap"
                as="node()*">
    <entry key="dut">nld</entry>
  </xsl:variable>

  <!--
  Definition:	A language of the resource. This refers to the natural language used for textual metadata (i.e., titles, descriptions, etc.) of a cataloged resource (i.e., dataset or service) or the textual values of a dataset distribution

  Range:
  dcterms:LinguisticSystem
  Resources defined by the Library of Congress (ISO 639-1, ISO 639-2) SHOULD be used.

  If a ISO 639-1 (two-letter) code is defined for language, then its corresponding IRI SHOULD be used; if no ISO 639-1 code is defined, then IRI corresponding to the ISO 639-2 (three-letter) code SHOULD be used.

  Usage note:	Repeat this property if the resource is available in multiple languages.
  -->
  <!-- Map DUT to NLD -->
  <xsl:template mode="iso19115-3-to-dcat"
                match="mri:defaultLocale
                      |mri:otherLocale
                      |mdb:defaultLocale
                      |mdb:otherLocale">


    <xsl:variable name="languageValue"
                  as="xs:string?"
                  select="if ($languageMap[@key = current()/*/lan:language/*/@codeListValue])
                          then $languageMap[@key = current()/*/lan:language/*/@codeListValue]
                          else */lan:language/*/@codeListValue"/>

    <dct:language>
      <!-- TO CHECK: In DCAT, maybe we should use another base URI? -->
      <dct:LinguisticSystem rdf:about="{concat($europaPublicationLanguage, upper-case($languageValue))}"/>
    </dct:language>
  </xsl:template>

</xsl:stylesheet>
