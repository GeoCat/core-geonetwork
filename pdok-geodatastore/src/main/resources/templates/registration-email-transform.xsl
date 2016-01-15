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
      <subject>Aanvraag nieuw NGR account</subject>
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
            <p>Dit is een aanvraag voor een nieuw NGR account die is aangemaakt door de klant vanuit de PDOK
              Geodatastore. Zo mogelijk deze aanvraag dezelfde dag afhandelen.
            </p>
            <hr/>
            <h3>
              Organisatie
            </h3>
            <div>
              <label>Organisatienaam:</label>
              <xsl:value-of select="/root/org"/>
            </div>
            <div>
              <label>Adres:</label>
              <xsl:value-of select="/root/address"/>
            </div>
            <div>
              <label>Postcode:</label>
              <xsl:value-of select="/root/zip"/>
            </div>
            <div>
              <label>Plaats:</label>
              <xsl:value-of select="/root/city"/>
            </div>
            <div>
              <label>Land:</label>
              <xsl:value-of select="/root/country"/>
            </div>
            <div>
              <label>E-mail:</label>
              <xsl:value-of select="/root/orgEmail"/>
            </div>
            <div>
              <label>Website:</label>
              <xsl:value-of select="/root/website"/>
            </div>

            <h3>
              Contactpersoon voor PDOK
            </h3>
            <xsl:choose>
              <xsl:when test="/root/title = 'mr'">
                <div>
                  De heer
                </div>
              </xsl:when>
              <xsl:when test="/root/title = 'ms'">
                <div>
                  Mevrouw
                </div>
            </xsl:when>
            </xsl:choose>
            <div>
              <label>Achternaam:</label>
              <xsl:value-of select="/root/surname"/>
            </div>
            <div>
              <label>Voorletters:</label>
              <xsl:value-of select="/root/name"/>
            </div>
            <div>
              <label>E-mail:</label>
              <xsl:value-of select="/root/email"/>
            </div>
            <div>
              <label>Telefoon:</label>
              <xsl:value-of select="/root/telephone"/>
            </div>
            <hr/>

          </body>
        </html>
      </content>
    </email>
  </xsl:template>

</xsl:stylesheet>
