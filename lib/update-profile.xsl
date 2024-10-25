<?xml version="1.0" ?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:prof="http://www.tibco.com/xmlns/repo/types/2002"
	xmlns:m="http://www.tibco.com/xmlns/ApplicationManagement/merge"
	exclude-result-prefixes="m">
	
	<xsl:output method="xml" indent="yes"/>
  
	<xsl:param name="app-config" />
	<xsl:param name="global-config" />
	<xsl:param name="environmentName" />
	<xsl:param name="default-environmentName" />

	<xsl:template match="/">
		<xsl:if test="string($app-config)=''">
			<xsl:message terminate="yes">
				<xsl:text>No input file specified (parameter 'app-config')</xsl:text>
			</xsl:message>
		</xsl:if>

		<xsl:if test="string($global-config)=''">
			<xsl:message terminate="yes">
				<xsl:text>No input file specified (parameter 'global-config')</xsl:text>
			</xsl:message>
		</xsl:if>

		<xsl:if test="string($environmentName)=''">
			<xsl:message terminate="yes">
				<xsl:text>No environmentName specified (parameter 'environmentName')</xsl:text>
			</xsl:message>
		</xsl:if>
		
		<xsl:if test="string($default-environmentName)=''">
			<xsl:message terminate="yes">
				<xsl:text>No default-environmentName specified (parameter 'default-environmentName')</xsl:text>
			</xsl:message>
		</xsl:if>

		<xsl:message>
			<xsl:text>Merging input with '</xsl:text>
			<xsl:value-of select="$app-config"/>
			<xsl:text>'</xsl:text>
		</xsl:message>

		<xsl:message>
			<xsl:text>Merging input with '</xsl:text>
			<xsl:value-of select="$global-config"/>
			<xsl:text>'</xsl:text>
		</xsl:message>

		<xsl:copy>
		  <xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:variable name="appconfig" select="document($app-config)/configuration/properties"/>
	<xsl:variable name="globalconf" select="document($global-config)/configuration/properties"/>

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="prof:globalVariables">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			
			<xsl:apply-templates select="prof:globalVariable">
				<xsl:sort select="prof:name"/>
				<!-- TODO: sorting by folder name would match better module properties order in Designer -->
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="prof:globalVariable">

		<xsl:variable name="ACN" select="$appconfig/property[@name=current()/prof:name]"/>
		<xsl:variable name="GCN" select="$globalconf/property[@name=current()/prof:name]"/>

		<xsl:choose>
			<xsl:when test="$ACN">
			
				<xsl:if test="count[$ACN] > 1">
					<xsl:message><xsl:value-of select="concat(prof:name, 'is configured several times, we will use the last one...')"/></xsl:message>
				</xsl:if>

				<xsl:variable name="VALUE">
					<xsl:choose>
						<xsl:when test="$ACN[last()]/environment[@name=$environmentName]/@value">
							<xsl:value-of select="$ACN/environment[@name=$environmentName]/@value"/>
						</xsl:when>
						<xsl:when test="$ACN[last()]/environment[@name=$default-environmentName]/@value">
							<xsl:value-of select="$ACN/environment[@name=$default-environmentName]/@value"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:message>
					<xsl:choose>
						<xsl:when test="$ACN/@type='Password'">
							<xsl:value-of select="concat(prof:name, ': Use value from app config...')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(prof:name, ': Use value from app config...: ', $VALUE)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:message>

				<xsl:copy>
					<xsl:copy-of select="prof:name"/>
					<xsl:element name="value" namespace="{namespace-uri(.)}">
						<xsl:value-of select="$VALUE"/>
					</xsl:element>
					<xsl:copy-of select="prof:deploymentSettable"/>
					<xsl:copy-of select="prof:serviceSettable"/>
					<xsl:copy-of select="prof:type"/>
					<xsl:copy-of select="prof:isOverride"/>
					<xsl:if test="prof:modTime"><xsl:copy-of select="prof:modTime"/></xsl:if>
					<xsl:if test="prof:useLookupValue"><xsl:copy-of select="prof:useLookupValue"/></xsl:if>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$GCN">

				<xsl:if test="count[$GCN] > 1">
					<xsl:message><xsl:value-of select="concat(prof:name, 'is configured several times, we will use the last one...')"/></xsl:message>
				</xsl:if>
				
				<xsl:variable name="VALUE">
					<xsl:choose>
						<xsl:when test="$GCN[last()]/environment[@name=$environmentName]/@value">
							<xsl:value-of select="$GCN/environment[@name=$environmentName]/@value"/>
						</xsl:when>
						<xsl:when test="$GCN[last()]/environment[@name=$default-environmentName]/@value">
							<xsl:value-of select="$GCN/environment[@name=$default-environmentName]/@value"/>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
			
				<xsl:message>
					<xsl:choose>
						<xsl:when test="$GCN/@type='Password'">
							<xsl:value-of select="concat(prof:name, ': Use value from global config...')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(prof:name, ': Use value from global config...: ', $VALUE)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:message>

				<xsl:copy>
					<xsl:copy-of select="prof:name"/>
					<xsl:element name="value" namespace="{namespace-uri(.)}">
						<xsl:value-of select="$VALUE"/>
					</xsl:element>
					<xsl:copy-of select="prof:deploymentSettable"/>
					<xsl:copy-of select="prof:serviceSettable"/>
					<xsl:copy-of select="prof:type"/>
					<xsl:copy-of select="prof:isOverride"/>
					<xsl:if test="prof:modTime"><xsl:copy-of select="prof:modTime"/></xsl:if>
					<xsl:if test="prof:useLookupValue"><xsl:copy-of select="prof:useLookupValue"/></xsl:if>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="prof:name"/>
					<xsl:copy-of select="prof:value"/>
					<xsl:copy-of select="prof:deploymentSettable"/>
					<xsl:copy-of select="prof:serviceSettable"/>
					<xsl:copy-of select="prof:type"/>
					<xsl:copy-of select="prof:isOverride"/>
					<xsl:if test="prof:modTime"><xsl:copy-of select="prof:modTime"/></xsl:if>
					<xsl:if test="prof:useLookupValue"><xsl:copy-of select="prof:useLookupValue"/></xsl:if>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
