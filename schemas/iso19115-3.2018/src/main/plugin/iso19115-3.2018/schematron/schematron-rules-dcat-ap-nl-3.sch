<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <sch:ns prefix="gml" uri="http://www.opengis.net/gml"/>
  <sch:ns prefix="gmd" uri="http://standards.iso.org/iso/19115/-3/gmd"/>
  <sch:ns prefix="gmx" uri="http://standards.iso.org/iso/19115/-3/gmx"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="srv" uri="http://standards.iso.org/iso/19115/-3/srv/2.0"/>
  <sch:ns prefix="mdb" uri="http://standards.iso.org/iso/19115/-3/mdb/2.0"/>
  <sch:ns prefix="mcc" uri="http://standards.iso.org/iso/19115/-3/mcc/1.0"/>
  <sch:ns prefix="mri" uri="http://standards.iso.org/iso/19115/-3/mri/1.0"/>
  <sch:ns prefix="mrs" uri="http://standards.iso.org/iso/19115/-3/mrs/1.0"/>
  <sch:ns prefix="mrd" uri="http://standards.iso.org/iso/19115/-3/mrd/1.0"/>
  <sch:ns prefix="mco" uri="http://standards.iso.org/iso/19115/-3/mco/1.0"/>
  <sch:ns prefix="msr" uri="http://standards.iso.org/iso/19115/-3/msr/2.0"/>
  <sch:ns prefix="lan" uri="http://standards.iso.org/iso/19115/-3/lan/1.0"/>
  <sch:ns prefix="gcx" uri="http://standards.iso.org/iso/19115/-3/gcx/1.0"/>
  <sch:ns prefix="gex" uri="http://standards.iso.org/iso/19115/-3/gex/1.0"/>
  <sch:ns prefix="dqm" uri="http://standards.iso.org/iso/19157/-2/dqm/1.0"/>
  <sch:ns prefix="cit" uri="http://standards.iso.org/iso/19115/-3/cit/2.0"/>
  <sch:ns prefix="mdq" uri="http://standards.iso.org/iso/19157/-2/mdq/1.0"/>
  <sch:ns prefix="mrl" uri="http://standards.iso.org/iso/19115/-3/mrl/2.0"/>
  <sch:ns prefix="gco" uri="http://standards.iso.org/iso/19115/-3/gco/1.0"/>
  <sch:ns prefix="mmi" uri="http://standards.iso.org/iso/19115/-3/mmi/1.0"/>

	<sch:let name="lowercase" value="'abcdefghijklmnopqrstuvwxyz'"/>
	<sch:let name="uppercase" value="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">Validatie tegen het DCAT-AP-NL 3 metadata profiel</sch:title>

	<sch:pattern>
		<sch:title>Informatie over de bron</sch:title>

    <!-- Dataset title -->
		<sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:citation/*/cit:title">
      <sch:let name="mdTitle" value="gco:CharacterString"/>
      <sch:assert test="$mdTitle != ''">$loc/strings/dataset.title</sch:assert>
    </sch:rule>

    <!-- Dataset abstract -->
    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:abstract">
      <sch:let name="mdAbstract" value="gco:CharacterString"/>
      <sch:assert test="$mdAbstract != ''">$loc/strings/dataset.abstract</sch:assert>
    </sch:rule>

    <!-- Dataset language -->
    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:defaultLocale/lan:PT_Locale/lan:language">
      <sch:let name="mdLanguage" value="(*/@codeListValue = 'dut' or */@codeListValue = 'eng')"/>

      <sch:assert test="$mdLanguage">$loc/strings/dataset.language</sch:assert>
    </sch:rule>

    <!-- Dataset contact -->
    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue = 'pointOfContact']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name">
      <sch:let name="orgName" value="gco:CharacterString"/>

      <sch:assert test="$orgName != ''">$loc/strings/dataset.contact.organisationName</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue = 'pointOfContact']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress">
      <sch:let name="email" value="gco:CharacterString"/>

      <sch:assert test="$email != ''">$loc/strings/dataset.contact.email</sch:assert>
    </sch:rule>


    <!-- Dataset creator -->
    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue = 'originator']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name">
      <sch:let name="orgName" value="gco:CharacterString"/>

      <sch:assert test="$orgName != ''">$loc/strings/dataset.creator.organisationName</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue = 'originator']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress">
      <sch:let name="email" value="gco:CharacterString"/>

      <sch:assert test="$email != ''">$loc/strings/dataset.creator.email</sch:assert>
    </sch:rule>

    <!-- Dataset publisher -->
    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name">
      <sch:let name="orgName" value="gco:CharacterString"/>

      <sch:assert test="$orgName != ''">$loc/strings/dataset.publisher.organisationName</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact[cit:CI_Responsibility/cit:role/cit:CI_RoleCode/@codeListValue = 'publisher']/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress">
      <sch:let name="email" value="gco:CharacterString"/>

      <sch:assert test="$email != ''">$loc/strings/dataset.publisher.email</sch:assert>
    </sch:rule>


    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:pointOfContact/cit:CI_Responsibility/cit:role">
      <sch:let name="role" value="*/@codeListValue"/>

      <sch:assert test="$role != ''">$loc/strings/dataset.contact.role</sch:assert>
    </sch:rule>


    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[mri:MD_Keywords/mri:thesaurusName/cit:CI_Citation/cit:title/gcx:Anchor/@xlink:href= 'http://publications.europa.eu/resource/authority/access-right']">
      <sch:let name="accessRights" value="mri:MD_Keywords/mri:keyword/*/text()"/>

      <sch:assert test="$accessRights != ''">$loc/strings/dataset.accessRights</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:descriptiveKeywords[mri:MD_Keywords/mri:thesaurusName/cit:CI_Citation/cit:title/gcx:Anchor/@xlink:href= 'http://publications.europa.eu/resource/authority/data-theme']">
      <sch:let name="dataTheme" value="mri:MD_Keywords/mri:keyword/*/text()"/>

      <sch:assert test="$dataTheme != ''">$loc/strings/dataset.dataTheme</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:status">
      <sch:let name="status" value="*/@codeListValue"/>

      <sch:assert test="$status != ''">$loc/strings/dataset.status</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:resourceMaintenance/mmi:MD_MaintenanceInformation/mmi:maintenanceAndUpdateFrequency">
      <sch:let name="frequency" value="*/@codeListValue"/>

      <sch:assert test="$frequency != ''">$loc/strings/dataset.updateFrequency</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:identificationInfo/*/mri:resourceConstraints/mco:MD_LegalConstraints/mco:otherConstraints">
      <sch:let name="license" value="gco:CharacterString"/>

      <sch:assert test="$license != ''">$loc/strings/dataset.license</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Distributie</sch:title>

    <!-- Distribution -->
    <sch:rule context="//mdb:MD_Metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource/cit:linkage">
      <sch:let name="distributionLink" value="gco:CharacterString"/>

      <sch:assert test="$distributionLink != ''">$loc/strings/distribution.link</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource/cit:protocol">
      <sch:let name="distributionProtocol" value="gco:CharacterString"/>

      <sch:assert test="$distributionProtocol != ''">$loc/strings/distribution.protocol</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:distributionInfo/*/mrd:transferOptions/mrd:MD_DigitalTransferOptions/mrd:onLine/cit:CI_OnlineResource/cit:description">
      <sch:let name="distributionDescription" value="gco:CharacterString"/>

      <sch:assert test="$distributionDescription != ''">$loc/strings/distribution.description</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Over de metadata</sch:title>

    <!-- Metadata language -->
    <sch:rule context="//mdb:MD_Metadata/mdb:defaultLocale/lan:PT_Locale/lan:language">
      <sch:let name="mdLanguage" value="(*/@codeListValue = 'dut' or */@codeListValue = 'eng')"/>

      <sch:assert test="$mdLanguage">$loc/strings/metadata.language</sch:assert>
    </sch:rule>

    <!-- Metadata contact -->
    <sch:rule context="//mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:name">
      <sch:let name="orgName" value="gco:CharacterString"/>

      <sch:assert test="$orgName != ''">$loc/strings/metadata.contact.organisationName</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:party/cit:CI_Organisation/cit:contactInfo/cit:CI_Contact/cit:address/cit:CI_Address/cit:electronicMailAddress">
      <sch:let name="email" value="gco:CharacterString"/>

      <sch:assert test="$email != ''">$loc/strings/metadata.contact.email</sch:assert>
    </sch:rule>

    <sch:rule context="//mdb:MD_Metadata/mdb:contact/cit:CI_Responsibility/cit:role">
      <sch:let name="role" value="*/@codeListValue"/>

      <sch:assert test="$role != ''">$loc/strings/metadata.contact.role</sch:assert>
    </sch:rule>
  </sch:pattern>
</sch:schema>
