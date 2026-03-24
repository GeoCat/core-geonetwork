<?xml version="1.0" encoding="UTF-8"?>
<!--
  The main entry point for all user interface generated
  from XSLT.
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">


<xsl:template name="header">
  <!--<div class="container" style="background-color: #fff;">-->

  <div class="container" style="background-color: #fff;">
    <header class="row">
        <div class="col-md-6 col-sm-6 text-left">
          <a href="{/root/gui/nodeUrl}/dut/catalog.search#/home" title="Home pagina">
            <img src="{/root/gui/url}/images/logos/{$env//system/site/siteId}.png" alt="Nationaal georegister" /></a>
        </div>
        <div class="col-md-6 col-sm-6 hidden-xs text-right">
          <ul style="list-style: none;">
            <li>
              <a href="https://www.pdok.nl/contact" target="_blank">Contact</a>
            </li>
            <li>
              <a href="{/root/gui/nodeUrl}dut/catalog.search#/page/Help?page=Help">Help</a>
            </li>
          </ul>
        </div>
    </header>

  </div>

  <div class="container" style="background-color: #1A1E4F;">
    <div class="row navbar navbar-default gn-top-bar ng-scope" role="navigation">
    <div class="ng-scope">
      <div class="navbar-header">
        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
          <span class="sr-only">Toggle navigation</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
      </div>
      <div id="navbar" class="navbar-collapse collapse">
        <ul class="nav navbar-nav">
          <li class="active">
            <a title="Home" href="{/root/gui/nodeUrl}dut/catalog.search#/home">
              <span class="ng-binding">Home</span>
            </a>
          </li>
          <li>
            <a title="Zoeken" href="{/root/gui/nodeUrl}dut/catalog.search#/search">
              <span class="ng-scope">Zoeken</span>
            </a>
          </li>
          <li>
            <a title="Kaart" href="{/root/gui/nodeUrl}dut/catalog.search#/map">
              <span>Kaart</span>
            </a>
          </li>
          <li>
            <a href="{/root/gui/nodeUrl}dut/catalog.search#/page/Actueel?page=Actueel" title="Actueel" >
              <span>Actueel</span>
            </a>
          </li>
          <li>
            <a  href="{/root/gui/nodeUrl}dut/catalog.search#/page/Over NGR?page=Over NGR" title="Over NGR" >
              <span >Over NGR</span>
            </a>
          </li>
          <li>
            <a href="{/root/gui/nodeUrl}dut/catalog.search#/page/Voor ontwikkelaars?page=Voor ontwikkelaars" title="Voor ontwikkelaars" >
              <span >Voor ontwikkelaars</span>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </div>
  </div>

  <div class="container" style="background-color: #98c8f6;">
    <div class="row crumb" style="margin-bottom: 0px;">
      <div class="col-md-1" style="text-align:right"><b>Zoeken</b></div>
      <div class="col-md-11">
                  <form action="{/root/gui/url}"
                        class="form-inline">
                    <div class="input-group gn-form-any">

                      <input type="text"
                             name="any"
                             id="fldAny"
                             placeholder="{$t/anyPlaceHolder}"
                             value="{/root/request/any}"
                             class="form-control"
                             style="margin-top: 4px"
                             autofocus=""/>
                      <div class="input-group-btn">
                        <button type="submit"
                                class="btn btn-primary">
                          &#160;&#160;
                          <i class="fa fa-search">&#160;</i>
                          &#160;&#160;
                        </button>
                        <!--<a href="{$nodeUrl}search"
                           class="btn btn-link">
                          <i class="fa fa-times">&#160;</i>
                        </a>-->
                      </div>
                    </div>
                  </form>
        </div>
      </div>
  </div>
  <!--</div>-->
</xsl:template>

<xsl:template name="footer">
<div class="container row">
  <div class="pull-right" id="footer">
    <a href="https://www.pdok.nl/privacy" target="_blank">Privacy</a>
    <a href="https://www.pdok.nl/cookies" target="_blank">Cookies</a>
    <a href="https://www.pdok.nl/copyright" target="_blank">Copyright</a>
  </div>
</div>
</xsl:template>

</xsl:stylesheet>
