<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--
  Create xml containing profile request email details from user/instance details passed
  Allows email to be customised without changing java service - info supplied is as follows

<root>
<site>localtrunk</site>
<siteURL>http://127.0.0.1:8122/geonetwork</siteURL>
<userName>John Doe</userName>
<datasetTitle>Dataset title</datasetTitle>
</root>

  -->
  <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes" />
  <xsl:template match="/">
    <email>
      <subject>Bevestiging upload PDOK Geodatastore voor <xsl:value-of select="/root/datasetTile"/></subject>
      <content>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="nl">
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
            <title>
              Bevestiging upload PDOK Geodatastore voor <xsl:value-of select="/root/datasetTile"/>
            </title>
          </head>
          <body>
            <p>De dataset <xsl:value-of select="/root/datasetTile"/> is succesvol geupload in de PDOK Geodatastore.
              De metadata zal de volgende dag gepubliceerd worden op het Nationaal Georegister en na 2 dagen op
              <a href="http://data.overheid.nl">data.overheid.nl</a>.
            </p>
            <p>
              <i>Dit is een automatisch gegenereerd bericht waarop niet gereageerd kan worden.</i>
            </p>
          </body>
        </html>
      </content>
    </email>
  </xsl:template>

</xsl:stylesheet>
