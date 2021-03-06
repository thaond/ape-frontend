<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="portal" uri="http://portal.archivesportaleurope.eu/tags"%>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<%@ taglib prefix="liferay-portlet" uri="http://liferay.com/tld/portlet" %>
<fmt:requestEncoding value="UTF-8" />
<portlet:defineObjects />
<portlet:renderURL var="advancedSearchUrl">
	<portlet:param name="myaction" value="advancedSearch" />
</portlet:renderURL>
<c:set var="portletNamespace"><portlet:namespace/></c:set>
<portal:friendlyUrl var="helpUrl" type="help-pages"/>
<portal:removeParameters  var="ajaxAdvancedSearchUrl" namespace="${portletNamespace}" parameters="myaction,term,resultsperpage,advanced,dao,view,method"><portlet:resourceURL id="advancedSearch" /></portal:removeParameters>
<portal:removeParameters  var="displayPreviewUrl" namespace="${portletNamespace}" parameters="myaction,term,resultsperpage,advanced,dao,view,method"><portlet:resourceURL id="displayPreview" /></portal:removeParameters>
<portal:removeParameters  var="autocompletionUrl" namespace="${portletNamespace}" parameters="myaction,term,resultsperpage,advanced,dao,view,method"><portlet:resourceURL id="autocompletion" /></portal:removeParameters>
<portlet:resourceURL var="navigatedTreeUrl" id="navigatedTree" />
<portlet:resourceURL var="generateNavigatedTreeAiUrl" id="generateNavigatedTreeAi" />
<portlet:resourceURL var="generateNavigatedTreeAiContentUrl" id="generateNavigatedTreeAiContent" />
<portlet:resourceURL var="archivalLandscapeTreeUrl" id="archivalLandscapeTree" />
<portlet:resourceURL var="saveSearchUrl" id="saveSearch" />

<portal:page  varPlId="eacCpfSearchPlId"  varPortletId="eacCpfSearchPortletId" portletName="eaccpfsearch" friendlyUrl="/name-search"/>		
<liferay-portlet:renderURL var="eacCpfSearchUrl"  plid="${eacCpfSearchPlId}" portletName="${eacCpfSearchPortletId}">
	<portlet:param name="myaction" value="simpleSearch" />
</liferay-portlet:renderURL>
<portal:page  varPlId="eagSearchPlId"  varPortletId="eagSearchPortletId" portletName="eagsearch" friendlyUrl="/institution-search"/>		
<liferay-portlet:renderURL var="eagSearchUrl"  plid="${eagSearchPlId}" portletName="${eagSearchPortletId}">
	<portlet:param name="myaction" value="simpleSearch" />
</liferay-portlet:renderURL>
		<c:choose>
			<c:when test="${eadSearch.showOnlyResults}">
		<script type="text/javascript">
			$(document).ready(function() {
				setUrls("${ajaxAdvancedSearchUrl}","${autocompletionUrl}", "${saveSearchUrl}","${archivalLandscapeTreeUrl}","${displayPreviewUrl}", "<portlet:namespace/>");	
			});
			
		</script>			
			</c:when>
			<c:otherwise>
		<script type="text/javascript">
			$(document).ready(function() {
				setCommonUrls("${eacCpfSearchUrl}","","${eagSearchUrl}");
				initCommon();
				setUrls("${ajaxAdvancedSearchUrl}","${autocompletionUrl}", "${saveSearchUrl}","${archivalLandscapeTreeUrl}","${displayPreviewUrl}", "<portlet:namespace/>");
				init();
				initTooltip('#sourceTabs .icon_help', "#sourceTabsSearchHelpDialog", "left", "center");
				initTooltip('#navigatedSearch .icon_help', "#navigatedSearchHelpDialog", "right", "center");
				initTooltip('#advancedSearch .icon_help', "#advancedSearchHelpDialog", "right", "center");
				initTooltip('#simpleSearch .icon_help', "#simpleSearchHelpDialog", "left", "center");
				initTooltip('#searchResultsContainer #tabs .icon_help', "#searchResultsHelpDialog", "right", "center");				
			});
			
		</script>
			</c:otherwise>
</c:choose>
<div id="searchingPart">
		<div id="eadSearchPortlet" >
		<c:choose>
			<c:when test="${eadSearch.showOnlyResults}">
			<portal:friendlyUrl var="savedSearchUrl" type="widget-saved-search" />
			<h2 id="searchResultsHeader"><fmt:message key="advancedsearch.text.results.in" /> '<c:out value="${eadSearch.savedSearchDescription }"/>' <fmt:message key="advancedsearch.text.results.with.searchterm" />: '<c:out value="${eadSearch.term }"/>' (<a href="${savedSearchUrl}/${eadSearch.savedSearchId}?term=<c:out value="${eadSearch.term }"/>"><fmt:message key="advancedsearch.text.results.alloptions" /></a>)</h2></c:when>
			<c:otherwise>
			<portal:sourceTabs results="${results}" type="ead"/>
			<div id="searchOptions">
			
			<div id="sourceTabsSearchHelpDialog" class="hidden">
				<div class="tooltipContent">
					<h3><fmt:message key="search.sourcetabs.help.title"/>:</h3>
					<ul>
						<li><b><fmt:message key="menu.archives-search"/></b>&nbsp;<fmt:message key="search.sourcetabs.help.ead.description"/></li>
						<li><b><fmt:message key="menu.name-search"/></b>&nbsp;<fmt:message key="search.sourcetabs.help.eac-cpf.description"/></li>
						<li><b><fmt:message key="menu.institution-search"/></b>&nbsp;<fmt:message key="search.sourcetabs.help.eag.description"/></li>
					</ul>
				</div>
			</div>			
			<div id="navigatedSearchHelpDialog" class="hidden">
				<div class="tooltipContent">
					<div class="tooltipSubContent"><fmt:message key="search.ead.navigatedsearch.help" /></div>
					<div class="linkToMoreHelp"><fmt:message key="search.help.more" />&nbsp;<a href="${helpUrl}/searching" target="blank"><fmt:message key="search.help.more.link" /></a>.</div>
				</div>
			</div>
			<div id="advancedSearchHelpDialog" class="hidden">
				<div class="tooltipContent">			
					<h3><fmt:message key="help.tooltip.prefix" /> '<fmt:message key="advancedsearch.title.advancedsearch" />':</h3>
					<div class="tooltipSubContent">
						<ul>
							<li><fmt:message key="search.ead.element.help" /></li>
							<li class="ul-with-children">	
								<ul>
									<li><fmt:message key="search.ead.element.referencecode.help" /></li>
								</ul>
							</li>
							<li><fmt:message key="search.ead.typedocument.help" /></li>
							<li class="ul-with-children">	
								<ul>
									<li><fmt:message key="search.ead.typedocument.fa.help" /></li>
									<li><fmt:message key="search.ead.typedocument.hg.help" /></li>
									<li><fmt:message key="search.ead.typedocument.sg.help" /></li>
								</ul>
							</li>								
						</ul>
					</div>
					<div class="linkToMoreHelp"><fmt:message key="search.help.more" />&nbsp;<a href="${helpUrl}/searching" target="blank"><fmt:message key="search.help.more.link" /></a>.</div>
				</div>
			</div>	
			<div id="simpleSearchHelpDialog" class="hidden">
				<div class="tooltipContent">			
					<div class="tooltipSubContent">
						<ul>
							<li><fmt:message key="search.ead.hierarchy.help" /></li>
							<li><fmt:message key="search.method.help" /></li>

					
						</ul>		
					</div>
					<div class="linkToMoreHelp"><fmt:message key="search.help.more" />&nbsp;<a href="${helpUrl}/searching" target="blank"><fmt:message key="search.help.more.link" /></a>.</div>
				</div>
			</div>
			<div id="searchResultsHelpDialog" class="hidden">
				<div class="tooltipContent">	
				<h3><fmt:message key="help.tooltip.prefix" /> '<fmt:message key="advancedsearch.text.results" />':</h3>	
					<div class="tooltipSubContent">
					<ul>
						<li><fmt:message key="search.results.ead.hierarchy.list.help" /></li>
						<li><fmt:message key="search.results.ead.hierarchy.context.help" /></li>
						<li><fmt:message key="search.results.refine.help" /></li>
						<li><fmt:message key="search.results.sort.help" /></li>	
						<li><fmt:message key="search.results.savesearch.help" /></li>	
					</ul>
					</div>				
					<div class="linkToMoreHelp"><fmt:message key="search.results.help.more" />&nbsp;<a href="${helpUrl}/search-results" target="blank"><fmt:message key="search.help.more.link" /></a>.</div>
				</div>
			</div>							
			<form:form id="newSearchForm" name="eadSearchForm" commandName="eadSearch" method="post"
				action="${advancedSearchUrl}">
				<form:hidden id="mode" path="mode" />
				<form:hidden id="advanced" path="advanced" />
				<form:hidden id="selectedNodes" path="selectedNodes"/>	
				<div id="navigatedSearch">
					<h2 id="navigatedSearchOptionsHeader" class="blockHeader collapsed">
						<fmt:message key="advancedsearch.title.navigatedsearch" /><span id="aiNumber" class="hidden"></span><span class="icon_help"></span>
					</h2>
					<div id="navigatedSearchOptionsContent" class="searchOptionsContent hidden">
						<div id="navigatedSearchOptionsSubHeader">
							<fmt:message key="advancedsearch.subtitle.navigatedsearch" />
						</div>
						<div id="archivalLandscapeTree" class="treeWithPreview"></div>
						<div class="preview-column">
						<div id="al-preview" class="preview-container al-preview-container"></div>
						</div>
					</div>
				</div>
				<div id="simpleAndAdvancedSearch">
					<div id="advancedSearch">
						<h2 id="advancedSearchOptionsHeader" class="blockHeader">
							<fmt:message key="advancedsearch.title.advancedsearch" /><span class="icon_help"></span>
						</h2>
						<div id="advancedSearchOptionsContent" class="searchOptionsContent">
							<table id="advancedsearchCriteria">
								<tr>
									<td><label for="element"><fmt:message key="advancedsearch.text.selectelement" />:</label></td>
									<td colspan="3"><form:select path="element" id="element" tabindex="6">
											<form:option value="0">
												<fmt:message key="advancedsearch.text.noselection" />
											</form:option>
											<form:option value="1">
												<fmt:message key="advancedsearch.text.title1" />
											</form:option>
											<form:option value="2">
												<fmt:message key="advancedsearch.text.contentsummary" />
											</form:option>
											<form:option value="3">
												<fmt:message key="advancedsearch.text.referencecode" />
											</form:option>
										</form:select></td>
								</tr>
								<tr>
									<td><label for="typedocument"><fmt:message key="advancedsearch.text.selectdocument" /></label></td>
									<td colspan="3"><form:select path="typedocument" id="typedocument" tabindex="7">
											<form:option value="">
												<fmt:message key="advancedsearch.text.noselection" />
											</form:option>
											<form:option value="fa">
												<fmt:message key="advancedsearch.text.onlyfas" />
											</form:option>
											<form:option value="hg">
												<fmt:message key="advancedsearch.text.onlyhgs" />
											</form:option>
											<form:option value="sg">
												<fmt:message key="advancedsearch.text.onlysgs" />
											</form:option>											
										</form:select></td>
								</tr>
								<tr>
									<td><label for="fromdate"><fmt:message key="advancedsearch.text.datefrom" /></label></td>
									<td><form:input path="fromdate" id="fromdate" cssClass="datefield" tabindex="8" maxlength="10" /></td>
									<td id="datetoHeader"><label id="todateLabel" for="todate"><fmt:message key="advancedsearch.text.dateto" /></label></td>
									<td><form:input path="todate" id="todate" cssClass="datefield" tabindex="9"  maxlength="10"/></td>
								</tr>
								<tr>
									<td></td>
									<td colspan="3"><form:checkbox id="exactDateSearch" path="exactDateSearch" value="true" tabindex="10"/><label for="exactDateSearch"><fmt:message key="advancedsearch.message.exactdatesearch" /></label></td>
								</tr>
		
							</table>
						</div>
					</div>
					<div id="simpleSearch">
						<h2 id="simpleSearchOptionsHeader" class="blockHeader">
							<fmt:message key="advancedsearch.title.simplesearch" /><span class="icon_help"></span>
						</h2>
						<div id="simpleSearchOptionsContent" class="searchOptionsContent">
							<div class="simpleSearchOptions">
								<table id="simplesearchCriteria">
									<fmt:message key="advancedsearch.message.typesearchterms2" var="termTitle" />
									<tr>
										<td colspan="2"><form:input path="term" id="searchTerms" title="${termTitle}" tabindex="1" maxlength="100"/> <input
											type="submit" id="searchButton" title="<fmt:message key="advancedsearch.message.start"/>" tabindex="10"
											value="<fmt:message key="advancedsearch.message.search"/>" /></td>
									</tr>
									<tr>
										<td class="leftcolumn">
											<div class="row">
												<form:checkbox path="view" id="checkboxHierarchy" tabindex="2" value="hierarchy"/>
												<label for="checkboxHierarchy"><fmt:message key="advancedsearch.message.hierarchy" /></label>
											</div>
											<div class="row">
												<form:checkbox path="method" id="checkboxMethod" tabindex="3" value="optional"/>
												<label for="checkboxMethod"><fmt:message key="advancedsearch.message.method" /></label>
											</div>
											<div class="row">
												<form:checkbox path="simpleSearchDao" id="checkboxDao" tabindex="4" value="true"/>
												<label for="checkboxDao"><fmt:message key="advancedsearch.message.dao" /></label>
											</div>
										
										</td>
										<td class="rightcolumn">
											<div id="clearSearchRow" class="row">
												<a href="javascript:clearSearch()"><fmt:message key="searchpage.options.simple.clearsearch" /></a>	
											</div>
										</td>
									</tr>
									<tr>
										<td colspan="2">
										<div id="simpleSearchTopicSelected" class="row selectedCriteria ${eadSearch.selectedSimpleSearchTopicCssClass}" ><div id="selectedRefinementsTitle"><fmt:message key="advancedsearch.facet.title.topic" />:</div><form:hidden path="simpleSearchTopic" id="simpleSearchTopic"/>
											<ul>
												<c:if test="${!empty eadSearch.selectedSimpleSearchTopic}">
													<li><a title='${eadSearch.selectedSimpleSearchTopic.longDescription}' href="javascript:removeSimpleSearchTopic()">
											${eadSearch.selectedSimpleSearchTopic.longDescription}<span class='close-icon'></span></a></li>							
							
												</c:if>
												
											</ul>
											
											</div>
										</td>									
									</tr>
								</table>
							</div>
						</div>
					</div>
		
		
		
				</div>
			</form:form>
			</div>
			</c:otherwise></c:choose>
			<c:if test="${empty results or eadSearch.mode == 'new'}">
				<c:set var="showResults" value="hidden" />
			</c:if>
			<div id="searchResultsContainer" class="${showResults }">
				<div class="suggestionSearch" id="suggestionSearch">
					<c:if test="${results.showSuggestions}">
						<span class="suggestionText"> <c:choose>
								<c:when test="${results.totalNumberOfResults > 0}">
									<fmt:message key="advancedsearch.message.suggestion.results" />
								</c:when>
								<c:otherwise>
									<fmt:message key="advancedsearch.message.suggestion.noresults" />
								</c:otherwise>
							</c:choose>
						</span>
						<br />
						<portal:autosuggestion spellCheckResponse="${results.spellCheckResponse}" styleClass="suggestionLink"
							numberOfResultsStyleClass="suggestionNumberOfHits" misSpelledStyleClass="suggestionMisspelled" />
					</c:if>
				</div>
				<c:if test="${!eadSearch.showOnlyResults}">
				<h2 id="searchResultsHeader">
					<fmt:message key="advancedsearch.text.results" />:
				</h2>
				</c:if>
				<div id="tabs">
					<c:if test="${!eadSearch.showOnlyResults}">
					<ul id="tabscontainer">
						<li><a href="#tabs-list"><fmt:message key="advancedsearch.text.list" /></a></li>
						<li><a href="#tabs-context"><fmt:message key="advancedsearch.text.context" /></a></li>
					</ul>
					<div id="saveSearch">
						 <div id="saveSearchButton" class="linkButton">
						 	<c:choose>
						 		<c:when test="${empty ownSavedSearchId}">
									<a href="javascript:saveSearch()"><fmt:message key="advancedsearch.text.savesearch" /></a>
								</c:when>
								<c:otherwise>
									<a href="javascript:saveSearch('${ownSavedSearchId}')"><fmt:message key="advancedsearch.text.savesearch.modified" /></a>
								</c:otherwise>
							</c:choose>
						</div>
						<div id="answerMessageSavedSearch"></div>
						
					</div>
					
					<div class="icon_help"></div>
					</c:if>
					<div id="tabs-context">
						<c:if test="${!empty results and eadSearch.mode != 'new' and eadSearch.view == 'hierarchy'}">
						<jsp:include page="results.jsp" />
						</c:if> 
					</div>
					<div id="tabs-list">
						<c:if test="${!empty results and eadSearch.mode != 'new' and eadSearch.view != 'hierarchy'}">
						<jsp:include page="results.jsp" />
					</c:if>
					</div>
				</div>
			</div>
			<div id="loadingText" class="hidden"><fmt:message key="advancedsearch.message.loading"/>
			</div>
		</div>
</div>
