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
    <xsl:choose>
        <xsl:when test="contains(@src,'uzor_end')">
            <xsl:attribute name="class">
                <xsl:text>ornamentlast</xsl:text>
            </xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(@src,'uzor_end')">
            <xsl:attribute name="class">
                <xsl:text>ornamentfirst</xsl:text>
            </xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(../@class, 'wrapfig')">
            <xsl:attribute name="class">
                <xsl:text>icon</xsl:text>
            </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
         <xsl:attribute name="width">
            <xsl:text>70%</xsl:text>
         </xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
 </xsl:copy>
</xsl:template>

<xsl:template match="xhtml:div[@class='center']">
 <xsl:copy>
    <xsl:if test="contains(xhtml:p/xhtml:img/@src,'uzor_end')">
        <xsl:attribute name="class">
            <xsl:text>mychapterending</xsl:text>
        </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="node()"/>
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
