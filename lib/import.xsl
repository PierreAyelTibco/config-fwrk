<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="prof:globalVariables">
    <xsl:copy>
      <xsl:copy-of select="@*"/>

      <xsl:call-template name="m:gv-reconcile">
        <xsl:with-param name="nodes1" select="prof:*"/>
        <xsl:with-param name="appconfig" select="document($app-config)/configuration/properties"/>
        <xsl:with-param name="globalconf" select="document($global-config)/configuration/properties"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="m:gv-reconcile">
    <xsl:param name="nodes1"/>
    <xsl:param name="appconfig"/>
    <xsl:param name="globalconf"/>

    <xsl:for-each select="$nodes1">
		
      <xsl:choose>
        <xsl:when test="$appconfig/property[@name=current()/prof:name]">
        	<xsl:message><xsl:value-of select="concat(prof:name, ': Use value from app config...')"/></xsl:message>
        	
          <xsl:copy>
            <xsl:copy-of select="prof:name"/>
            <xsl:element name="value" namespace="{namespace-uri(.)}">
			 <xsl:choose>
              <xsl:when test="$appconfig/property[@name=current()/prof:name]/environment[@name=$environmentName]/@value">
                <xsl:value-of select="$appconfig/property[@name=current()/prof:name]/environment[@name=$environmentName]/@value"/>
              </xsl:when>
              <xsl:when test="$appconfig/property[@name=current()/prof:name]/environment[@name=$default-environmentName]/@value">
                <xsl:value-of select="$appconfig/property[@name=current()/prof:name]/environment[@name=$default-environmentName]/@value"/>
              </xsl:when>
               </xsl:choose>
            </xsl:element>
            <xsl:copy-of select="prof:deploymentSettable"/>
            <xsl:copy-of select="prof:serviceSettable"/>
            <xsl:copy-of select="prof:type"/>
            <xsl:copy-of select="prof:isOverride"/>
            <xsl:copy-of select="prof:modTime"/>
          </xsl:copy>
        </xsl:when>
		
        <xsl:when test="$globalconf/property[@name=current()/prof:name]">
        	<xsl:message><xsl:value-of select="concat(prof:name, ': Use value from global config...')"/></xsl:message>
        	
          <xsl:copy>
            <xsl:copy-of select="prof:name"/>
            <xsl:element name="value" namespace="{namespace-uri(.)}">
			 <xsl:choose>
              <xsl:when test="$globalconf/property[@name=current()/prof:name]/environment[@name=$environmentName]/@value">
                <xsl:value-of select="$globalconf/property[@name=current()/prof:name]/environment[@name=$environmentName]/@value"/>
              </xsl:when>
              <xsl:when test="$globalconf/property[@name=current()/prof:name]/environment[@name=$default-environmentName]/@value">
                <xsl:value-of select="$globalconf/property[@name=current()/prof:name]/environment[@name=$default-environmentName]/@value"/>
              </xsl:when>
              </xsl:choose>

            </xsl:element>
            <xsl:copy-of select="prof:deploymentSettable"/>
            <xsl:copy-of select="prof:serviceSettable"/>
            <xsl:copy-of select="prof:type"/>
            <xsl:copy-of select="prof:isOverride"/>
            <xsl:copy-of select="prof:modTime"/>
          </xsl:copy>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="current()"/>
        </xsl:otherwise>
      </xsl:choose>
	  
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
