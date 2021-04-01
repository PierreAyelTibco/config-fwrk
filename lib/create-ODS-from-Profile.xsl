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

	<!-- name of input profile file without directory name nor extension -->
	<xsl:param name="PROFILE_NAME_NOEXT"/>
	
	<!-- spreadsheet sheet name -->
	<xsl:param name="SHEET_NAME"/>
	
	<!-- *********************************************************************** -->
	<!-- ***  Default template: COPY ALL  ************************************** -->
	<!-- *********************************************************************** -->

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
	
	<!-- *********************************************************************** -->
	<!-- ***  COPY ALL INPUT TABLE-CELLS  ************************************** -->
	<!-- *********************************************************************** -->

	<xsl:template name="copy-columns">
		<xsl:for-each select="*[local-name()='table-cell' and count(@*[local-name()='number-columns-repeated'])=0]">
			<xsl:copy>
				<xsl:apply-templates select="@* | node()" />
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>
	
	<!-- *********************************************************************** -->
	<!-- ***  MAIN  ************************************************************ -->
	<!-- *********************************************************************** -->

	<xsl:template match="table:table[@table:name=$SHEET_NAME]">
		<table:table table:name="$SHEET_NAME" table:style-name="ta1">
			<table:table-column table:style-name="co1" table:default-cell-style-name="ce3"/>
			<table:table-column table:style-name="co2" table:default-cell-style-name="ce3"/>
			<table:table-column table:style-name="co1" table:default-cell-style-name="ce3"/>
			<table:table-column table:style-name="co1" table:default-cell-style-name="ce3"/>
			<table:table-column table:style-name="co3" table:number-columns-repeated="256" table:default-cell-style-name="ce3"/>

			<!-- header row from input ODS -->
			<xsl:variable name="HEADER" select="*[local-name()='table-row'][1]"/>

			<!-- does the profile column exists? -->
			<xsl:variable name="HAS_ENV" select="count($HEADER/*[local-name()='table-cell' and *[local-name()='p']=$PROFILE_NAME_NOEXT])=1"/>

			<!-- header columns -->        
			<table:table-row table:style-name="ro1">
				<xsl:for-each select="$HEADER">
					<xsl:call-template name="copy-columns"/>
				</xsl:for-each>
				<xsl:if test="$HAS_ENV != 'true'">
					<table:table-cell office:value-type="string" table:style-name="ce2">
						<text:p><xsl:value-of select="$PROFILE_NAME_NOEXT"/></text:p>
					</table:table-cell>
				</xsl:if>
			</table:table-row>

			<!-- rows -->

			<xsl:variable name="GVARS" select="document($PROFILE)/prof:repository/prof:globalVariables/prof:globalVariable"/>

			<!-- update existing rows -->
			<xsl:for-each select="*[local-name()='table-row'][position() > 1]">
				<xsl:variable name="NAME" select="*[local-name()='table-cell'][2]/*[local-name()='p']"/>

				<xsl:if test="$NAME != ''">
				<xsl:copy>
					<xsl:choose>
						<xsl:when test="count($GVARS[prof:name = $NAME]) = 1">
							<!-- row has global variable from profile -->

							<xsl:choose>
								<xsl:when test="$HAS_ENV != 'true'">
									<xsl:call-template name="copy-columns"/>
									<table:table-cell office:value-type="string" table:style-name="ce5">
										<text:p><xsl:value-of select="$GVARS[prof:name = $NAME]/prof:value"/></text:p>
									</table:table-cell>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="*[local-name()='table-cell' and count(@*[local-name()='number-columns-repeated'])=0]">
										<xsl:variable name="POS" select="position()"/>
										<xsl:choose>
											<xsl:when test="$HEADER/*[local-name()='table-cell'][$POS]/*[local-name()='p'] = $PROFILE_NAME_NOEXT">
												<!-- //TODO warn when overidding value -->
												<table:table-cell office:value-type="string" table:style-name="ce5">
													<text:p><xsl:value-of select="$GVARS[prof:name = $NAME]/prof:value"/></text:p>
												</table:table-cell>
											</xsl:when>
											<xsl:otherwise>
												<xsl:copy>
													<xsl:apply-templates select="@* | node()" />
												</xsl:copy>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="copy-columns"/>
							<xsl:if test="$HAS_ENV != 'true'">
								<table:table-cell office:value-type="string" table:style-name="ce5">
									<text:p/>
								</table:table-cell>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:copy>
				</xsl:if>
			</xsl:for-each>

			<!-- create new rows -->
			<xsl:variable name="THIS" select="."/>
			<xsl:for-each select="$GVARS">
				<xsl:variable name="GNAME" select="prof:name"/>
				<xsl:variable name="GVALUE" select="prof:value"/>

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
					<xsl:when test="count($THIS/*[local-name()='table-row'][position() > 1 and *[local-name()='table-cell'][2]/*[local-name()='p'] = $GNAME]) = 1"/>
					<xsl:when test="$HAS_ENV = 'true'">
						<table:table-row table:style-name="ro1">
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="position()"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce5">
								<text:p><xsl:value-of select="prof:name"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="prof:type"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p></text:p>
							</table:table-cell>
							<xsl:for-each select="$HEADER/*[local-name()='table-cell' and position() > 4 and count(@*[local-name()='number-columns-repeated'])=0]">
								<table:table-cell office:value-type="string" table:style-name="ce5">
									<text:p><xsl:value-of select="$GVALUE"/></text:p>
								</table:table-cell>
							</xsl:for-each>
						</table:table-row>
					</xsl:when>
					<xsl:otherwise>
						<table:table-row table:style-name="ro1">
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="position()"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce5">
								<text:p><xsl:value-of select="prof:name"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p><xsl:value-of select="prof:type"/></text:p>
							</table:table-cell>
							<table:table-cell office:value-type="string" table:style-name="ce1">
								<text:p></text:p>
							</table:table-cell>
							<xsl:for-each select="$HEADER/*[local-name()='table-cell' and position() > 4 and count(@*[local-name()='number-columns-repeated'])=0]">
								<table:table-cell office:value-type="string" table:style-name="ce5">
									<text:p/>
								</table:table-cell>
							</xsl:for-each>
							<table:table-cell office:value-type="string" table:style-name="ce5">
								<text:p><xsl:value-of select="$GVALUE"/></text:p>
							</table:table-cell>
						</table:table-row>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</table:table>
	</xsl:template>
</xsl:stylesheet>