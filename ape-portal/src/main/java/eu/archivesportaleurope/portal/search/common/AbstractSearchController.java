package eu.archivesportaleurope.portal.search.common;

import javax.portlet.PortletRequest;

import org.apache.commons.lang.StringUtils;

import eu.archivesportaleurope.portal.search.advanced.AdvancedSearch;

public class AbstractSearchController {

	private EadSearcher eadSearcher;
	private EacCpfSearcher eacCpfSearcher;
	
	public EadSearcher getEadSearcher() {
		return eadSearcher;
	}

	public void setEadSearcher(EadSearcher eadSearcher) {
		this.eadSearcher = eadSearcher;
	}

	public EacCpfSearcher getEacCpfSearcher() {
		return eacCpfSearcher;
	}

	public void setEacCpfSearcher(EacCpfSearcher eacCpfSearcher) {
		this.eacCpfSearcher = eacCpfSearcher;
	}
	public static SolrQueryParameters getSolrQueryParametersByForm(AbstractSearchForm abstractSearchForm, PortletRequest portletRequest){
		if (StringUtils.isNotBlank(abstractSearchForm.getTerm())){
			SolrQueryParameters solrQueryParameters = new SolrQueryParameters();
			if (AbstractSearchForm.SEARCH_ALL_STRING.equals(abstractSearchForm.getTerm())){
				solrQueryParameters.setTerm("");
			}else {
				solrQueryParameters.setTerm(abstractSearchForm.getTerm());
			}
			solrQueryParameters.setMatchAllWords(abstractSearchForm.matchAllWords());
			return solrQueryParameters;			
		}
		return null;

	}
	protected static void updatePagination( ListResults results) {
		Long totalNumberOfPages = results.getTotalNumberOfResults() / results.getPageSize();
		Long rest = results.getTotalNumberOfResults() % results.getPageSize();
		if (rest > 0) {
			totalNumberOfPages++;
		}
		results.setTotalNumberOfPages(totalNumberOfPages);
	}
	public String validate(AbstractSearchForm abstractSearchForm) {
		if (StringUtils.isNotBlank(abstractSearchForm.getFromdate())
				&& !AdvancedSearchUtil.isValidDate(abstractSearchForm.getFromdate())) {
			return "search.message.IncorrectDateTyped";

		}
		if (StringUtils.isNotBlank(abstractSearchForm.getTodate())
				&& !AdvancedSearchUtil.isValidDate(abstractSearchForm.getTodate())) {
			return "search.message.IncorrectDateTyped";
		}
		return null;
	}
}
