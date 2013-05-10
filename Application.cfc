/**
* 
* This file is part of MuraPlugin
*
* Copyright 2013 Stephen J. Withington, Jr.
* Licensed under the Apache License, Version v2.0
* http://www.apache.org/licenses/LICENSE-2.0
*
*/
component accessors=true output=false {

	property name='$';
	property name='pluginConfig';

	this.pluginName = 'MuraPlugin';

	include '../../config/applicationSettings.cfm';
	include '../../config/mappings.cfm';
	include '../mappings.cfm';

	public any function onApplicationStart() {
		include '../../config/appcfc/onApplicationStart_include.cfm';
		return true;
	}

	public any function onRequestStart(required string targetPage) {
		var $ = StructKeyExists(application, 'serviceFactory') ? application.serviceFactory.getBean('$') : {};

		include '../../config/appcfc/onRequestStart_include.cfm';

		if ( StructKeyExists(session, 'siteid') ) {
			$.init(session.siteid);
		} else {
			$.init('default');
		}

		if ( StructKeyExists(url, $.globalConfig('appreloadkey')) ) {
			onApplicationStart();
		}

		set$($);
		setPluginConfig($.getPlugin(this.pluginName));
		// You may want to change the methods being used to secure the request
		secureRequest();

		return true;
	}

	public void function onRequest(required string targetPage) {
		include '#arguments.targetPage#';
	}


	// ---------------------------------------------------------------------------------
	// HELPERS

	public any function secureRequest() {
		if ( !allowedAccess() ) {
			location(url='#$.globalConfig('context')#/admin/index.cfm?muraAction=clogin.main&returnURL=/plugins/MuraPlugin/', addtoken=false);
		}
	}

	public any function allowedAccess() {
		// You could also check the user's group with $.currentUser().isInGroup('Some Group Name')
		return $.currentUser().isSuperUser() && inPluginDirectory() ? true : false;
	}

	public boolean function inPluginDirectory() {
		return ListFindNoCase(getPageContext().getRequest().getRequestURI(), 'plugins', '/');
	}

}