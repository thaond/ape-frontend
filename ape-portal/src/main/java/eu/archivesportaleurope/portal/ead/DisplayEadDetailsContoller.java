package eu.archivesportaleurope.portal.ead;

import java.util.List;

import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.portlet.ModelAndView;
import org.springframework.web.portlet.bind.annotation.ActionMapping;
import org.springframework.web.portlet.bind.annotation.RenderMapping;
import org.springframework.web.portlet.bind.annotation.ResourceMapping;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.util.PropsUtil;
import com.liferay.portal.model.User;
import com.liferay.portal.service.UserLocalServiceUtil;

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
import eu.archivesportaleurope.portal.common.SpringResourceBundleSource;
import eu.archivesportaleurope.portal.common.email.EmailSender;
import eu.archivesportaleurope.portal.contact.Contact;
import eu.archivesportaleurope.portal.contact.ContactValidator;

/**
 * 
 * This is display ead controller
 * 
 * @author bverhoef
 * 
 */
@Controller(value = "displayEadDetailsController")
@RequestMapping(value = "VIEW")
public class DisplayEadDetailsContoller {
	private static final int PAGE_SIZE = 10;
	private final static Logger LOGGER = Logger.getLogger(DisplayEadDetailsContoller.class);
	private CLevelDAO clevelDAO;
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

	public void setClevelDAO(CLevelDAO clevelDAO) {
		this.clevelDAO = clevelDAO;
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
		modelAndView.getModelMap().addAttribute("type", AbstractEadTag.CDETAILS_XSLT);
		CLevel currentCLevel = clevelDAO.findById(id);
		Integer pageNumberInt = 1;
		if (eadDetailsParams.getPageNumber() != null) {
			pageNumberInt = eadDetailsParams.getPageNumber();
		}
		int orderId = (pageNumberInt - 1) * PAGE_SIZE;
		List<CLevel> children = clevelDAO.findChildCLevels(currentCLevel.getClId(), orderId, PAGE_SIZE);
		Long totalNumberOfChildren = clevelDAO.countChildCLevels(id);
		StringBuilder builder = new StringBuilder();
		builder.append("<c xmlns=\"urn:isbn:1-931666-22-9\">");
		for (CLevel child : children) {
			builder.append(child.getXml());
		}
		builder.append("</c>");
		ArchivalInstitution archivalInstitution = currentCLevel.getEadContent().getEad().getArchivalInstitution();
		modelAndView.getModelMap().addAttribute("c", currentCLevel);
		modelAndView.getModelMap().addAttribute("totalNumberOfChildren", totalNumberOfChildren);
		modelAndView.getModelMap().addAttribute("pageNumber", pageNumberInt);
		modelAndView.getModelMap().addAttribute("pageSize", PAGE_SIZE);
		modelAndView.getModelMap().addAttribute("childXml", builder.toString());
		SpringResourceBundleSource source = new SpringResourceBundleSource(this.getMessageSource(),
				portletRequest.getLocale());
		String localizedName = DisplayUtils.getLocalizedCountryName(source, archivalInstitution.getCountry());
		modelAndView.getModelMap().addAttribute("localizedCountryName", localizedName);
		String documentTitle = currentCLevel.getUnittitle();
		documentTitle = PortalDisplayUtil.getEadDisplayTitle(currentCLevel.getEadContent().getEad(), documentTitle);
		modelAndView.getModelMap().addAttribute("documentTitle", documentTitle);
		modelAndView.getModelMap().addAttribute("aiId", archivalInstitution.getAiId());
		modelAndView.getModelMap().addAttribute("archivalInstitution", archivalInstitution);
		modelAndView.setViewName("eaddetails");
		
		return addAttributes(modelAndView, portletRequest);
	}
	
	private ModelAndView displayEadDetails(EadDetailsParams eadDetailsParams, PortletRequest portletRequest) {
		ModelAndView modelAndView = new ModelAndView();
		if (eadDetailsParams.getEcId() != null) {
			EadContent eadContent = eadContentDAO.findById(eadDetailsParams.getEcId());
			if (eadContent != null) {
				modelAndView.getModelMap().addAttribute("type", AbstractEadTag.FRONTPAGE_XSLT);	
				SpringResourceBundleSource source = new SpringResourceBundleSource(this.getMessageSource(),
						portletRequest.getLocale());
				ArchivalInstitution archivalInstitution = eadContent.getEad().getArchivalInstitution();
				String localizedName = DisplayUtils.getLocalizedCountryName(source, archivalInstitution.getCountry());
				modelAndView.getModelMap().addAttribute("localizedCountryName", localizedName);
				String documentTitle = eadContent.getUnittitle();
				documentTitle = PortalDisplayUtil.getEadDisplayTitle(eadContent.getEad(), documentTitle);
				modelAndView.getModelMap().addAttribute("documentTitle",documentTitle);
				modelAndView.getModelMap().addAttribute("eadContent", eadContent);
				XmlType xmlType = XmlType.getEadType(eadContent.getEad());
				modelAndView.getModelMap().addAttribute("archivalInstitution", archivalInstitution);
				modelAndView.getModelMap().addAttribute("xmlTypeName", xmlType.getResourceName());
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
		
		return addAttributes(modelAndView, portletRequest);
	}

	/**
	 * This method loads all required fields to load reCaptcha object in the "Send feedback" page from the portal-ext.properties file using the PropsUtil.get method.
	 * @param model ModelAndView object.
	 * @param portletRequest PortletRequest object.
	 * @return modelAndView object with the next attributes loaded: "loggedIn", "reCaptchaUrl_script", "reCaptchaUrl_noscript" and "recaptchaPubKey".
	 */
	private ModelAndView addAttributes (ModelAndView model, PortletRequest portletRequest){
		ModelAndView modelAndView = model;
		
		String logged = null;
		if (portletRequest.getUserPrincipal() != null && portletRequest.getUserPrincipal().getName() != null) {
			logged = portletRequest.getUserPrincipal().getName();
			try {
				User user = UserLocalServiceUtil.getUser(Long.parseLong(portletRequest.getUserPrincipal().getName()));

		        modelAndView.getModelMap().addAttribute("eMail", user.getEmailAddress());
			} catch (NumberFormatException e) {
				LOGGER.error("Number format exception: " + e.getMessage());
			} catch (PortalException e) {
				LOGGER.error("Portal exception: " + e.getMessage());
			} catch (SystemException e) {
				LOGGER.error("System exception: " + e.getMessage());
			}
		}
		modelAndView.getModelMap().addAttribute("loggedIn", logged);
		modelAndView.getModelMap().addAttribute("reCaptchaUrl_script", PropsUtil.get("captcha.engine.recaptcha.url.script"));
		modelAndView.getModelMap().addAttribute("reCaptchaUrl_noscript", PropsUtil.get("captcha.engine.recaptcha.url.noscript"));
		modelAndView.getModelMap().addAttribute("recaptchaPubKey", PropsUtil.get("captcha.engine.recaptcha.key.public"));
		
		return modelAndView;
	}

    @RenderMapping(params = "myaction=success")
    public String showPageResult(RenderResponse response, Model model) {
        return "success";
    }

    @RenderMapping(params = "myaction=error")
    public String showPageError(RenderResponse response, Model model) {
        return "error";
    }


    @ActionMapping(params = "myaction=contact")
    public void showResult(@ModelAttribute("contact") Contact contact, BindingResult result, ActionResponse response) {
        ContactValidator contactValidator = new ContactValidator();
        contactValidator.validate(contact, result);
        if(result.hasErrors()) {
            response.setRenderParameter("myaction", "error");
            return;
        }
        try {
            EmailSender.sendEmail(contact.getType(), contact.getEmail(), contact.getFeedback());
            response.setRenderParameter("myaction", "success");
        } catch (Exception e) {
            response.setRenderParameter("myaction", "error");
        }
    }
}
