<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/2005/Atom"
                xmlns:georss="http://www.georss.org/georss"
        >


    <!-- This file defines what parts of the metadata are indexed by Lucene
         Searches can be conducted on indexes defined here.
         The Field@name attribute defines the name of the search variable.
         If a variable has to be maintained in the user session, it needs to be
         added to the GeoNetwork constants in the Java source code.
         Please keep indexes consistent among metadata standards if they should
         work accross different metadata resources -->
    <!-- ========================================================================================= -->

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no" />


    <!-- ========================================================================================= -->

    <xsl:template match="/">

        <xsl:variable name="isoLangId" select="*[name(.)='feed']/@xml:lang" />

        <Document locale="{$isoLangId}">
            <Field name="_locale" string="{$isoLangId}" store="true" index="true"/>
            <Field name="_docLocale" string="{$isoLangId}" store="true" index="true"/>

            <xsl:apply-templates select="*[name(.)='feed']" mode="atom"/>
        </Document>
    </xsl:template>

    <!-- ========================================================================================= -->

    <xsl:template match="*" mode="atom">
        <xsl:for-each select="*[name(.)='title']">
            <Field name="atom_title" string="{string(.)}" store="true" index="true"/>
            <Field name="atom_lang" string="{string(@xml:lang)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="*[name(.)='subtitle']">
            <Field name="atom_subtitle" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <xsl:for-each select="*[name(.)='rights']">
            <Field name="atom_rights" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>


        <xsl:for-each select="*[name(.)='author']">
            <Field name="atom_authorname" string="{string(*[name(.)='name'])}" store="true" index="true"/>
            <Field name="atom_authoremail" string="{string(*[name(.)='email'])}" store="true" index="true"/>
        </xsl:for-each>

        <Field name="atom_url" string="{string(*[name(.)='link' and @rel='self']/@href)}" store="true" index="false"/>

        <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
        <!-- === Free text search === -->

        <Field name="any" store="false" index="true">
            <xsl:attribute name="string">
                <xsl:for-each select="//@type='text'">
                    <xsl:value-of select="concat(., ' ')"/>
                </xsl:for-each>
            </xsl:attribute>
        </Field>
    </xsl:template>
</xsl:stylesheet>
