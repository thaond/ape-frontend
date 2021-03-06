<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.liferay.portal.kernel.portlet.LiferayWindowState"%>
<%@ taglib uri="http://commons.archivesportaleurope.eu/tags" prefix="ape"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet"%>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme"%>
<%@ taglib uri="http://portal.archivesportaleurope.eu/tags" prefix="portal"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<portlet:defineObjects />
<c:set var="element">
	<c:out value="${param['element']}" />
</c:set>
<c:set var="term">
	<c:out value="${param['term']}" />
</c:set>

<portal:friendlyUrl var="eacUrl" type="eac-display"/>

<portlet:resourceURL var="displayChildrenUrl" id="displayEadDetails">
	<c:if test="${not empty c}">
	<portlet:param name="id" value="${c.id}" />
	</c:if>
	<portlet:param name="element" value="${element}" />
	<portlet:param name="term" value="${term}" />
</portlet:resourceURL>

<portlet:renderURL var="printEadDetailsUrl" windowState="<%=LiferayWindowState.POP_UP.toString()%>">
	<portlet:param name="myaction" value="printEadDetails" />
	<c:if test="${not empty c}">
	<portlet:param name="id" value="${c.id}" />
	</c:if>
	<portlet:param name="ecId" value="${eadContent.ecId}" />
	<portlet:param name="element" value="${element}" />
	<portlet:param name="term" value="${term}" />
	<portlet:param name="type" value="${type}" />
	<portlet:param name="pageNumber" value="${pageNumber}" />
</portlet:renderURL>

<c:set var="portletNamespace"><portlet:namespace/></c:set>
<portal:removeParameters  var="feedbackUrl" namespace="${portletNamespace}" parameters="eadid,element,term,ecId,id,unitid,xmlTypeName,repoCode"><portlet:resourceURL id="feedback"/></portal:removeParameters>


<div id="buttonsHeader">

	<!-- Print section. -->
	<div id="printEadDetails" class="linkButton">
		<a href="javascript:printEadDetails('${printEadDetailsUrl}')"><fmt:message key="label.print" /><span
			class="icon_print">&nbsp;</span></a>
	</div>
	<c:if test="${not previewDetails}">
	<!-- Persistent link. -->
	<c:choose>
		<c:when test="${empty c}">
			<portal:eadPersistentLink var="url" repoCode="${archivalInstitution.repositorycode}" xmlTypeName="${xmlTypeName}" eadid="${eadContent.ead.eadid}" searchFieldsSelectionId="${element}" searchTerms="${term}"/>
		</c:when>
		<c:otherwise>
			<portal:eadPersistentLink var="url" repoCode="${archivalInstitution.repositorycode}" xmlTypeName="${xmlTypeName}" eadid="${eadContent.ead.eadid}" clevel="${c}" searchFieldsSelectionId="${element}" searchTerms="${term}"/>
		</c:otherwise>
	</c:choose>
	
	<!-- Save bookmarks section. -->
	<div id="bookmarksArea">
		<portlet:resourceURL var="bookmarkUrl" id="bookmark"/>
		<div id="bookmarkEad" class="linkButton">	
 			<a id="eadBookmark" href="javascript:showBookmark('<c:out value='${bookmarkUrl}' />', '<c:out value='${documentTitle}' />', '<c:out value='${url}' />', 'ead')"><fmt:message key="bookmark.this" /></a>
		</div>
		<!-- Disabled button -->
		<div id="bookmarkEadGrey" class="disableBookmarkButton hidden">	
 			<fmt:message key="bookmark.this" />
		</div>
	</div>

	<!-- share section. -->
	<div id="shareButton" class="linkButton">
		<span class="st_sharethis_button" displayText='<fmt:message key="label.share" />' st_title="${documentTitle}"
			st_url="${url}"></span>
	</div>
	</c:if>
</div>

<div id="collection-details" class="hidden"></div>

<div id="collectionCreateAction" class="hidden"></div>

<div id="bookmarkAnswer">
	<div id="bookmarkContent" class="hidden"></div>
</div>

<div id="eaddetailsContent">
	<c:choose>
		<c:when test="${empty c}">
			<c:choose>
                <c:when test="${xmlTypeName eq 'ead3'}">
                    <portal:ead type="frontpage-ead3" xml="${eadContent.xml}" searchTerms="${term}" searchFieldsSelectionId="${element}" xmlTypeName="${xmlTypeName}" eacUrl="${eacUrl}"/>
                </c:when>
                <c:otherwise>
                    <portal:ead type="frontpage" xml="${eadContent.xml}" searchTerms="${term}" searchFieldsSelectionId="${element}" xmlTypeName="${xmlTypeName}" eacUrl="${eacUrl}"/>
                </c:otherwise>
            </c:choose>
		</c:when>
		<c:otherwise>
                    <c:choose>
                        <c:when test="${xmlTypeName eq 'ead3'}">
                            <portal:eadPersistentLink var="secondDisplayUrl" repoCode="${archivalInstitution.encodedRepositorycode}" xmlTypeName="ead3" eadid=""/>		
			<portal:ead type="ead3-cdetails" xml="${c.xml}" searchTerms="${term}" searchFieldsSelectionId="${element}" aiId="${aiId}"
				secondDisplayUrl="${secondDisplayUrl}" dashboardPreview="${previewDetails}" xmlTypeName="${xmlTypeName}" eacUrl="${eacUrl}"/>
                        </c:when>
                        <c:otherwise>
                            <portal:eadPersistentLink var="secondDisplayUrl" repoCode="${archivalInstitution.encodedRepositorycode}" xmlTypeName="fa" eadid=""/>		
			<portal:ead type="cdetails" xml="${c.xml}" searchTerms="${term}" searchFieldsSelectionId="${element}" aiId="${aiId}"
				secondDisplayUrl="${secondDisplayUrl}" dashboardPreview="${previewDetails}" xmlTypeName="${xmlTypeName}" eacUrl="${eacUrl}"/>
                        </c:otherwise>
                    </c:choose>
			<c:if test="${not c.leaf}">
				<div id="children" class="box">
					<div class="boxtitle">
						<div class="numberOfPages">
							<ape:pageDescription numberOfItems="${totalNumberOfChildren}" pageSize="${pageSize}" pageNumber="${pageNumber}" />
						</div>
						<div id="child-paging" class="paging">
							<c:if test="${not previewDetails}">
							<ape:paging numberOfItems="${totalNumberOfChildren}" pageSize="${pageSize}" pageNumber="${pageNumber}"
								refreshUrl="javascript:updatePageNumber('${displayChildrenUrl}')" pageNumberId="pageNumber" />
							</c:if>
						</div>
					</div>
                                                        <c:choose>
                                                            <c:when test="${xmlTypeName eq 'ead3'}">
                                                                <portal:ead type="ead3-cdetails-child" xml="${childXml}" xmlTypeName="${xmlTypeName}"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <portal:ead type="cdetails-child" xml="${childXml}" xmlTypeName="${xmlTypeName}"/>
                                                            </c:otherwise>
                                                        </c:choose>
				</div>
			</c:if>
		</c:otherwise>
	</c:choose>
</div>
<c:if test="${not previewDetails}">
<!-- there is the user's feedback feature for WEB 2.0 -->
<div id="feedbackArea">
	<div id="sendFeedbackButton" class="linkButton">
		<a href="javascript:showFeedback('<c:out value='${feedbackUrl}' />', '<c:out value='${aiId}' />', '<c:out value='${documentTitle}' />','<c:out value='${url}' />','<c:out value='${recaptchaPubKey}' />')"><fmt:message
				key="label.feedback" /></a>
	</div>
	<div id="feedbackContent" class="hidden"></div>
</div>
</c:if>
<script type="text/javascript" defer="defer">
	 var RecaptchaOptions = {
	    theme : 'white'
	 };

	$(document).ready(function() {
		document.title = "${pageTitle}";
		initExpandableParts();
	});

</script>