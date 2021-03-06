package eu.archivesportaleurope.portal.search.ead.altree;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.apache.commons.lang.StringUtils;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.portlet.bind.annotation.ResourceMapping;

import eu.apenet.commons.types.XmlType;
import eu.apenet.persistence.dao.ArchivalInstitutionDAO;
import eu.apenet.persistence.dao.CLevelDAO;
import eu.apenet.persistence.dao.ContentSearchOptions;
import eu.apenet.persistence.dao.CountryDAO;
import eu.apenet.persistence.dao.EadDAO;
import eu.apenet.persistence.vo.ArchivalInstitution;
import eu.apenet.persistence.vo.CLevel;
import eu.apenet.persistence.vo.Ead;
import eu.apenet.persistence.vo.FindingAid;
import eu.apenet.persistence.vo.HgSgFaRelation;
import eu.apenet.persistence.vo.HoldingsGuide;
import eu.apenet.persistence.vo.SourceGuide;
import eu.archivesportaleurope.portal.common.SpringResourceBundleSource;
import eu.apenet.commons.ai.AlType;
import eu.apenet.commons.ai.ArchivalLandscapeUtil;
import eu.apenet.commons.ai.CountryUnit;
import eu.apenet.commons.ai.TreeType;
import eu.archivesportaleurope.portal.common.tree.AbstractJSONWriter;
import eu.archivesportaleurope.portal.common.tree.TreeNode;
import eu.archivesportaleurope.util.ApeUtil;

/**
 * JSON Writer for the navigated tree
 *
 * @author bastiaan
 *
 */
@Controller(value = "archivalLandscapeTreeJSONWriter")
@RequestMapping(value = "VIEW")
public class ArchivalLandscapeTreeJSONWriter extends AbstractJSONWriter {
	private static final Integer MAX_NUMBER_OF_CLEVELS = 20;
	private static final Integer MAX_NUMBER_OF_EADS = 20;
	private CountryDAO countryDAO;

	private ArchivalInstitutionDAO archivalInstitutionDAO;

	private EadDAO eadDAO;
	private CLevelDAO cLevelDAO;

	public void setCountryDAO(CountryDAO countryDAO) {
		this.countryDAO = countryDAO;
	}

	public void setArchivalInstitutionDAO(ArchivalInstitutionDAO archivalInstitutionDAO) {
		this.archivalInstitutionDAO = archivalInstitutionDAO;
	}

	public void setEadDAO(EadDAO eadDAO) {
		this.eadDAO = eadDAO;
	}

	public void setcLevelDAO(CLevelDAO cLevelDAO) {
		this.cLevelDAO = cLevelDAO;
	}

	@ResourceMapping(value = "archivalLandscapeTree")
	public void writeJSON(@ModelAttribute(value = "alTreeParams") AlTreeParams alTreeParams,
			ResourceRequest resourceRequest, ResourceResponse resourceResponse) {
		try {
			Locale locale = resourceRequest.getLocale();
			SpringResourceBundleSource source = new SpringResourceBundleSource(this.getMessageSource(),
					locale);
			ArchivalLandscapeUtil archivalLandscapeUtil = new ArchivalLandscapeUtil(source);
			if (StringUtils.isBlank(alTreeParams.getKey())) {
				if (alTreeParams.isContainSelectedNodes()){
					alTreeParams.setExpandedNodesList(generateExpandedNodes(alTreeParams.getSelectedNodesList()));
				}
				writeToResponseAndClose(generateCountriesTreeJSON(alTreeParams, archivalLandscapeUtil, locale), resourceResponse);
			} else {
				AlType parentType = AlType.getAlType(alTreeParams.getKey());
				TreeType treeType = AlType.getTreeType(alTreeParams.getKey());
				int depth = AlType.getDepth(alTreeParams.getKey());
				Long id = AlType.getId(alTreeParams.getKey());
				Integer start = AlType.getStart(alTreeParams.getKey());
				Integer countryId = null;
				Integer aiId = null;
				boolean displayAis = false;
				if (AlType.COUNTRY.equals(parentType) || AlType.ARCHIVAL_INSTITUTION.equals(parentType)) {
					if (AlType.COUNTRY.equals(parentType)) {
						countryId = id.intValue();
						displayAis = true;
					} else if (AlType.ARCHIVAL_INSTITUTION.equals(parentType)) {
						aiId = id.intValue();
						if (TreeType.GROUP.equals(treeType)) {
							displayAis = true;
						} else {
							writeToResponseAndClose(generateEADFoldersTreeJSON(aiId, locale), resourceResponse);
						}
					}
					if (displayAis) {
						writeToResponseAndClose(generateArchivalInstitutionsTreeJSON(alTreeParams, countryId, aiId, locale,depth),
								resourceResponse);
					}
				} else if (AlType.SOURCE_GUIDE.equals(parentType) || AlType.HOLDINGS_GUIDE.equals(parentType)
						|| AlType.FINDING_AID.equals(parentType)) {
					if (TreeType.GROUP.equals(treeType)) {
						aiId = id.intValue();
						if (AlType.SOURCE_GUIDE.equals(parentType) || AlType.HOLDINGS_GUIDE.equals(parentType)) {
							ContentSearchOptions eadSearchOptions = new ContentSearchOptions();
							if (AlType.HOLDINGS_GUIDE.equals(parentType)) {
								eadSearchOptions.setContentClass(HoldingsGuide.class);
							} else if (AlType.SOURCE_GUIDE.equals(parentType)) {
								eadSearchOptions.setContentClass(SourceGuide.class);
							}
							eadSearchOptions.setArchivalInstitionId(aiId);
							eadSearchOptions.setPublished(true);
							eadSearchOptions.setFirstResult(start);
							eadSearchOptions.setPageSize(MAX_NUMBER_OF_EADS + 1);
							List<? extends Ead> eads = eadDAO.getEads(eadSearchOptions);
							writeToResponseAndClose(
									generateEadFolderTreeJSON(eads, parentType, aiId, start, locale),
									resourceResponse);
						}
					} else {
						Integer parentId = id.intValue();
						List<CLevel> topClevels = cLevelDAO.getTopClevelsByFileId(parentId, (Class<? extends Ead>) XmlType
								.getTypeBySolrPrefix(parentType.toString()).getClazz(), start,
								MAX_NUMBER_OF_CLEVELS + 1);
						writeToResponseAndClose(
								generateCLevelsJSON(topClevels, alTreeParams.getKey(),
										alTreeParams.getAiId(), locale), resourceResponse);
					}
				} else if (AlType.C_LEVEL.equals(parentType)) {
					List<CLevel> clevels = cLevelDAO.findChildCLevels(id, start,
							MAX_NUMBER_OF_CLEVELS + 1);
					writeToResponseAndClose(
							generateCLevelsJSON(clevels,alTreeParams.getKey(),
									alTreeParams.getAiId(), locale), resourceResponse);
				}
			}

		} catch (Exception e) {
			log.error(ApeUtil.generateThrowableLog(e));
		}
	}

	/**
	 * Generate countries in the archival landscape tree
	 *
	 * @param archivalLandscapeUtil
	 * @return
	 */
	private List<AlTreeNode> generateCountriesTreeJSON(AlTreeParams alTreeParams, ArchivalLandscapeUtil archivalLandscapeUtil, Locale locale) {
		List<CountryUnit> countryList = archivalLandscapeUtil.localizeCountries(countryDAO
				.getCountriesWithSearchableItems());
		List<AlTreeNode> alTreeNodes = new ArrayList<AlTreeNode>();
		for (CountryUnit countryUnit : countryList) {
			AlTreeNode node = new AlTreeNode();
			addTitle(node, countryUnit.getLocalizedName(), archivalLandscapeUtil.getLocale());
			node.setFolder(true);
			Integer countryId = countryUnit.getCountry().getId();
			node.setSelected(alTreeParams.existInSelectedNodes(AlType.COUNTRY, countryId, TreeType.GROUP));
			addKey(node, AlType.COUNTRY, countryId, TreeType.GROUP);
			if (alTreeParams.existInExpandedNodes(AlType.COUNTRY, countryId, TreeType.GROUP)){
				node.setLazy(false);
				node.setExpanded(true);
				node.setChildren(generateArchivalInstitutionsTreeJSON(alTreeParams, countryId, null, locale, -1));
			}
			alTreeNodes.add(node);
		}
		return alTreeNodes;

	}

	private List<AlTreeNode> generateArchivalInstitutionsTreeJSON(AlTreeParams alTreeParams,Integer countryId, Integer parentAiId, Locale locale, int parentDepth) {
		int depth = parentDepth+1;
		List<ArchivalInstitution> archivalInstitutions = archivalInstitutionDAO
				.getArchivalInstitutionsWithSearchableItems(countryId, parentAiId);
		List<AlTreeNode> alTreeNodes = new ArrayList<AlTreeNode>();
		for (ArchivalInstitution archivalInstitution : archivalInstitutions) {
			AlTreeNode node = new AlTreeNode();
			addTitle(node, archivalInstitution.getAiname(), locale);
			if (archivalInstitution.isGroup()) {
				node.setFolder(true);
				node.setSelected(alTreeParams.existInSelectedNodes(AlType.ARCHIVAL_INSTITUTION, archivalInstitution.getAiId(), TreeType.GROUP));
				addKeyWithDepth(node, AlType.ARCHIVAL_INSTITUTION, archivalInstitution.getAiId(), TreeType.GROUP, depth);
				if (alTreeParams.existInExpandedNodes(AlType.ARCHIVAL_INSTITUTION, archivalInstitution.getAiId(), TreeType.GROUP)){
					node.setLazy(false);
					node.setExpanded(true);
					node.setChildren(generateArchivalInstitutionsTreeJSON(alTreeParams, countryId, archivalInstitution.getAiId(), locale,depth));
				}
			} else {
				node.setSelected(alTreeParams.existInSelectedNodes(AlType.ARCHIVAL_INSTITUTION, archivalInstitution.getAiId(), TreeType.LEAF));
				addKey(node, AlType.ARCHIVAL_INSTITUTION, archivalInstitution.getAiId(), TreeType.LEAF);
				if (hasHGorSG(archivalInstitution.getAiId())){
					node.setFolder(true);
				}
			}
			alTreeNodes.add(node);
		}
		return alTreeNodes;

	}
	private boolean hasHGorSG(Integer aiId){
		/*
		 * check if Holdings Guide exist
		 */
		ContentSearchOptions eadSearchOptions = new ContentSearchOptions();
		eadSearchOptions.setArchivalInstitionId(aiId);
		eadSearchOptions.setPublished(true);
		eadSearchOptions.setContentClass(HoldingsGuide.class);
		boolean hasHGorSG = eadDAO.existEads(eadSearchOptions);
		if (hasHGorSG){
			return true;
		}else {
			/*
			 * check if Source Guide exist
			 */
			eadSearchOptions.setContentClass(SourceGuide.class);
			return eadDAO.existEads(eadSearchOptions);
		}


	}

	private List<AlTreeNode> generateEADFoldersTreeJSON(Integer aiId, Locale locale) {
		List<AlTreeNode> alTreeNodes = new ArrayList<AlTreeNode>();
		/*
		 * check if Holdings Guide exist
		 */
		ContentSearchOptions eadSearchOptions = new ContentSearchOptions();
		eadSearchOptions.setArchivalInstitionId(aiId);
		eadSearchOptions.setPublished(true);
		eadSearchOptions.setContentClass(HoldingsGuide.class);
		boolean holdingsGuideExists = eadDAO.existEads(eadSearchOptions);
		/*
		 * check if Source Guide exist
		 */
		eadSearchOptions.setContentClass(SourceGuide.class);
		boolean sourceGuideExists = eadDAO.existEads(eadSearchOptions);
		//boolean otherFindingAidExists = findingAidDAO.existFindingAidsNotLinkedByArchivalInstitution(aiId);
		if (holdingsGuideExists) {
			AlTreeNode hgNode = new AlTreeNode();
			addTitleFromKey(hgNode, "text.holdings.guide.folder", locale);
			hgNode.setFolder(true);
			hgNode.setHideCheckbox(true);
			addKey(hgNode, AlType.HOLDINGS_GUIDE, aiId, TreeType.GROUP);
			alTreeNodes.add(hgNode);
		}
		if (sourceGuideExists) {
			AlTreeNode sgNode = new AlTreeNode();
			addTitleFromKey(sgNode, "text.source.guide.folder", locale);
			sgNode.setFolder(true);
			sgNode.setHideCheckbox(true);
			addKey(sgNode, AlType.SOURCE_GUIDE, aiId, TreeType.GROUP);
			alTreeNodes.add(sgNode);
		}
		return alTreeNodes;
	}

	private List<AlTreeNode> generateEadFolderTreeJSON(List<? extends Ead> eads, AlType alType, Integer aiId,
			Integer start, Locale locale) {
		List<AlTreeNode> alTreeNodes = new ArrayList<AlTreeNode>();
		int numberOfEadsToShow;
		if (eads.size() > MAX_NUMBER_OF_EADS) {
			numberOfEadsToShow = MAX_NUMBER_OF_EADS;
		} else {
			numberOfEadsToShow = eads.size() - 1;
		}
		for (int i = 0; i <= numberOfEadsToShow; i++) {
			Ead ead = eads.get(i);

			AlTreeNode node = new AlTreeNode();
			addTitle(node, ead.getTitle(), locale);
			addAiId(node, aiId);
			addKey(node, alType, ead.getId(), TreeType.LEAF);
			addPreviewId(node, ead.getId(), XmlType.getContentType(ead));
			if (!(ead instanceof FindingAid)) {
				node.setFolder(true);
			}
			alTreeNodes.add(node);
		}
		if (eads.size() > MAX_NUMBER_OF_EADS) {
			// There are more eads to show, so it is necessary to
			// display a More after... node
			AlTreeNode node = new AlTreeNode();
			addMore(node, locale);
			addKey(node, alType, aiId, TreeType.GROUP, start + MAX_NUMBER_OF_EADS+1);
			node.setHideCheckbox(true);
			node.setFolder(true);
			alTreeNodes.add(node);
		}
		return alTreeNodes;
	}

	private List<AlTreeNode> generateCLevelsJSON(List<CLevel> clevels, String key,
			Integer aiId, Locale locale) {
		List<AlTreeNode> alTreeNodes = new ArrayList<AlTreeNode>();
		int numberOfCLevelsToShow;
		if (clevels.size() > MAX_NUMBER_OF_CLEVELS) {
			numberOfCLevelsToShow = MAX_NUMBER_OF_CLEVELS;
		} else {
			numberOfCLevelsToShow = clevels.size() - 1;
		}
		for (int i = 0; i <= numberOfCLevelsToShow; i++) {
			CLevel clevel = clevels.get(i);
			AlTreeNode node = new AlTreeNode();
			addTitle(node, clevel.getUnittitle(), locale);
			if (clevel.isLeaf()) {
				HgSgFaRelation hgSgFaRelation = clevel.getHgSgFaRelation();
				// The node is a Finding Aid
				if (hgSgFaRelation != null && hgSgFaRelation.getFindingAid().isPublished()) {
					addKey(node, AlType.FINDING_AID, hgSgFaRelation.getFaId(), TreeType.LEAF);
					addPreviewCId(node, clevel.getId());
				} else {
					node.setHideCheckbox(true);
					addPreviewCId(node, clevel.getId());
				}

			} else {
				// The node is a group (series, subseries) within the
				// EAD
				addKey(node, AlType.C_LEVEL, clevel.getId(), TreeType.GROUP);
				node.setFolder(true);
				addAiId(node, aiId);
				node.setHideCheckbox(true);
			}
			alTreeNodes.add(node);
		}

		if (clevels.size() > MAX_NUMBER_OF_CLEVELS) {
			// There are more c_levels to show, so it is necessary to
			// display a More after... node
			AlTreeNode node = new AlTreeNode();
			addMore(node, locale);
			Integer start = AlType.getStart(key);
			addKey(node, key, start + MAX_NUMBER_OF_CLEVELS+1);
			addAiId(node, aiId);
			node.setHideCheckbox(true);
			node.setFolder(true);
			alTreeNodes.add(node);
		}
		return alTreeNodes;
	}
	private List<String> generateExpandedNodes(List<String> selectedNodes){
		List<String> expandedNodesList = new ArrayList<String>();
		for (String selectedNode: selectedNodes){
			AlType alType = AlType.getAlType(selectedNode);
			Long id = AlType.getId(selectedNode);
//			TreeType treeType = AlType.getTreeType(selectedNode);
			if (AlType.ARCHIVAL_INSTITUTION.equals(alType)){
				ArchivalInstitution archivalInstitution = archivalInstitutionDAO.getArchivalInstitution(id.intValue());
				Integer parentAiId = archivalInstitution.getParentAiId();
				ArchivalInstitution current = archivalInstitution;
				while (parentAiId != null){
					current = current.getParent();
					expandedNodesList.add(AlType.getKey(AlType.ARCHIVAL_INSTITUTION, parentAiId, TreeType.GROUP));
					parentAiId = current.getParentAiId();
				}
				if (current.getParentAiId() == null){
					expandedNodesList.add(AlType.getKey(AlType.COUNTRY, current.getCountryId(), TreeType.GROUP));
				}
			}
		}
		return expandedNodesList;

	}

	private void addTitle(TreeNode dynaTreeNode, String title, Locale locale) {
		addTitle(dynaTreeNode, null, title, locale);
	}

	private void addAiId(AlTreeNode node, Integer aiId) {
		node.setAiId(aiId);
	}

	private void addTitleFromKey(AlTreeNode node, String titleKey, Locale locale) {
		addTitle(node, null, this.getMessageSource().getMessage(titleKey, null, locale), locale);
	}
	private static void addKeyWithDepth(AlTreeNode node, AlType alType, Number id, TreeType treeType, int depth) {
		node.setKey(AlType.getKeyWithDepth(alType, id, treeType, depth));
	}
	private static void addKey(AlTreeNode node, AlType alType, Number id, TreeType treeType) {
		node.setKey(AlType.getKey(alType, id, treeType));
	}
	private static void addKey(AlTreeNode node, AlType alType, Number id, TreeType treeType, Integer start) {
		node.setKey(AlType.getKey(alType, id, treeType, start));
	}
	private static void addKey(AlTreeNode node, String key, Integer start) {
		node.setKey(AlType.getKey(key, start));

	}

	private void addPreviewId(AlTreeNode node, Integer id, XmlType xmlType) {
		node.setPreviewId(xmlType.getSolrPrefix() + id);
	}

	private void addPreviewCId(AlTreeNode node, Long id) {
		node.setPreviewId("C" + id);
	}

}
