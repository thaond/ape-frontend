<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns='http://www.w3.org/1999/xhtml' xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ape="http://www.archivesportaleurope.eu/xslt/extensions"
	exclude-result-prefixes="xlink xlink xsi eac ape">
	
	<xsl:output method="html" indent="yes" version="4.0"
		encoding="UTF-8"/>
	<xsl:param name="eaccontent.extref.prefix"/>
	<xsl:param name="language.selected"/>
	<xsl:param name="lang.navigator"/>
	<xsl:param name="aiCodeUrl"/>
	<xsl:param name="eacUrlBase"/>
	<xsl:param name="eadUrl"/>
	<xsl:param name="searchTerms"/>
	<xsl:param name="translationLanguage"/>

	<xsl:variable name="language.default" select="'eng'"/>

	<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    
    <xsl:include href="dateOrDateRange.xsl"/>
	
	<xsl:template match="text()" mode="other">
		<xsl:value-of select="fn:normalize-space(ape:highlight(., 'other'))" disable-output-escaping="yes" />
	</xsl:template>
	
	<xsl:template match="/">
		<xsl:variable name="existDates" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:existDates"/>
		<xsl:variable name="entityType" select="./eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType"/>
		<xsl:variable name="iconType">
   			<xsl:choose>
	   			<xsl:when test="$entityType='person'">
				   <xsl:value-of select="'iconPerson'"/>
				</xsl:when>
				<xsl:when test="$entityType='corporateBody'">
				   <xsl:value-of select="'iconCorporateBody'"/>
				</xsl:when>
				<xsl:when test="$entityType='family'">
				   <xsl:value-of select="'iconFamily'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''"/>
				</xsl:otherwise>
			</xsl:choose>
   		</xsl:variable>
   		
   		<!-- Set the variable which checks if at least one of the links in
				 "<citation>" element inside "<places>" is a valid
				 one. -->
			<xsl:variable name="validHrefLinkPlaces">
				<xsl:choose>
					<xsl:when test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places//eac:citation[@xlink:href != '']">
						<xsl:value-of select="ape:checkHrefValue(string-join(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places//eac:citation/@xlink:href, '_HREF_SEPARATOR_'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- variable of location -->
			<xsl:variable name="location" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places"/>
			<xsl:variable name="langLocation">
			 	<xsl:variable name="lang" select="$location//@xml:lang"/>
			    <xsl:variable name="listLang" select="string-join($lang,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelected" select="($location//eac:placeRole[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or $location//eac:placeEntry[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or $location//eac:date[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or $location//eac:fromDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != '' 
							or $location//eac:toDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or $location//eac:citation[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ($location//eac:citation[@xlink:href != '' and @xml:lang=$language.selected]
								and $validHrefLinkPlaces = 'true')
							or $location//eac:citation[@xlink:title != '' and @xml:lang=$language.selected]
							or $location//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or $location//eac:addressLine[@xml:lang=$language.selected]/text() != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigator" select="($location//eac:placeRole[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or $location//eac:placeEntry[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or $location//eac:date[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or $location//eac:fromDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '' 
							or $location//eac:toDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or $location//eac:citation[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ($location//eac:citation[@xlink:href != '' and @xml:lang=$lang.navigator]
								and $validHrefLinkPlaces = 'true')
							or $location//eac:citation[@xlink:title != '' and @xml:lang=$lang.navigator]
							or $location//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or $location//eac:addressLine[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefault" select="($location//eac:placeRole[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or $location//eac:placeEntry[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or $location//eac:date[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or $location//eac:fromDate[@xml:lang=$language.default]/fn:normalize-space(text()) != '' 
							or $location//eac:toDate[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or $location//eac:citation[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ($location//eac:citation[@xlink:href != '' and @xml:lang=$language.default]
								and $validHrefLinkPlaces = 'true')
							or $location//eac:citation[@xlink:title != '' and @xml:lang=$language.default]
							or $location//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or $location//eac:addressLine[@xml:lang=$language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLang" select="($location//eac:placeRole[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or $location//eac:placeEntry[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or $location//eac:date[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or $location//eac:fromDate[not(@xml:lang)]/fn:normalize-space(text()) != '' 
							or $location//eac:toDate[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or $location//eac:citation[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ($location//eac:citation[@xlink:href != '' and not(@xml:lang)]
								and $validHrefLinkPlaces = 'true')
							or $location//eac:citation[@xlink:title != '' and not(@xml:lang)]
							or $location//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or $location//eac:addressLine[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLang,$language.selected) and $conditionLangSelected">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$lang.navigator) and $conditionLangNavigator">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$language.default) and $conditionLangDefault">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLang">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLang,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
			</xsl:variable>
			
		<h1 class="titleproperEac {$iconType}">
		    <!-- nameEntry -->
	      	<xsl:call-template name="namePriorisation">
	      		<xsl:with-param name="list" select="//eac:nameEntry"/>
		    </xsl:call-template> 
			<!-- dates -->
			<xsl:if test="$existDates/eac:date/text() or $existDates/eac:dateRange/eac:fromDate or $existDates/eac:dateRange/eac:toDate or $existDates/eac:dateSet/eac:date/text() or $existDates/eac:dateSet/eac:dateRange/eac:fromDate or $existDates/eac:dateSet/eac:dateRange/eac:toDate">
				<!-- when there are only 1 dateSet -->
				<xsl:if test="$existDates/eac:dateSet and (($existDates/eac:dateSet/eac:dateRange/eac:fromDate or $existDates/eac:dateSet/eac:dateRange/eac:toDate) or ($existDates/eac:dateSet/eac:date and $existDates/eac:dateSet/eac:date/text()))">
					<xsl:apply-templates select="$existDates/eac:dateSet">
						<xsl:with-param name="mode" select="'default'" />
						<xsl:with-param name="langNode" select="''"/>
					</xsl:apply-templates>
				</xsl:if>
				<!-- when there are only 1 dateRange -->
				<xsl:if test="$existDates/eac:dateRange and ($existDates/eac:dateRange/eac:fromDate or $existDates/eac:dateRange/eac:toDate)">
					<xsl:text> (</xsl:text>
						<span class="nameEtryDates">
							<xsl:apply-templates select="$existDates/eac:dateRange"/>
						</span>
					<xsl:text>)</xsl:text>
				</xsl:if>
				<!-- when there are only 1 date -->
				<xsl:if test="$existDates/eac:date and $existDates/eac:date/text()">
					<xsl:text> (</xsl:text>
						<span class="nameEtryDates">
							<xsl:apply-templates select="$existDates/eac:date"/>
						</span>
					<xsl:text>)</xsl:text>
				</xsl:if>
				<span class="existDates hidden">
					<xsl:apply-templates select="$existDates"/>
				</span>
			</xsl:if>
		<!-- 	<xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType/text()">
				<xsl:text> </xsl:text>
				<span id="entityType">
					<xsl:if test="$entityType='person'">
					   <xsl:value-of select="ape:resource('eaccpf.portal.person')"/>
					</xsl:if>
					<xsl:if test="$entityType='corporateBody'">
					   <xsl:value-of select="ape:resource('eaccpf.portal.corporateBody')"/>
					</xsl:if>
					<xsl:if test="$entityType='family'">
					   <xsl:value-of select="ape:resource('eaccpf.portal.family')"/>
					</xsl:if>
				</span>
			</xsl:if>-->
		</h1>
		<div id="details">	
			<!-- Dates -->
			<!-- dateRange fromDate -->
			<xsl:if test="$existDates/eac:dateRange/eac:fromDate/text() or $existDates/eac:dateSet/eac:dateRange/eac:fromDate/text() or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='birth']/text()
			              or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='foundation']/text()">
				<div class="row">
						<div class="leftcolumn">
							<h2>
								<xsl:if test="$entityType = 'person' or $entityType = 'family'">
									<xsl:value-of select="ape:resource('eaccpf.portal.birthDate')"/>
								</xsl:if>
								<xsl:if test="$entityType = 'corporateBody'">
									<xsl:value-of select="ape:resource('eaccpf.portal.foundationDate')"/>
								</xsl:if>	
								<xsl:text>:</xsl:text>
							</h2>	
						</div>
						<div class="rightcolumn">
							<xsl:if test="$existDates/eac:dateRange">
									<xsl:call-template name="dateUnknow">
										<xsl:with-param name="dateUnknow" select="$existDates/eac:dateRange/eac:fromDate"/>
									</xsl:call-template>
								</xsl:if> 
								<xsl:if test="$existDates/eac:dateSet/eac:dateRange/eac:fromDate">
									<xsl:call-template name="multilanguageOneDate">
										<xsl:with-param name="list" select="$existDates/eac:dateSet/eac:dateRange/eac:fromDate"/>
									</xsl:call-template>	
							</xsl:if>
							<xsl:if test="$entityType = 'person' or $entityType = 'family'">
								<xsl:if test="($langLocation='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='birth'][not(@xml:lang)]/text()) 
									 or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='birth'][@xml:lang=$langLocation]/text() 
					                 or ($searchTerms!='' and 
					                 	(
						                 	./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='birth'][@xml:lang != $langLocation][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
							      		 	or (
							      		 		$langLocation!='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='birth'][not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
						      		 		)
						      		 	)
						      		 )
								">
									<xsl:text>, </xsl:text>
									<xsl:call-template name="showDetailsPlaceEntry">
										<xsl:with-param name="list" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='birth']"/>
										<xsl:with-param name="langNode" select="$langLocation"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:if>
							<xsl:if test="$entityType = 'corporateBody'">
								<xsl:if test="($langLocation='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='foundation'][not(@xml:lang)]/text()) 
									 or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='foundation'][@xml:lang=$langLocation]/text() 
					                 or ($searchTerms!='' and 
					                 	(
						                 	./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='foundation'][@xml:lang != $langLocation][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
							      		 	or (
							      		 		$langLocation!='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='foundation'][not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
						      		 		)
						      		 	)
						      		 )
								">
									<xsl:text>, </xsl:text>
									<xsl:call-template name="showDetailsPlaceEntry">
										<xsl:with-param name="list" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='foundation']"/>
										<xsl:with-param name="langNode" select="$langLocation"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:if>
						</div>
				</div>
			</xsl:if>
			<!-- dateRange toDate -->
			<xsl:if test="($existDates/eac:dateRange/eac:toDate/text() or $existDates/eac:dateSet/eac:dateRange/eac:toDate/text()
						  or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='death']/text()
			              or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='suppression']/text())
						  and ($existDates/eac:dateRange[1][@localType!='open'] or $existDates/eac:dateSet/eac:dateRange[1][@localType!='open']
						  	or $existDates/eac:dateRange[1][not(@localType)] or $existDates/eac:dateSet/eac:dateRange[1][not(@localType)])">
					<div class="row">
							<div class="leftcolumn">
						   		<h2>
						   		<xsl:if test="$entityType = 'person' or $entityType = 'family'">
									<xsl:value-of select="ape:resource('eaccpf.portal.deathDate')"/>
								</xsl:if>
								<xsl:if test="$entityType = 'corporateBody'">
									<xsl:value-of select="ape:resource('eaccpf.portal.closingDate')"/>
								</xsl:if>
						   		<xsl:text>:</xsl:text>
						   		</h2>
						   	</div>
						   	<div class="rightcolumn">
						   	    <xsl:if test="$existDates/eac:dateRange">
									<xsl:call-template name="dateUnknow">
										<xsl:with-param name="dateUnknow" select="$existDates/eac:dateRange/eac:toDate"/>
									</xsl:call-template>	
								</xsl:if> 
								<xsl:if test="$existDates/eac:dateSet/eac:dateRange/eac:toDate">
									<xsl:call-template name="multilanguageOneDate">
										<xsl:with-param name="list" select="$existDates/eac:dateSet/eac:dateRange/eac:toDate"/>
									</xsl:call-template>		
								</xsl:if>	
							    <xsl:if test="$entityType = 'person' or $entityType = 'family'">
									<xsl:if test="($langLocation='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='death'][not(@xml:lang)]/text()) 
													 or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='death'][@xml:lang=$langLocation]/text() 
									                 or ($searchTerms!='' and 
									                 	(
										                 	./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='death'][@xml:lang != $langLocation][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
											      		 	or (
											      		 		$langLocation!='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='death'][not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
										      		 		)
										      		 	)
										      		 )
												">
									<xsl:text>, </xsl:text>
									<xsl:call-template name="showDetailsPlaceEntry">
										<xsl:with-param name="list" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='death']"/>
										<xsl:with-param name="langNode" select="$langLocation"/>
									</xsl:call-template>
								</xsl:if>
								</xsl:if>
								<xsl:if test="$entityType = 'corporateBody'">
									<xsl:if test="($langLocation='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='suppression'][not(@xml:lang)]/text()) 
													 or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='suppression'][@xml:lang=$langLocation]/text() 
									                 or ($searchTerms!='' and 
									                 	(
										                 	./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='suppression'][@xml:lang != $langLocation][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
											      		 	or (
											      		 		$langLocation!='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='suppression'][not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
										      		 		)
										      		 	)
										      		 )
												">
									<xsl:text>, </xsl:text>
									<xsl:call-template name="showDetailsPlaceEntry">
										<xsl:with-param name="list" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place/eac:placeEntry[@localType='suppression']"/>
										<xsl:with-param name="langNode" select="$langLocation"/>
									</xsl:call-template>
								</xsl:if>
								</xsl:if>
							</div>
					</div>
			</xsl:if>
			<!-- Date -->
			<xsl:if test="($existDates/eac:date/text() or $existDates/eac:dateSet/eac:date/text())
						and (not($existDates/eac:dateRange/eac:fromDate/text()) and not($existDates/eac:dateSet/eac:dateRange/eac:fromDate/text()) and not($existDates/eac:dateRange/eac:toDate/text()) and not($existDates/eac:dateSet/eac:dateRange/eac:toDate/text()))">
					<div class="row">
							<div class="leftcolumn">
						   		<h2>
									<xsl:value-of select="ape:resource('eaccpf.portal.date')"/>
						   			<xsl:text>:</xsl:text>
						   		</h2>
						   	</div>
						   	<div class="rightcolumn">
						   		<xsl:if test="$existDates/eac:date/text()">
									<xsl:apply-templates select="$existDates/eac:date"/>
								</xsl:if>
						   		<xsl:if test="$existDates/eac:dateSet/eac:date/text()">
									<xsl:apply-templates select="$existDates/eac:dateSet/eac:date[1]"/>
								</xsl:if>
							</div>
					</div>
			</xsl:if>
			<!-- descriptiveNote of the existDates element. -->
			<xsl:if test="$existDates/eac:descriptiveNote/eac:p/text()">   
				<div class="row">
						<div class="leftcolumn">
					   		<h2><xsl:value-of select="ape:resource('eaccpf.portal.note')"/><xsl:text>:</xsl:text></h2>
					   	</div>
					   	<div class="rightcolumn">
							<xsl:call-template name="multilanguage">
					   			<xsl:with-param name="list" select="$existDates/eac:descriptiveNote/eac:p"/>
					   			<xsl:with-param name="clazz" select="'language'"/>
					   		</xsl:call-template>
						</div>
				</div>
			</xsl:if>

			<!-- alternative names -->
			<xsl:if test="count(//eac:nameEntry) > 1">
				<div class="row" id="titleAlternativeName">
					<div class="leftcolumn">
				   		<h2><xsl:value-of select="ape:resource('eaccpf.portal.alternativeForms')"/><xsl:text>:</xsl:text></h2>
				   	</div>
				   	<div class="rightcolumn">
				   			<xsl:call-template name="alternativeNamePriorisation">
				   				<xsl:with-param name="list" select="//eac:nameEntry"/>
				   				<xsl:with-param name="clazz" select="'alternativeName'"/>
				   			</xsl:call-template>  
					</div>
				</div>
			</xsl:if>
			<!--descriptive note inside identity -->
			<xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:identity/eac:descriptiveNote/eac:p/text()">   
				<div class="row">
						<div class="leftcolumn">
					   		<h2><xsl:value-of select="ape:resource('eaccpf.portal.note')"/><xsl:text>:</xsl:text></h2>
					   	</div>
					   	<div class="rightcolumn">
							<xsl:call-template name="multilanguage">
					   			<xsl:with-param name="list" select="./eac:eac-cpf/eac:cpfDescription/eac:identity/eac:descriptiveNote/eac:p"/>
					   			<xsl:with-param name="clazz" select="'language'"/>
					   		</xsl:call-template>
						</div>
				</div>
			</xsl:if>
			
			<!-- location -->
			
			<xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places/eac:place">
				<h2 class="title">
					<xsl:value-of select="translate(ape:resource('eaccpf.description.place'), $smallcase, $uppercase)"/>
				</h2>
				<xsl:for-each select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:places"> 
					<div class="blockPlural">		
						<xsl:variable name="posParent" select="position()"/>
						<!-- placeEntry in place and other nodes-->
							 	<xsl:call-template name="placesPriorisation">
						    		<xsl:with-param name="list" select="./eac:place"/>
					   				<xsl:with-param name="posParent" select="$posParent"/>
					    			<xsl:with-param name="langNode" select="$langLocation"/>
					    		</xsl:call-template>

				     	<!-- descriptiveNote places-->
				     	<xsl:if test="./eac:descriptiveNote/eac:p/text()">
							 <xsl:call-template name="commonChild">
					    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
					    		<xsl:with-param name="clazz" select="'descriptiveNotelocationPlaces_'"/>
					   			<xsl:with-param name="posParent" select="$posParent"/>
			    				<xsl:with-param name="posChild" select="''"/>
					    		<xsl:with-param name="title" select="'eaccpf.portal.place.note'"/>
					    		<xsl:with-param name="langNode" select="$langLocation"/>
					    	 </xsl:call-template>
				    	 </xsl:if>
				    </div>
			    </xsl:for-each>
			</xsl:if>
			
			<!-- localDescription -->
			<!-- Set the variable which checks if at least one of the links in
				 "<citation>" element inside "<localDescriptions>" is a valid
				 one. -->
			<xsl:variable name="validHrefLinkLocalDescription">
				<xsl:choose>
					<xsl:when test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xlink:href != '']">
						<xsl:value-of select="ape:checkHrefValue(string-join(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation/@xlink:href, '_HREF_SEPARATOR_'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="langLocalDescriptions">
			 	<xsl:variable name="lang" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//@xml:lang"/>
			    <xsl:variable name="listLang" select="string-join($lang,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelected" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:term[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:placeEntry[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:date[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:fromDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:toDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xlink:href != '' and @xml:lang=$language.selected]
								and $validHrefLinkLocalDescription = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xlink:title != '' and @xml:lang=$language.selected]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigator" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:term[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:placeEntry[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:date[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:fromDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:toDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xlink:href != '' and @xml:lang=$lang.navigator]
								and $validHrefLinkLocalDescription = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xlink:title != '' and @xml:lang=$lang.navigator]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefault" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:term[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:placeEntry[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:date[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:fromDate[@xml:lang=$language.default]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:toDate[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xlink:href != '' and @xml:lang=$language.default]
								and $validHrefLinkLocalDescription = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xlink:title != '' and @xml:lang=$language.default]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLang" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:term[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:placeEntry[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:date[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:fromDate[not(@xml:lang)]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:toDate[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xlink:href != '' and not(@xml:lang)]
								and $validHrefLinkLocalDescription = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:citation[@xlink:title != '' and not(@xml:lang)]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLang,$language.selected) and $conditionLangSelected">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$lang.navigator) and $conditionLangNavigator">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$language.default) and $conditionLangDefault">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLang">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLang,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
			</xsl:variable>
			
			<xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription
						and (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:term/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:placeEntry/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:dateSet/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:citation/text() != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:citation[@xlink:href != '']
								and $validHrefLinkLocalDescription = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:citation[@xlink:title != '']
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:localDescription/eac:descriptiveNote/eac:p/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions/eac:descriptiveNote/eac:p/text() != '')">
			    <h2 class="title"><xsl:value-of select="translate(ape:resource('eaccpf.portal.localDescription'), $smallcase, $uppercase)"/></h2>
				<xsl:for-each select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:localDescriptions"> 
					<div class="blockPlural">
						<xsl:variable name="posParent" select="position()"/>
					    <xsl:for-each select="./eac:localDescription">
					    	<xsl:if test="./eac:term/text() != ''
					    				or ./eac:placeEntry/text() != ''
										or ./eac:date/text() != ''
										or ./eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:dateSet/eac:date/text() != ''
										or ./eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:citation/text() != ''
										or (./eac:citation[@xlink:href != ''] and $validHrefLinkLocalDescription = 'true')
										or ./eac:citation[@xlink:title != '']
					    				or ./eac:descriptiveNote/eac:p/text() != ''">
					    		<div class="blockSingular">
						    		<xsl:variable name="posChild" select="position()"/>

						    		<!-- term localDescription -->
							    	<xsl:call-template name="term">
							    		<xsl:with-param name="list" select="./eac:term"/>
							    		<xsl:with-param name="clazz" select="'localDescription_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.localDescription'"/>
							    		<xsl:with-param name="langNode" select="$langLocalDescriptions"/>
							    	</xsl:call-template>

									<!-- placeEntry in localDescription -->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:placeEntry"/>
							    		<xsl:with-param name="clazz" select="'locationLocalDescription_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.location'"/>
							    		<xsl:with-param name="langNode" select="$langLocalDescriptions"/>
							    	</xsl:call-template>

									<!-- dates in localDescription -->
									<xsl:call-template name="commonDates">
							    		<xsl:with-param name="date" select="./eac:date"/>
							    		<xsl:with-param name="dateRange" select="./eac:dateRange"/>
							    		<xsl:with-param name="dateSet" select="./eac:dateSet"/>
					   					<xsl:with-param name="mode" select="'default'"/>
							    		<xsl:with-param name="langNode" select="$langLocalDescriptions"/>
							    	</xsl:call-template>

									<!-- citation in localDescription -->
								  	<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:citation"/>
							    		<xsl:with-param name="clazz" select="'citationLocalDescription_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.citation'"/>
							    		<xsl:with-param name="langNode" select="$langLocalDescriptions"/>
							    	</xsl:call-template>

									<!-- descriptiveNote in localDescription -->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
							    		<xsl:with-param name="clazz" select="'descriptiveNoteLocalDescription_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
							    		<xsl:with-param name="langNode" select="$langLocalDescriptions"/>
							    	</xsl:call-template>
							    </div>
							</xsl:if>	
						</xsl:for-each>
							<!-- descriptiveNote in localDescriptions -->
						 	<xsl:call-template name="commonChild">
					    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
					    		<xsl:with-param name="clazz" select="'descriptiveNoteLocalDescriptions_'"/>
					    		<xsl:with-param name="posParent" select="$posParent"/>
					    		<xsl:with-param name="posChild" select="''"/>
					    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
				    	 		<xsl:with-param name="langNode" select="$langLocalDescriptions"/>
				    	 	</xsl:call-template>
					</div> 	 	
				</xsl:for-each>		
		   </xsl:if>

			<!-- legalStatus -->
			<!-- Set the variable which checks if at least one of the links in
				 "<citation>" element inside "<legalStatuses>" is a valid one. -->
			<xsl:variable name="validHrefLinkLegalStatus">
				<xsl:choose>
					<xsl:when test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xlink:href != '']">
						<xsl:value-of select="ape:checkHrefValue(string-join(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation/@xlink:href, '_HREF_SEPARATOR_'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="langLegalStatus">
			 	<xsl:variable name="langLegal" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//@xml:lang"/>
			    <xsl:variable name="listLangLegal" select="string-join($langLegal,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelectedLegal" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:term[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:placeEntry[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:date[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:fromDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
                            or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:toDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xlink:href != '' and @xml:lang=$language.selected]
								and $validHrefLinkLegalStatus = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xlink:title != '' and @xml:lang=$language.selected]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigatorLegal" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:term[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:placeEntry[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:date[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:fromDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
                            or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:toDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xlink:href != '' and @xml:lang=$lang.navigator]
								and $validHrefLinkLegalStatus = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xlink:title != '' and @xml:lang=$lang.navigator]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefaultLegal" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:term[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:placeEntry[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:date[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:fromDate[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
                            or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:toDate[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xlink:href != '' and @xml:lang=$language.default]
								and $validHrefLinkLegalStatus = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xlink:title != '' and @xml:lang=$language.default]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLangLegal" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:term[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:placeEntry[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:date[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:fromDate[not(@xml:lang)]/fn:normalize-space(text()) != ''
                            or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:toDate[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xlink:href != '' and not(@xml:lang)]
								and $validHrefLinkLegalStatus = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:citation[@xlink:title != '' and not(@xml:lang)]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLangLegal,$language.selected) and $conditionLangSelectedLegal">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLangLegal,$lang.navigator) and $conditionLangNavigatorLegal">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLangLegal,$language.default) and $conditionLangDefaultLegal">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLangLegal">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLangLegal,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
			</xsl:variable>

			<xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus
						and (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:term/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:placeEntry/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:dateSet/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:citation/text() != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:citation[@xlink:href != '']
								and $validHrefLinkLegalStatus = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:citation[@xlink:title != '']
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:legalStatus/eac:descriptiveNote/eac:p/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses/eac:descriptiveNote/eac:p/text() != '')">
			    <h2 class="title"><xsl:value-of select="translate(ape:resource('eaccpf.portal.legalStatus'), $smallcase, $uppercase)"/></h2>
				<xsl:for-each select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:legalStatuses">
					<div class="blockPlural">
						<xsl:variable name="posParent" select="position()"/> 
					    <xsl:for-each select="./eac:legalStatus">
						    <xsl:if test="./eac:term/text() != ''
					    				or ./eac:placeEntry/text() != ''
										or ./eac:date/text() != ''
										or ./eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:dateSet/eac:date/text() != ''
										or ./eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:citation/text() != ''
										or (./eac:citation[@xlink:href != ''] and $validHrefLinkLegalStatus = 'true')
										or ./eac:citation[@xlink:title != '']
					    				or ./eac:descriptiveNote/eac:p/text() != ''">
					    		<div class="blockSingular">
						    		<xsl:variable name="posChild" select="position()"/>

						    		<!-- term legalStatus -->
							    	<xsl:call-template name="term">
							    		<xsl:with-param name="list" select="./eac:term"/>
							    		<xsl:with-param name="clazz" select="'legalStatus_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.legalStatus'"/>
							    		<xsl:with-param name="langNode" select="$langLegalStatus"/>
							    	</xsl:call-template>

									<!-- placeEntry in legalStatus -->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:placeEntry"/>
							    		<xsl:with-param name="clazz" select="'locationLegalStatus_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.location'"/>
							    		<xsl:with-param name="langNode" select="$langLegalStatus"/>
							    	</xsl:call-template>

									<!-- dates in legalStatus -->
									<xsl:call-template name="commonDates">
							    		<xsl:with-param name="date" select="./eac:date"/>
							    		<xsl:with-param name="dateRange" select="./eac:dateRange"/>
							    		<xsl:with-param name="dateSet" select="./eac:dateSet"/>
					   					<xsl:with-param name="mode" select="'default'"/>
							    		<xsl:with-param name="langNode" select="$langLegalStatus"/>
							    	</xsl:call-template>

									<!-- citation in legalStatus -->
								  	<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:citation"/>
							    		<xsl:with-param name="clazz" select="'citationLegalStatus_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.citation'"/>
							    		<xsl:with-param name="langNode" select="$langLegalStatus"/>
							    	</xsl:call-template>

									<!-- descriptiveNote in legalStatus -->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
							    		<xsl:with-param name="clazz" select="'descriptiveNoteLegalStatus_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
							    		<xsl:with-param name="langNode" select="$langLegalStatus"/>
							    	</xsl:call-template>
							    </div>
							</xsl:if>	
						</xsl:for-each>
							<!-- descriptiveNote in legalStatus -->
							 <xsl:call-template name="commonChild">
					    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
					    		<xsl:with-param name="clazz" select="'descriptiveNoteLegalStatuses_'"/>
					    		<xsl:with-param name="posParent" select="$posParent"/>
					    		<xsl:with-param name="posChild" select="''"/>
					    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
					    	 	<xsl:with-param name="langNode" select="$langLegalStatus"/>
					    	 </xsl:call-template>
			    	 </div>
				</xsl:for-each>		
		   </xsl:if>

			<!-- function -->
			<!-- Set the variable which checks if at least one of the links in
				 "<citation>" element inside "<functions>" is a valid one. -->
			<xsl:variable name="validHrefLinkFunction">
				<xsl:choose>
					<xsl:when test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xlink:href != '']">
						<xsl:value-of select="ape:checkHrefValue(string-join(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation/@xlink:href, '_HREF_SEPARATOR_'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="langFunctions">
			 	<xsl:variable name="lang" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//@xml:lang"/>
			    <xsl:variable name="listLang" select="string-join($lang,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelected" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:term[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:placeEntry[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:date[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:fromDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:toDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xlink:href != '' and @xml:lang=$language.selected]
								and $validHrefLinkFunction = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xlink:title != '' and @xml:lang=$language.selected]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigator" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:term[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:placeEntry[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:date[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:fromDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:toDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xlink:href != '' and @xml:lang=$lang.navigator]
								and $validHrefLinkFunction = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xlink:title != '' and @xml:lang=$lang.navigator]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefault" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:term[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:placeEntry[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:date[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:fromDate[@xml:lang=$language.default]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:toDate[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xlink:href != '' and @xml:lang=$language.default]
								and $validHrefLinkFunction = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xlink:title != '' and @xml:lang=$language.default]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLang" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:term[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:placeEntry[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:date[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:fromDate[not(@xml:lang)]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:toDate[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xlink:href != '' and not(@xml:lang)]
								and $validHrefLinkFunction = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:citation[@xlink:title != '' and not(@xml:lang)]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLang,$language.selected) and $conditionLangSelected">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$lang.navigator) and $conditionLangNavigator">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$language.default) and $conditionLangDefault">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLang">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLang,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
			</xsl:variable>
			
			<xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function
						and (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:term/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:placeEntry/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:dateSet/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:citation/text() != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:citation[@xlink:href != '']
								and $validHrefLinkFunction = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:citation[@xlink:title != '']
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:function/eac:descriptiveNote/eac:p/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions/eac:descriptiveNote/eac:p/text() != '')">
			    <h2 class="title"><xsl:value-of select="translate(ape:resource('eaccpf.portal.function'), $smallcase, $uppercase)"/></h2>
				<xsl:for-each select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:functions">
					<div class="blockPlural">
						<xsl:variable name="posParent" select="position()"/> 
					    <xsl:for-each select="./eac:function">
						    <xsl:if test="./eac:term/text() != ''
					    				or ./eac:placeEntry/text() != ''
										or ./eac:date/text() != ''
										or ./eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:dateSet/eac:date/text() != ''
										or ./eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:citation/text() != ''
										or (./eac:citation[@xlink:href != ''] and $validHrefLinkFunction = 'true')
										or ./eac:citation[@xlink:title != '']
					    				or ./eac:descriptiveNote/eac:p/text() != ''">
						    	<div class="blockSingular">
						    		<xsl:variable name="posChild" select="position()"/>

						    		<!-- term function -->
							    	<xsl:call-template name="term">
							    		<xsl:with-param name="list" select="./eac:term"/>
							    		<xsl:with-param name="clazz" select="'function_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.function'"/>
							    		<xsl:with-param name="langNode" select="$langFunctions"/>
							    	</xsl:call-template>

									<!-- placeEntry in function-->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:placeEntry"/>
							    		<xsl:with-param name="clazz" select="'locationFunction_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.location'"/>
							    		<xsl:with-param name="langNode" select="$langFunctions"/>
							    	</xsl:call-template>

									<!-- dates in function-->
									<xsl:call-template name="commonDates">
							    		<xsl:with-param name="date" select="./eac:date"/>
							    		<xsl:with-param name="dateRange" select="./eac:dateRange"/>
							    		<xsl:with-param name="dateSet" select="./eac:dateSet"/>
					   					<xsl:with-param name="mode" select="'default'"/>
							    		<xsl:with-param name="langNode" select="$langFunctions"/>
							    	</xsl:call-template>

									<!-- citation in function -->
								  	<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:citation"/>
							    		<xsl:with-param name="clazz" select="'citationFunction_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.citation'"/>
							    		<xsl:with-param name="langNode" select="$langFunctions"/>
							    	</xsl:call-template>

									<!-- descriptiveNote in function-->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
							    		<xsl:with-param name="clazz" select="'descriptiveNoteFunction_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
							    		<xsl:with-param name="langNode" select="$langFunctions"/>
							    	</xsl:call-template>
						    	</div>
							</xsl:if>
						</xsl:for-each>
							<!-- descriptiveNote in functions -->
							 <xsl:call-template name="commonChild">
					    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
					    		<xsl:with-param name="clazz" select="'descriptiveNoteFunctions_'"/>
					    		<xsl:with-param name="posParent" select="$posParent"/>
					    		<xsl:with-param name="posChild" select="''"/>
					    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
					    	 	<xsl:with-param name="langNode" select="$langFunctions"/>
					    	 </xsl:call-template>
					</div>	    	 
				</xsl:for-each>		
		    </xsl:if>

		    <!-- occupation -->
			<!-- Set the variable which checks if at least one of the links in
				 "<citation>" element inside "<occupations>" is a valid one. -->
			<xsl:variable name="validHrefLinkOccupation">
				<xsl:choose>
					<xsl:when test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xlink:href != '']">
						<xsl:value-of select="ape:checkHrefValue(string-join(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation/@xlink:href, '_HREF_SEPARATOR_'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
		    
		    <xsl:variable name="langOccupations">
			 	<xsl:variable name="lang" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//@xml:lang"/>
			    <xsl:variable name="listLang" select="string-join($lang,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelected" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:term[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:placeEntry[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:date[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:fromDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:toDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xlink:href != '' and @xml:lang=$language.selected]
								and $validHrefLinkOccupation = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xlink:title != '' and @xml:lang=$language.selected]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigator" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:term[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:placeEntry[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:date[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:fromDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:toDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xlink:href != '' and @xml:lang=$lang.navigator]
								and $validHrefLinkOccupation = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xlink:title != '' and @xml:lang=$lang.navigator]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefault" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:term[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:placeEntry[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:date[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:fromDate[@xml:lang=$language.default]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:toDate[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xlink:href != '' and @xml:lang=$language.default]
								and $validHrefLinkOccupation = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xlink:title != '' and @xml:lang=$language.default]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLang" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:term[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:placeEntry[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:date[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:fromDate[not(@xml:lang)]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:toDate[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xlink:href != '' and not(@xml:lang)]
								and $validHrefLinkOccupation = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:citation[@xlink:title != '' and not(@xml:lang)]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLang,$language.selected) and $conditionLangSelected">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$lang.navigator) and $conditionLangNavigator">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$language.default) and $conditionLangDefault">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLang">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLang,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
			</xsl:variable>
			
		    <xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation
						and (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:term/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:placeEntry/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:dateSet/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:citation/text() != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:citation[@xlink:href != '']
								and $validHrefLinkOccupation = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:citation[@xlink:title != '']
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:occupation/eac:descriptiveNote/eac:p/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations/eac:descriptiveNote/eac:p/text() != '')">
			    <h2 class="title"><xsl:value-of select="translate(ape:resource('eaccpf.portal.occupation'), $smallcase, $uppercase)"/></h2>
				<xsl:for-each select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:occupations"> 
					<div class="blockPlural">
						<xsl:variable name="posParent" select="position()"/> 
					    <xsl:for-each select="./eac:occupation">
						    <xsl:if test="./eac:term/text() != ''
					    				or ./eac:placeEntry/text() != ''
										or ./eac:date/text() != ''
										or ./eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:dateSet/eac:date/text() != ''
										or ./eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:citation/text() != ''
										or (./eac:citation[@xlink:href != ''] and $validHrefLinkOccupation = 'true')
										or ./eac:citation[@xlink:title != '']
					    				or ./eac:descriptiveNote/eac:p/text() != ''">
					    		<div class="blockSingular">
						    		<xsl:variable name="posChild" select="position()"/>

						    		<!-- term occupation -->
							    	<xsl:call-template name="term">
							    		<xsl:with-param name="list" select="./eac:term"/>
							    		<xsl:with-param name="clazz" select="'occupation_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.occupation'"/>
							    		<xsl:with-param name="langNode" select="$langOccupations"/>
							    	</xsl:call-template>

									<!-- placeEntry in occupation-->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:placeEntry"/>
							    		<xsl:with-param name="clazz" select="'locationOccupation_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.location'"/>
							    		<xsl:with-param name="langNode" select="$langOccupations"/>
							    	</xsl:call-template>

									<!-- dates in occupation-->
									<xsl:call-template name="commonDates">
							    		<xsl:with-param name="date" select="./eac:date"/>
							    		<xsl:with-param name="dateRange" select="./eac:dateRange"/>
							    		<xsl:with-param name="dateSet" select="./eac:dateSet"/>
					   					<xsl:with-param name="mode" select="'default'"/>
							    		<xsl:with-param name="langNode" select="$langOccupations"/>
							    	</xsl:call-template>

									<!-- citation in occupation -->
								  	<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:citation"/>
							    		<xsl:with-param name="clazz" select="'citationOccupation_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.citation'"/>
							    		<xsl:with-param name="langNode" select="$langOccupations"/>
							    	</xsl:call-template>

									<!-- descriptiveNote in occupation-->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
							    		<xsl:with-param name="clazz" select="'descriptiveNoteOccupation_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
							    		<xsl:with-param name="langNode" select="$langOccupations"/>
							    	</xsl:call-template>
							    </div>
							</xsl:if>
						</xsl:for-each>
						<!-- descriptiveNote in occupations -->
						 <xsl:call-template name="commonChild">
				    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
				    		<xsl:with-param name="clazz" select="'descriptiveNoteOccupations_'"/>
				    		<xsl:with-param name="posParent" select="$posParent"/>
				    		<xsl:with-param name="posChild" select="''"/>
				    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
				    	 	<xsl:with-param name="langNode" select="$langOccupations"/>
				    	 </xsl:call-template>
			    	 </div>
				</xsl:for-each>		
		    </xsl:if>

		    <!--mandates-->
			<!-- Set the variable which checks if at least one of the links in
				 "<citation>" element inside "<mandates>" is a valid one. -->
			<xsl:variable name="validHrefLinkMandate">
				<xsl:choose>
					<xsl:when test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xlink:href != '']">
						<xsl:value-of select="ape:checkHrefValue(string-join(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation/@xlink:href, '_HREF_SEPARATOR_'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="langMandates">
			 	<xsl:variable name="lang" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//@xml:lang"/>
			    <xsl:variable name="listLang" select="string-join($lang,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelected" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:term[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:placeEntry[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:date[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:fromDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:toDate[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xlink:href != '' and @xml:lang=$language.selected]
								and $validHrefLinkMandate = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xlink:title != '' and @xml:lang=$language.selected]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigator" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:term[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:placeEntry[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:date[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:fromDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:toDate[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xlink:href != '' and @xml:lang=$lang.navigator]
								and $validHrefLinkMandate = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xlink:title != '' and @xml:lang=$lang.navigator]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefault" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:term[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:placeEntry[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:date[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:fromDate[@xml:lang=$language.default]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:toDate[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xlink:href != '' and @xml:lang=$language.default]
								and $validHrefLinkMandate = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xlink:title != '' and @xml:lang=$language.default]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLang" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:term[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:placeEntry[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:date[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:fromDate[not(@xml:lang)]/fn:normalize-space(text()) != '' 
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:toDate[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xlink:href != '' and not(@xml:lang)]
								and $validHrefLinkMandate = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:citation[@xlink:title != '' and not(@xml:lang)]
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLang,$language.selected) and $conditionLangSelected">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$lang.navigator) and $conditionLangNavigator">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$language.default) and $conditionLangDefault">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLang">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLang,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
			</xsl:variable>
			
		    <xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate
						and (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:term/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:placeEntry/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:dateSet/eac:date/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:citation/text() != ''
							or (./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:citation[@xlink:href != '']
								and $validHrefLinkMandate = 'true')
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:citation[@xlink:title != '']
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:mandate/eac:descriptiveNote/eac:p/text() != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates/eac:descriptiveNote/eac:p/text() != '')">
			    <h2 class="title"><xsl:value-of select="translate(ape:resource('eaccpf.portal.mandate'), $smallcase, $uppercase)"/></h2>
				<xsl:for-each select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:mandates">
					<div class="blockPlural">
						<xsl:variable name="posParent" select="position()"/>  
					    <xsl:for-each select="./eac:mandate">
					    	<xsl:if test="./eac:term/text() != ''
					    				or ./eac:placeEntry/text() != ''
										or ./eac:date/text() != ''
										or ./eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:dateSet/eac:date/text() != ''
										or ./eac:dateSet/eac:dateRange[eac:fromDate or eac:toDate]/text() != ''
										or ./eac:citation/text() != ''
										or (./eac:citation[@xlink:href != ''] and $validHrefLinkMandate = 'true')
										or ./eac:citation[@xlink:title != '']
					    				or ./eac:descriptiveNote/eac:p/text() != ''">
					    		<div class="blockSingular">
						    		<xsl:variable name="posChild" select="position()"/>

						    		<!-- term mandate -->
							    	<xsl:call-template name="term">
							    		<xsl:with-param name="list" select="./eac:term"/>
							    		<xsl:with-param name="clazz" select="'mandate_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.mandate'"/>
							    		<xsl:with-param name="langNode" select="$langMandates"/>
							    	</xsl:call-template>

									<!-- placeEntry in mandate-->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:placeEntry"/>
							    		<xsl:with-param name="clazz" select="'locationMandate_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.location'"/>
							    		<xsl:with-param name="langNode" select="$langMandates"/>
							    	</xsl:call-template>

									<!-- dates in mandate-->
									<xsl:call-template name="commonDates">
							    		<xsl:with-param name="date" select="./eac:date"/>
							    		<xsl:with-param name="dateRange" select="./eac:dateRange"/>
							    		<xsl:with-param name="dateSet" select="./eac:dateSet"/>
					   					<xsl:with-param name="mode" select="'default'"/>
							    		<xsl:with-param name="langNode" select="$langMandates"/>
							    	</xsl:call-template>

									<!-- citation in mandate -->
								  	<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:citation"/>
							    		<xsl:with-param name="clazz" select="'citationMandate_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.citation'"/>
							    		<xsl:with-param name="langNode" select="$langMandates"/>
							    	</xsl:call-template>

									<!-- descriptiveNote in mandate-->
									<xsl:call-template name="commonChild">
							    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
							    		<xsl:with-param name="clazz" select="'descriptiveNoteMandate_'"/>
							    		<xsl:with-param name="posParent" select="$posParent"/>
							    		<xsl:with-param name="posChild" select="$posChild"/>
							    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
							    		<xsl:with-param name="langNode" select="$langMandates"/>
							    	</xsl:call-template>
							    </div>
							</xsl:if>	
						</xsl:for-each>
						<!-- descriptiveNote in mandates -->
						 <xsl:call-template name="commonChild">
				    		<xsl:with-param name="list" select="./eac:descriptiveNote/eac:p"/>
				    		<xsl:with-param name="clazz" select="'descriptiveNoteMandates_'"/>
				    		<xsl:with-param name="posParent" select="$posParent"/>
				    		<xsl:with-param name="posChild" select="''"/>
				    		<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
				    		<xsl:with-param name="langNode" select="$langMandates"/>
				    	 </xsl:call-template>
			    	 </div>
				</xsl:for-each>		
		    </xsl:if>
			
			<!-- languagesUsed -->
			<xsl:variable name="languagesUsed">
			 	<xsl:variable name="lang" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//@xml:lang"/>
			    <xsl:variable name="listLang" select="string-join($lang,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelected" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:language[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:script[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigator" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:language[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:script[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefault" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:language[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:script[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLang" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:language[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:script[not(@xml:lang)]/fn:normalize-space(text()) != ''
							or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLang,$language.selected) and $conditionLangSelected">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$lang.navigator) and $conditionLangNavigator">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$language.default) and $conditionLangDefault">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLang">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLang,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
			</xsl:variable>
			
			<!--language -->
			<xsl:if test="($languagesUsed='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:language[not(@xml:lang)]/text()) 
								 or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:language[@xml:lang=$languagesUsed]/text() 
				                 or ($searchTerms!='' and 
				                 	(
					                 	./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:language[@xml:lang != $languagesUsed][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
						      		 	or (
						      		 		$languagesUsed!='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:language[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
					      		 		)
					      		 	)
					      		 )
							">
			
			<div class="row">
				<div class="leftcolumn">
					<h2>
						<xsl:value-of select="ape:resource('eaccpf.portal.languagesUsed')"/>
						<xsl:text>:</xsl:text>
					</h2>
				</div>
				<div class="rightcolumn">
				 	<xsl:call-template name="showDetailsDescriptiveNote">
			   			<xsl:with-param name="list" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:language"/>
			   			<xsl:with-param name="clazz" select="'language'"/>
			   			<xsl:with-param name="langNode" select="$languagesUsed"/>
			   		</xsl:call-template>
				</div>
			</div>	
		</xsl:if>
			
			<!-- script -->
			<xsl:if test="($languagesUsed='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:script[not(@xml:lang)]/text()) 
								 or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:script[@xml:lang=$languagesUsed]/text() 
				                 or ($searchTerms!='' and 
				                 	(
					                 	./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:script[@xml:lang != $languagesUsed][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
						      		 	or (
						      		 		$languagesUsed!='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:script[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
					      		 		)
					      		 	)
					      		 )
							">
			
				<div class="row">
					<div class="leftcolumn">
						<h2>
							<xsl:value-of select="ape:resource('eaccpf.portal.scriptUsed')"/>
							<xsl:text>:</xsl:text>
						</h2>
					</div>
					<div class="rightcolumn">
					 	<xsl:call-template name="showDetailsDescriptiveNote">
				   			<xsl:with-param name="list" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:languageUsed/eac:script"/>
				   			<xsl:with-param name="clazz" select="'script'"/>
				   			<xsl:with-param name="langNode" select="$languagesUsed"/>
				   		</xsl:call-template>
					</div>
				</div>	
			</xsl:if>
			
			<!--descriptive note inside languagesUsed -->
			<xsl:if test="($languagesUsed='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:descriptiveNote/eac:p[not(@xml:lang)]/text()) 
								 or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:descriptiveNote/eac:p[@xml:lang=$languagesUsed]/text() 
				                 or ($searchTerms!='' and 
				                 	(
					                 	./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:descriptiveNote/eac:p[@xml:lang != $languagesUsed][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
						      		 	or (
						      		 		$languagesUsed!='notLang' and ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:descriptiveNote/eac:p[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
					      		 		)
					      		 	)
					      		 )
							">
			
				<div class="row">
					<div class="leftcolumn">
						<h2>
							<xsl:value-of select="ape:resource('eaccpf.portal.note')"/>
							<xsl:text>:</xsl:text>
						</h2>
					</div>
					<div class="rightcolumn">
					 	<xsl:call-template name="showDetailsDescriptiveNote">
				   			<xsl:with-param name="list" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:languagesUsed/eac:descriptiveNote/eac:p"/>
				   			<xsl:with-param name="clazz" select="'languagesUsedDescription'"/>
				   			<xsl:with-param name="langNode" select="$languagesUsed"/>
				   		</xsl:call-template>
					</div>
				</div>	
			</xsl:if>
			
			<!-- structureOrGenealogy -->
			<xsl:variable name="langStructureOrGenealogy">
			 	<xsl:variable name="lang" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:structureOrGenealogy/eac:p//@xml:lang"/>
			    <xsl:variable name="listLang" select="string-join($lang,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelected" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:structureOrGenealogy//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigator" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:structureOrGenealogy//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefault" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:structureOrGenealogy//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLang" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:structureOrGenealogy//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLang,$language.selected) and $conditionLangSelected">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$lang.navigator) and $conditionLangNavigator">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$language.default) and $conditionLangDefault">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLang">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLang,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
			</xsl:variable>
			
			<xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:structureOrGenealogy/eac:p/text() or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:structureOrGenealogy/eac:outline/eac:level/eac:item/text()">
				    <xsl:if test="$entityType='person'">
				    	<h2><xsl:value-of select="translate(ape:resource('eaccpf.portal.genealogy'), $smallcase, $uppercase)"/></h2>
					</xsl:if>
					<xsl:if test="$entityType='corporateBody'">
						<h2><xsl:value-of select="translate(ape:resource('eaccpf.portal.structure'), $smallcase, $uppercase)"/></h2>
					</xsl:if>
					<xsl:if test="$entityType='family'">
						<h2><xsl:value-of select="translate(ape:resource('eaccpf.portal.structureOrGenealogy'), $smallcase, $uppercase)"/></h2>
				   </xsl:if>
				
				<xsl:for-each select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:structureOrGenealogy">
					<xsl:variable name="firstchild" select="./*[1]"/>
				  	<xsl:if test="name($firstchild)='outline'">
						   <xsl:call-template name="outlineStructure">
						   	 <xsl:with-param name="list" select="."/>
						   	 <xsl:with-param name="clazz" select="'structureOrGenealogy'"/>	
						   	 <xsl:with-param name="entityType" select="$entityType"/>	
						   </xsl:call-template> 
						   <xsl:call-template name="p">
						   	 <xsl:with-param name="list" select="."/>
						  	 <xsl:with-param name="clazz" select="'structureOrGenealogyNote'"/>	
						  	<xsl:with-param name="langNode" select="$langStructureOrGenealogy"/>
						   </xsl:call-template>
					</xsl:if>
					<xsl:if test="name($firstchild)='p'">    
						    <xsl:call-template name="p">
						   	  <xsl:with-param name="list" select="."/>
						   	  <xsl:with-param name="clazz" select="'structureOrGenealogyNote'"/>	
						   	  <xsl:with-param name="langNode" select="$langStructureOrGenealogy"/>	
						    </xsl:call-template>
						   <xsl:call-template name="outlineStructure">
						   	 <xsl:with-param name="list" select="."/>
						   	 <xsl:with-param name="clazz" select="'structureOrGenealogy'"/>
						   	 <xsl:with-param name="entityType" select="$entityType"/>
						   </xsl:call-template> 
					</xsl:if>
				</xsl:for-each>
			</xsl:if>

			<!-- generalContext -->
			<xsl:variable name="langGeneralContext">
			 	<xsl:variable name="lang" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:generalContext/eac:p//@xml:lang"/>
			    <xsl:variable name="listLang" select="string-join($lang,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelected" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:generalContext//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigator" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:generalContext//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefault" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:generalContext//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLang" select="(./eac:eac-cpf/eac:cpfDescription/eac:description/eac:generalContext//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLang,$language.selected) and $conditionLangSelected">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$lang.navigator) and $conditionLangNavigator">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$language.default) and $conditionLangDefault">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLang">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLang,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
			</xsl:variable>
			
			<xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:generalContext/eac:p/text() or ./eac:eac-cpf/eac:cpfDescription/eac:description/eac:generalContext/eac:outline/eac:level/eac:item/text()">
			  	<h2><xsl:value-of select="translate(ape:resource('eaccpf.portal.generalContext'), $smallcase, $uppercase)"/></h2> 
				
				<xsl:for-each select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:generalContext">
					<xsl:variable name="firstchild" select="./*[1]"/>
				  	<xsl:if test="name($firstchild)='outline'">
						   <xsl:call-template name="outline">
						   	 <xsl:with-param name="list" select="."/>
						   	 <xsl:with-param name="clazz" select="'generalContext'"/>	
						  	 <xsl:with-param name="title" select="'eaccpf.portal.generalContext'"/> 
						   </xsl:call-template>
						   <xsl:call-template name="p">
						   	 <xsl:with-param name="list" select="."/>
						  	 <xsl:with-param name="clazz" select="'generalContextNote'"/>	
						  	 <xsl:with-param name="langNode" select="$langGeneralContext"/>
						   </xsl:call-template>
					</xsl:if>
					<xsl:if test="name($firstchild)='p'">    
						    <xsl:call-template name="p">
						   	  <xsl:with-param name="list" select="."/>
						   	  <xsl:with-param name="clazz" select="'generalContextNote'"/>	
						      <xsl:with-param name="langNode" select="$langGeneralContext"/>
						    </xsl:call-template>
						   <xsl:call-template name="outline">
						   	  <xsl:with-param name="list" select="."/>
						   	  <xsl:with-param name="clazz" select="'generalContext'"/>	
						  	  <xsl:with-param name="title" select="'eaccpf.portal.generalContext'"/>	
						   </xsl:call-template>
					</xsl:if>
				</xsl:for-each>
			</xsl:if> 

			<!-- biogHist -->
			<xsl:if test="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:biogHist">   
				<xsl:call-template name="bioHistMultilanguage">
					<xsl:with-param name="bioHist" select="./eac:eac-cpf/eac:cpfDescription/eac:description/eac:biogHist"/>
					<xsl:with-param name="entityType" select="$entityType"></xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			
			<!-- provided by -->
		<!--  	<xsl:if test="./eac:eac-cpf/eac:control/eac:maintenanceAgency/eac:agencyName/text()">
				<div class="row">
						<div class="leftcolumn">
					   		<h2><xsl:value-of select="ape:resource('eaccpf.portal.agencyName')"/><xsl:text>:</xsl:text></h2>
					   	</div>
					   	<div class="rightcolumn">
							<xsl:choose>
								<xsl:when test="./eac:eac-cpf/eac:control/eac:maintenanceAgency/eac:agencyCode/text()">
									<xsl:variable name="href" select="./eac:eac-cpf/eac:control/eac:maintenanceAgency/eac:agencyCode"/>
									<xsl:if test="starts-with($href, 'http') or starts-with($href, 'https') or starts-with($href, 'ftp') or starts-with($href, 'www')">
										<a href="{$href}" target="_blank">
											<xsl:apply-templates select="./eac:eac-cpf/eac:control/eac:maintenanceAgency/eac:agencyName" mode="other"/>
										</a>
							  		</xsl:if>
							  		<xsl:if test="not(starts-with($href, 'http')) and not(starts-with($href, 'https')) and not(starts-with($href, 'ftp')) and not(starts-with($href, 'www'))">
							  			<xsl:variable name="aiCode" select="ape:checkAICode($href, '', 'true')" />
							  			<xsl:choose>
							  				<xsl:when test="$aiCode != 'ERROR' and $aiCode != ''">
												<xsl:variable name="encodedAiCode" select="ape:encodeSpecialCharacters($aiCode)" />
												<a href="{$aiCodeUrl}/{$encodedAiCode}" target="_blank">
													<xsl:apply-templates select="./eac:eac-cpf/eac:control/eac:maintenanceAgency/eac:agencyName" mode="other"/>
												</a>
							  				</xsl:when>
							  				<xsl:otherwise>
							  					<xsl:apply-templates select="./eac:eac-cpf/eac:control/eac:maintenanceAgency/eac:agencyName" mode="other"/>
							  				</xsl:otherwise>
							  			</xsl:choose>
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="./eac:eac-cpf/eac:control/eac:maintenanceAgency/eac:agencyName" mode="other"/>
								</xsl:otherwise>
							</xsl:choose>
						</div>
				</div>
			</xsl:if>-->
	</div>
	</xsl:template>
	
	<xsl:template name="bioHistMultilanguage">
		<xsl:param name="bioHist"></xsl:param>
		<xsl:param name="entityType"></xsl:param>
		
		<!-- Set the variable which checks if at least one of the links in
				 "<citation>" element inside "<biogHist>" is a valid
				 one. -->
		<xsl:variable name="validHrefLinkBiogHist">
			<xsl:choose>
				<xsl:when test="$bioHist/eac:citation[@xlink:href != '']">
					<xsl:value-of select="ape:checkHrefValue(string-join($bioHist/eac:citation/@xlink:href, '_HREF_SEPARATOR_'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="false"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!--Set the language to select in biogHist  -->
		<xsl:variable name="langBiogHist">
			 	<xsl:variable name="lang" select="$bioHist//@xml:lang"/>
			    <xsl:variable name="listLang" select="string-join($lang,'')"/>
			 	
			 	<xsl:variable name="conditionLangSelected" select="($bioHist//eac:abstract[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
			               or $bioHist//eac:p[@xml:lang=$language.selected]/fn:normalize-space(text()) != ''
			               or $bioHist//eac:citation[@xml:lang=$language.selected]/fn:normalize-space(text())!= ''
			               or ($bioHist//eac:citation[@xml:lang=$language.selected and @xlink:href != ''] and $validHrefLinkBiogHist = 'true')
			               or $bioHist//eac:citation[@xml:lang=$language.selected and @xlink:title != '']
			               or $bioHist//eac:date[@xml:lang = $language.selected]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:fromDate[@xml:lang = $language.selected]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:toDate[@xml:lang = $language.selected]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:placeEntry[@xml:lang = $language.selected]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:event[@xml:lang = $language.selected]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangNavigator" select="($bioHist//eac:abstract[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
			               or $bioHist//eac:p[@xml:lang=$lang.navigator]/fn:normalize-space(text()) != ''
			               or $bioHist//eac:citation[@xml:lang=$lang.navigator]/fn:normalize-space(text())!= ''
			               or ($bioHist//eac:citation[@xml:lang=$lang.navigator and @xlink:href != ''] and $validHrefLinkBiogHist = 'true')
			               or $bioHist//eac:citation[@xml:lang=$lang.navigator and @xlink:title != '']
			               or $bioHist//eac:date[@xml:lang = $lang.navigator]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:fromDate[@xml:lang = $lang.navigator]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:toDate[@xml:lang = $lang.navigator]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:placeEntry[@xml:lang = $lang.navigator]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:event[@xml:lang = $lang.navigator]/fn:normalize-space(text()) != '')"/>
			 	
			 	<xsl:variable name="conditionLangDefault" select="($bioHist//eac:abstract[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
			               or $bioHist//eac:p[@xml:lang=$language.default]/fn:normalize-space(text()) != ''
			               or $bioHist//eac:citation[@xml:lang=$language.default]/fn:normalize-space(text())!= ''
			               or ($bioHist//eac:citation[@xml:lang=$language.default and @xlink:href != ''] and $validHrefLinkBiogHist = 'true')
			               or $bioHist//eac:citation[@xml:lang=$language.default and @xlink:title != '']
			               or $bioHist//eac:date[@xml:lang = $language.default]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:fromDate[@xml:lang = $language.default]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:toDate[@xml:lang = $language.default]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:placeEntry[@xml:lang = $language.default]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:event[@xml:lang = $language.default]/fn:normalize-space(text()) != '')"/>
							
			 	<xsl:variable name="conditionNotLang" select="($bioHist//eac:abstract[not(@xml:lang)]/fn:normalize-space(text()) != ''
			               or $bioHist//eac:p[not(@xml:lang)]/fn:normalize-space(text()) != ''
			               or $bioHist//eac:citation[not(@xml:lang)]/fn:normalize-space(text())!= ''
			               or ($bioHist//eac:citation[not(@xml:lang) and @xlink:href != ''] and $validHrefLinkBiogHist = 'true')
			               or $bioHist//eac:citation[not(@xml:lang) and @xlink:title != '']
			               or $bioHist//eac:date[not(@xml:lang)]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:fromDate[not(@xml:lang)]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:toDate[not(@xml:lang)]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:placeEntry[not(@xml:lang)]/fn:normalize-space(text()) != ''
						   or $bioHist//eac:event[not(@xml:lang)]/fn:normalize-space(text()) != '')"/>
			 	
			 	 <xsl:choose>
			    	<xsl:when test="fn:contains($listLang,$language.selected) and $conditionLangSelected">
			    	  <xsl:value-of select="$language.selected"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$lang.navigator) and $conditionLangNavigator">
			    		<xsl:value-of select="$lang.navigator"/>
			    	</xsl:when>
			    	<xsl:when test="fn:contains($listLang,$language.default) and $conditionLangDefault">
			    		<xsl:value-of select="$language.default"/>
			    	</xsl:when>
			    	<xsl:when test="$conditionNotLang">
			    		<xsl:value-of select="'notLang'"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    	  <xsl:value-of select="substring($listLang,0,4)"/>
			    	</xsl:otherwise>
			    </xsl:choose> 
		</xsl:variable>
		
		<!-- bioHist section title -->
		<xsl:if test="$bioHist//eac:p/text() or $bioHist//eac:citation or $bioHist//eac:chronList/eac:chronItem or $bioHist//eac:abstract/text()">
			<h2 id="chronListTitle">
				<xsl:if test="$entityType='corporateBody'">
	   				<xsl:value-of select="translate(ape:resource('eaccpf.portal.historicalNote'), $smallcase, $uppercase)"/>
	   			</xsl:if>
	   			<xsl:if test="$entityType='person' or $entityType='family'">
	   				<xsl:value-of select="translate(ape:resource('eaccpf.portal.biogHist'), $smallcase, $uppercase)"/>
	   			</xsl:if>
			</h2>
		</xsl:if>
		
		<!-- Display the information of biogHist in the same order that are in the xml file -->
		<!-- abstract always goes in the first position -->
		
		<xsl:for-each select="$bioHist">
			<!-- biogHist abstract -->
		
			<xsl:if test="($langBiogHist='notLang' and ./eac:abstract[not(@xml:lang)]/text()) 
								 or ./eac:abstract[@xml:lang=$langBiogHist]/text() 
				                 or ($searchTerms!='' and 
				                 	(
					                 	./eac:abstract[@xml:lang != $langBiogHist][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
						      		 	or (
						      		 		$langBiogHist!='notLang' and ./eac:abstract[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
					      		 		)
					      		 	)
					      		 )
							">
							
					<div class="row">
						<div class="leftcolumn">
							<h2>
								<xsl:value-of select="ape:resource('eaccpf.portal.abstract')"/><xsl:text>:</xsl:text>
							</h2>
						</div>
						<div class="rightcolumn">
							<xsl:call-template name="showDetailsDescriptiveNote">
					   			<xsl:with-param name="list" select="./eac:abstract"/>
					   			<xsl:with-param name="clazz" select="'biogistAbstract'"/>
					   			<xsl:with-param name="langNode" select="$langBiogHist"/>
					   		</xsl:call-template>
						</div>
					</div>
			</xsl:if>
			
			<!-- Set the positions of the <citation>, <chronList>, <p> in the xml file-->
			<xsl:variable name="pPosition">
				<xsl:choose>
					<xsl:when test="./eac:p">
						<xsl:for-each select="./*">
				  			<xsl:if test="name() = 'p'">
								<xsl:value-of select="concat(position(),',')" /> 
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('6',',')" /> 
					</xsl:otherwise>	
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="posP" select="number(substring-before($pPosition,',' ))"/>
			
			<xsl:variable name="citationPosition">
				<xsl:choose>
				<xsl:when test="./eac:citation">
					<xsl:for-each select="./*">
			  			<xsl:if test="name() = 'citation'">
							<xsl:value-of select="concat(position(),',')" /> 
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('6',',')" />
				</xsl:otherwise>	
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="posCitation" select="number(substring-before($citationPosition,',' ))"/>
			
			<xsl:variable name="chronListPosition">
				<xsl:choose>
					<xsl:when test="./eac:chronList">
						<xsl:for-each select="./*">
				  			<xsl:if test="name() = 'chronList'">
								<xsl:value-of select="concat(position(),',')" /> 
							</xsl:if>
						</xsl:for-each>
					</xsl:when>	
					<xsl:otherwise>
						<xsl:value-of select="concat('6',',')" /> 
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="posChron" select="number(substring-before($chronListPosition,',' ))"/>
			
			<!-- Display the information according to the position of the nodes -->
			<xsl:choose>
				<xsl:when test="($posP &lt; $posCitation) and ($posP &lt; $posChron)">
					<!-- biogHist p -->
					<xsl:call-template name="templateBiogHistP">
						<xsl:with-param name="bioHist" select="."/>
						<xsl:with-param name="entityType" select="$entityType"/>
						<xsl:with-param name="langNode" select="$langBiogHist"/>
					</xsl:call-template>
					<xsl:choose>
						<xsl:when test="$posCitation &lt; $posChron">
							<!-- biogHist citation --> 
							<xsl:call-template name="templateBiogHistCitation">
								<xsl:with-param name="bioHist" select="."/>
								<xsl:with-param name="entityType" select="$entityType"/>
								<xsl:with-param name="langNode" select="$langBiogHist"/>
							</xsl:call-template>	
							<!-- biogHist chronList -->
							<xsl:if test="./eac:chronList/eac:chronItem">
								<xsl:call-template name="chronListMultilanguage">
									<xsl:with-param name="list" select="./eac:chronList"></xsl:with-param>
									<xsl:with-param name="langNode" select="$langBiogHist"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<!-- biogHist chronList -->
							<xsl:if test="./eac:chronList/eac:chronItem">
								<xsl:call-template name="chronListMultilanguage">
									<xsl:with-param name="list" select="./eac:chronList"></xsl:with-param>
									<xsl:with-param name="langNode" select="$langBiogHist"/>
								</xsl:call-template>
							</xsl:if>
							<!-- biogHist citation --> 
							<xsl:call-template name="templateBiogHistCitation">
								<xsl:with-param name="bioHist" select="."/>
								<xsl:with-param name="entityType" select="$entityType"/>
								<xsl:with-param name="langNode" select="$langBiogHist"/>
							</xsl:call-template>	
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="($posCitation &lt; $posP) and ($posCitation &lt; $posChron)">
					<!-- biogHist citation --> 
					<xsl:call-template name="templateBiogHistCitation">
						<xsl:with-param name="bioHist" select="."/>
						<xsl:with-param name="entityType" select="$entityType"/>
						<xsl:with-param name="langNode" select="$langBiogHist"/>
					</xsl:call-template>	
					<xsl:choose>
						<xsl:when test="$posP &lt; $posChron">
							<!-- biogHist p -->
							<xsl:call-template name="templateBiogHistP">
								<xsl:with-param name="bioHist" select="."/>
								<xsl:with-param name="entityType" select="$entityType"/>
								<xsl:with-param name="langNode" select="$langBiogHist"/>
							</xsl:call-template>
							<!-- biogHist chronList -->
							<xsl:if test="$bioHist/eac:chronList/eac:chronItem">
								<xsl:call-template name="chronListMultilanguage">
									<xsl:with-param name="list" select="./eac:chronList"></xsl:with-param>
									<xsl:with-param name="langNode" select="$langBiogHist"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<!-- biogHist chronList -->
							<xsl:if test="./eac:chronList/eac:chronItem">
								<xsl:call-template name="chronListMultilanguage">
									<xsl:with-param name="list" select="./eac:chronList"></xsl:with-param>
									<xsl:with-param name="langNode" select="$langBiogHist"/>
								</xsl:call-template>
							</xsl:if>
							<!-- biogHist p -->
							<xsl:call-template name="templateBiogHistP">
								<xsl:with-param name="bioHist" select="."/>
								<xsl:with-param name="entityType" select="$entityType"/>
								<xsl:with-param name="langNode" select="$langBiogHist"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="($posChron &lt; $posP) and ($posChron &lt; $posCitation)">
					<!-- biogHist chronList -->
					<xsl:if test="./eac:chronList/eac:chronItem">
						<xsl:call-template name="chronListMultilanguage">
							<xsl:with-param name="list" select="./eac:chronList"></xsl:with-param>
							<xsl:with-param name="langNode" select="$langBiogHist"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="$posP &lt; $posCitation">
							<!-- biogHist p -->
							<xsl:call-template name="templateBiogHistP">
								<xsl:with-param name="bioHist" select="."/>
								<xsl:with-param name="entityType" select="$entityType"/>
								<xsl:with-param name="langNode" select="$langBiogHist"/>
							</xsl:call-template>
							<!-- biogHist citation --> 
							<xsl:call-template name="templateBiogHistCitation">
								<xsl:with-param name="bioHist" select="."/>
								<xsl:with-param name="entityType" select="$entityType"/>
								<xsl:with-param name="langNode" select="$langBiogHist"/>
							</xsl:call-template>	
						</xsl:when>
						<xsl:otherwise>
							<!-- biogHist citation --> 
							<xsl:call-template name="templateBiogHistCitation">
								<xsl:with-param name="bioHist" select="."/>
								<xsl:with-param name="entityType" select="$entityType"/>
								<xsl:with-param name="langNode" select="$langBiogHist"/>
							</xsl:call-template>	
							<!-- biogHist p -->
							<xsl:call-template name="templateBiogHistP">
								<xsl:with-param name="bioHist" select="."/>
								<xsl:with-param name="entityType" select="$entityType"/>
								<xsl:with-param name="langNode" select="$langBiogHist"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>	
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Template to display biogHist citation -->
	<xsl:template name="templateBiogHistCitation">
		<xsl:param name="bioHist"/>
		<xsl:param name="entityType"/>
		<xsl:param name="langNode"/>
		
		<xsl:variable name="condSearchTermLang" select="$bioHist/eac:citation[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]"/>
		<xsl:variable name="condSearchTermNoLang" select="$langNode!='notLang' and $bioHist/eac:citation[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]"/>
		<xsl:variable name="condCitationText" select="$bioHist/eac:citation[fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]"/>
		<xsl:variable name="titleCitation" select="$bioHist/eac:citation/@xlink:title"/>
		<xsl:variable name="condCitationNoText" select="not($bioHist/eac:citation/text()) and $bioHist/eac:citation[fn:contains(fn:upper-case($titleCitation),fn:upper-case($searchTerms))]"/>	
		
		<xsl:if test="($langNode='notLang' and $bioHist/eac:citation[not(@xml:lang)]/text()) or $bioHist/eac:citation[@xml:lang=$langNode]/text() 
		               or ($searchTerms!='' and ($condSearchTermLang or $condSearchTermNoLang  or $condCitationText or $condCitationNoText))">
		
			<div class="row">
				<div class="leftcolumn">
			   		<h2 class="subrow">
			   			<xsl:value-of select="ape:resource('eaccpf.portal.citation')"/>
			   			<xsl:text>:</xsl:text>
			   		</h2>
			   	</div>
			   	<div class="rightcolumn">
					<xsl:for-each select="./eac:citation">						
						<xsl:choose>
							<xsl:when test=".[@xml:lang=$langNode]/text() or ($langNode='notLang' and .[not(@xml:lang)]/text())">
								<p>
									<xsl:call-template name="citationHref">
										<xsl:with-param name="link" select="./@xlink:href"/>
										<xsl:with-param name="title" select="./@xlink:title" />
										<xsl:with-param name="content" select="./text()"/>
										<xsl:with-param name="section" select="current()"/>
									</xsl:call-template>
								</p>
							</xsl:when>
							<xsl:when test="$searchTerms != '' and (fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms))
									                        or (not(./text()) and fn:contains(fn:upper-case(./@xlink:title),fn:upper-case($searchTerms))))">
				    
				    			<p>
									<xsl:call-template name="citationHref">
										<xsl:with-param name="link" select="./@xlink:href"/>
										<xsl:with-param name="title" select="./@xlink:title" />
										<xsl:with-param name="content" select="./text()"/>
										<xsl:with-param name="section" select="current()"/>
									</xsl:call-template>
								</p>
				    		</xsl:when>
				    		<xsl:otherwise/>
				    	</xsl:choose>	
				     </xsl:for-each>
				</div>
			</div>
		</xsl:if>	
	</xsl:template>
	
	<!-- Template to display biogHist p -->
	<xsl:template name="templateBiogHistP">
		<xsl:param name="bioHist"/>
		<xsl:param name="entityType"/>
		<xsl:param name="langNode"/>
		
		
		<xsl:if test="($langNode='notLang' and $bioHist/eac:p[not(@xml:lang)]/text()) 
				 or $bioHist/eac:p[@xml:lang=$langNode]/text() 
                 or ($searchTerms!='' and 
                 	(
	                 	$bioHist/eac:p[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
		      		 	or (
		      		 		$langNode!='notLang' and $bioHist/eac:p[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
	      		 		)
	      		 	)
	      		 )
			">
			
			<div class="row">
				<div class="leftcolumn">
					<h2>
						<xsl:if test="$entityType='corporateBody'">
							<xsl:value-of select="ape:resource('eaccpf.portal.historicalNote')"/>
						</xsl:if>
						<xsl:if test="$entityType='person' or $entityType='family'">
							<xsl:value-of select="ape:resource('eaccpf.portal.biogHist')"/>
						</xsl:if>
						<xsl:text>:</xsl:text>
					</h2>
				</div>
				<div class="rightcolumn">
					<xsl:call-template name="showDetailsDescriptiveNote">
			   			<xsl:with-param name="list" select="$bioHist/eac:p"/>
			   			<xsl:with-param name="clazz" select="'biogist'"/>
			   			<xsl:with-param name="langNode" select="$langNode"/>
			   		</xsl:call-template>
				</div>
			</div>
		</xsl:if>	
	</xsl:template>
	
	<xsl:template name="chronListMultilanguage">
		<xsl:param name="list"/>
		<xsl:param name="langNode"/>
		
	
	 	<xsl:if test="$list/eac:chronItem or $list/eac:placeEntry or $list/eac:event">
			
			<xsl:if test="($langNode='notLang' and ($list/eac:chronItem/eac:date[not(@xml:lang)]/text()
										or $list/eac:chronItem/eac:dateRange/eac:fromDate[not(@xml:lang)]/text()
										or $list/eac:chronItem/eac:dateRange/eac:toDate[not(@xml:lang)]/text()
										or $list/eac:chronItem/eac:placeEntry[not(@xml:lang)]/text()
										or $list/eac:chronItem/eac:event[not(@xml:lang)]/text())) 
							 or ($list/eac:chronItem/eac:date[@xml:lang=$langNode]/text()
										or $list/eac:chronItem/eac:dateRange/eac:fromDate[@xml:lang=$langNode]/text()
										or $list/eac:chronItem/eac:dateRange/eac:toDate[@xml:lang=$langNode]/text()
										or $list/eac:chronItem/eac:placeEntry[@xml:lang=$langNode]/text()
										or $list/eac:chronItem/eac:event[@xml:lang=$langNode]/text()) 
			                 or ($searchTerms!='' and 
			                 	(
				                 	$list/eac:chronItem/eac:placeEntry[@xml:lang!=$langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
										or $list/eac:chronItem/eac:event[@xml:lang!=$langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]  
					      		 	or (
					      		 		$langNode!='notLang' and ($list/eac:chronItem/eac:placeEntry[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
										or $list/eac:chronItem/eac:event[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))])
				      		 		)
				      		 	)
				      		 )
						">
					
				<xsl:for-each select="$list" >
					<div class="blockPlural">
						<xsl:for-each select="./eac:chronItem" >
							<xsl:if test="($langNode='notLang' and (./eac:date[not(@xml:lang)]/text()
															or ./eac:dateRange/eac:fromDate[not(@xml:lang)]/text()
															or ./eac:dateRange/eac:toDate[not(@xml:lang)]/text()
															or ./eac:placeEntry[not(@xml:lang)]/text()
															or ./eac:event[not(@xml:lang)]/text())) 
												 or (./eac:date[@xml:lang=$langNode]/text()
															or ./eac:dateRange/eac:fromDate[@xml:lang=$langNode]/text()
															or ./eac:dateRange/eac:toDate[@xml:lang=$langNode]/text()
															or ./eac:placeEntry[@xml:lang=$langNode]/text()
															or ./eac:event[@xml:lang=$langNode]/text()) 
								                 or ($searchTerms!='' and 
								                 	(
									                 	./eac:placeEntry[@xml:lang!=$langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
															or ./eac:event[@xml:lang!=$langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]  
										      		 	or (
										      		 		$langNode!='notLang' and ($list/eac:chronItem/eac:placeEntry[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
															or ./eac:event[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))])
									      		 		)
									      		 	)
									      		 )">
											
								<div class="blockSingular">
									<xsl:if test="($langNode='notLang' and (./eac:date[not(@xml:lang)]/text()
																		or ./eac:dateRange/eac:fromDate[not(@xml:lang)]/text()
																		or ./eac:dateRange/eac:toDate[not(@xml:lang)]/text())) 
															 or (./eac:date[@xml:lang=$langNode]/text()
																		or ./eac:dateRange/eac:fromDate[@xml:lang=$langNode]/text()
																		or ./eac:dateRange/eac:toDate[@xml:lang=$langNode]/text())">
														
										<div id="chronListItemContent" >
											<xsl:call-template name="commonDates">
												<xsl:with-param name="date" select="./eac:date"/>
												<xsl:with-param name="dateRange" select="./eac:dateRange"/>
												<xsl:with-param name="dateSet" select="./eac:dateSet"/>
					   							<xsl:with-param name="mode" select="'default'"/>
												<xsl:with-param name="langNode" select="$langNode"/>
											</xsl:call-template>
										</div>
									</xsl:if>
	
									<xsl:if test="($langNode='notLang' and ./eac:placeEntry[not(@xml:lang)]/text()) 
													 or ./eac:placeEntry[@xml:lang=$langNode]/text() 
									                 or ($searchTerms!='' and 
									                 	(./eac:placeEntry[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
											      		 	or (
											      		 		$langNode!='notLang' and ./eac:placeEntry[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
										      		 		)
										      		 	)
										      		 )
												">
										<div id="chronListItemContent" class="row">
											<div class="leftcolumn">
												<h2>
													<xsl:value-of select="ape:resource('eaccpf.description.place')"/>
													<xsl:text>:</xsl:text>
												</h2>
											</div>
											<div class="rightcolumn">
												<xsl:call-template name="showDetailsPlaceEntry">
													<xsl:with-param name="list" select="./eac:placeEntry"/>
													<xsl:with-param name="langNode" select="$langNode"/>
												</xsl:call-template>
											</div>
										</div>
									</xsl:if>
	
									<xsl:if test="($langNode='notLang' and ./eac:event[not(@xml:lang)]/text()) 
													 or ./eac:event[@xml:lang=$langNode]/text() 
									                 or ($searchTerms!='' and 
									                 	(./eac:event[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
											      		 	or (
											      		 		$langNode!='notLang' and ./eac:event[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
										      		 		)
										      		 	)
										      		 )
												">
										<div id="chronListItemContent" class="row">
											<div class="leftcolumn">
												<h2>
													<xsl:value-of select="ape:resource('eaccpf.portal.event')"/>
													<xsl:text>:</xsl:text>
												</h2>
											</div> 
											<div class="rightcolumn"> 
												<xsl:call-template name="showDetailsNoP"> <!-- multilanguageEvent -->
													<xsl:with-param name="list" select="./eac:event"/>
													<xsl:with-param name="langNode" select="$langNode"/>
												</xsl:call-template>
											</div>
										</div>
									</xsl:if>
								</div>
							</xsl:if>	
						</xsl:for-each>
					</div>
				</xsl:for-each>
			</xsl:if>
		</xsl:if> 
	</xsl:template>
	
	<!-- Template for select the correct order to display the alternative names
		 based in the value of the attribute "@localType". -->
	<xsl:template name="alternativeNamePriorisation">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>

		<div id="{$clazz}">
			<xsl:choose>
				<xsl:when test="count($list) > 1">
					<!-- Checks the attribute "@localType". -->
					<!-- localType = preferred -->
					<xsl:if test="$list[@localType = 'preferred']">
						<xsl:call-template name="alternativeName">
							<xsl:with-param name="list" select="$list[@localType = 'preferred']"/>
						</xsl:call-template> 
					</xsl:if>
					<!-- localType = authorized -->
					<xsl:if test="$list[@localType = 'authorized']">
						<xsl:call-template name="alternativeName">
							<xsl:with-param name="list" select="$list[@localType = 'authorized']"/>
						</xsl:call-template> 
					</xsl:if>
					<!-- not @localType -->
					<xsl:if test="$list[not(@localType)]">
						<xsl:call-template name="alternativeName">
							<xsl:with-param name="list" select="$list[not(@localType)]"/>
						</xsl:call-template> 
					</xsl:if>
					<!-- localType = alternative -->
					<xsl:if test="$list[@localType = 'alternative']">
						<xsl:call-template name="alternativeName">
							<xsl:with-param name="list" select="$list[@localType = 'alternative']"/>
						</xsl:call-template> 
					</xsl:if>
					<!-- localType = abbreviation -->
					<xsl:if test="$list[@localType = 'abbreviation']">
						<xsl:call-template name="alternativeName">
							<xsl:with-param name="list" select="$list[@localType = 'abbreviation']"/>
						</xsl:call-template> 
					</xsl:if>
					<!-- localType = other -->
					<xsl:if test="$list[@localType = 'other']">
						<xsl:call-template name="alternativeName">
							<xsl:with-param name="list" select="$list[@localType = 'other']"/>
						</xsl:call-template> 
					</xsl:if>
					<!-- In any other case checks the whole list. -->
					<xsl:if test="$list[not(@localType = 'preferred') and not(@localType = 'authorized') and not(@localType = 'alternative') and not(@localType = 'abbreviation') and not(@localType = 'other') and @localType]">
						<xsl:call-template name="alternativeName">
							<xsl:with-param name="list" select="$list[not(@localType = 'preferred') and not(@localType = 'authorized') and not(@localType = 'alternative') and not(@localType = 'abbreviation') and not(@localType = 'other') and @localType]"/>
						</xsl:call-template> 
					</xsl:if>
				</xsl:when>

				<xsl:otherwise>
					<xsl:call-template name="alternativeName">
						<xsl:with-param name="list" select="$list"/>
					</xsl:call-template> 
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<!-- Template for alternative forms of name -->
	<xsl:template name="alternativeName">
		<xsl:param name="list"/>

		<xsl:for-each select="$list">
			<p>
				<xsl:call-template name="compositeName">
					<xsl:with-param name="listName" select="current()"/>
					<xsl:with-param name="isHeader" select="'false'"/>
				</xsl:call-template> 
		    </p>
		</xsl:for-each>
	</xsl:template>

	<!--template to order eac:placeEntry into eac:places level -->
	<xsl:template name="placesPriorisation">
		<xsl:param name="list"/>
		<xsl:param name="posParent"/>
		<xsl:param name="langNode"/>
		
		<!-- Checks the attribute "@localType". -->
		<!-- localType = birth -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'birth']">
			<xsl:for-each select="$list">
				<xsl:variable name="posChild" select="position()"/>
				<xsl:if test="./eac:placeEntry[@localType = 'birth']">
					<xsl:call-template name="placeDetails">
						<xsl:with-param name="list" select="."/>
					  	<xsl:with-param name="posChild" select="$posChild"/>
						<xsl:with-param name="posParent" select="$posParent"/>
						<xsl:with-param name="langNode" select="$langNode"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

		<!-- localType = foundation -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'foundation']">
			<xsl:for-each select="$list">
				<xsl:variable name="posChild" select="position()"/>
				<xsl:if test="./eac:placeEntry[@localType ='foundation'] and not(./eac:placeEntry[@localType = 'birth'])">
				  	<xsl:call-template name="placeDetails">
						<xsl:with-param name="list" select="."/>
						<xsl:with-param name="posChild" select="$posChild"/>
						<xsl:with-param name="posParent" select="$posParent"/>
						<xsl:with-param name="langNode" select="$langNode"/>
					</xsl:call-template>	
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

		<!-- localType = private-residence -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'private-residence']">
			<xsl:for-each select="$list">
				<xsl:variable name="posChild" select="position()"/>
				<xsl:if test="./eac:placeEntry[@localType ='private-residence'] and not(./eac:placeEntry[@localType = 'birth']) and not(./eac:placeEntry[@localType = 'foundation'])">
				  	<xsl:call-template name="placeDetails">
						<xsl:with-param name="list" select="."/>
						<xsl:with-param name="posChild" select="$posChild"/>
						<xsl:with-param name="posParent" select="$posParent"/>
						<xsl:with-param name="langNode" select="$langNode"/>
					</xsl:call-template>	
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

		<!-- localType = business-residence -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'business-residence']">
			<xsl:for-each select="$list">
				<xsl:variable name="posChild" select="position()"/>
				<xsl:if test="./eac:placeEntry[@localType ='business-residence'] and not(./eac:placeEntry[@localType = 'birth']) and not(./eac:placeEntry[@localType = 'foundation'])
								and not(./eac:placeEntry[@localType = 'private-residence'])">
				  	<xsl:call-template name="placeDetails">
						<xsl:with-param name="list" select="."/>
						<xsl:with-param name="posChild" select="$posChild"/>
						<xsl:with-param name="posParent" select="$posParent"/>
						<xsl:with-param name="langNode" select="$langNode"/>
					</xsl:call-template>	
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

		<!-- localType = death -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'death']">
			<xsl:for-each select="$list">
				<xsl:variable name="posChild" select="position()"/>
				<xsl:if test="./eac:placeEntry[@localType ='death'] and not(./eac:placeEntry[@localType = 'birth']) and not(./eac:placeEntry[@localType = 'foundation'])
								and not(./eac:placeEntry[@localType = 'private-residence']) and not(./eac:placeEntry[@localType = 'business-residence'])">
				  	<xsl:call-template name="placeDetails">
						<xsl:with-param name="list" select="."/>
						<xsl:with-param name="posChild" select="$posChild"/>
						<xsl:with-param name="posParent" select="$posParent"/>
						<xsl:with-param name="langNode" select="$langNode"/>
					</xsl:call-template>	
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
		
		<!-- localType = suppression -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'suppression']">
			<xsl:for-each select="$list">
				<xsl:variable name="posChild" select="position()"/>
				<xsl:if test="./eac:placeEntry[@localType ='suppression'] and not(./eac:placeEntry[@localType = 'birth']) and not(./eac:placeEntry[@localType = 'foundation'])
								and not(./eac:placeEntry[@localType = 'private-residence']) and not(./eac:placeEntry[@localType = 'business-residence'])
								and not(./eac:placeEntry[@localType = 'death'])">
				  	<xsl:call-template name="placeDetails">
						<xsl:with-param name="list" select="."/>
						<xsl:with-param name="posChild" select="$posChild"/>
						<xsl:with-param name="posParent" select="$posParent"/>
						<xsl:with-param name="langNode" select="$langNode"/>
					</xsl:call-template>	
				</xsl:if>
			</xsl:for-each>
		</xsl:if>

		<!-- In any other case checks the whole list. -->
		<!-- localType = other -->
		<!-- no localType -->
		<!-- empty localType -->
		<xsl:if test="$list/eac:placeEntry[not(@localType = 'birth') and not(@localType = 'death') and not(@localType = 'foundation') and not(@localType = 'private-residence') and not(@localType = 'business-residence') and not(@localType = 'suppression')]">
			<xsl:for-each select="$list">
				<xsl:variable name="posChild" select="position()"/>
				<xsl:if test="./eac:placeEntry[not(@localType = 'birth') and not(@localType = 'death') and not(@localType = 'foundation') and not(@localType = 'private-residence') and not(@localType = 'business-residence') and not(@localType = 'suppression')] 
								and not(./eac:placeEntry[@localType = 'birth']) and not(./eac:placeEntry[@localType = 'foundation'])
								and not(./eac:placeEntry[@localType = 'private-residence']) and not(./eac:placeEntry[@localType = 'business-residence'])
								and not(./eac:placeEntry[@localType = 'death']) and not(./eac:placeEntry[@localType = 'suppression'])">
				  	<xsl:call-template name="placeDetails">
						<xsl:with-param name="list" select="."/>
						<xsl:with-param name="posChild" select="$posChild"/>
						<xsl:with-param name="posParent" select="$posParent"/>
						<xsl:with-param name="langNode" select="$langNode"/>
					</xsl:call-template>	
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	
	<!-- template for the details in /places/place -->
	<xsl:template name="placeDetails">
		<xsl:param name="list"/>
		<xsl:param name="posChild"/>
		<xsl:param name="posParent"/>
		<xsl:param name="langNode"/>
			
			<div class="blockSingular">	
				
			   <!--  placeEntry in place  --> 
				<xsl:call-template name="placePriorisation">
		    		<xsl:with-param name="list" select="$list"/>
	   				<xsl:with-param name="posParent" select="$posParent"/>
	   				<xsl:with-param name="posChild" select="$posChild"/>
	    			<xsl:with-param name="langNode" select="$langNode"/>
	    		</xsl:call-template>
	
		      <!--   placeRole  -->
		        <xsl:if test="(	$langNode='notLang' and $list/eac:placeRole[not(@xml:lang)]/text()) 
								 or $list/eac:placeRole[@xml:lang=$langNode]/text() 
				                 or ($searchTerms!='' and 
				                 	(
					                 	$list/eac:placeRole[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
						      		 	or (
						      		 		$langNode!='notLang' and $list/eac:placeRole[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
					      		 		)
					      		 	)
					      		 )
							">

			
					<div class="row">
					    <div class="leftcolumn">
				   			<h2>
				   				<xsl:value-of select="ape:resource('eaccpf.portal.roleOfLocation')"/>
				   				<xsl:text>:</xsl:text>
				   			</h2>
				   	    </div>
				     	<div class="rightcolumn">
				     		<xsl:call-template name="showDetails">
	  							<xsl:with-param name="list" select="$list/eac:placeRole"/>
				   				<xsl:with-param name="clazz" select="'placeRole_'"/>
				   				<xsl:with-param name="langNode" select="$langNode"/>
				   			</xsl:call-template>
					    </div>
			        </div>
				</xsl:if>
			    
	    		<!--  addressLine  -->
				<!--  Tittle for the address section.-->
				<xsl:if test="$list/eac:address/eac:addressLine[@xml:lang=$langNode]/text() or ($langNode='notLang' and $list/eac:address/eac:addressLine[not(@xml:lang)]/text())">
					<div class="row">
					    <div class="leftcolumn">
				   			<h2 class="subrow">
					   			<xsl:choose>
					    			<xsl:when test="$list/eac:address[@localType='visitors address']">
					    				<xsl:value-of select="ape:resource('eaccpf.portal.place.address.visitors')"/>
					    			</xsl:when>
					    			<xsl:when test="$list/eac:address[@localType='postal address']">
							    		<xsl:value-of select="ape:resource('eaccpf.portal.place.address.postal')"/>
					    			</xsl:when>
					    			<xsl:otherwise>
							    		<xsl:value-of select="ape:resource('eaccpf.portal.place.address')"/>
					    			</xsl:otherwise>
				    			</xsl:choose>
				   			<!--<xsl:text>:</xsl:text>-->
			   				</h2>
				   	    </div>
				     	<div class="rightcolumn">
					    </div>
			        </div>
				</xsl:if>
				<!-- addressLine @localType="street" --> 
		    	<xsl:if test="$list/eac:address/eac:addressLine[@localType='street']/text()">
			    	<xsl:call-template name="commonChild">
			   			<xsl:with-param name="list" select="$list/eac:address/eac:addressLine[@localType='street']"/>
			   			<xsl:with-param name="clazz" select="'addressLineStreet'"/>
			   			<xsl:with-param name="posParent" select="$posParent"/>
    					<xsl:with-param name="posChild" select="$posChild"/>
			    		<xsl:with-param name="title" select="'eaccpf.description.combo.address.component.street'"/>
			    		<xsl:with-param name="langNode" select="$langNode"/>
			    	</xsl:call-template>
				</xsl:if>
				<!--  addressLine @localType="postalcode"  -->
				<xsl:if test="$list/eac:address/eac:addressLine[@localType='postalcode']/text()">
		    		<xsl:call-template name="commonChild">
			   			<xsl:with-param name="list" select="$list/eac:address/eac:addressLine[@localType='postalcode']"/>
			   			<xsl:with-param name="clazz" select="'addressLinePC'"/>
			   			<xsl:with-param name="posParent" select="$posParent"/>
    					<xsl:with-param name="posChild" select="$posChild"/>
		    			<xsl:with-param name="title" select="'eaccpf.description.combo.address.component.postalcode'"/>
	    				<xsl:with-param name="langNode" select="$langNode"/>
	    			</xsl:call-template>
			    </xsl:if>
				 <!--  addressLine @localType="firstdem" -->
				<xsl:if test="$list/eac:address/eac:addressLine[@localType='firstdem']/text()">
		    		<xsl:call-template name="commonChild">
			   			<xsl:with-param name="list" select="./eac:address/eac:addressLine[@localType='firstdem']"/>
			   			<xsl:with-param name="clazz" select="'addressLineFirst'"/>
			   			<xsl:with-param name="posParent" select="$posParent"/>
    					<xsl:with-param name="posChild" select="$posChild"/>
		    			<xsl:with-param name="title" select="'eaccpf.description.combo.address.component.firstdem'"/>
		    			<xsl:with-param name="langNode" select="$langNode"/>
		    		</xsl:call-template>
				</xsl:if>
			 	<!--  addressLine @localType="secondem" -->
				<xsl:if test="$list/eac:address/eac:addressLine[@localType='secondem']/text()">
		    		<xsl:call-template name="commonChild">
			   			<xsl:with-param name="list" select="$list/eac:address/eac:addressLine[@localType='secondem']"/>
			   			<xsl:with-param name="clazz" select="'addressLineSecond'"/>
			   			<xsl:with-param name="posParent" select="$posParent"/>
    					<xsl:with-param name="posChild" select="$posChild"/>
		    			<xsl:with-param name="title" select="'eaccpf.description.combo.address.component.secondem'"/>
		    			<xsl:with-param name="langNode" select="$langNode"/>
		    		</xsl:call-template>
				</xsl:if>
				 <!--  addressLine @localType="localentity" -->
			    <xsl:if test="$list/eac:address/eac:addressLine[@localType='localentity']/text()">
		    		<xsl:call-template name="commonChild">
			   			<xsl:with-param name="list" select="$list/eac:address/eac:addressLine[@localType='localentity']"/>
			   			<xsl:with-param name="clazz" select="'addressLineLocal'"/>
			   			<xsl:with-param name="posParent" select="$posParent"/>
    					<xsl:with-param name="posChild" select="$posChild"/>
		    			<xsl:with-param name="title" select="'eaccpf.description.combo.address.component.localentity'"/>
		    			<xsl:with-param name="langNode" select="$langNode"/>
		    		</xsl:call-template>
				</xsl:if>
				 <!-- addressLine @localType="other" -->
				<xsl:if test="$list/eac:address/eac:addressLine[@localType='other']/text()">
		    		<xsl:call-template name="commonChild">
			   			<xsl:with-param name="list" select="$list/eac:address/eac:addressLine[@localType='other']"/>
			   			<xsl:with-param name="clazz" select="'addressLineOther'"/>
			   			<xsl:with-param name="posParent" select="$posParent"/>
    					<xsl:with-param name="posChild" select="$posChild"/>
		    			<xsl:with-param name="title" select="'eaccpf.portal.place.address.information'"/>
		    			<xsl:with-param name="langNode" select="$langNode"/>
		    		</xsl:call-template>
				</xsl:if>
				<!-- addressLine @localType="country" -->
				<xsl:if test="$list/eac:address/eac:addressLine[@localType='country']/text()">
		    		<xsl:call-template name="commonChild">
			   			<xsl:with-param name="list" select="$list/eac:address/eac:addressLine[@localType='country']"/>
			   			<xsl:with-param name="clazz" select="'addressLineCountry'"/>
			   			<xsl:with-param name="posParent" select="$posParent"/>
    					<xsl:with-param name="posChild" select="$posChild"/>
		    			<xsl:with-param name="title" select="'eaccpf.description.combo.address.component.country'"/>
		    			<xsl:with-param name="langNode" select="$langNode"/>
		    		</xsl:call-template>
				</xsl:if>
	
				<!--   dates in place -->
			  	<xsl:call-template name="commonDates">
		    		<xsl:with-param name="date" select="$list/eac:date"/>
		    		<xsl:with-param name="dateRange" select="$list/eac:dateRange"/>
		    		<xsl:with-param name="dateSet" select="$list/eac:dateSet"/>
   					<xsl:with-param name="mode" select="'default'"/>
		    		<xsl:with-param name="langNode" select="$langNode"/>
		    	</xsl:call-template>
	
				<!--  descriptive note place -->
				<xsl:if test="./eac:descriptiveNote/eac:p/text()">   
		    		<xsl:call-template name="commonChild">
			    		<xsl:with-param name="list" select="$list/eac:descriptiveNote/eac:p"/>
			    		<xsl:with-param name="clazz" select="'descriptiveNotelocationPlace_'"/>					   			
		   				<xsl:with-param name="posParent" select="$posParent"/>
    					<xsl:with-param name="posChild" select="$posChild"/>
		    			<xsl:with-param name="title" select="'eaccpf.portal.note'"/>
	    				<xsl:with-param name="langNode" select="$langNode"/>
	    			</xsl:call-template>
			    </xsl:if>
	
			    <!--  citation in place  -->
			    <xsl:call-template name="commonChild">
		    		<xsl:with-param name="list" select="$list/eac:citation"/>
		    		<xsl:with-param name="clazz" select="'citationlocationPlace_'"/>
		    		<xsl:with-param name="posParent" select="$posParent"/>
		    		<xsl:with-param name="posChild" select="$posChild"/>
		    		<xsl:with-param name="title" select="'eaccpf.relations.link'"/>
		    		<xsl:with-param name="langNode" select="$langNode"/>
		    	</xsl:call-template>
	    	</div>
	</xsl:template>
	
	<!-- Template for select the correct order to display the places based in
		 the value of the attribute "@localType". -->
	<xsl:template name="placePriorisation">
		<xsl:param name="list"/>
		<xsl:param name="posParent"/>
		<xsl:param name="posChild"/>
		<xsl:param name="langNode"/>

		<!-- Checks the attribute "@localType". -->
		<!-- localType = birth -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'birth']">
			<xsl:call-template name="places">
   				<xsl:with-param name="list" select="$list/eac:placeEntry[@localType = 'birth']"/>
   				<xsl:with-param name="clazz" select="'locationBirthPlace_'"/>
   				<xsl:with-param name="posParent" select="$posParent"/>
   				<xsl:with-param name="posChild" select="$posChild"/>
				<xsl:with-param name="title" select="'eaccpf.description.combo.place.role.birth'"/>
   				<xsl:with-param name="langNode" select="$langNode"/>
   			</xsl:call-template>
		</xsl:if>

		<!-- localType = foundation -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'foundation']">
			<xsl:call-template name="places">
   				<xsl:with-param name="list" select="$list/eac:placeEntry[@localType = 'foundation']"/>
   				<xsl:with-param name="clazz" select="'locationFoundationPlace_'"/>
   				<xsl:with-param name="posParent" select="$posParent"/>
   				<xsl:with-param name="posChild" select="$posChild"/>
				<xsl:with-param name="title" select="'eaccpf.description.combo.place.role.foundation'"/>
   				<xsl:with-param name="langNode" select="$langNode"/>
   			</xsl:call-template>
		</xsl:if>

		<!-- localType = private-residence -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'private-residence']">
			<xsl:call-template name="places">
   				<xsl:with-param name="list" select="$list/eac:placeEntry[@localType = 'private-residence']"/>
   				<xsl:with-param name="clazz" select="'locationPrivatePlace_'"/>
   				<xsl:with-param name="posParent" select="$posParent"/>
   				<xsl:with-param name="posChild" select="$posChild"/>
				<xsl:with-param name="title" select="'eaccpf.description.combo.place.role.private-residence'"/>
   				<xsl:with-param name="langNode" select="$langNode"/>
   			</xsl:call-template>
		</xsl:if>

		<!-- localType = business-residence -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'business-residence']">
			<xsl:call-template name="places">
   				<xsl:with-param name="list" select="$list/eac:placeEntry[@localType = 'business-residence']"/>
   				<xsl:with-param name="clazz" select="'locationBusinessPlace_'"/>
   				<xsl:with-param name="posParent" select="$posParent"/>
   				<xsl:with-param name="posChild" select="$posChild"/>
				<xsl:with-param name="title" select="'eaccpf.description.combo.place.role.business-residence'"/>
   				<xsl:with-param name="langNode" select="$langNode"/>
   			</xsl:call-template>
		</xsl:if>

		<!-- localType = death -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'death']">
			<xsl:call-template name="places">
   				<xsl:with-param name="list" select="$list/eac:placeEntry[@localType = 'death']"/>
   				<xsl:with-param name="clazz" select="'locationDeathPlace_'"/>
   				<xsl:with-param name="posParent" select="$posParent"/>
   				<xsl:with-param name="posChild" select="$posChild"/>
				<xsl:with-param name="title" select="'eaccpf.description.combo.place.role.death'"/>
   				<xsl:with-param name="langNode" select="$langNode"/>
   			</xsl:call-template>
		</xsl:if>

		<!-- localType = suppression -->
		<xsl:if test="$list/eac:placeEntry[@localType = 'suppression']">
			<xsl:call-template name="places">
   				<xsl:with-param name="list" select="$list/eac:placeEntry[@localType = 'suppression']"/>
   				<xsl:with-param name="clazz" select="'locationSuppressionPlace_'"/>
   				<xsl:with-param name="posParent" select="$posParent"/>
   				<xsl:with-param name="posChild" select="$posChild"/>
				<xsl:with-param name="title" select="'eaccpf.description.combo.place.role.suppression'"/>
   				<xsl:with-param name="langNode" select="$langNode"/>
   			</xsl:call-template>
		</xsl:if>

		<!-- In any other case checks the whole list. -->
		<!-- localType = other -->
		<!-- no localType -->
		<!-- empty localType -->
		<xsl:if test="$list/eac:placeEntry[not(@localType = 'birth') and not(@localType = 'death') and not(@localType = 'foundation') and not(@localType = 'private-residence') and not(@localType = 'business-residence') and not(@localType = 'suppression')]">
			<xsl:call-template name="places">
				<xsl:with-param name="list" select="$list/eac:placeEntry[not(@localType = 'birth') and not(@localType = 'death') and not(@localType = 'foundation') and not(@localType = 'private-residence') and not(@localType = 'business-residence') and not(@localType = 'suppression')]"/>
   				<xsl:with-param name="clazz" select="'locationOtherPlace_'"/>
   				<xsl:with-param name="posParent" select="$posParent"/>
   				<xsl:with-param name="posChild" select="$posChild"/>
				<xsl:with-param name="title" select="'eaccpf.description.place'"/>
				<xsl:with-param name="langNode" select="$langNode"/>
			</xsl:call-template> 
		</xsl:if>
	</xsl:template>

	<!-- template places -->
	<xsl:template name="places">
		<xsl:param name="list"/>
	    <xsl:param name="clazz"/>
	    <xsl:param name="posParent"/>
	    <xsl:param name="posChild"/>
	    <xsl:param name="title"/>
	    <xsl:param name="langNode"/>
	    
	    
		<xsl:if test="($langNode='notLang' and $list[not(@xml:lang)]/text()) 
						 or $list[@xml:lang=$langNode]/text() 
		                 or ($searchTerms!='' and 
		                 	(
			                 	$list[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
				      		 	or (
				      		 		$langNode!='notLang' and $list[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
			      		 		)
			      		 	)
			      		 )
					">
			
			<div class="row locationPlace">
			 	<div class="leftcolumn">
			   		<h2>
			   			<xsl:value-of select="ape:resource($title)"/>
			   			<xsl:text>:</xsl:text>
			   		</h2>
			   	</div>
			   	<div class="rightcolumn">
					<xsl:call-template name="showDetailsPlaceEntrySeveral">
		   				<xsl:with-param name="list" select="$list"/>
		   				<xsl:with-param name="clazz" select="$clazz"/>
		   				<xsl:with-param name="posParent" select="$posParent"/>
		   				<xsl:with-param name="posChild" select="$posChild"/>
		   				<xsl:with-param name="langNode" select="$langNode"/>
		   			</xsl:call-template>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- template term -->
	<xsl:template name="term">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>
		<xsl:param name="posParent"/>
		<xsl:param name="posChild"/>
		<xsl:param name="title"/>
		<xsl:param name="langNode"/>
		
		<xsl:if test="($langNode='notLang' and $list[not(@xml:lang)]/text()) 
				 or $list[@xml:lang=$langNode]/text() 
                 or ($searchTerms!='' and 
                 	(
	                 	$list[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
		      		 	or (
		      		 		$langNode!='notLang' and $list[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
	      		 		)
	      		 	)
	      		 )
			">
			<div class="row">
				<div class="leftcolumn">
			   		<h2>
			   			<xsl:value-of select="ape:resource($title)"/>
			   			<xsl:if test="$list/parent::node()/@localType">
				   			<xsl:text> (</xsl:text>
				   			<xsl:value-of select="$list/parent::node()/@localType"/>
				   			<xsl:text>)</xsl:text>
				   		</xsl:if>
			   			<xsl:text>:</xsl:text>
			   		</h2>
			   	</div>
			   	<div class="rightcolumn">
			   		<xsl:call-template name="showDetails">
		   				<xsl:with-param name="list" select="$list"/>
		   				<xsl:with-param name="clazz" select="$clazz"/>
		   				<xsl:with-param name="langNode" select="$langNode"/>
		   			</xsl:call-template>
				</div>
			</div>
			<xsl:if test="@href">
				<xsl:variable name="href" select="./@href"/>
				<a href="{$href}" target="_blank"><xsl:apply-templates select="." mode="other"/></a>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<!--template for common childs -->
	<xsl:template name="commonChild">
		<xsl:param name="list"/>
	    <xsl:param name="clazz"/>
	    <xsl:param name="posParent"/>
	    <xsl:param name="posChild"/>
	    <xsl:param name="title"/>
	    <xsl:param name="langNode"/>
	    	    
		<xsl:variable name="condSearchTermLang" select="$list[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]"/>
		<xsl:variable name="condSearchTermNoLang" select="$langNode!='notLang' and $list[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]"/>
		<xsl:variable name="condCitationText" select="name($list[1])='citation' and $list[fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]"/>
		<xsl:variable name="titleCitation" select="$list/@xlink:title"/>
		<xsl:variable name="condCitationNoText" select="name($list[1])='citation' and not($list/text()) and $list[fn:contains(fn:upper-case($titleCitation),fn:upper-case($searchTerms))]"/>	
		
		<xsl:if test="($langNode='notLang' and $list[not(@xml:lang)]/text()) or $list[@xml:lang=$langNode]/text() or (name($list[1]) ='citation' and (($langNode='notLang' and $list[not(@xml:lang)]) or $list[@xml:lang=$langNode]))
		                                     or ($searchTerms!='' and ($condSearchTermLang or $condSearchTermNoLang  or $condCitationText or $condCitationNoText))">
																  
			<div class="row">
				<div class="leftcolumn">
			   		<h2 class="subrow">
			   			<xsl:value-of select="ape:resource($title)"/>
			   			<xsl:text>:</xsl:text>
			   		</h2>
			   	</div>
			   	<div class="rightcolumn">
					<xsl:call-template name="showDetails">
		   				<xsl:with-param name="list" select="$list"/>
		   				<xsl:with-param name="clazz" select="$clazz"/>
		   				<xsl:with-param name="langNode" select="$langNode"/>
		   			</xsl:call-template>
				</div>
			</div>
			<xsl:if test="@href">
				<xsl:variable name="href" select="./@href"/>
				<a href="{$href}" target="_blank"><xsl:apply-templates select="." mode="other"/></a>
			</xsl:if>
		</xsl:if>	
	</xsl:template>

	<!-- Template for select the correct name to display as title based in the
		 value of the attribute "@localType". -->
	<xsl:template name="namePriorisation">
		<xsl:param name="list"/>

		<xsl:choose>
			<xsl:when test="count($list) > 1">
				<!-- Checks the attribute "@localType". -->
				<xsl:choose>
					<!-- localType = preferred -->
					<xsl:when test="$list[@localType = 'preferred']">
						<xsl:call-template name="multilanguageName">
							<xsl:with-param name="list" select="$list[@localType = 'preferred']"/>
						</xsl:call-template> 
					</xsl:when>
					<!-- localType = authorized -->
					<xsl:when test="$list[@localType = 'authorized']">
						<xsl:call-template name="multilanguageName">
							<xsl:with-param name="list" select="$list[@localType = 'authorized']"/>
						</xsl:call-template> 
					</xsl:when>
					<!-- not @localType -->
					<xsl:when test="$list[not(@localType)]">
						<xsl:call-template name="multilanguageName">
							<xsl:with-param name="list" select="$list[not(@localType)]"/>
						</xsl:call-template> 
					</xsl:when>
					<!-- localType = alternative -->
					<xsl:when test="$list[@localType = 'alternative']">
						<xsl:call-template name="multilanguageName">
							<xsl:with-param name="list" select="$list[@localType = 'alternative']"/>
						</xsl:call-template> 
					</xsl:when>
					<!-- localType = abbreviation -->
					<xsl:when test="$list[@localType = 'abbreviation']">
						<xsl:call-template name="multilanguageName">
							<xsl:with-param name="list" select="$list[@localType = 'abbreviation']"/>
						</xsl:call-template> 
					</xsl:when>
					<!-- localType = other -->
					<xsl:when test="$list[@localType = 'other']">
						<xsl:call-template name="multilanguageName">
							<xsl:with-param name="list" select="$list[@localType = 'other']"/>
						</xsl:call-template> 
					</xsl:when>
					<!-- In any other case checks the whole list. -->
					<xsl:otherwise>
						<xsl:call-template name="multilanguageName">
							<xsl:with-param name="list" select="$list"/>
						</xsl:call-template> 
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>
				<xsl:call-template name="multilanguageName">
					<xsl:with-param name="list" select="$list"/>
				</xsl:call-template> 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- template for language nameEntry -->
	<xsl:template name="multilanguageName">
		<xsl:param name="list"/>
			<xsl:choose>
				<xsl:when test="count($list) > 1">
					<xsl:choose>
						<xsl:when test="$list/eac:part[@xml:lang = $language.selected] and $list/eac:part[@xml:lang = $language.selected]/text() and $list/eac:part[@xml:lang = $language.selected]/text() != ''">
						    <xsl:for-each select="$list/eac:part[@xml:lang = $language.selected]">
								<xsl:if test="position()=1"> 
										<xsl:call-template name="compositeName">
											<xsl:with-param name="listName" select="current()/parent::node()"/>
											<xsl:with-param name="isHeader" select="'true'"/>
										</xsl:call-template> 
							 	</xsl:if> 
					 	    </xsl:for-each> 
						</xsl:when>
						<xsl:when test="$list/eac:part[@xml:lang = $lang.navigator] and $list/eac:part[@xml:lang = $lang.navigator]/text() and $list/eac:part[@xml:lang = $lang.navigator]/text() != ''"> 
						    <xsl:for-each select="$list/eac:part[@xml:lang = $lang.navigator]">
								<xsl:if test="position()=1"> 
										<xsl:call-template name="compositeName">
											<xsl:with-param name="listName" select="current()/parent::node()"/>
											<xsl:with-param name="isHeader" select="'true'"/>
										</xsl:call-template> 
							 	</xsl:if> 
					 	    </xsl:for-each> 
						</xsl:when>
						<xsl:when test="$list/eac:part[@xml:lang = $language.default] and $list/eac:part[@xml:lang = $language.default]/text() and $list/eac:part[@xml:lang = $language.default]/text() != ''">
						 	<xsl:for-each select="$list/eac:part[@xml:lang = $language.default]"> 
								  <xsl:if test="position()=1">
										<xsl:call-template name="compositeName"> 
											<xsl:with-param name="listName" select="current()/parent::node()"/>
											<xsl:with-param name="isHeader" select="'true'"/>
										</xsl:call-template> 
								 </xsl:if>
						  	</xsl:for-each>
						</xsl:when>
						<xsl:when test="$list/eac:part[not(@xml:lang)] and $list/eac:part[not(@xml:lang)]/text() and $list/eac:part[not(@xml:lang)]/text() != ''">
						  	<xsl:for-each select="$list/eac:part[not(@xml:lang)]"> 
							 	  <xsl:if test="position()=1"> 
									 <xsl:call-template name="compositeName">
												<xsl:with-param name="listName" select="current()/parent::node()"/>
												<xsl:with-param name="isHeader" select="'true'"/>
									 </xsl:call-template> 
							  	 </xsl:if>
						   	</xsl:for-each> 
						</xsl:when>
						<xsl:otherwise> 
						 	<xsl:variable name="language.first" select="$list[1]/eac:part[@xml:lang]"></xsl:variable>
							<xsl:for-each select="$list">
								<xsl:variable name="currentLang" select="current()/eac:part[@xml:lang]"></xsl:variable>
								<xsl:variable name="currentNode" select="current()/eac:part"></xsl:variable>
										<xsl:if test="$currentLang = $language.first">
											<xsl:if test="position() = 1">
												<xsl:call-template name="compositeName">
													<xsl:with-param name="listName" select="$currentNode/parent::node()"/>
													<xsl:with-param name="isHeader" select="'true'"/>
										   		</xsl:call-template> 
										  	</xsl:if>
										</xsl:if>
							</xsl:for-each>
					   </xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$list">
							<xsl:call-template name="compositeName">
								<xsl:with-param name="listName" select="current()"/>
								<xsl:with-param name="isHeader" select="'true'"/>
							</xsl:call-template> 
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>

	<!-- template for compose the name -->
	<xsl:template name="compositeName">
		<xsl:param name="listName"/>
		<xsl:param name="isHeader"/>
	    <xsl:call-template name="nameEntry">
	    	<xsl:with-param name="listName" select="$listName"/>
	    </xsl:call-template>
	    <xsl:if test="$isHeader = 'true'"> <!-- to display the alternative names -->
  			<span id="nameTitle" class="hidden">
  				<xsl:call-template name="nameEntry">
  					<xsl:with-param name="listName" select="$listName"/>
  				</xsl:call-template>
  			</span>
  		</xsl:if>	
	</xsl:template> 
	
	<!-- template nameEntry -->
	<xsl:template name="nameEntry">
		<xsl:param name="listName"/>
    	<xsl:variable name="firstName" select="$listName/eac:part[@localType='firstname']"/>
		<xsl:variable name="surName" select="$listName/eac:part[@localType='surname']"/>
		<xsl:variable name="patronymic" select="$listName/eac:part[@localType='patronymic']"/>
	    <xsl:variable name="prefix" select="$listName/eac:part[@localType='prefix']"/>
	    <xsl:variable name="suffix" select="$listName/eac:part[@localType='suffix']"/>
		<xsl:variable name="alias" select="$listName/eac:part[@localType='alias']"/>
		<xsl:variable name="title" select="$listName/eac:part[@localType='title']"/>
		<xsl:variable name="birthname" select="$listName/eac:part[@localType='birthname']"/>
		<xsl:variable name="legalform" select="$listName/eac:part[@localType='legalform']"/>
		<xsl:variable name="corpname" select="$listName/eac:part[@localType='corpname']"/>
		<xsl:variable name="famname" select="$listName/eac:part[@localType='famname']"/>
		<xsl:variable name="persname" select="$listName/eac:part[@localType='persname']"/>
    	<xsl:choose>
	    	<xsl:when test="not($corpname) and not($famname) and not($persname) and not($legalform) and not($listName/eac:part[not(@localType) or @localType=''])"> 
	    		<xsl:if test="$surName">
	    		<xsl:for-each select="$surName">
	    			<xsl:apply-templates select="." mode="other"/>
	    			<xsl:if test="position()!=last()">
	    				<xsl:text> </xsl:text>
	    			</xsl:if>
	    		</xsl:for-each>	
	    			<xsl:if test="$birthname">
	    				<xsl:text> </xsl:text>
	    			</xsl:if>
	    		</xsl:if>
	    		<xsl:if test="$birthname">
	    			<xsl:text>(</xsl:text>
	    		    <xsl:for-each select="$birthname"> 	
	    				<xsl:apply-templates select="." mode="other"/>
	    				<xsl:if test="position()!=last()">
	    					<xsl:text> </xsl:text>
	    				</xsl:if>
	    		  	</xsl:for-each>	  
	    			<xsl:text>)</xsl:text>
	    		</xsl:if>
	    		<xsl:if test="$prefix">
	    			<xsl:if test="$surName or $birthname">
	    				<xsl:text>, </xsl:text>
	    			</xsl:if>
	    			<xsl:for-each select="$prefix"> 	
	    				<xsl:apply-templates select="." mode="other"/>
	    				<xsl:if test="position()!=last()">
	    					<xsl:text> </xsl:text>
	    			    </xsl:if>
	    			</xsl:for-each>	  
	    		</xsl:if>
	    		<xsl:if test="$firstName">
	    			<xsl:if test="$surName or $birthname or $prefix">
	    				<xsl:text>, </xsl:text>
	    			</xsl:if>
	    			<xsl:for-each select="$firstName"> 	
	    				<xsl:apply-templates select="." mode="other"/>
	    				<xsl:if test="position()!=last()">
	    					<xsl:text> </xsl:text>
	    			    </xsl:if>
	    			</xsl:for-each>	
	    		</xsl:if>
	    		<xsl:if test="$patronymic">
	    			<xsl:choose>
	    				<xsl:when test="$firstName">
	    					<xsl:text> </xsl:text>
	    				</xsl:when>
	    				<xsl:otherwise>
	    					<xsl:if test="$surName or $birthname or $prefix">
			    				<xsl:text>, </xsl:text>
			    			</xsl:if>
	    				</xsl:otherwise>
	    			</xsl:choose>
	    			<xsl:for-each select="$patronymic"> 	
	    				<xsl:apply-templates select="." mode="other"/>
	    				<xsl:if test="position()!=last()">
	    					<xsl:text> </xsl:text>
	    			    </xsl:if>
	    			</xsl:for-each>	
	    		</xsl:if>
	    		<xsl:if test="$suffix">
	    			<xsl:if test="$surName or $birthname or $prefix or $firstName or $patronymic">
	    				<xsl:text>, </xsl:text>
	    			</xsl:if>
	    			<xsl:for-each select="$suffix"> 	
	    				<xsl:apply-templates select="." mode="other"/>
	    				<xsl:if test="position()!=last()">
	    					<xsl:text> </xsl:text>
	    			    </xsl:if>
	    			</xsl:for-each>	
	    		</xsl:if>
	    		<xsl:if test="$title">
	    			<xsl:if test="$surName or $birthname or $prefix or $firstName or $patronymic or $suffix">
	    				<xsl:text>, </xsl:text>
	    			</xsl:if>
	    			<xsl:for-each select="$title"> 	
	    				<xsl:apply-templates select="." mode="other"/>
	    				<xsl:if test="position()!=last()">
	    					<xsl:text> </xsl:text>
	    			    </xsl:if>
	    			</xsl:for-each>	
	    		</xsl:if>
	    	</xsl:when>
	    	<xsl:otherwise>
	    		<xsl:choose>
	    			<xsl:when test="$corpname and $legalform">
	    				<xsl:apply-templates select="$corpname" mode="other"/>
	    				<xsl:text> </xsl:text>
	    				<xsl:apply-templates select="$legalform" mode="other"/>
	    			</xsl:when>
	    			<xsl:otherwise>
	    				<xsl:apply-templates select="$listName/eac:part[1]" mode="other"/>
	    			</xsl:otherwise>
	    		</xsl:choose>
	    	</xsl:otherwise>
	    </xsl:choose>
	    <xsl:if test="$alias">
	    	<xsl:if test="$surName or $birthname or $prefix or $firstName or $patronymic or $suffix or $title or $corpname or $famname or $persname">
   				<xsl:text> </xsl:text> 
   			</xsl:if>
	   		<xsl:text>(</xsl:text><xsl:value-of select="ape:resource('eaccpf.portal.alias')"/><xsl:text>: </xsl:text>
	   		<xsl:for-each select="$alias"> 	
   				<xsl:apply-templates select="." mode="other"/>
   				<xsl:if test="position()!=last()">
   					<xsl:text> </xsl:text>
   			    </xsl:if>
   			</xsl:for-each>	
	   		<xsl:text>)</xsl:text>
	    </xsl:if>
	</xsl:template>
	
	<!-- template vocabularySource -->
	<xsl:template name="vocabularySource">
		<xsl:param name="node"/>
		<xsl:variable name="link" select="$node/@vocabularySource"/>
		<xsl:if test="not(starts-with($link, 'http')) and not(starts-with($link, 'https')) and not(starts-with($link, 'ftp')) and not(starts-with($link, 'www'))">
			<xsl:variable name="aiCodeEac" select="ape:aiFromEac($link, '')"/>
			<xsl:variable name="aiCodeEad" select="ape:aiFromEad($link, '')"/>
			<xsl:variable name="aiCodeEag" select="ape:checkAICode($link, '', 'true')" />
			<xsl:choose>
				<xsl:when test="$aiCodeEac != 'ERROR' and $aiCodeEac != ''">
					<xsl:variable name="encodedAiCode" select="ape:encodeSpecialCharacters($aiCodeEac)" />
					<xsl:variable name="encodedlink" select="ape:encodeSpecialCharacters($link)" />
					<a href="{$eacUrlBase}/aicode/{$encodedAiCode}/type/ec/id/{$encodedlink}" target="_blank">
						<xsl:apply-templates select="$node" mode="other"/>
					</a>
				</xsl:when>
				<xsl:when test="$aiCodeEad != 'ERROR' and $aiCodeEad != ''">
					<a href="{$eadUrl}/{$aiCodeEad}" target="_blank">
						<xsl:apply-templates select="$node" mode="other"/>
					</a>
				</xsl:when>
				<xsl:when test="$aiCodeEag != 'ERROR' and $aiCodeEag != ''">
					<xsl:variable name="encodedAiCode" select="ape:encodeSpecialCharacters($aiCodeEag)" />
					<a href="{$aiCodeUrl}/{$encodedAiCode}" target="_blank">
						<xsl:apply-templates select="$node" mode="other"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$node" mode="other"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if> 
		<xsl:if test="starts-with($link, 'http') or starts-with($link, 'https') or starts-with($link, 'ftp') or starts-with($link, 'www')">
			<a href="{$link}" target="_blank">
				<xsl:apply-templates select="$node" mode="other"/>
			</a>
		</xsl:if>	
	</xsl:template>	
	
	<xsl:template name="citationHrefTitle">
		<xsl:param name="content"/>
		<xsl:param name="section" />
		<xsl:param name="title"/>
		<xsl:variable name="name" select="name($section/parent::node())"/>
		<xsl:choose>
			<xsl:when test="$content != '' ">
				<xsl:apply-templates select="$content" mode="other"/>
			</xsl:when>
			<xsl:when test="$title != ''">
				<xsl:value-of select="fn:normalize-space(ape:highlight($title, 'other'))" disable-output-escaping="yes" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="ape:resource('eaccpf.portal.seeCitation')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- template for citation with/without @href -->
	<xsl:template name="citationHref">
		<xsl:param name="link"/>
		<xsl:param name="title"/>
		<xsl:param name="content"/>
		<xsl:param name="section" />
		<xsl:choose>
			<!--link ok -->
			<xsl:when test="starts-with($link, 'http') or starts-with($link, 'https') or starts-with($link, 'ftp') or starts-with($link, 'www')">
				<a href="{$link}" target="_blank">
					<xsl:call-template name="citationHrefTitle">
						<xsl:with-param name="content" select="$content" />
						<xsl:with-param name="section" select="$section" />
						<xsl:with-param name="title" select="$title" />
					</xsl:call-template>
				</a>
			</xsl:when>
			<!-- internal links -->
			<xsl:when test="$link != '' and not(starts-with($link, 'http')) and 
							not(starts-with($link, 'https')) and 
							not(starts-with($link, 'ftp')) and 
							not(starts-with($link, 'www'))">
				<xsl:variable name="aiCodeEac" select="ape:aiFromEac($link, '')"/>
				<xsl:variable name="aiCodeEad" select="ape:aiFromEad($link, '')"/>
				<xsl:variable name="aiCodeEag" select="ape:checkAICode($link, '', 'true')" />
				<xsl:choose>
					<xsl:when test="$aiCodeEac != 'ERROR' and $aiCodeEac != ''">
						<xsl:variable name="encodedAiCode" select="ape:encodeSpecialCharacters($aiCodeEac)" />
						<xsl:variable name="encodedlink" select="ape:encodeSpecialCharacters($link)" />
						<a href="{$eacUrlBase}/aicode/{$encodedAiCode}/type/ec/id/{$encodedlink}" target="_blank">
							<xsl:call-template name="citationHrefTitle">
								<xsl:with-param name="content" select="$content" />
								<xsl:with-param name="section" select="$section" />
								<xsl:with-param name="title" select="$title" />
							</xsl:call-template>
						</a>
					</xsl:when>
					<xsl:when test="$aiCodeEad != 'ERROR' and $aiCodeEad != ''">
						<a href="{$eadUrl}/{$aiCodeEad}" target="_blank">
							<xsl:call-template name="citationHrefTitle">
								<xsl:with-param name="content" select="$content" />
								<xsl:with-param name="section" select="$section" />
								<xsl:with-param name="title" select="$title" />
							</xsl:call-template>
						</a>
					</xsl:when>
					<xsl:when test="$aiCodeEag != 'ERROR' and $aiCodeEag != ''">
						<xsl:variable name="encodedAiCode" select="ape:encodeSpecialCharacters($aiCodeEag)" />
						<a href="{$aiCodeUrl}/{$encodedAiCode}" target="_blank">
							<xsl:call-template name="citationHrefTitle">
								<xsl:with-param name="content" select="$content" />
								<xsl:with-param name="section" select="$section" />
								<xsl:with-param name="title" select="$title" />
							</xsl:call-template>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="citationHrefTitle">
							<xsl:with-param name="content" select="$content" />
							<xsl:with-param name="section" select="$section" />
							<xsl:with-param name="title" select="$title" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!--link ko -->
			<xsl:otherwise>
				<xsl:call-template name="citationHrefTitle">
					<xsl:with-param name="content" select="$content" />
					<xsl:with-param name="section" select="$section" />
					<xsl:with-param name="title" select="$title" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Template to display de country name from country code. -->
	<xsl:template name="countryName">
		<xsl:param name="countryCode"/>

		<xsl:choose>
			<xsl:when test="$countryCode = 'EU' or $countryCode = 'eu'">
				<xsl:text> (</xsl:text>
					<xsl:value-of select="ape:resource('country.europe')"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="countryName" select="ape:countryName($language.selected, $countryCode)" />
				<xsl:if test="$countryName != 'ERROR' and $countryName != ''">
					<xsl:text> (</xsl:text>
						<xsl:value-of select="$countryName"/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- template for multilanguage -->
	<xsl:template name="multilanguage">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>
		<xsl:choose>
			<xsl:when test="count($list) > 1">
			<div id="{$clazz}" class= "moreDisplay">
				<xsl:choose>
					<xsl:when test="$list[@xml:lang = $language.selected] and $list[@xml:lang = $language.selected]/text() and $list[@xml:lang = $language.selected]/text() != ''">
						<xsl:for-each select="$list">
							<xsl:variable name="currentLang" select="current()/@xml:lang"></xsl:variable>
							<xsl:if test="(($currentLang = $language.selected) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms)))">
								<p>
								    <xsl:apply-templates mode="other"/> 
			   						<xsl:if test="name(current()) = 'language'">
										<xsl:if test="./parent::node()/eac:descriptiveNote/eac:p/text() ">
											<xsl:text> (</xsl:text>
											<xsl:call-template  name="multilanguageNoP">
									   			<xsl:with-param name="list" select="./parent::node()/eac:descriptiveNote/eac:p"/>
									   			<xsl:with-param name="clazz" select="'language'"/>
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:if>
								</p>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$list[@xml:lang = $lang.navigator] and $list[@xml:lang = $lang.navigator]/text() and $list[@xml:lang = $lang.navigator]/text() != ''">
						<xsl:for-each select="$list">
							<xsl:variable name="currentLang" select="current()/@xml:lang"></xsl:variable>
							<xsl:if test="(($currentLang = $lang.navigator) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms)))">
								<p>
								    <xsl:apply-templates mode="other"/> 
			   						<xsl:if test="name(current()) = 'language'">
										<xsl:if test="./parent::node()/eac:descriptiveNote/eac:p/text() ">
											<xsl:text> (</xsl:text>
											<xsl:call-template  name="multilanguageNoP">
									   			<xsl:with-param name="list" select="./parent::node()/eac:descriptiveNote/eac:p"/>
									   			<xsl:with-param name="clazz" select="'language'"/>
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:if>
								</p>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$list[@xml:lang = $language.default] and $list[@xml:lang = $language.default]/text() and $list[@xml:lang = $language.default]/text() != ''">
						<xsl:for-each select="$list">
							<xsl:variable name="currentLang" select="current()/@xml:lang"></xsl:variable>
							<xsl:if test="(($currentLang = $language.default) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms)))">
								<p>
									<xsl:apply-templates mode="other"/> 
			   						<xsl:if test="name(current()) = 'language'">
										<xsl:if test="./parent::node()/eac:descriptiveNote/eac:p/text() ">
											<xsl:text> (</xsl:text>
											<xsl:call-template  name="multilanguageNoP">
									   			<xsl:with-param name="list" select="./parent::node()/eac:descriptiveNote/eac:p"/>
									   			<xsl:with-param name="clazz" select="'language'"/>
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:if>
								</p>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$list[not(@xml:lang)] and $list[not(@xml:lang)]/text() and $list[not(@xml:lang)]/text() != ''">
						  	<!--  	<xsl:for-each select="$list[not(@xml:lang)]"> -->
						     <xsl:for-each select="$list">
						     	<xsl:if test="not(@xml:lang) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms))">
									<p>
									  	<xsl:apply-templates select="." mode="other"/>
			   							<xsl:if test="name(current()) = 'language'">
											<xsl:if test="./parent::node()/eac:descriptiveNote/eac:p/text() ">
												<xsl:text> (</xsl:text>
												<xsl:call-template  name="multilanguageNoP">
										   			<xsl:with-param name="list" select="./parent::node()/eac:descriptiveNote/eac:p"/>
										   			<xsl:with-param name="clazz" select="'language'"/>
												</xsl:call-template>
												<xsl:text>)</xsl:text>
											</xsl:if>
										</xsl:if>
							   		</p>
							   	</xsl:if>	
						   	</xsl:for-each> 
					</xsl:when>
					<xsl:otherwise> <!-- first language -->
						<xsl:variable name="language.first" select="$list[1]/@xml:lang"></xsl:variable>
						<xsl:for-each select="$list">
							<xsl:variable name="currentLang" select="current()/@xml:lang"></xsl:variable>
							<xsl:if test="(($currentLang = $language.first) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms)))">
								<p>
									 <xsl:apply-templates select="." mode="other"/> 	
			   							<xsl:if test="name(current()) = 'language'">
										<xsl:if test="./parent::node()/eac:descriptiveNote/eac:p/text() ">
											<xsl:text> (</xsl:text>
											<xsl:call-template  name="multilanguageNoP">
									   			<xsl:with-param name="list" select="./parent::node()/eac:descriptiveNote/eac:p"/>
									   			<xsl:with-param name="clazz" select="'language'"/>
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:if>	 
								</p>			
							</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$list">
					<p>
						<xsl:apply-templates mode="other"/>
						<xsl:if test="name(current()) = 'language'">
							<xsl:if test="./parent::node()/eac:descriptiveNote/eac:p/text() ">
								<xsl:text> (</xsl:text>
								<xsl:call-template  name="multilanguageNoP">
						   			<xsl:with-param name="list" select="./parent::node()/eac:descriptiveNote/eac:p"/>
						   			<xsl:with-param name="clazz" select="'language'"/>
								</xsl:call-template>
								<xsl:text>)</xsl:text>
							</xsl:if>
						</xsl:if>
					</p>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- template for multilanguage wit no <p> -->
	<xsl:template name="multilanguageNoP">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>	
		<xsl:choose>
			<xsl:when test="count($list) > 1">
				<xsl:choose>
					<!-- lang equals selected language -->
					<xsl:when test="$list[@xml:lang = $language.selected] and $list[@xml:lang = $language.selected]/text() and $list[@xml:lang = $language.selected]/text() != ''">
						<xsl:for-each select="$list">
						   <xsl:variable name="currentLang" select="current()/@xml:lang"/>
							 <xsl:if test="(($currentLang = $language.selected) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms)))">
								<xsl:if test="position() > 1">
									<xsl:text> </xsl:text>
							    </xsl:if>
						   		 <xsl:apply-templates mode="other"/> 
							 </xsl:if>
						</xsl:for-each>
					</xsl:when>
					<!-- navigator's language -->
					<xsl:when test="$list[@xml:lang = $lang.navigator] and $list[@xml:lang = $lang.navigator]/text() and $list[@xml:lang = $lang.navigator]/text() != ''">
						<xsl:for-each select="$list">
						   <xsl:variable name="currentLang" select="current()/@xml:lang"/>
							 <xsl:if test="(($currentLang = $lang.navigator) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms)))">
								<xsl:if test="position() > 1">
									<xsl:text> </xsl:text>
							    </xsl:if>
						   		 <xsl:apply-templates mode="other"/> 
							 </xsl:if>
						</xsl:for-each>
					</xsl:when>
					<!-- default language -->
					<xsl:when test="$list[@xml:lang = $language.default] and $list[@xml:lang = $language.default]/text() and $list[@xml:lang = $language.default]/text() != ''">
						<xsl:for-each select="$list">
						   <xsl:variable name="currentLang" select="current()/@xml:lang"/>
							 <xsl:if test="(($currentLang = $language.default) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms)))">
								<xsl:if test="position() > 1">
									<xsl:text> </xsl:text>
							    </xsl:if>
						   		 <xsl:apply-templates mode="other"/> 
							 </xsl:if>
						</xsl:for-each>
					</xsl:when>
				  	
				  	<!-- no lang -->
					<xsl:when test="$list[not(@xml:lang)] and $list[not(@xml:lang)]/text() and $list[not(@xml:lang)]/text() != ''">
					   <xsl:for-each select="$list">
					     <xsl:if test="not(@xml:lang) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms))">
							<xsl:if test="position() > 1">
								<xsl:text> </xsl:text>
						    </xsl:if>
					   		 <xsl:apply-templates mode="other"/> 
						 </xsl:if>
						</xsl:for-each>
					</xsl:when>
					
					<!-- first language -->
					<xsl:otherwise> 
						<xsl:variable name="language.first" select="$list[1]/@xml:lang"></xsl:variable>
						<xsl:for-each select="$list">
							<xsl:variable name="currentLang" select="current()/@xml:lang"></xsl:variable>
							<xsl:if test="(($currentLang = $language.first) or fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms)))">
								<xsl:if test="position() > 1">
								   <xsl:text> </xsl:text>
						        </xsl:if>
					   		 	<xsl:apply-templates mode="other"/> 
						    </xsl:if>
						 </xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- 1 element -->
			<xsl:otherwise>
				<xsl:for-each select="$list">
					<xsl:apply-templates mode="other"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--template for outline in structureOrGenealogy-->
	<xsl:template name="outlineStructure">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>
		<xsl:param name="entityType"/>
		<xsl:if test="$list/eac:outline/eac:level/eac:item/text()"> 
		   	<div class="row">
				<div class="leftcolumn">
					<xsl:if test="$entityType='person'">
				    	<h2 class="subrow"><xsl:value-of select="ape:resource('eaccpf.portal.genealogy')"/><xsl:text>:</xsl:text></h2>
					</xsl:if>
					<xsl:if test="$entityType='corporateBody'">
						<h2 class="subrow"><xsl:value-of select="ape:resource('eaccpf.portal.structure')"/><xsl:text>:</xsl:text></h2>
					</xsl:if>
					<xsl:if test="$entityType='family'">
						<h2 class="subrow"><xsl:value-of select="ape:resource('eaccpf.portal.structureOrGenealogy')"/><xsl:text>:</xsl:text></h2>
				   </xsl:if>
			   	</div>
			   	<div class="rightcolumn" id="{$clazz}">
			   		<xsl:call-template name="multilanguageOutline">
			   			<xsl:with-param name="list" select="$list/eac:outline/eac:level"/>
			   		</xsl:call-template>
				</div>
		  </div>
		</xsl:if>
	</xsl:template>
	
	<!--template for outline -->
	<xsl:template name="outline">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>
		<xsl:param name="title"/>
		<xsl:if test="$list/eac:outline/eac:level/eac:item/text()"> 
		   	<div class="row">
				<div class="leftcolumn">
			   		<h2 class="subrow"><xsl:value-of select="ape:resource($title)"/><xsl:text>:</xsl:text></h2>
			   	</div>
			   	<div class="rightcolumn" id="{$clazz}">
			   		<xsl:call-template name="multilanguageOutline">
			   			<xsl:with-param name="list" select="$list/eac:outline/eac:level"/>
			   		</xsl:call-template>
				</div>
		  </div>
		</xsl:if>
	</xsl:template>
	
	<!-- template for <p> in structureOrGenealogy or generalContext-->
	<xsl:template name="p">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>
		<xsl:param name="langNode"/>
		
		 <xsl:if test="($langNode='notLang' and $list/eac:p[not(@xml:lang)]/text()) 
						 or $list/eac:p[@xml:lang=$langNode]/text() 
		                 or ($searchTerms!='' and 
		                 	(
			                 	$list/eac:p[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
				      		 	or (
				      		 		$langNode!='notLang' and $list/eac:p[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
			      		 		)
			      		 	)
			      		 )
					">
	
			<div class="row">
				<div class="leftcolumn">
			   		<h2>
			   			<xsl:value-of select="ape:resource('eaccpf.portal.note')"/>
			   			<xsl:text>:</xsl:text>
		   			</h2>
			   	</div>
			   	<div class="rightcolumn">
					
					<xsl:call-template name="showDetailsDescriptiveNote">
			   			<xsl:with-param name="list" select="$list/eac:p"/>
			   			<xsl:with-param name="clazz" select="$clazz"/>
			   			<xsl:with-param name="langNode" select="$langNode"/>
			   		</xsl:call-template>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- template for outline -->
	<xsl:template name="multilanguageOutline">
		<xsl:param name="list"/><!-- outline/level -->
		<xsl:choose>
		    <!-- selected language -->
			<xsl:when test="$list/descendant-or-self::node()/eac:item[@xml:lang = $language.selected] and $list/descendant-or-self::node()/eac:item[@xml:lang = $language.selected]/text() and $list/descendant-or-self::node()/eac:item[@xml:lang = $language.selected]/text() != ''">
				<xsl:call-template name="multilanguageOutlineRecursive">
					<xsl:with-param name="list" select="$list"/>
					<xsl:with-param name="language" select="$language.selected"/>
				</xsl:call-template>
			</xsl:when> 
			<!-- language's navigator -->
			<xsl:when test="$list/descendant-or-self::node()/eac:item[@xml:lang = $lang.navigator] and $list/descendant-or-self::node()/eac:item[@xml:lang = $lang.navigator]/text() and $list/descendant-or-self::node()/eac:item[@xml:lang = $lang.navigator]/text() != ''">
				<xsl:call-template name="multilanguageOutlineRecursive">
					<xsl:with-param name="list" select="$list"/>
					<xsl:with-param name="language" select="$lang.navigator"/>
				</xsl:call-template>
			</xsl:when> 
			<!-- default language (english) -->
			<xsl:when test="$list/descendant-or-self::node()/eac:item[@xml:lang = $language.default] and $list/descendant-or-self::node()/eac:item[@xml:lang = $language.default]/text() and $list/descendant-or-self::node()/eac:item[@xml:lang = $language.default]/text() != ''">
				<xsl:call-template name="multilanguageOutlineRecursive">
					<xsl:with-param name="list" select="$list"/>
					<xsl:with-param name="language" select="$language.default"/>
				</xsl:call-template>
			</xsl:when>
			<!-- not lang -->
			<xsl:when test="$list/descendant-or-self::node()/eac:item[not(@xml:lang)] and $list/descendant-or-self::node()/eac:item[not(@xml:lang)]/text() and $list/descendant-or-self::node()/eac:item[not(@xml:lang)]/text() != ''">
				<xsl:call-template name="multilanguageOutlineRecursive">
					<xsl:with-param name="list" select="$list"/>
					<xsl:with-param name="language" select="'notLang'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise> <!-- First language -->
				<xsl:variable name="language.first" select="$list[1]/eac:item/@xml:lang"/>
				<xsl:call-template name="multilanguageOutlineRecursive">
					<xsl:with-param name="list" select="$list"/>
					<xsl:with-param name="language" select="$language.first"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	
	<!-- template for outline recursive -->
	<xsl:template name="multilanguageOutlineRecursive">
		<xsl:param name="list"/>
		<xsl:param name="language"/>
	    <ul class="level">
			 <xsl:for-each select="$list">
				 	<xsl:if test="./descendant-or-self::node()/eac:item[@xml:lang = $language] or ($language='notLang' and ./descendant-or-self::node()/eac:item[not(@xml:lang)]) or ./descendant-or-self::node()/eac:item[fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]"> 
						<xsl:choose>
							<xsl:when test="name(./parent::node()) != 'outline'">
							   <ul class="level">
							      <li class="item">
							        <xsl:apply-templates select="./eac:item" mode="other"/> 
							      </li>
								</ul>
							</xsl:when>
							<xsl:otherwise>
								<li class="item">
								 	<xsl:apply-templates select="./eac:item" mode="other"/> 
							 	</li>
						 	</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:for-each select="./eac:level">
						<xsl:call-template name="multilanguageOutlineRecursive">
							<xsl:with-param name="list" select="."/>
							<xsl:with-param name="language" select="$language"/>
						</xsl:call-template>
					</xsl:for-each> 
				</xsl:for-each> 
 		</ul>
	</xsl:template>
	<!-- Template to show the information according with the language and the search term  -->
	<xsl:template name="showDetails">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>
		<xsl:param name="langNode"/>
		
	  	<div id="{$clazz}">
			<xsl:for-each select="$list">
				<xsl:choose>
					<xsl:when test=".[@xml:lang=$langNode]/text() or ($langNode='notLang' and .[not(@xml:lang)]/text()) or (name(.)='citation'and (@xml:lang=$langNode) or ($langNode='notLang' and not(@xml:lang)))">
						<p>
							<xsl:choose>
								<xsl:when test="@vocabularySource">
									<xsl:call-template name="vocabularySource">
										<xsl:with-param name="node" select="."/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="name(current()) = 'citation'">
									<xsl:call-template name="citationHref">
										<xsl:with-param name="link" select="./@xlink:href"/>
										<xsl:with-param name="title" select="./@xlink:title" />
										<xsl:with-param name="content" select="./text()"/>
										<xsl:with-param name="section" select="$list"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="other"/> 
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="@countryCode">
								<xsl:call-template name="countryName">
									<xsl:with-param name="countryCode" select="./@countryCode"/>
			   			        </xsl:call-template>
		   			        </xsl:if>
						</p>
					</xsl:when>
					<xsl:when test="$searchTerms != '' and (fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms))
									                        or (name(.)='citation' and not(./text()) and fn:contains(fn:upper-case(./@xlink:title),fn:upper-case($searchTerms))))">
						<p>

							<xsl:choose>
								<xsl:when test="@vocabularySource">
									<xsl:call-template name="vocabularySource">
										<xsl:with-param name="node" select="."/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="name(current()) = 'citation'">
									<xsl:call-template name="citationHref">
										<xsl:with-param name="link" select="./@xlink:href"/>
										<xsl:with-param name="title" select="./@xlink:title" />
										<xsl:with-param name="content" select="./text()"/>
										<xsl:with-param name="section" select="$list"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="other"/> 
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="@countryCode">
								<xsl:call-template name="countryName">
									<xsl:with-param name="countryCode" select="./@countryCode"/>
			   			        </xsl:call-template>
		   			        </xsl:if>
						</p>
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>	
			</xsl:for-each>
		 </div> 
	</xsl:template>
	
	<!--Template to show the information about placeEntry  -->
		<xsl:template name="showDetailsPlaceEntrySeveral">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>
		<xsl:param name="posParent"/>
		<xsl:param name="posChild"/>
		<xsl:param name="langNode"/>
		
		<div id="{$clazz}{$posParent}{$posChild}" class= "moreDisplay">
			<xsl:for-each select="$list">
				<xsl:choose>
					<xsl:when test=".[@xml:lang=$langNode]/text() or ($langNode='notLang' and .[not(@xml:lang)]/text())">
						<p>
							<xsl:choose>
								<xsl:when test="@vocabularySource">
									<xsl:call-template name="vocabularySource">
										<xsl:with-param name="node" select="."/>
			   		   			    </xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="other"/>
								</xsl:otherwise>
							</xsl:choose>
		
							<xsl:if test="@countryCode">
								<xsl:call-template name="countryName">
									<xsl:with-param name="countryCode" select="./@countryCode"/>
			   			        </xsl:call-template>
		   			        </xsl:if>
						</p>
					</xsl:when>
					<xsl:when test="$searchTerms != '' and fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms))">
						<p>
							<xsl:choose>
								<xsl:when test="@vocabularySource">
									<xsl:call-template name="vocabularySource">
										<xsl:with-param name="node" select="."/>
			   		   			    </xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="other"/>
								</xsl:otherwise>
							</xsl:choose>
		
							<xsl:if test="@countryCode">
								<xsl:call-template name="countryName">
									<xsl:with-param name="countryCode" select="./@countryCode"/>
			   			        </xsl:call-template>
		   			        </xsl:if>
						</p>
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>	
			</xsl:for-each>
		</div>
	</xsl:template>
	<xsl:template name="showDetailsDescriptiveNote">
		<xsl:param name="list"/>
		<xsl:param name="clazz"/>
		<xsl:param name="langNode"/>

		<div id="{$clazz}">
			<xsl:for-each select="$list">
				<xsl:choose>
					<xsl:when test=".[@xml:lang=$langNode]/text() or ($langNode='notLang' and .[not(@xml:lang)]/text())">
						<p>
							<xsl:apply-templates select="." mode="other"/>
							<xsl:if test="name(current()) = 'language'">
								<xsl:call-template  name="descriptiveNoteNoP">
									<xsl:with-param name="element" select="current()"/>
									<xsl:with-param name="clazz" select="'language'"/>
									<xsl:with-param name="langNode" select="$langNode"/>								
								</xsl:call-template>
							</xsl:if>
						</p>
					</xsl:when>
					<xsl:when test="$searchTerms != '' and fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms))">
						<p>
							<xsl:apply-templates select="." mode="other"/>
							<xsl:if test="name(current()) = 'language'">
								<xsl:call-template  name="descriptiveNoteNoP">
									<xsl:with-param name="element" select="current()"/>
									<xsl:with-param name="clazz" select="'language'"/>
									<xsl:with-param name="langNode" select="$langNode"/>
								</xsl:call-template>
							</xsl:if>
						</p>
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>	
			</xsl:for-each>
		</div>
	</xsl:template>
	
	<!-- Template to display correctly the details of the "<descriptiveNote>"
		 element inside "<languageUsed>" element. -->
	<xsl:template name="descriptiveNoteNoP">
		<xsl:param name="element"/>
		<xsl:param name="clazz"/>
		<xsl:param name="langNode"/>
		
		<!-- Try to select the 'default' mode. -->
		<xsl:if test="($langNode='notLang' and $element/parent::node()/eac:descriptiveNote/eac:p[not(@xml:lang)]/text()) 
				 or $element/parent::node()/eac:descriptiveNote/eac:p[@xml:lang=$langNode]/text() 
                 or ($searchTerms!='' and 
                 	(
	                 	$element/parent::node()/eac:descriptiveNote/eac:p[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
		      		 	or (
		      		 		$langNode!='notLang' and $element/parent::node()/eac:descriptiveNote/eac:p[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]
	      		 		)
	      		 	)
	      		 )
			">
			
			<xsl:text> (</xsl:text>
			<xsl:call-template  name="showDetailsNoP">
				<xsl:with-param name="list" select="$element/parent::node()/eac:descriptiveNote/eac:p"/>
				<xsl:with-param name="langNode" select="$langNode"/>
			</xsl:call-template>
			<xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- template for show details in descriptiveNote -->
	<xsl:template name="showDetailsNoP">
		<xsl:param name="list"/>
		<xsl:param name="langNode"/>
		
		<xsl:for-each select="$list">
			<xsl:choose>
				<xsl:when test=".[@xml:lang=$langNode]/text() or ($langNode='notLang' and .[not(@xml:lang)]/text())">
					<xsl:if test="position() > 1">
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:apply-templates mode="other"/>
				</xsl:when>
				<xsl:when test="$searchTerms != '' and fn:contains(fn:upper-case(./text()),fn:upper-case($searchTerms))">
					<xsl:if test="position() > 1">
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:apply-templates mode="other"/>
				</xsl:when>
				<xsl:otherwise/>
				</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Template that will show the information in placeEntry -->
	<xsl:template name="showDetailsPlaceEntry">
		<xsl:param name="list"/>
		<xsl:param name="langNode"/>
		
			<xsl:choose>
				<xsl:when test="$list[@xml:lang=$langNode]/text()">
					<xsl:for-each select="$list[@xml:lang=$langNode]">
						<xsl:if test="position() = 1">
							<xsl:choose>
								<xsl:when test="@vocabularySource">
									<xsl:call-template name="vocabularySource">
										<xsl:with-param name="node" select="."/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="other"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="@countryCode">
								<xsl:call-template name="countryName">
									<xsl:with-param name="countryCode" select="./@countryCode"/>
			   			        </xsl:call-template>
		   			        </xsl:if>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>	
				<xsl:when test="$langNode='notLang' and $list[not(@xml:lang)]/text()">
					<xsl:for-each select="$list[not(@xml:lang)]">
						<xsl:if test="position() =1 and $langNode = 'notLang'">
							<xsl:choose>
								<xsl:when test="@vocabularySource">
									<xsl:call-template name="vocabularySource">
										<xsl:with-param name="node" select="."/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="other"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="@countryCode">
								<xsl:call-template name="countryName">
									<xsl:with-param name="countryCode" select="./@countryCode"/>
			   			        </xsl:call-template>
		   			        </xsl:if>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$searchTerms != '' and ($list[@xml:lang != $langNode][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] 
														or ($list[not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))] and $langNode!='notLang'))">
					
					<xsl:for-each select="$list[@xml:lang != $langNode or not(@xml:lang)][fn:contains(fn:upper-case(text()),fn:upper-case($searchTerms))]">
						<xsl:if test="position()=1 and $langNode!='notLang'"> 
							<xsl:choose>
								<xsl:when test="@vocabularySource">
									<xsl:call-template name="vocabularySource">
										<xsl:with-param name="node" select="."/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="other"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="@countryCode">
								<xsl:call-template name="countryName">
									<xsl:with-param name="countryCode" select="./@countryCode"/>
			   			        </xsl:call-template>
		   			        </xsl:if>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
	</xsl:template>
</xsl:stylesheet>