package eu.archivesportaleurope.portal.ead;

import java.util.List;

import javax.portlet.PortletRequest;
import javax.portlet.RenderRequest;
import javax.portlet.ResourceRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.portlet.ModelAndView;
import org.springframework.web.portlet.bind.annotation.RenderMapping;
import org.springframework.web.portlet.bind.annotation.ResourceMapping;

import eu.apenet.commons.solr.SolrValues;
import eu.apenet.commons.types.XmlType;
import eu.apenet.commons.utils.DisplayUtils;
import eu.apenet.commons.xslt.tags.AbstractEadTag;
import eu.apenet.persistence.dao.CLevelDAO;
import eu.apenet.persistence.dao.EadContentDAO;
import eu.apenet.persistence.vo.ArchivalInstitution;
import eu.apenet.persistence.vo.CLevel;
import eu.apenet.persistence.vo.EadContent;
import eu.archivesportaleurope.portal.common.PortalDisplayUtil;
import eu.archivesportaleurope.portal.common.PropertiesKeys;
import eu.archivesportaleurope.portal.common.PropertiesUtil;
import eu.archivesportaleurope.portal.common.SpringResourceBundleSource;

/**
 * 
 * This is display ead controller
 * 
 * @author bverhoef
 * 
 */
@Controller(value = "displayEadDetailsController")
@RequestMapping(value = "VIEW")
public class DisplayEadDetailsContoller extends AbstractEadController {
	private static final int PAGE_SIZE = 10;
	private final static Logger LOGGER = Logger.getLogger(DisplayEadDetailsContoller.class);
	private EadContentDAO eadContentDAO;
	private MessageSource messageSource;
	
	public void setMessageSource(MessageSource messageSource) {
		this.messageSource = messageSource;
	}

	public MessageSource getMessageSource() {
		return messageSource;
	}
	
	public void setEadContentDAO(EadContentDAO eadContentDAO) {
		this.eadContentDAO = eadContentDAO;
	}


	@ResourceMapping(value = "displayEadDetails")
	public ModelAndView displayDetails(@ModelAttribute(value = "eadDetailsParams") EadDetailsParams eadDetailsParams, ResourceRequest resourceRequest) {
		if (StringUtils.isNotBlank(eadDetailsParams.getId())) {
			return displayCDetails(eadDetailsParams,resourceRequest);
		} else {
			return displayEadDetails(eadDetailsParams,resourceRequest);
		}
	}

	@RenderMapping(params = "myaction=printEadDetails")
	public ModelAndView printDetails(@ModelAttribute(value = "eadDetailsParams") EadDetailsParams eadDetailsParams, RenderRequest renderRequest) {
		ModelAndView modelAndView = null;
		if (StringUtils.isNotBlank(eadDetailsParams.getId())) {
			modelAndView = displayCDetails(eadDetailsParams, renderRequest);
		} else {
			modelAndView = displayEadDetails(eadDetailsParams, renderRequest);
		}
		modelAndView.setViewName("printEaddetails");
		return modelAndView;

	}
	    
	private ModelAndView displayCDetails(EadDetailsParams eadDetailsParams, PortletRequest portletRequest) {
		ModelAndView modelAndView = new ModelAndView();
		Long id = null;
		if (eadDetailsParams.getId().startsWith(SolrValues.C_LEVEL_PREFIX)) {
			id = Long.parseLong(eadDetailsParams.getId().substring(1));
		} else {
			id = Long.parseLong(eadDetailsParams.getId());
		}
		CLevel currentCLevel = getClevelDAO().findById(id);
		fillCDetails(currentCLevel, portletRequest, eadDetailsParams.getPageNumber(),modelAndView );
		modelAndView.setViewName("eaddetails");
		return modelAndView;
	}

	private ModelAndView displayEadDetails(EadDetailsParams eadDetailsParams, PortletRequest portletRequest) {
		ModelAndView modelAndView = new ModelAndView();
		if (eadDetailsParams.getEcId() != null) {
			EadContent eadContent = eadContentDAO.findById(eadDetailsParams.getEcId());
			if (eadContent != null) {
				fillEadDetails(eadContent,portletRequest, modelAndView);
				modelAndView.setViewName("eaddetails");
			} else {
				LOGGER.warn("No data available for ecId: " + eadDetailsParams.getEcId());
				modelAndView.getModelMap().addAttribute("errorMessage", "error.user.second.display.notexist");
				modelAndView.setViewName("eadDetailsError");
			}
		} else {
			LOGGER.warn("No ecId given");
			modelAndView.getModelMap().addAttribute("errorMessage", "error.user.second.display.notexist");
			modelAndView.setViewName("eadDetailsError");
		}

		
		return modelAndView;
	}


}
