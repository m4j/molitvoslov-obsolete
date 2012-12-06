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

<xsl:param name="document-info-id">AF0BDE17-0E06-48C1-9449-EEF622B3740B</xsl:param>
<xsl:param name="document-info-version">123456789</xsl:param>
<xsl:param name="document-info-date">2006-03-30</xsl:param>
<xsl:param name="document-info-date-value">2006-03-30</xsl:param>
<xsl:param name="cover-image-id">cover</xsl:param>

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
      <genre>religion_rel</genre>
      <author>
        <nickname/>
      </author>
      <book-title>Полный православный молитвослов на всякую потребу</book-title>
      <annotation>
      <p>Полный православный молитвослов создан на основе материалов сайта <a xlink:href="http://www.molitvoslov.com/">http://www.molitvoslov.com</a></p>
      </annotation>
      <coverpage>
      	<image>
       	  <xsl:attribute name = "xlink:href">
	    <xsl:value-of select = "$cover-image-id" />
          </xsl:attribute>
	</image>
      </coverpage>
      <lang>ru</lang>
      <src-lang>ru</src-lang>
    </title-info>
    <document-info>
      <author>
        <nickname/>
      </author>
      <program-used>TeX4ht (http://www.tug.org/tex4ht/), xsltproc (http://xmlsoft.org/)</program-used>
      <date>
        <xsl:attribute name = "value">
            <xsl:value-of select = "$document-info-date-value"/>
        </xsl:attribute>
        <xsl:value-of select = "$document-info-date" />
      </date>
      <src-url>https://github.com/m4j/molitvoslov.com</src-url>
      <id>
        <xsl:value-of select = "$document-info-id" />
      </id>
      <version>
        <xsl:value-of select = "$document-info-version" />
      </version>
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
Remove empty links
-->
<xsl:template 
    match="fb2:a[count(node()) = 0]" />

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
