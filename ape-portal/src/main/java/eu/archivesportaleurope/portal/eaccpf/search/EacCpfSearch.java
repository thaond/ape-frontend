package eu.archivesportaleurope.portal.eaccpf.search;

import java.util.List;

import org.apache.commons.lang.StringUtils;

import eu.archivesportaleurope.portal.search.advanced.list.ListFacetSettings;
import eu.archivesportaleurope.portal.search.common.AbstractSearchForm;
import eu.archivesportaleurope.portal.search.common.FacetType;

public class EacCpfSearch extends AbstractSearchForm {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1707315274413272934L;

	public static final String LIST_SEPARATOR = ",";
	public static final String VIEW_HIERARCHY = "hierarchy";
	public static final String METHOD_OPTIONAL = "optional";
	public static final String MODE_NEW = "new";
	public static final String MODE_NEW_SEARCH = "new-search";
	public static final String MODE_UPDATE_SEARCH = "update-search";
	public static final String SEARCH_ALL_STRING = "*:*";
	private String element;
	private String entityType;
	private String nameType;

	private String country;
	private String ai;

	private String dateType;
	private String order;
	private String startdate;
	private String enddate;
	private String facetField;
	private String facetOffset;
	private String pageNumber = "1";
	private String keyPrefix;
	private String valueIsKey;
	private String hasId;
	private List<ListFacetSettings> facetSettingsList = FacetType.getDefaultListFacetSettings();
	private String publishedFromDate;
	private String publishedToDate;

	public String getCountry() {
		return country;
	}

	// public List<String> getCountryList(){
	// if (StringUtils.isNotBlank(country)){
	// return Arrays.asList(country.split(LIST_SEPARATOR));
	// }else {
	// return null;
	// }
	// }
	// public List<String> getAiList(){
	// if (StringUtils.isNotBlank(ai)){
	// return Arrays.asList(ai.split(LIST_SEPARATOR));
	// }else {
	// return null;
	// }
	// }
	// public List<String> getDateTypeList(){
	// if (StringUtils.isNotBlank(dateType)){
	// return Arrays.asList(dateType.split(LIST_SEPARATOR));
	// }else {
	// return null;
	// }
	// }

	public void setCountry(String country) {
		this.country = country;
	}

	public String getAi() {
		return ai;
	}

	public void setAi(String ai) {
		this.ai = ai;
	}

	public String getDateType() {
		return dateType;
	}

	public void setDateType(String dateType) {
		this.dateType = dateType;
	}

	public String getOrder() {
		return order;
	}

	public void setOrder(String order) {
		this.order = order;
	}

	public String getStartdate() {
		return startdate;
	}

	public void setStartdate(String startdate) {
		this.startdate = startdate;
	}

	public String getEnddate() {
		return enddate;
	}

	public void setEnddate(String enddate) {
		this.enddate = enddate;
	}

	public String getFacetField() {
		return facetField;
	}

	public void setFacetField(String facetField) {
		this.facetField = facetField;
	}

	public String getFacetOffset() {
		return facetOffset;
	}

	public void setFacetOffset(String facetOffset) {
		this.facetOffset = facetOffset;
	}


	public String getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(String pageNumber) {
		this.pageNumber = pageNumber;
	}

	public String getKeyPrefix() {
		return keyPrefix;
	}

	public void setKeyPrefix(String keyPrefix) {
		this.keyPrefix = keyPrefix;
	}

	public String getValueIsKey() {
		return valueIsKey;
	}

	public void setValueIsKey(String valueIsKey) {
		this.valueIsKey = valueIsKey;
	}

	public String getHasId() {
		return hasId;
	}

	public void setHasId(String hasId) {
		this.hasId = hasId;
	}

	public String getFacetSettings() {
		String result = null;
		for (ListFacetSettings facetSettings : facetSettingsList) {
			if (result == null) {
				result = facetSettings.toString();
			} else {
				result += LIST_SEPARATOR + facetSettings;
			}
		}
		return result;
	}

	public void setFacetSettings(String facetSettings) {
		if (StringUtils.isNotBlank(facetSettings)) {
			facetSettingsList.clear();
			String[] temp = facetSettings.split(LIST_SEPARATOR);
			for (String tempItem : temp) {
				facetSettingsList.add(new ListFacetSettings(tempItem));
			}
		} else {
			facetSettingsList = FacetType.getDefaultListFacetSettings();
		}
	}

	public List<ListFacetSettings> getFacetSettingsList() {
		return facetSettingsList;
	}


	public String getPublishedFromDate() {
		return publishedFromDate;
	}

	public void setPublishedFromDate(String publishedFromDate) {
		this.publishedFromDate = publishedFromDate;
	}

	public String getPublishedToDate() {
		return publishedToDate;
	}

	public void setPublishedToDate(String publishedToDate) {
		this.publishedToDate = publishedToDate;
	}

	public String getElement() {
		return element;
	}

	public void setElement(String element) {
		this.element = element;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getNameType() {
		return nameType;
	}

	public void setNameType(String nameType) {
		this.nameType = nameType;
	}



}
