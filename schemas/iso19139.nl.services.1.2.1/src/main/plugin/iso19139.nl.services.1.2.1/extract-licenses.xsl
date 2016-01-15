<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                exclude-result-prefixes="#all">
  <xsl:template match="gmd:MD_Metadata">
    <licenses>
      <xsl:for-each select="gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints">
        <xsl:for-each select="gmd:otherConstraints[not(@gco:nilReason)]">
          <license>
            <xsl:value-of select="gco:CharacterString"/>
          </license>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints">
        <xsl:for-each select="gmd:otherConstraints[not(@gco:nilReason)]">
          <license>
            <xsl:value-of select="gco:CharacterString"/>
          </license>
        </xsl:for-each>
      </xsl:for-each>
    </licenses>
  </xsl:template>
</xsl:stylesheet>