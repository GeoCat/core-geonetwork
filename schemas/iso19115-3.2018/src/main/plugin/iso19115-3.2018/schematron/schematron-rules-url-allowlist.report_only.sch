<?xml version="1.0" encoding="UTF-8"?>
<!--
  Reports online resources the catalogue is not allowed to use.

  A warning, not an error: an address nobody is allowed to reach is worth flagging on a record,
  it is not worth stopping the record from being saved, and records arrive by harvesting and
  import as well as from the editor. The report_only in the file name is what makes it a warning;
  an administrator can raise it to an error in the administration interface.

  Nothing is reported while the URL checks are switched off.
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron">

  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">URL allowlist</sch:title>
  <sch:ns prefix="cit" uri="http://standards.iso.org/iso/19115/-3/cit/2.0"/>
  <sch:ns prefix="mdb" uri="http://standards.iso.org/iso/19115/-3/mdb/2.0"/>
  <sch:ns prefix="gco" uri="http://standards.iso.org/iso/19115/-3/gco/1.0"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <sch:ns prefix="xslutil" uri="java:org.fao.geonet.util.XslUtil"/>

  <sch:pattern>
    <sch:title>$loc/strings/urlAllowlistCheck</sch:title>
    <sch:rule context="//cit:linkage//gco:CharacterString[starts-with(text(), 'http')]">

      <sch:let name="isAllowed" value="xslutil:isUrlAllowed(text(), 'ONLINE_RESOURCE')"/>
      <sch:assert test="$isAllowed = true()">
        <sch:value-of select="$loc/strings/alert.urlNotAllowed/div"/>
        <sch:value-of select="string(.)"/>
      </sch:assert>
      <sch:report test="$isAllowed = true()">
        <sch:value-of select="$loc/strings/alert.urlAllowed/div"/>
        '<sch:value-of select="string(.)"/>'
      </sch:report>
    </sch:rule>
  </sch:pattern>

</sch:schema>
