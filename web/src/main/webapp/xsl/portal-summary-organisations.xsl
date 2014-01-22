<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method='xml' encoding='UTF-8' indent='yes'/>

<xsl:template match="/">
    <summary field="orgName">
    <xsl:for-each select="/root/response/summary/organisations/organisation">
        <value count="{@count}">
            <xsl:value-of select="@name"/>
        </value>
    </xsl:for-each>
    </summary>
</xsl:template>

	
</xsl:stylesheet>
