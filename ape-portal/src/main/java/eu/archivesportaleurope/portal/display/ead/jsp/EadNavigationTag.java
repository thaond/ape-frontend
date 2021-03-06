package eu.archivesportaleurope.portal.display.ead.jsp;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.portlet.PortletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.SimpleTagSupport;

import eu.apenet.commons.types.XmlType;
import eu.apenet.persistence.vo.CLevel;
import eu.apenet.persistence.vo.Ead;
import eu.apenet.persistence.vo.EadContent;
import eu.archivesportaleurope.portal.common.FriendlyUrlUtil;
import eu.archivesportaleurope.portal.common.urls.EadPersistentUrl;

public class EadNavigationTag extends SimpleTagSupport {

	private Object clevel;

	public void doTag() throws JspException, IOException {
		PortletRequest portletRequest = (PortletRequest) ((PageContext) getJspContext()).getRequest().getAttribute(
				"javax.portlet.request");
		List<HierarchyInfo> hierarchy = new ArrayList<HierarchyInfo>();
		EadContent eadContent = null;
		StringBuilder result = new StringBuilder();
		if (clevel != null){
			CLevel currentCLevel = (CLevel) clevel;
			CLevel parent = currentCLevel.getParent();
			eadContent = currentCLevel.getEadContent();
			Ead ead = eadContent.getEad();
			String repoCode = ead.getArchivalInstitution().getEncodedRepositorycode();
			String xmlTypeName = XmlType.getContentType(ead).getResourceName();			
			while (parent != null ){
				EadPersistentUrl persistentUrl = new EadPersistentUrl(repoCode, xmlTypeName, ead.getIdentifier());
				persistentUrl.setClevel(parent);
				String url = FriendlyUrlUtil.getEadPersistentUrl(portletRequest, persistentUrl, false);
				hierarchy.add(new HierarchyInfo(url, parent.getUnittitle()));
				parent = parent.getParent();
			}
			EadPersistentUrl persistentUrl = new EadPersistentUrl(repoCode, xmlTypeName, ead.getIdentifier());
			String url = FriendlyUrlUtil.getEadPersistentUrl(portletRequest, persistentUrl, false);
			hierarchy.add(new HierarchyInfo(url,eadContent.getUnittitle()));
		}
		
		if (eadContent != null){
			result.append("<ul class=\"context\">");
			int numberOfWhitespaces = 0;
			for (int i = hierarchy.size() -1; i >=0;i--){
				result.append("<li>");
				HierarchyInfo hierarchyInfo = hierarchy.get(i);
				//result.append("<span class=\"contextHierarchyItem\">");
				for (int j = 0; j < numberOfWhitespaces;j++){
					result.append("<span class=\"context_space\"> </span>");
				}
				
				result.append("<a href=\"" + hierarchyInfo.url+  "\">"+ hierarchyInfo.description+"</a>");
				result.append("</li>");
				numberOfWhitespaces++;
			}
			result.append("</ul>");
		}
		this.getJspContext().getOut().print(result);

	}



	public Object getClevel() {
		return clevel;
	}



	public void setClevel(Object clevel) {
		this.clevel = clevel;
	}



	private static class HierarchyInfo{
		String url;
		String description;
		private HierarchyInfo(String url, String description){
			this.url = url;
			this.description = description;
		}
	}


}
