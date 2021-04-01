<?xml version="1.0" encoding = "UTF-8"?>
<xsl:stylesheet version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:prof="http://www.tibco.com/xmlns/repo/types/2002" 
      
      xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
      xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
      xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	
      exclude-result-prefixes="prof">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
	<office:document-content
		xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
		xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
		xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
		xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
		xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
		xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
		xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
		xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" office:version="1.2">
		<office:font-face-decls>
			<style:font-face style:name="Calibri" svg:font-family="Calibri"/>
		</office:font-face-decls>
		<office:automatic-styles>
			<style:style style:name="ce1" style:family="table-cell" style:parent-style-name="Default" style:data-style-name="N0"/>
			    <style:style style:name="ce2" style:family="table-cell" style:parent-style-name="Default" style:data-style-name="N0">
			      <style:table-cell-properties fo:background-color="#5B9BD5"/>
			      <style:text-properties fo:color="#FFFFFF"/>
			    </style:style>
			    <style:style style:name="ce3" style:family="table-cell" style:data-style-name="N0">
			      <style:table-cell-properties style:vertical-align="automatic" fo:background-color="transparent"/>
			    </style:style>
			    <style:style style:name="ce4" style:family="table-cell" style:parent-style-name="Default" style:data-style-name="N0">
			      <style:table-cell-properties style:vertical-align="automatic" fo:wrap-option="wrap" fo:background-color="#5B9BD5"/>
			      <style:text-properties fo:color="#FFFFFF"/>
			    </style:style>
			    <style:style style:name="ce5" style:family="table-cell" style:parent-style-name="Default" style:data-style-name="N0">
			      <style:table-cell-properties style:vertical-align="automatic" fo:wrap-option="wrap"/>
			    </style:style>
			    <style:style style:name="ce6" style:family="table-cell" style:data-style-name="N0">
			      <style:table-cell-properties style:vertical-align="automatic" fo:wrap-option="wrap" fo:background-color="transparent"/>
			    </style:style>
			    <style:style style:name="co1" style:family="table-column">
			      <style:table-column-properties fo:break-before="auto" style:column-width="1.69333333333333cm"/>
			    </style:style>
			    <style:style style:name="co2" style:family="table-column">
			      <style:table-column-properties fo:break-before="auto" style:column-width="13.3614583333333cm"/>
			    </style:style>
			    <style:style style:name="co3" style:family="table-column">
			      <style:table-column-properties fo:break-before="auto" style:column-width="8.75770833333333cm"/>
			    </style:style>
			    <style:style style:name="ro1" style:family="table-row">
			      <style:table-row-properties style:row-height="15pt" style:use-optimal-row-height="true" fo:break-before="auto"/>
			    </style:style>
			    <style:style style:name="ro2" style:family="table-row">
			      <style:table-row-properties style:row-height="30pt" style:use-optimal-row-height="true" fo:break-before="auto"/>
			    </style:style>
			    <style:style style:name="ta1" style:family="table" style:master-page-name="mp1">
			      <style:table-properties table:display="true" style:writing-mode="lr-tb"/>
    			</style:style>
		</office:automatic-styles>
		<office:body>
			<office:spreadsheet>
				<table:calculation-settings table:case-sensitive="false" table:search-criteria-must-apply-to-whole-cell="true" table:use-wildcards="true" table:use-regular-expressions="false" table:automatic-find-labels="false"/>
				<table:table table:name="Sheet1" table:style-name="ta1">
					<table:table-column table:style-name="co1" table:number-columns-repeated="16384" table:default-cell-style-name="ce1"/>
					<table:table-row table:style-name="ro1">
						<table:table-cell office:value-type="string" table:style-name="ce2">
							<text:p>ID</text:p>
						</table:table-cell>
						<table:table-cell office:value-type="string" table:style-name="ce4">
							<text:p>Name</text:p>
						</table:table-cell>
						<table:table-cell office:value-type="string" table:style-name="ce2">
							<text:p>Type</text:p>
						</table:table-cell>
						<table:table-cell office:value-type="string" table:style-name="ce2">
							<text:p>Description</text:p>
						</table:table-cell>
						<table:table-cell office:value-type="string" table:style-name="ce2">
							<text:p>Default</text:p>
						</table:table-cell>
						<table:table-cell office:value-type="string" table:style-name="ce2">
							<text:p>DEV</text:p>
						</table:table-cell>
						<table:table-cell office:value-type="string" table:style-name="ce2">
							<text:p>SIT</text:p>
						</table:table-cell>
						<table:table-cell office:value-type="string" table:style-name="ce2">
							<text:p>UAT</text:p>
						</table:table-cell>
						<table:table-cell office:value-type="string" table:style-name="ce2">
							<text:p>PreProd</text:p>
						</table:table-cell>
						<table:table-cell office:value-type="string" table:style-name="ce2">
							<text:p>PROD</text:p>
						</table:table-cell>
					</table:table-row>

					<xsl:for-each select="/configuration/properties/property">
						<table:table-row table:style-name="ro1">
							<table:table-cell office:value-type="string" table:style-name="ce3">
								<text:p><xsl:value-of select="position()"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce5">
								<text:p><xsl:value-of select="@name"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="cel">
								<text:p></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="environment[@name='DEFAULT']/@value"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="environment[@name='DEV']/@value"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="environment[@name='SIT']/@value"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="environment[@name='UAT']/@value"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="environment[@name='PreProd']/@value"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="environment[@name='PROD']/@value"/></text:p>
							</table:table-cell>
						</table:table-row>
					</xsl:for-each>
				</table:table>
			</office:spreadsheet>
		</office:body>
	</office:document-content>
</xsl:template>
</xsl:stylesheet>