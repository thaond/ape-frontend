package eu.archivesportaleurope.portal.common.jsp;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.jsp.JspException;

import eu.apenet.commons.types.XmlType;
import eu.apenet.persistence.vo.CLevel;
import eu.apenet.persistence.vo.Ead;
import eu.apenet.persistence.vo.EadContent;

public class EadNavigationTag extends AbstractFriendlyUrlTag {

	private Object clevel;

	public void doTag() throws JspException, IOException {
		List<HierarchyInfo> hierarchy = new ArrayList<HierarchyInfo>();
		EadContent eadContent = null;
		StringBuilder result = new StringBuilder();
		if (clevel != null){
			CLevel currentCLevel = (CLevel) clevel;
			CLevel parent = currentCLevel.getParent();
			
			while (parent != null ){
				String url = getUrl(EAD_DISPLAY_SEARCH) + "/C" + parent.getClId();
				hierarchy.add(new HierarchyInfo(url, parent.getUnittitle()));
				parent = parent.getParent();
			}
			eadContent = currentCLevel.getEadContent();
			Ead ead = eadContent.getEad();
			String repoCode = ead.getArchivalInstitution().getRepositorycode().replace('/', '_');
			XmlType xmlType = XmlType.getEadType(ead);
			String url = getUrl(EAD_DISPLAY_FRONTPAGE) + "/" + repoCode + "/" + xmlType.getResourceName()+ "/"+ ead.getEadid();
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
