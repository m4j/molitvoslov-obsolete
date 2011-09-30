<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns="http://www.daisy.org/z3986/2005/ncx/"
  exclude-result-prefixes="xhtml xsl">
 
  <xsl:output method="xml" version="1.0" encoding="UTF-8" doctype-public="-//NISO//DTD ncx 2005-1//EN" doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd" indent="yes"/>
 
  <!-- the identity template -->
  <xsl:template match="@*|node()">
      <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

  <xsl:template match="xhtml:div[@class='tableofcontents']">
    <ncx version="2005-1">
        <head xmlns="http://www.daisy.org/z3986/2005/ncx/">
           <meta name="dtb:uid" content="http://www.hxa7241.org/articles/content/epup-guide_hxa7241_2007_1.epub"/>
        </head>
        <docTitle>
            <text>
                <xsl:value-of select = "//xhtml:h2[@class='titleHead']" /> 
            </text>
        </docTitle>
        <navMap>
          <xsl:apply-templates select="xhtml:div"/>
        </navMap>
    </ncx>
  </xsl:template>
 
  <xsl:template match="xhtml:div[@class='partToc']">
<!--
    <xsl:variable name="count">
        <xsl:number/>
    </xsl:variable>
-->
    <navPoint id="">
        <xsl:attribute name = "id">
            <xsl:value-of select = "substring-before(xhtml:a/@href,'#')"/>
        </xsl:attribute>
        <xsl:attribute name = "playOrder">
<!--
            The following expression with count is taken from here
            http://stackoverflow.com/questions/833118/in-xslt-how-do-i-increment-a-global-variable-from-a-different-scope
-->
            <xsl:value-of select = "count(preceding-sibling::xhtml:div[@class='partToc']) + 1"/>
        </xsl:attribute>
        <navLabel>
            <text>
                <xsl:value-of select="normalize-space(.)"/>
            </text>
        </navLabel>
        <content>
            <xsl:attribute name = "src">
                <xsl:value-of select = "substring-before(xhtml:a/@href,'#')"/>
            </xsl:attribute>
        </content>
    </navPoint>
  </xsl:template>
 
</xsl:stylesheet>
