<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >
	<xsl:import href="../iso19139/update-fixed-info.xsl" />

	<!-- Dutch profile uses gco:Date instead of gco:DateTime -->
	<xsl:template match="gmd:dateStamp" priority="99">
		<xsl:choose>
			<xsl:when test="/root/env/changeDate">
				<xsl:copy>
					<gco:Date>
						 <xsl:value-of select="tokenize(/root/env/changeDate,'T')[1]" />
					</gco:Date>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
