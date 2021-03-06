package eu.archivesportaleurope.portal.directory;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.portlet.bind.annotation.ResourceMapping;

import com.google.code.geocoder.Geocoder;
import com.google.code.geocoder.GeocoderRequestBuilder;
import com.google.code.geocoder.model.GeocodeResponse;
import com.google.code.geocoder.model.GeocoderGeometry;
import com.google.code.geocoder.model.GeocoderRequest;
import com.google.code.geocoder.model.GeocoderResult;
import com.google.code.geocoder.model.GeocoderStatus;
import com.google.code.geocoder.model.LatLng;
import com.google.code.geocoder.model.LatLngBounds;

import eu.apenet.commons.infraestructure.ArchivalInstitutionUnit;
import eu.apenet.commons.infraestructure.CountryUnit;
import eu.apenet.commons.infraestructure.NavigationTree;
import eu.apenet.commons.utils.APEnetUtilities;
import eu.apenet.persistence.dao.ArchivalInstitutionDAO;
import eu.apenet.persistence.dao.CoordinatesDAO;
import eu.apenet.persistence.dao.CountryDAO;
import eu.apenet.persistence.vo.ArchivalInstitution;
import eu.apenet.persistence.vo.Coordinates;
import eu.apenet.persistence.vo.Country;
import eu.archivesportaleurope.portal.common.PortalDisplayUtil;
import eu.archivesportaleurope.portal.common.PropertiesKeys;
import eu.archivesportaleurope.portal.common.PropertiesUtil;
import eu.archivesportaleurope.portal.common.SpringResourceBundleSource;
import eu.archivesportaleurope.portal.common.tree.AbstractJSONWriter;
import eu.archivesportaleurope.util.ApeUtil;

	/**
	 * Class for JSON Writer for the directory tree
	 * 
	 * @author bastiaan
	 * 
	 */
	@Controller(value = "directoryJSONWriter")
	@RequestMapping(value = "VIEW")
	public class DirectoryJSONWriter extends AbstractJSONWriter {
		private static final String FOLDER_LAZY = "\"isFolder\": true, \"isLazy\": true";
		private static final String FOLDER_NOT_LAZY = "\"isFolder\": true";
		private static final String NO_LINK = "\"noLink\": true";
		private static final String EUROPE = "Europe";
		private CoordinatesDAO coordinatesDAO;
		private ArchivalInstitutionDAO archivalInstitutionDAO;
		private CountryDAO countryDAO;
		private final Logger log = Logger.getLogger(getClass());
		
		/**
		 * Method for write conuntries JSON
		 * @param resourceRequest {@link ResourceRequest} The ResourceRequest interface represents the request send to the portlet for rendering resources.
		 * @param resourceResponse {@link ResourceResponse} The ResourceResponse defines an object to assist a portlet for rendering a resource. 
		 */
		@ResourceMapping(value = "directoryTree")
		public void writeCountriesJSON(ResourceRequest resourceRequest, ResourceResponse resourceResponse) {
			this.log.debug("Method start: \"fillEAG2012\"");
			long startTime = System.currentTimeMillis();
			try {
				SpringResourceBundleSource source = new SpringResourceBundleSource(this.getMessageSource(),
						resourceRequest.getLocale());
				NavigationTree navigationTree = new NavigationTree(source);
				List<CountryUnit> countryList = navigationTree.getALCountriesWithArchivalInstitutionsWithEAG();
	
				Collections.sort(countryList);
				writeToResponseAndClose(generateDirectoryJSON(navigationTree, countryList), resourceResponse);
			} catch (Exception e) {
				log.error(ApeUtil.generateThrowableLog(e));
			}
			log.debug("Context search time: " + (System.currentTimeMillis() - startTime));
	}
		
	/**
	 * Method for generate countries tree JSON
	 * @param navigationTree {@link NavigationTree}
	 * @param countryList {@link List<CountryUnit>}}
	 * @return builder {@link StringBuilder}
	 */
	private StringBuilder generateCountriesTreeJSON(NavigationTree navigationTree, List<CountryUnit> countryList) {
		this.log.debug("Method start: \"fillEAG2012\"");
		CountryUnit countryUnit = null;
		StringBuilder builder = new StringBuilder();
		builder.append(START_ARRAY);
		for (int i = 0; i < countryList.size(); i++) {
			// It is necessary to build a JSON response to display all the
			// countries in Directory Tree
			countryUnit = countryList.get(i);
			builder.append(START_ITEM);
			addTitle(builder, countryUnit.getLocalizedName(), navigationTree.getResourceBundleSource().getLocale());
			builder.append(COMMA);
			builder.append(FOLDER_LAZY);
			builder.append(COMMA);
			addKey(builder, countryUnit.getCountry().getId(), "country");
			addGoogleMapsAddress(builder, countryUnit.getCountry().getCname());
			addCountryCode(builder, countryUnit.getCountry().getIsoname());
			builder.append(END_ITEM);
			if (i != countryList.size() - 1) {
				builder.append(COMMA);
			}
		}

		builder.append(END_ARRAY);
		countryUnit = null;
		this.log.debug("End method: \"fillEAG2012\"");
		return builder;

	}
	
	/**
	 * Method for generate directory JSON
	 * @param navigationTree {@link NavigationTree}
	 * @param countryList {@link List<CountryUnit>}
	 * @return builder {@link StringBuilder}
	 */
	private StringBuilder generateDirectoryJSON(NavigationTree navigationTree, List<CountryUnit> countryList) {
		this.log.debug("Method start: \"generateDirectoryJSON\"");
		StringBuilder builder = new StringBuilder();
		builder.append(START_ARRAY);
		builder.append(START_ITEM);
		addTitle(builder, navigationTree.getResourceBundleSource().getString("directory.text.directory"),
				navigationTree.getResourceBundleSource().getLocale());
		addGoogleMapsAddress(builder, EUROPE);
		builder.append(COMMA);
		addExpand(builder);
		builder.append(COMMA);
		builder.append(FOLDER_WITH_CHILDREN);
		builder.append(generateCountriesTreeJSON(navigationTree, countryList));
		builder.append(END_ITEM);
		builder.append(END_ARRAY);
		this.log.debug("End method: \"generateDirectoryJSON\"");
		return builder;
	}
	
	/**
	 * Method for write AiJson
	 * @param resourceRequest {@link ResourceRequest} The ResourceRequest interface represents the request send to the portlet for rendering resources.
	 * @param resourceResponse {@link ResourceResponse} The ResourceResponse defines an object to assist a portlet for rendering a resource. 
	 */
	@ResourceMapping(value = "directoryTreeAi")
	public void writeAiJSON(ResourceRequest resourceRequest, ResourceResponse resourceResponse) {
		this.log.debug("Method start: \"writeAiJSON\"");
		String nodeId = resourceRequest.getParameter("nodeId");
		String countryCode = resourceRequest.getParameter("countryCode");
		try {
			
			if (StringUtils.isBlank(nodeId) || StringUtils.isBlank(countryCode)) {
				StringBuilder builder = new StringBuilder();
				builder.append(START_ARRAY);
				builder.append(END_ARRAY);
				writeToResponseAndClose(builder, resourceResponse);
			} else {
				SpringResourceBundleSource source = new SpringResourceBundleSource(this.getMessageSource(),
						resourceRequest.getLocale());
				NavigationTree navigationTree = new NavigationTree(source);
				List<ArchivalInstitutionUnit> archivalInstitutionList = navigationTree
						.getArchivalInstitutionsByParentAiId(nodeId);

				// This filter has been added to display only those final
				// archival institutions or groups which have eag files uploaded
				// to the System
				// Remove it if the user wants to display again all the
				// institutions even if they doesn't eag files uploaded
				archivalInstitutionList = navigationTree.filterArchivalInstitutionsWithEAG(archivalInstitutionList);

				Collections.sort(archivalInstitutionList);
				writeToResponseAndClose(
						generateArchivalInstitutionsTreeJSON(navigationTree, archivalInstitutionList, countryCode),
						resourceResponse);
			}
			
		} catch (Exception e) {
			log.error(ApeUtil.generateThrowableLog(e));
		}
		this.log.debug("End method: \"writeAiJSON\"");

	}
	
	/**
	 * Method for generate archival institutions tree JSON
	 * @param navigationTree {@link NavigationTree}
	 * @param archivalInstitutionList {@link List<ArchivalInstitutionUnit>}
	 * @param countryCode {@link String}
	 * @return buffer {@link StringBuffer}
	 */
	private StringBuilder generateArchivalInstitutionsTreeJSON(NavigationTree navigationTree,	
		List<ArchivalInstitutionUnit> archivalInstitutionList, String countryCode) {
		this.log.debug("Method start: \"generateArchivalInstitutionsTreeJSON\"");
		Locale locale = navigationTree.getResourceBundleSource().getLocale();
		StringBuilder buffer = new StringBuilder();
		ArchivalInstitutionUnit archivalInstitutionUnit = null;
		
		buffer.append(START_ARRAY);
		for (int i = 0; i < archivalInstitutionList.size(); i++) {
			// It is necessary to build a JSON response to display all the
			// archival institutions in Directory Tree
			archivalInstitutionUnit = archivalInstitutionList.get(i);
			if (archivalInstitutionUnit.getIsgroup() && archivalInstitutionUnit.isHasArchivalInstitutions()) {
				// The Archival Institution is a group and it has archival
				// institutions within it
				buffer.append(START_ITEM);
				addTitle(buffer, archivalInstitutionUnit.getAiname(), locale);
				buffer.append(COMMA);
				buffer.append(FOLDER_LAZY);
				buffer.append(COMMA);
				addKey(buffer, archivalInstitutionUnit.getAiId(), "archival_institution_group");
				addCountryCode(buffer, countryCode);
				buffer.append(END_ITEM);
			} else if (archivalInstitutionUnit.getIsgroup() && !archivalInstitutionUnit.isHasArchivalInstitutions()) {
				// The Archival Institution is a group but it doesn't have any
				// archival institutions within it
				buffer.append(START_ITEM);
				addTitle(buffer, archivalInstitutionUnit.getAiname(), locale);
				buffer.append(COMMA);
				buffer.append(FOLDER_NOT_LAZY);
				buffer.append(COMMA);
				buffer.append(NO_LINK);
				buffer.append(COMMA);
				addKey(buffer, archivalInstitutionUnit.getAiId(), "archival_institution_group");
				addCountryCode(buffer, countryCode);
				buffer.append(END_ITEM);
			} else if (!archivalInstitutionUnit.getIsgroup()) {
				// The Archival Institution is a leaf
				buffer.append(START_ITEM);
				addTitle(buffer, archivalInstitutionUnit.getAiname(), locale);
				buffer.append(COMMA);
				if (archivalInstitutionUnit.getPathEAG() != null && !archivalInstitutionUnit.getPathEAG().equals("")) {
					// The archival institution has EAG
					addKey(buffer, archivalInstitutionUnit.getAiId(), "archival_institution_eag");
				} else {
					addKey(buffer, archivalInstitutionUnit.getAiId(), "archival_institution_no_eag");
					buffer.append(COMMA);
					buffer.append(NO_LINK);
				}
				addCountryCode(buffer, countryCode);
				buffer.append(END_ITEM);
			}
			if (i != archivalInstitutionList.size() - 1) {
				buffer.append(COMMA);
			}
		}

		buffer.append(END_ARRAY);
		archivalInstitutionUnit = null;
		this.log.debug("End method: \"generateArchivalInstitutionsTreeJSON\"");
		return buffer;

	}

	private void addTitle(StringBuilder buffer, String title, Locale locale) {
		addTitle(null, buffer, title, locale);
	}

	private static void addGoogleMapsAddress(StringBuilder buffer, String address) {
		buffer.append(COMMA);
		buffer.append("\"googleMapsAddress\":\"" + address + "\"");
	}

	private static void addCountryCode(StringBuilder buffer, String countryCode) {
		buffer.append(COMMA);
		buffer.append("\"countryCode\":\"" + countryCode + "\"");
	}

	private static void addKey(StringBuilder buffer, Number key, String nodeType) {

		if (nodeType.equals("country")) {
			buffer.append("\"key\":" + "\"country_" + key + "\"");
		} else if (nodeType.equals("archival_institution_group")) {
			buffer.append("\"key\":" + "\"aigroup_" + key + "\"");
		} else if (nodeType.equals("archival_institution_eag")) {
			buffer.append("\"aiId\":");
			buffer.append(" \"" + key);
			buffer.append("\" ");
			buffer.append(COMMA);
			buffer.append("\"key\":" + "\"aieag_" + key + "\"");

		} else if (nodeType.equals("archival_institution_no_eag")) {
			buffer.append("\"key\":" + "\"ainoeag_" + key + "\"");
		}
		
	}
	
	/**
	 * Method for display archival institution parents tree
	 * @param resourceRequest {@link ResourceRequest} The ResourceRequest interface represents the request send to the portlet for rendering resources.
	 * @param resourceResponse {@link ResourceResponse} The ResourceResponse defines an object to assist a portlet for rendering a resource. 
	 */
	@ResourceMapping(value = "directoryTreeArchivalInstitution")
	public void displayArchivalInstitutionParentsTree(ResourceRequest resourceRequest, ResourceResponse resourceResponse) {
		this.log.debug("Method start: \"displayArchivalInstitutionParentsTree\"");
		String aiId = null;
		if(resourceRequest.getParameter("aiId")!=null){
			aiId = (String)resourceRequest.getParameter("aiId");
		}
		if(aiId!=null){
			StringBuilder builder = new StringBuilder();
			builder.append(START_ARRAY);
			try{
				ArchivalInstitution ai = archivalInstitutionDAO.getArchivalInstitution(new Integer(aiId));
				Integer countryId = ai.getCountryId();
				builder.append(START_ITEM);
				Number key = ai.getAiId();
				addKey(builder,key,(ai.getEagPath()!=null)?"archival_institution_eag":"archival_institution_no_eag");
				builder.append(END_ITEM);
				builder.append(COMMA);
				boolean loop = ai.getParent()!=null;
				do{
					builder.append(START_ITEM);
					ai = ai.getParent();
					key = (ai!=null)?ai.getAiId():countryId;
					addKey(builder,key,(ai!=null)?"archival_institution_group":"country");
					builder.append(END_ITEM);
					if(loop){
						builder.append(COMMA);
					}
					if(ai.getParent()==null){
						builder.append(START_ITEM);
						addKey(builder,countryId,"country");
						builder.append(END_ITEM);
						loop = false;
					}
				}while(loop);
			}catch (Exception e) {
				log.error(APEnetUtilities.generateThrowableLog(e));
			}finally{
				builder.append(END_ARRAY);
				try {
					writeToResponseAndClose(builder, resourceResponse);
				} catch (UnsupportedEncodingException e) {
					log.error(APEnetUtilities.generateThrowableLog(e));
				} catch (IOException e) {
					log.error(APEnetUtilities.generateThrowableLog(e));
				}
			}
		}
		this.log.debug("End method: \"displayArchivalInstitutionParentsTree\"");
	}
	
	/***
	 * This method recovers the coordinates and other data from the database, In case of the selected item on the tree is a country this method call geocoder and gets coordinates for that country. Also This method prints only coordinates "inside the world" limits avoiding the use of non valid coordinates 
	 * @param resourceRequest {@link ResourceRequest} The ResourceRequest interface represents the request send to the portlet for rendering resources. It 
	 * extends the ClientDataRequest interface and provides resource request information to portlets. 
	 * The portlet container creates an ResourceRequest object and passes it as argument to the portlet's 
	 * serveResource method. 
	 * The ResourceRequest is provided with the current portlet mode, window state, and render parameters 
	 * that the portlet can access via the PortletResourceRequest with getPortletMode and, getWindowState, or 
	 * one of the getParameter methods. ResourceURLs cannot change the current portlet mode, window state 
	 * or render parameters. Parameters set on a resource URL are not render parameters but parameters for 
	 * serving this resource and will last only for only this the current serveResource request.
	 * @param resourceResponse {@link ResourceResponse} The ResourceResponse defines an object to assist a portlet for rendering a resource. 
	 * The difference between the RenderResponse is that for the ResourceResponse the output of this 
	 * response is delivered directly to the client without any additional markup added by the portal. It is 
	 * therefore allowed for the portlet to return binary content in this response. 
	 * A portlet can set HTTP headers for the response via the setProperty or addProperty call in the 
	 * ResourceResponse. To be successfully transmitted back to the client, headers must be set before the 
	 * response is committed. Headers set after the response is committed will be ignored by the portlet 
	 * container. 
	 * The portlet container creates a ResourceResponse object and passes it as argument to the portlet's 
	 */
	@ResourceMapping(value = "directoryTreeGMaps")
	public void displayGmaps(ResourceRequest resourceRequest, ResourceResponse resourceResponse) {
		this.log.debug("Method start: \"displayGmaps\"");
		long startTime = System.currentTimeMillis();
		try {
			SpringResourceBundleSource source = new SpringResourceBundleSource(this.getMessageSource(),
					resourceRequest.getLocale());
			NavigationTree navigationTree = new NavigationTree(source);

			String countryCode = resourceRequest.getParameter("countryCode");
			String institutionID = resourceRequest.getParameter("institutionID");
			String repositoryName = resourceRequest.getParameter("repositoryName");
			String onlyBounds = resourceRequest.getParameter("onlyBounds");
			//parse bad params (if jquery parse a null to "null", it has to be reconverted
			countryCode = (countryCode!=null && countryCode.equalsIgnoreCase("null"))?null:countryCode;
			institutionID = (institutionID!=null && institutionID.equalsIgnoreCase("null"))?null:institutionID;
			repositoryName = (repositoryName!=null && repositoryName.equalsIgnoreCase("null"))?null:repositoryName;
			List<Coordinates> reposList = new ArrayList<Coordinates>();
			if (!"true".equalsIgnoreCase(onlyBounds)){
				// Always recovers all the coordinates.
				reposList = coordinatesDAO.getCoordinates();
	
				// Remove coordinates with values (0, 0).
				if (reposList != null && !reposList.isEmpty()) {
					// New list without (0, 0) values.
					List<Coordinates> cleanReposList = new ArrayList<Coordinates>();
					Iterator<Coordinates> reposIt = reposList.iterator();
					while (reposIt.hasNext()) {
						Coordinates coordinates = reposIt.next();
						if (coordinates.getLat() != 0 || coordinates.getLon() != 0) {
							//control elements outside the printable earth coordinates (-77 to 82) and (-177 to 178)
							if ((coordinates.getLat() >=-77 && coordinates.getLat() <= 82) && (coordinates.getLon() >=-177 && coordinates.getLon() <= 178)) {
								cleanReposList.add(coordinates);
							}
						}
					}
					// Pass the clean array to the existing one.
					reposList = cleanReposList;
				}
			}
			// Check the part to center.
			if (repositoryName != null && !repositoryName.isEmpty()
					&& institutionID != null && !institutionID.isEmpty()) {
				writeToResponseAndClose(generateGmapsJSON(navigationTree, reposList, null, institutionID, repositoryName), resourceResponse);
			} else if (institutionID != null && !institutionID.isEmpty()) {
				writeToResponseAndClose(generateGmapsJSON(navigationTree, reposList, null, institutionID, null), resourceResponse);
			} else if (countryCode != null && !countryCode.isEmpty()) {
				writeToResponseAndClose(generateGmapsJSON(navigationTree, reposList, countryCode, null, null), resourceResponse);
			} else {
				writeToResponseAndClose(generateGmapsJSON(navigationTree, reposList, null, null, null), resourceResponse);
			}
		} catch (Exception e) {
			log.error(e.getMessage(), e);
		}
		log.debug("Context search time: " + (System.currentTimeMillis() - startTime));
		this.log.debug("End method: \"displayGmaps\"");
	}
	
	/**
	 * Method for generate Gmaps JSON
	 * @param navigationTree {@link NavigationTree}
	 * @param repoList {@link List<Coordinates>}
	 * @param countryCode {@link String}
	 * @param institutionID {@link String}
	 * @param repositoryName {@link String}
	 * @return builder {@link StringBuilder}
	 */
	private StringBuilder generateGmapsJSON(NavigationTree navigationTree, List<Coordinates> repoList, String countryCode, String institutionID, String repositoryName) {
		this.log.debug("Method start: \"generateGmapsJSON\"");
		StringBuilder builder = new StringBuilder();
		builder.append(START_ITEM);
		builder.append("\"count\":" + repoList.size());
		builder.append(COMMA);
		builder.append("\"repos\":");
		
		builder.append(START_ARRAY);
		if(repoList!=null){
			Iterator<Coordinates> itRepoList = repoList.iterator();
			while(itRepoList.hasNext()){
				Coordinates repo = itRepoList.next();
				builder.append(buildNode(repo));
				if(itRepoList.hasNext()){
					builder.append(COMMA);
				}
			}
		}
		builder.append(END_ARRAY);

		// Add the center values.
		if (repositoryName != null && !repositoryName.isEmpty()
				&& institutionID != null && !institutionID.isEmpty()) {
			// Call the method to add the bounds for the repository of the institution.
			builder.append(this.buildInstitutionBounds(institutionID, repositoryName));
		} else if (institutionID != null && !institutionID.isEmpty()) {
			// Call the method to add the bounds for the institution.
			builder.append(this.buildInstitutionBounds(institutionID, null));
		} else if (countryCode != null && !countryCode.isEmpty()) {
			// Call the method to add the bounds for the country.
			builder.append(this.buildCountryBounds(countryCode));
		}else{
			//To know if map must be focused in Europe
			String focusOnEurope = PropertiesUtil.get(PropertiesKeys.APE_GOOGLEMAPS_FOCUS_ON_EUROPE);
				
			//To get Map bounds to fit the map in Europe
			String southwestLatitude = PropertiesUtil.get(PropertiesKeys.APE_GOOGLEMAPS_CENTER_SOUTHWEST_LATITUDE);
			String southwestLongitude = PropertiesUtil.get(PropertiesKeys.APE_GOOGLEMAPS_CENTER_SOUTHWEST_LONGITUDE);
			String northeastLatitude = PropertiesUtil.get(PropertiesKeys.APE_GOOGLEMAPS_CENTER_NORTHEAST_LATITUDE);
			String northeastLongitude = PropertiesUtil.get(PropertiesKeys.APE_GOOGLEMAPS_CENTER_NORTHEAST_LONGITUDE);
			if(southwestLatitude!=null && southwestLongitude!=null && northeastLatitude!=null && northeastLongitude!=null){
				if(focusOnEurope.compareTo("true")==0){
					// Call the method to add the bounds for Europe.
					builder.append(this.centerMapBuilder(southwestLatitude.toString(),southwestLongitude.toString(),northeastLatitude.toString(),northeastLongitude.toString()));
				}
			}else{
				// bounds to the markers
			}
		}
		
		builder.append(END_ITEM);
		this.log.debug("End method: \"generateGmapsJSON\"");
		return builder;
	}
	
	/**
	 * Method for center map builder
	 * @param southwestLatitude {@link String}
	 * @param southwestLongitude {@link String}
	 * @param northeastLatitude {@link String}
	 * @param northeastLongitude {@link String}
	 * @return builder {@link StringBuilder}
	 */
	private StringBuilder centerMapBuilder(String southwestLatitude, String southwestLongitude,
		
			String northeastLatitude, String northeastLongitude) {
		this.log.debug("Method start: \"centerMapBuilder\"");
		StringBuilder builder = new StringBuilder();
		// Build bounds node.
		builder.append(COMMA);
		builder.append("\"bounds\":");

		//coordinates shouln't be with wrong characters, but as there are manually typed, it may be controlled
		
		builder.append(START_ARRAY);
		// Build southwest node.
		builder.append(START_ITEM);
		builder.append("\"latitude\":\"" + PortalDisplayUtil.replaceQuotesAndReturns(southwestLatitude) + "\"");
		builder.append(COMMA);
		builder.append("\"longitude\":\"" + PortalDisplayUtil.replaceQuotesAndReturns(southwestLongitude) + "\"");
		builder.append(END_ITEM);

		// Build northeast node.
		builder.append(COMMA);
		builder.append(START_ITEM);
		builder.append("\"latitude\":\"" + PortalDisplayUtil.replaceQuotesAndReturns(northeastLatitude) + "\"");
		builder.append(COMMA);
		builder.append("\"longitude\":\"" + PortalDisplayUtil.replaceQuotesAndReturns(northeastLongitude) + "\"");
		builder.append(END_ITEM);
		builder.append(END_ARRAY);
		this.log.debug("End method: \"centerMapBuilder\"");
		return builder;
	}
	
	/**
	 * Method for build node
	 * @param repon {@link Coordinates}
	 * @return builder {@link StringBuilder}
	 */
	private StringBuilder buildNode(Coordinates repo){
		this.log.debug("Method start: \"buildNode\"");
		StringBuilder builder = new StringBuilder();
		builder.append(START_ITEM);
		builder.append("\"latitude\":\""+repo.getLat()+"\"");
		builder.append(COMMA);
		builder.append("\"longitude\":\""+repo.getLon()+"\"");
		builder.append(COMMA);
		//this escapes " in field
		builder.append("\"name\":\""+PortalDisplayUtil.replaceQuotesAndReturns(repo.getNameInstitution())+"\"");
		ArchivalInstitution ai = repo.getArchivalInstitution();
		if(ai!=null){
			builder.append(COMMA);
			builder.append("\"aiId\":\""+ai.getAiId()+"\"");
		}
		//Parse street, postalCity and country 
		builder.append(COMMA);
		builder.append("\"street\":\""+PortalDisplayUtil.replaceQuotesAndReturns(repo.getStreet())+"\"");
		builder.append(COMMA);
		builder.append("\"postalcity\":\""+PortalDisplayUtil.replaceQuotesAndReturns(repo.getPostalCity())+"\"");
		builder.append(COMMA);
		builder.append("\"country\":\""+PortalDisplayUtil.replaceQuotesAndReturns(repo.getCountry())+"\"");
		builder.append(END_ITEM);
		this.log.debug("End method: \"buildNode\"");
		return builder;
	}

	/**
	 * Method to build the data for the institution bounds.
	 *
	 * @param institutionIDm {@link String} the Institution for recover the bounds.
	 * @return Element with the bounds for the institution passed.
	 */
	private StringBuilder buildInstitutionBounds(String institutionID, String repositoryName) {
		this.log.debug("Method start: \"buildInstitutionBounds\"");
		StringBuilder builder = new StringBuilder();
		// Recover the list of coordinates for the current institution.
		ArchivalInstitution archivalInstitution = archivalInstitutionDAO.findById(Integer.parseInt(institutionID));
		List<Coordinates> repoCoordinatesList = coordinatesDAO.findCoordinatesByArchivalInstitution(archivalInstitution);

		// If the list contains more than one elemet, find the proper element.
		if (repoCoordinatesList != null && !repoCoordinatesList.isEmpty()) {
			Coordinates coordinates = null;
			if (repoCoordinatesList.size() > 1) {
				Iterator<Coordinates> repoCoordinatesIt = repoCoordinatesList.iterator();
				if (repositoryName != null && !repositoryName.isEmpty()) {
					// Select the proper element from database.
					while (repoCoordinatesIt.hasNext()) {
						Coordinates coordinatesTest = repoCoordinatesIt.next();
						if (repositoryName.startsWith(coordinatesTest.getNameInstitution())) {
							coordinates = coordinatesTest;
						}
					}
				} else {
					// First element in database (main institution)
					while (repoCoordinatesIt.hasNext()) {
						Coordinates coordinatesTest = repoCoordinatesIt.next();
						if (coordinates != null) {
							if (coordinates.getId() > coordinatesTest.getId()) {
								coordinates = coordinatesTest;
							}
						} else {
							coordinates = coordinatesTest;
						}
					}
				}
			}

			// At this point, if coordinates still null, set the value of the
			// first element of the list.
			if (coordinates == null) {
				coordinates = repoCoordinatesList.get(0);
			}

			// if coords=0,0 or null call to show the country
			if(coordinates.getLat()==0.0 && coordinates.getLon()==0.0){
				builder.append(buildCountryBounds(archivalInstitution.getCountry().getIsoname()));
			}
			else{	
				// Build bounds node.
				builder.append(COMMA);
				builder.append("\"bounds\":");
	
				// Build coordinates node.
				builder.append(START_ARRAY);
				builder.append(START_ITEM);
				builder.append("\"latitude\":\"" + coordinates.getLat() + "\"");
				builder.append(COMMA);
				builder.append("\"longitude\":\"" + coordinates.getLon() + "\"");
				builder.append(END_ITEM);
				builder.append(END_ARRAY);
			}
		}
		else{
			builder.append(buildCountryBounds(archivalInstitution.getCountry().getIsoname()));
		}
		this.log.debug("End method: \"buildInstitutionBounds\"");
		return builder;
	}

	/**
	 * Method to build the data for the country bounds.
	 *
	 * @param countryCode {@link String} Country code for recover the bounds.
	 * @return Element with the bounds for the country code passed.
	 */
	private StringBuilder buildCountryBounds(String countryCode) {
		this.log.debug("Method start: \"buildCountryBounds\"");
		StringBuilder builder = new StringBuilder();
		List<Country> countriesList = countryDAO.getCountries(countryCode);
		
		if (countriesList != null && !countriesList.isEmpty()) {
			String selectedCountryName = countriesList.get(0).getCname();
			// Issue #1924 - To locate correctly the country "Georgia" instead
			// of the state "Georgia", it's needed to add in the address, which
			// is passed to the geolocator, the string ", Europe".
			// Whit this change all the European countries are located
			// correctly.
			// NOTE: currently exists a country with name "Europe", which
			// represents the country for the archive "Historical Archives of
			// the European Union", for this one it's not needed to add the
			// string in the address.
			if (!selectedCountryName.trim().equalsIgnoreCase("EUROPE")) {
				builder.append(this.mapBuilder(selectedCountryName + ", Europe"));
			} else {
				builder.append(this.mapBuilder(selectedCountryName));
			}
		}
		this.log.debug("End method: \"buildCountryBounds\"");
		return builder;
	}
	
	/**
	 * Method for map builder
	 * @param location {@link String}
	 * @return builder {@link StringBuilder}
	 */
	private StringBuilder mapBuilder(String location){
		this.log.debug("Method start: \"mapBuilder\"");
		StringBuilder builder = new StringBuilder();
		// Try to recover the coordinates to bound.
		Geocoder geocoder = new Geocoder();

		GeocoderRequest geocoderRequest = new GeocoderRequestBuilder().setAddress(location).getGeocoderRequest();
		GeocodeResponse geocoderResponse = geocoder.geocode(geocoderRequest);

		if (geocoderResponse.getStatus().equals(GeocoderStatus.OK)) {
			List<GeocoderResult> geocoderResultList = geocoderResponse.getResults();

			// Always recover the first result.
			if (geocoderResultList.size() > 0) {
				GeocoderResult geocoderResult = geocoderResultList.get(0);
	
				// Get Geometry Object.
				GeocoderGeometry geocoderGeometry = geocoderResult.getGeometry();
				// Get Bounds Object.
				LatLngBounds latLngBounds = geocoderGeometry.getBounds();
	
				// Get southwest bound.
				LatLng southwestLatLng = latLngBounds.getSouthwest();
				// Get southwest latitude.
				Double southwestLatitude = southwestLatLng.getLat().doubleValue();
				// Get southwest longitude.
				Double southwestLongitude = southwestLatLng.getLng().doubleValue();
	
				// Get northeast bound.
				LatLng northeastLatLng = latLngBounds.getNortheast();
				// Get northeast latitude.
				Double northeastLatitude = northeastLatLng.getLat().doubleValue();
				// Get northeast longitude.
				Double northeastLongitude = northeastLatLng.getLng().doubleValue();
	
				builder.append(this.centerMapBuilder(southwestLatitude.toString(),
						southwestLongitude.toString(),
						northeastLatitude.toString(),
						northeastLongitude.toString()));

			}
		}
		this.log.debug("End method: \"mapBuilder\"");
		return builder;
	}

	public void setCoordinatesDAO(CoordinatesDAO coordinatesDAO) {
		this.coordinatesDAO = coordinatesDAO;
	}

	public void setArchivalInstitutionDAO(ArchivalInstitutionDAO archivalInstitutionDAO) {
		this.archivalInstitutionDAO = archivalInstitutionDAO;
	}

	public void setCountryDAO(CountryDAO countryDAO) {
		this.countryDAO = countryDAO;
	}
	
}