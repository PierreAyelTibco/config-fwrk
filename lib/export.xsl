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

	<!-- full path of input profile file -->
	<xsl:param name="PROFILE"/>

	<!-- name of environment column -->
	<xsl:param name="ENV"/>
	
	<!-- spreadsheet sheet name -->
	<xsl:param name="SHEET_NAME"/>
	
	<!-- the content of the first row and column (something line ID or # to mark the start of the property table) -->
	<xsl:param name="VALUE_ID"/>
	
	<xsl:param name="VALUE_ENVIRONMENT"/>
	<xsl:param name="VALUE_DESCRIPTION"/>
	
	<!-- optional: BW6 module.bwm file from app folder -->
	<xsl:param name="MODULE_CONFIG"/>
	
	<xsl:param name="DATE"/>
	<xsl:param name="USERNAME"/>
	
	<!-- *********************************************************************** -->
	<!-- ***  Default template: COPY ALL  ************************************** -->
	<!-- *********************************************************************** -->

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
	
	<!-- *********************************************************************** -->
	<!-- ***  Revisions Sheet  ************************************************* -->
	<!-- *********************************************************************** -->

	<xsl:template match="table:table[@table:name='Revisions']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			
			<!-- header row for revision list -->
			<xsl:variable name="HEADER_ROW" select="table:table-row[count(table:table-cell[text:p='Version'])>0][1]"/>
			<!-- first revision row to use as template -->
			<xsl:variable name="FIRST_ROW" select="$HEADER_ROW/following-sibling::table:table-row[1]"/>
			
			<!-- copy everything before header row -->
			<xsl:copy-of select="$HEADER_ROW/preceding-sibling::*"/>
			
			<!-- copy header row -->
			<xsl:copy-of select="$HEADER_ROW"/>
			
			<!-- copy every revision -->
			<xsl:copy-of select="$HEADER_ROW/following-sibling::table:table-row[count(table:table-cell/text:p)>0]"/>
		
			<!-- add our own revision row -->
			<!-- use for-each to copy first row element and attributes -->
			<xsl:for-each select="$FIRST_ROW">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
				
					<xsl:for-each select="table:table-cell">
						<xsl:variable name="POS" select="position()"/>
						
						<xsl:choose>
							<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Version'">
								<xsl:copy-of select="."/>
							</xsl:when>
							<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Date'">
								<table:table-cell office:value-type="string" table:style-name="{@table:style-name}">
									<text:p><xsl:value-of select="$DATE"/></text:p>
								</table:table-cell>
							</xsl:when>
							<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Author'">
								<table:table-cell office:value-type="string" table:style-name="{@table:style-name}">
									<text:p><xsl:value-of select="$USERNAME"/></text:p>
								</table:table-cell>
							</xsl:when>
							<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Description'">
								<table:table-cell office:value-type="string" table:style-name="{@table:style-name}">
									<text:p><xsl:value-of select="concat('Updated with file ', $PROFILE)"/></text:p>
								</table:table-cell>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:copy>
			</xsl:for-each>
			
			<!-- add subsequent rows if any -->
			<!-- xsl:copy-of select="$HEADER_ROW/following-sibling::table:table-row[count(table:table-cell/text:p)=0]"/ -->
		</xsl:copy>
	</xsl:template>
	
	<!-- *********************************************************************** -->
	<!-- ***  Configuration Sheet  ********************************************* -->
	<!-- *********************************************************************** -->
	
	<xsl:template match="table:table[@table:name=$SHEET_NAME]" xmlns:sca="http://www.osoa.org/xmlns/sca/1.0">
		
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			
			<!-- header row from input ODS -->
			<!-- first header line is first row with column 'ID' -->
			<xsl:variable name="HEADER_ROW" select="table:table-row[count(table:table-cell[text:p=$VALUE_ID]) > 0][1]"/>
			
			<xsl:variable name="COL_NAME_POS" select="count($HEADER_ROW/table:table-cell[text:p='Name']/preceding-sibling::table:table-cell)+1"/>
			
			<!-- first row -->
			<xsl:variable name="FIRST_ROW" select="$HEADER_ROW/following-sibling::table:table-row[1]"/>

			<!-- does the profile column exist? -->
			<xsl:variable name="HAS_ENV" select="count($HEADER_ROW/table:table-cell[text:p=$ENV])=1"/>

			<!-- create rows before header -->
			<xsl:copy-of select="$HEADER_ROW/preceding-sibling::*"/>

			<!-- create the output header row -->  
			<xsl:for-each select="$HEADER_ROW">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					
					<xsl:variable name="ID_COL" select="table:table-cell[text:p=$VALUE_ID]"/>
					
					<xsl:copy-of select="$ID_COL/preceding-sibling::*"/>
					<xsl:copy-of select="$ID_COL"/>
					<xsl:copy-of select="$ID_COL/following-sibling::table:table-cell[text:p!='' and text:p!=$VALUE_ENVIRONMENT]"/>
					<xsl:if test="$HAS_ENV != 'true'">
						<xsl:for-each select="table:table-cell[text:p!=''][position()=last()]">
							<xsl:copy>
								<xsl:apply-templates select="@*"/>
								<text:p><xsl:value-of select="$ENV"/></text:p>
							</xsl:copy>
						</xsl:for-each>
					</xsl:if>
				</xsl:copy>
			</xsl:for-each>

			<!-- create the output rows -->

			<xsl:variable name="GVARS" select="document($PROFILE)/prof:repository/prof:globalVariables/prof:globalVariable"/>
			
			<xsl:variable name="BW_CODE_PROPERTIES" select="document($MODULE_CONFIG)/sca:composite"/>

			<!-- update existing rows -->
			<xsl:variable name="EXISTING_ROWS" select="$HEADER_ROW/following-sibling::table:table-row[count(table:table-cell[text:p!=''])>0]"/>
			
			<xsl:for-each select="$EXISTING_ROWS">
				<xsl:variable name="NAME" select="table:table-cell[$COL_NAME_POS]/text:p"/>

				<xsl:choose>
					<xsl:when test="$NAME=''"/>
					<xsl:when test="count($GVARS[prof:name = $NAME]) = 1 and $HAS_ENV = 'true'">
						<!-- row has global variable from profile -->
						<xsl:variable name="GVALUE" select="$GVARS[prof:name = $NAME]/prof:value"/>

						<xsl:copy>
							<xsl:apply-templates select="@*"/>

							<xsl:for-each select="table:table-cell">
								<xsl:variable name="POS" select="position()"/>

								<xsl:choose>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_ID">
										<xsl:copy-of select="."/>
									</xsl:when>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Name'">
										<xsl:copy-of select="."/>
									</xsl:when>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Type'">
										<xsl:copy-of select="."/>
									</xsl:when>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_DESCRIPTION">
										<xsl:copy-of select="."/>
									</xsl:when>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$ENV">
										<xsl:copy>
											<xsl:apply-templates select="@*"/>
											<text:p><xsl:value-of select="$GVALUE"/></text:p>
										</xsl:copy>
									</xsl:when>
									<xsl:when test="count(@table:number-rows-repeated)>0"/>
									<xsl:otherwise>
										<xsl:copy-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:copy>
					</xsl:when>
					<xsl:when test="count($GVARS[prof:name = $NAME]) = 1">
						<!-- row has global variable from profile -->
						<xsl:variable name="GVALUE" select="$GVARS[prof:name = $NAME]/prof:value"/>

						<xsl:copy>
							<xsl:apply-templates select="@*"/>

							<xsl:for-each select="table:table-cell">
								<xsl:variable name="POS" select="position()"/>

								<xsl:choose>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_ID">
										<xsl:copy-of select="."/>
									</xsl:when>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Name'">
										<xsl:copy-of select="."/>
									</xsl:when>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Type'">
										<xsl:copy-of select="."/>
									</xsl:when>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_DESCRIPTION">
										<xsl:copy-of select="."/>
									</xsl:when>
									<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_ENVIRONMENT">
										<xsl:copy>
											<xsl:apply-templates select="@*"/>
											<text:p><xsl:value-of select="$GVALUE"/></text:p>
										</xsl:copy>
									</xsl:when>
									<xsl:when test="count(@table:number-columns-repeated)>0"/>
									<xsl:otherwise>
										<xsl:copy-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
							
							<xsl:if test="count($HEADER_ROW/table:table-cell[text:p=$VALUE_ENVIRONMENT])=0">
								<xsl:for-each select="table:table-cell">
									<xsl:variable name="POS" select="position()"/>

									<xsl:if test="$HEADER_ROW/table:table-cell[position()=($POS -1)]/text:p=$VALUE_DESCRIPTION">
										<xsl:copy>
											<xsl:apply-templates select="@*"/>
											<text:p><xsl:value-of select="$GVALUE"/></text:p>
										</xsl:copy>
									</xsl:if>
								</xsl:for-each>
							</xsl:if>
						</xsl:copy>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy>
							<xsl:apply-templates select="@*"/>
							<xsl:copy-of select="*[count(@table:number-columns-repeated)=0]"/>
						</xsl:copy>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>

			<!-- create new rows -->
			<xsl:variable name="THIS" select="."/>
			<xsl:for-each select="$GVARS">
				<xsl:sort select="prof:name"/>
			
				<xsl:variable name="GNAME" select="prof:name"/>
				<xsl:variable name="GVALUE" select="prof:value"/>
				<xsl:variable name="GTYPE" select="prof:type"/>
				<xsl:variable name="ID" select="count(EXISTING_ROWS) + position()"/>

				<xsl:variable name="SHORT_NAME" select="concat('/', substring-after($GNAME, '///'))"/>
				<xsl:variable name="GDESCRIPTION" select="$BW_CODE_PROPERTIES/sca:property[@name=$SHORT_NAME]/@description"/>

				<xsl:choose>
					<xsl:when test="contains(prof:name,'//BW.DEPLOYMENTUNIT.TYPE')"/>
					<xsl:when test="contains(prof:name,'//BW.DEPLOYMENTUNIT.NAME')"/>
					<xsl:when test="contains(prof:name,'//BW.APPNODE.NAME')"/>
					<xsl:when test="contains(prof:name,'//BW.HOST.NAME')"/>
					<xsl:when test="contains(prof:name,'//BW.DOMAIN.NAME')"/>
					<xsl:when test="contains(prof:name,'//BW.APPSPACE.NAME')"/>
					<xsl:when test="contains(prof:name,'//BW.MODULE.VERSION')"/>
					<xsl:when test="contains(prof:name,'//BW.DEPLOYMENTUNIT.VERSION')"/>
					<xsl:when test="contains(prof:name,'//BW.MODULE.NAME')"/>
					<xsl:when test="count($THIS/table:table-row[table:table-cell[$COL_NAME_POS]/text:p = $GNAME]) = 1"/>
					<xsl:when test="$HAS_ENV = 'true'">
						<xsl:for-each select="$FIRST_ROW">
							<xsl:copy>
								<xsl:apply-templates select="@*"/>
								
								<xsl:for-each select="table:table-cell">
									<xsl:variable name="POS" select="position()"/>
									
									<xsl:choose>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_ID">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>		
												<text:p><xsl:value-of select="$ID"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Name'">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>
												<text:p><xsl:value-of select="$GNAME"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Type'">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>
												<text:p><xsl:value-of select="$GTYPE"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_DESCRIPTION">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>
												<text:p><xsl:value-of select="$GDESCRIPTION"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$ENV">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>
												<text:p><xsl:value-of select="$GVALUE"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="count(@table:number-columns-repeated)>0"/>
										<xsl:otherwise>
											<xsl:copy-of select="."/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</xsl:copy>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$FIRST_ROW">
							<xsl:copy>
								<xsl:apply-templates select="@*"/>
								
								<xsl:for-each select="table:table-cell">
									<xsl:variable name="POS" select="position()"/>

									<xsl:choose>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_ID">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>		
												<text:p><xsl:value-of select="$ID"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Name'">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>
												<text:p><xsl:value-of select="$GNAME"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p='Type'">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>
												<text:p><xsl:value-of select="$GTYPE"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_DESCRIPTION">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>
												<text:p><xsl:value-of select="$GDESCRIPTION"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="$HEADER_ROW/table:table-cell[$POS]/text:p=$VALUE_ENVIRONMENT">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>
												<text:p><xsl:value-of select="$GVALUE"/></text:p>
											</xsl:copy>
										</xsl:when>
										<xsl:when test="count(@table:number-columns-repeated)>0"/>
										<xsl:otherwise>
											<xsl:copy-of select="."/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
								
								<xsl:if test="count($HEADER_ROW/table:table-cell[text:p=$VALUE_ENVIRONMENT])=0">
									<xsl:for-each select="table:table-cell">
										<xsl:variable name="POS" select="position()"/>

										<xsl:if test="$HEADER_ROW/table:table-cell[position()=($POS -1)]/text:p=$VALUE_DESCRIPTION">
											<xsl:copy>
												<xsl:apply-templates select="@*"/>
												<text:p><xsl:value-of select="$GVALUE"/></text:p>
											</xsl:copy>
										</xsl:if>
									</xsl:for-each>
								</xsl:if>
							</xsl:copy>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>