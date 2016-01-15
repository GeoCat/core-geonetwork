<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--
  Create xml containing profile request email details from user/instance details passed
  Allows email to be customised without changing java service - info supplied is as follows

<root>
</root>

  -->
  <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes" />
  <xsl:template match="/">
    <email>
      <subject>Aanvraag account PDOK Geodatastore en Nationaal Georegister</subject>
      <content>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="nl">
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
            <title>
              Aanvraag nieuw NGR account
            </title>
          </head>
          <body>
            <p>Hartelijk dank voor het aanvragen van een nieuw account voor de PDOK Geodatastore en het Nationaal Georegister. Uw accountgegevens zullen u per email worden toegezonden binnen 3 dagen.</p>
            <p>
              Dit is een automatisch gegenereerde email waarop u niet kunt reageren.
            </p>
          </body>
        </html>
      </content>
    </email>
  </xsl:template>

</xsl:stylesheet>
