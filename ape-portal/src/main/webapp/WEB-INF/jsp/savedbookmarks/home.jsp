<%@ taglib prefix="portlet" uri="http://java.sun.com/portlet_2_0"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="text/html" isELIgnored="false"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="portal" uri="http://portal.archivesportaleurope.eu/tags"%>
<%@ taglib prefix="ape" uri="http://commons.archivesportaleurope.eu/tags"%>
<portal:friendlyUrl var="savedBookmarkUrl" type="saved-Bookmark"/>
<portal:friendlyUrl var="savedBookmarkPublicUrl" type="saved-bookmarks" noHttps="true"/>
<portal:friendlyUrl var="savedBookmarkPagingUrl" type="saved-bookmarks-overview" />
<div id="savedBookmarksPortlet">
<c:choose>
	<c:when test="${not empty savedBookmarks}">
		<h2><fmt:message key="bookmarks.bookmarks"/></h2>
		<div id="children" class="box">
			<div class="boxtitle">
				<div class="numberOfPages">
					<ape:pageDescription numberOfItems="${totalNumberOfResults}" pageSize="${pageSize}" pageNumber="${pageNumber}" />
				</div>
				<div id="top-paging" class="paging">
					<ape:paging numberOfItems="${totalNumberOfResults}" pageSize="${pageSize}" pageNumber="${pageNumber}" refreshUrl="${savedBookmarkPagingUrl}/{pageNumber}" pageNumberId="pageNumber" liferayFriendlyUrl="true"/>
				</div>
			</div>
			<table id="savedBookmarksTable" class="defaultlayout">
				<tr>
					<th class="id"><fmt:message key="savedsearch.id"/></th>
					<th class="name"><fmt:message key="advancedsearch.eaccpf.element.name"/></th>
					<th class="description"><fmt:message key="savedsearch.description"/></th>
					<th class="type"><fmt:message key="advancedsearch.facet.title.repositorytypefacet"/></th>
					<th class="modified"><fmt:message key="savedsearch.modified"/></th>
					<th class="actions"><fmt:message key="savedsearches.overview.actions"/></th>
				</tr>
				<c:forEach var="savedBookmark" items="${savedBookmarks}">
					<tr class="${trClass}">
						<td><c:out value="${savedBookmark.id}"/></td>
						<td>
						<a href="${savedBookmark.link}"> <c:out value="${savedBookmark.name}"/> </a>
						</td>
						<td><c:out value="${savedBookmark.description}"/></td>
						<td><c:out value="${savedBookmark.typedocument}"/></td>
						<td><fmt:formatDate pattern="dd-MMM-yyyy HH:mm z"  value="${savedBookmark.modifiedDate}" timeZone="${timeZone}"/></td>
						<td>
						<div>
							<a href="<portlet:actionURL>
								<portlet:param name="myaction" value="deleteSavedBookmark" />
								<portlet:param name="id" value="${savedBookmark.id}" />
								</portlet:actionURL>" onclick="return confirm('<fmt:message key="bookmarks.delete.areyousure"/>')"><fmt:message key="savedsearches.overview.delete"/>
							</a>
						</div>
						<portlet:renderURL var="addSavedBookmarksForm">
							<portlet:param name="myaction" value="addSavedBookmarksForm" />
							<portlet:param name="id" value="${savedBookmark.id}" />
							<portlet:param name="overviewPageNumber" value="${pageNumber}" />
						</portlet:renderURL>
						<div>
							<a href="${addSavedBookmarksForm}"><fmt:message key="collections.add"/></a>
						</div>
						<portlet:renderURL var="editUrl">
							<portlet:param name="myaction" value="editSavedBookmarksForm" />
							<portlet:param name="id" value="${savedBookmark.id}" />
							<portlet:param name="overviewPageNumber" value="${pageNumber}" />
						</portlet:renderURL>
						<div>
							<a href="${editUrl}"><fmt:message key="savedsearches.overview.edit"/></a>
						</div>
						</td>
					</tr>
				</c:forEach>
			</table>
		</div>
	</c:when>
	<c:otherwise>
		<h2><fmt:message key="bookmarks.overview.nothing"/></h2>
	</c:otherwise>
</c:choose>
</div>