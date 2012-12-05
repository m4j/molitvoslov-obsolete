<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns="http://www.gribuser.ru/xml/fictionbook/2.0"
  xmlns:fb2="http://www.gribuser.ru/xml/fictionbook/2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="fb2 xsl">
  
  <xsl:strip-space  elements="fb2:*"/>
  <xsl:preserve-space elements="fb2:p"/>

<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

<!-- the identity template -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!--
Populate the description
-->
<xsl:template match="fb2:description">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
    <title-info>
      <genre>religion</genre>
      <author/>
      <book-title>Полный православный молитвослов</book-title>
      <annotation>
        <p>ANNOTATION</p>
      </annotation>
      <coverpage><image xlink:href="#cover"/></coverpage>
      <lang>ru</lang>
    </title-info>
    <document-info>
      <author>
        <nickname>molitvoslov.com</nickname>
        <home-page>http://www.molitvoslov.com/</home-page>
        <email>admin@molitvoslov.com</email>
      </author>
      <program-used>TeX4ht (http://www.tug.org/tex4ht/)</program-used>
      <date value="2006-03-30">DATE</date>
      <src-url>http://www.molitvoslov.com/</src-url>
      <version>VERSION</version>
    </document-info>
    <publish-info/>
  </xsl:copy>
</xsl:template>

<!-- Remove meta elements -->
<xsl:template match="fb2:meta" />

<!--
Remove paragraphs containing only whitespace or non-breaking space
match if only one node and that node is text and whitespace
-->
<xsl:template 
    match="fb2:p[count(node()) = 1 and child::node()[1][self::text() and normalize-space(.) = '']]" />
<!--
Remove paragraphs containing only whitespace or non-breaking space
match if only one node and that node is text and whitespace
-->
<xsl:template 
    match="fb2:v[count(node()) = 1 and child::node()[1][self::text() and normalize-space(.) = '']]" />

<!--
Remove comments
-->
<xsl:template match="comment()"/>

<!-- remove span elements, but not their contents -->
<xsl:template match="fb2:span">
    <xsl:apply-templates select="node()"/>
</xsl:template>

</xsl:stylesheet>
