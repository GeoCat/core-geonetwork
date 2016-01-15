<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" 
	xmlns:napec="http://www.ec.gc.ca/data_donnees/standards/schemas/napec"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:gfc="http://www.isotc211.org/2005/gfc"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:gml="http://www.opengis.net/gml"
	xmlns:gmi="http://www.isotc211.org/2005/gmi" 
	xmlns:gmx="http://www.isotc211.org/2005/gmx"
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:gts="http://www.isotc211.org/2005/gts"
	xmlns:srv="http://www.isotc211.org/2005/srv"
	exclude-result-prefixes="#all">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<!-- identity template -->
	<xsl:template match="@*|node()">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- remove napec:EC_CorporateInfo -->
	<xsl:template match="napec:EC_CorporateInfo" />

	<!-- handle napec:MD_DataIdentification -->
	<xsl:template match="napec:MD_DataIdentification">
		<gmd:MD_DataIdentification>
			<xsl:apply-templates select="@*|node()"/>
		</gmd:MD_DataIdentification>
	</xsl:template>

</xsl:stylesheet>