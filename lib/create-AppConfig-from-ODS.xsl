<?xml version="1.0" encoding = "UTF-8"?>
<xsl:stylesheet version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:prof="http://www.tibco.com/xmlns/repo/types/2002" 
      
      xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
      xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
      xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	
      exclude-result-prefixes="prof">

<xsl:output method="xml" indent="yes"/>

	<!-- *********************************************************************** -->
	<!-- ***  PARAMETERS  ****************************************************** -->
	<!-- *********************************************************************** -->

	<!-- spreadsheet sheet name (ignored) -->
	<xsl:param name="SHEET_NAME"/>

	<!-- the content of the first row and column (something line ID or # to mark the start of the property table) -->
	<xsl:param name="VALUE_ID"/>

	<!-- *********************************************************************** -->
	<!-- ***  MAIN  ************************************************************ -->
	<!-- *********************************************************************** -->

	<xsl:template match="/">
		<configuration>
			<properties>
				<xsl:for-each select="/office:document-content/office:body/office:spreadsheet/table:table"><!-- [@table:name=$SHEET_NAME]" -->

					<xsl:variable name="HEADER_ROW" select="table:table-row[count(table:table-cell[text:p=$VALUE_ID])>0][1]"/>

					<xsl:for-each select="$HEADER_ROW/following-sibling::table:table-row[count(@table:number-columns-repeated)=0]">
						<xsl:variable name="ROW" select="."/>

						<xsl:for-each select="$HEADER_ROW/table:table-cell">
							<xsl:variable name="HPOS" select="position()"/>

							<xsl:if test="text:p=$VALUE_ID">			
								<xsl:element name="property">
									<xsl:attribute name="name"><xsl:value-of select="$ROW/table:table-cell[position()=$HPOS + 1]/text:p"/></xsl:attribute>
									<xsl:attribute name="type"><xsl:value-of select="$ROW/table:table-cell[position()=$HPOS + 2]/text:p"/></xsl:attribute>
									<xsl:for-each select="$ROW/table:table-cell">
										<xsl:variable name="POS" select="position()"/>

										<xsl:if test="$POS > $HPOS + 3">
											<xsl:element name="environment">
												<xsl:attribute name="name"><xsl:value-of select="$HEADER_ROW/table:table-cell[$POS]/text:p"/></xsl:attribute>
												<xsl:attribute name="value"><xsl:value-of select="text:p"/></xsl:attribute>
											</xsl:element>
										</xsl:if>
									</xsl:for-each>
								</xsl:element>
							</xsl:if>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:for-each>
			</properties>
		</configuration>
	</xsl:template>
</xsl:stylesheet>