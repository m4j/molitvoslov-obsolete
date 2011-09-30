<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xhtml xsl">
  
  <xsl:strip-space  elements="*"/>
<!--
  <xsl:preserve-space elements="span"/>
-->

<xsl:output method="xml" version="1.0" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" indent="yes"/>

<!-- the identity template; also removes empty elements -->
<xsl:template match="@*|node()">
    <xsl:if test="normalize-space(.) != '' or ./@* != ''">
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

<!--
Assign class for images
-->
<xsl:template match="xhtml:img">
 <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
    <xsl:choose>
        <xsl:when test="contains(@src,'uzor_end')">
            <xsl:attribute name="class">
                <xsl:text>ornamentlast</xsl:text>
            </xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(@src,'uzor_begin')">
            <xsl:attribute name="class">
                <xsl:text>ornamentfirst</xsl:text>
            </xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(../@class, 'wrapfig')">
            <xsl:attribute name="class">
                <xsl:text>icon</xsl:text>
            </xsl:attribute>
        </xsl:when>
<!--
        <xsl:otherwise>
         <xsl:attribute name="width">
            <xsl:text>70%</xsl:text>
         </xsl:attribute>
        </xsl:otherwise>
-->
    </xsl:choose>
 </xsl:copy>
</xsl:template>

<!--
Assign class for the div with chapter ending ornament
-->
<xsl:template match="xhtml:div[@class='center']">
 <xsl:copy>
    <xsl:choose>
        <xsl:when test="contains(xhtml:p/xhtml:img/@src,'uzor_end')">
            <xsl:attribute name="class">
                <xsl:text>mychapterending</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
    </xsl:choose>
 </xsl:copy>
</xsl:template>

<!--
Assign div class based on image shape, the shape of the image is determined
by its placement in a subdirectory, e. g. tall images go into tall/ or wide/
-->
<xsl:template match="xhtml:div[contains(@class, 'wrapfig')]">
 <xsl:copy>
    <xsl:choose>
        <xsl:when test="contains(xhtml:img/@src,'tall')">
            <xsl:attribute name="class">
                <xsl:value-of select="concat(@class,'t')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:when>
        <xsl:when test="contains(xhtml:img/@src,'wide')">
            <xsl:attribute name="class">
                <xsl:value-of select="concat(@class,'w')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
    </xsl:choose>
 </xsl:copy>
</xsl:template>

<!--
Remove titlemark, e. g. "Part" wording
-->
<xsl:template match="xhtml:span[@class='titlemark']" />

<!--
Remove crosslinks at the bottom and at the top of the page
-->
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

<!--
Parts only in the main table of contents
-->
<xsl:template match="xhtml:div[@class='tableofcontents']">
  <div>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="child::xhtml:div[@class='partToc']"/>
  </div>
</xsl:template>

<xsl:template match="xhtml:div[@class='partToc']">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()"/>

<!--
Remove empty links
-->
<!--
<xsl:template match="xhtml:a[count(node()) = 0]" />
-->

<!--
Remove empty paragraphs
-->
<xsl:template match="xhtml:p[count(node()) = 0]" />

<!--
<xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)" />
</xsl:template>
-->

</xsl:stylesheet>
