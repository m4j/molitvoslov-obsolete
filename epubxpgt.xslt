<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xhtml xsl">

<xsl:output method="xml" version="1.0" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//RU" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" indent="yes"/>

<!-- the identity template; also removes empty elements -->
<xsl:template match="@*|node()">
    <xsl:if test=". != '' or ./@* != ''">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
</xsl:template>

<!-- template for the head section. Only needed if we want to change, delete or add nodes. In our case we need it to add a link element pointing to an external CSS stylesheet. -->

<xsl:template match="xhtml:head">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
    <link rel="stylesheet" type="application/adobe-page-template+xml" href="page-template.xpgt" />
  </xsl:copy>
</xsl:template>

<xsl:template match="xhtml:img">
 <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
    <xsl:attribute name="width"><xsl:text>100%</xsl:text></xsl:attribute>
 </xsl:copy>
</xsl:template>

<xsl:template match="xhtml:span[@class='titlemark']" />

<xsl:template match="xhtml:div[@class='crosslinks']" />

<!-- template for the body section. Only needed if we want to change, delete or add nodes. In our case we need it to add a div element containing a menu of navigation. -->
<!--
<xsl:template match="xhtml:body">
  <xsl:copy>
    <div class="menu">
      <p><a href="home">Homepage</a> &gt; <strong>Test document</strong></p>
    </div>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>
-->
</xsl:stylesheet>
