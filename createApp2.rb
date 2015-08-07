require 'fileutils'

data = IO.readlines("config.txt")
tablecount = 0

FileUtils::mkdir_p 'app_name/appserver'
	FileUtils::mkdir_p 'app_name/appserver/templates'
		f = File.open("app_name/appserver/templates/redirect.tmpl", "w")
		f.write("<%
import cherrypy, re
from lib.i18n import current_lang
root_endpoint = cherrypy.request.config.get('root_endpoint')
root = (root_endpoint or '') + '/'
# Remove duplicate slashes at beginning/end of root_endpoint
root = re.sub(r'(/)\\1+$', r'\\1', re.sub(r'^(/)\\1+', r'\\1', root))
locale = \"-\".join([ x.lower() for x in current_lang()[0:2] if x is not None ])
%>
<!DOCTYPE html>
<script type=\"text/javascript\">
    document.location = \"${root}dj/${locale}/${APP['id']}\"
</script>")
		f.close

FileUtils::mkdir_p 'app_name/bin'
	f = File.open("app_name/bin/README", "w")
	f.write("Put search commands, scripted inputs and scripted lookups here...
")
	f.close

FileUtils::mkdir_p 'app_name/default'
	f = File.open("app_name/default/app.conf", "w")
	f.write("#
# Splunk app configuration file
#

[install]
is_configured = 0

[package]
id = app_name

[ui]
is_visible = True
label = app_name

[launcher]
author = 
description = 
version = 1.0
")
	f.close

	FileUtils::mkdir_p 'app_name/default/data'
		FileUtils::mkdir_p 'app_name/default/data/ui'
			FileUtils::mkdir_p 'app_name/default/data/ui/nav'
				f = File.open("app_name/default/data/ui/nav/default.xml", "w")
				f.write("<nav>
    <view name=\"default\" default=\"true\"/>
    <a href=\"/dj/redirector/app_name/home\">Home</a>
</nav>")
				f.close

			FileUtils::mkdir_p 'app_name/default/data/ui/views'
				f = File.open("app_name/default/data/ui/views/default.xml", "w")
				f.write("<view template=\"app_name:/templates/redirect.tmpl\" isVisible=\"false\"><label>Home</label></view>")
				f.close

FileUtils::mkdir_p 'app_name/django'
	FileUtils::mkdir_p 'app_name/django/app_name'
		f = File.open("app_name/django/app_name/__init__.py", "w")
		f.write("# Copyright 2015
")
		f.close

		f = File.open("app_name/django/app_name/tests.py", "w")
		f.write("\"\"\"
This file demonstrates writing tests using the unittest module. These will pass
when you run \"manage.py test\".

Replace this with more appropriate tests for your application.
\"\"\"

from django.test import TestCase


class SimpleTest(TestCase):
    def test_basic_addition(self):
        \"\"\"
        Tests that 1 + 1 always equals 2.
        \"\"\"
        self.assertEqual(1 + 1, 2)
")
		f.close

		f = File.open("app_name/django/app_name/urls.py", "w")
		f.write("from django.conf.urls import patterns, include, url
from splunkdj.utility.views import render_template as render

urlpatterns = patterns('',
    url(r'^home/$', 'app_name.views.home', name='home'), 
)
")
		f.close

		f = File.open("app_name/django/app_name/views.py", "w")
		f.write("from django.contrib.auth.decorators import login_required
from splunkdj.decorators.render import render_to

@render_to('app_name:home.html')
@login_required
def home(request):
    return {
        \"message\": \"Hello World from app_name!\",
        \"app_name\": \"app_name\"
    }")
		f.close

		FileUtils::mkdir_p 'app_name/django/app_name/static'
			FileUtils::mkdir_p 'app_name/django/app_name/static/app_name'
				f = File.open("app_name/django/app_name/static/app_name/custom.css", "w")
				f.write(".main-area {
	border: solid;
	border-width: 1px;
	margin: 0px auto;
	margin-top: 30px;
	margin-bottom: 30px;
	padding: 30px;
	width: 1100px;
	background-color: white;
}")
				f.close

				f = File.open("app_name/django/app_name/static/app_name/custom.js", "w")
				f.write("var urlprefix = document.URL.substr(0, document.URL.search(\"/dj\"));

require.config({
    baseUrl: urlprefix + \"/static/js\",
    waitSeconds: 0 // Disable require.js load timeout
});

//
// LIBRARY REQUIREMENTS
//
// In the require function, we include the necessary libraries and modules for
// the HTML dashboard. Then, we pass variable names for these libraries and
// modules as function parameters, in order.
// 
// When you add libraries or modules, remember to retain this mapping order
// between the library or module and its function parameter. You can do this by
// adding to the end of these lists, as shown in the commented examples below.

require([
    \"splunkjs/mvc\",
    \"splunkjs/mvc/utils\",
    \"splunkjs/mvc/tokenutils\",
    \"underscore\",
    \"jquery\",
    \"splunkjs/mvc/simplexml\",
    \"splunkjs/mvc/headerview\",
    \"splunkjs/mvc/footerview\",
    \"splunkjs/mvc/simplexml/dashboardview\",
    \"splunkjs/mvc/simplexml/element/chart\",
    \"splunkjs/mvc/simplexml/element/event\",
    \"splunkjs/mvc/simplexml/element/html\",
    \"splunkjs/mvc/simplexml/element/list\",
    \"splunkjs/mvc/simplexml/element/map\",
    \"splunkjs/mvc/simplexml/element/single\",
    \"splunkjs/mvc/simplexml/element/table\",
    \"splunkjs/mvc/simpleform/formutils\",
    \"splunkjs/mvc/simpleform/input/dropdown\",
    \"splunkjs/mvc/simpleform/input/radiogroup\",
    \"splunkjs/mvc/simpleform/input/multiselect\",
    \"splunkjs/mvc/simpleform/input/checkboxgroup\",
    \"splunkjs/mvc/simpleform/input/text\",
    \"splunkjs/mvc/simpleform/input/timerange\",
    \"splunkjs/mvc/simpleform/input/submit\",
    \"splunkjs/mvc/searchmanager\",
    \"splunkjs/mvc/savedsearchmanager\",
    \"splunkjs/mvc/postprocessmanager\",
    \"splunkjs/mvc/simplexml/urltokenmodel\"
    // Add comma-separated libraries and modules manually here, for example:
    // ...\"splunkjs/mvc/simplexml/urltokenmodel\",
    // \"splunkjs/mvc/checkboxview\"
    ],
    function(
        mvc,
        utils,
        TokenUtils,
        _,
        $,
        DashboardController,
        HeaderView,
        FooterView,
        Dashboard,
        ChartElement,
        EventElement,
        HtmlElement,
        ListElement,
        MapElement,
        SingleElement,
        TableElement,
        FormUtils,
        DropdownInput,
        RadioGroupInput,
        MultiSelectInput,
        CheckboxGroupInput,
        TextInput,
        TimeRangeInput,
        SubmitButton,
        SearchManager,
        SavedSearchManager,
        PostProcessManager,
        UrlTokenModel

        // Add comma-separated parameter names here, for example: 
        // ...UrlTokenModel, 
        // CheckboxView
        ) {


        var pageLoading = true;
        // 
        // TOKENS
        //
        
        // Create token namespaces
        var urlTokenModel = new UrlTokenModel();
        mvc.Components.registerInstance('url', urlTokenModel);
        var defaultTokenModel = mvc.Components.getInstance('default', {create: true});
        var submittedTokenModel = mvc.Components.getInstance('submitted', {create: true});

        urlTokenModel.on('url:navigate', function() {
            defaultTokenModel.set(urlTokenModel.toJSON());
            if (!_.isEmpty(urlTokenModel.toJSON()) && !_.all(urlTokenModel.toJSON(), _.isUndefined)) {
                submitTokens();
            } else {
                submittedTokenModel.clear();
            }
        });

        // Initialize tokens
        defaultTokenModel.set(urlTokenModel.toJSON());

        function submitTokens() {
            // Copy the contents of the defaultTokenModel to the submittedTokenModel and urlTokenModel
            FormUtils.submitForm({ replaceState: pageLoading });
        }

        function setToken(name, value) {
            defaultTokenModel.set(name, value);
            submittedTokenModel.set(name, value);
        }

        function unsetToken(name) {
            defaultTokenModel.unset(name);
            submittedTokenModel.unset(name);
        }
        //
        // SEARCH MANAGERS
        //
		")
				for i in 0..data.length - 5
					search = data[i].scan(/Search: "(.*)" ChartType:/)[0][0]
					f.write("var search#{i} = new SearchManager({
             \"id\": \"search#{i}\",
             \"search\": \"#{search}\",
             \"latest_time\": \"\",
             \"cancelOnUnload\": true,
             \"status_buckets\": 0,
             \"earliest_time\": \"\",
             \"app\": utils.getCurrentApp(),
             \"auto_cancel\": 90,
             \"preview\": true,
             \"runWhenTimeIsUndefined\": false
         }, {tokens: true, tokenNamespace: \"submitted\"});
		")
				end

				f.write("
        //
        // SPLUNK HEADER AND FOOTER
        //

        new HeaderView({
            id: 'header',
            section: 'dashboards',
            el: $('.header'),
            acceleratedAppNav: true,
            useSessionStorageCache: true
        }, {tokens: true}).render();

        new FooterView({
            id: 'footer',
            el: $('.footer')
        }, {tokens: true}).render();


        //
        // DASHBOARD EDITOR
        //

        //
        // VIEWS: VISUALIZATION ELEMENTS
        //
		")
				for i in 0..data.length - 5
					charttype = data[i].scan(/ChartType: "(.*)" RowType:/)[0][0]
					f.write("var element#{i} = new ChartElement({
             \"id\": \"element#{i}\",
             \"charting.chart\": \"#{charttype}\",
             \"resizable\": false,
             \"managerid\": \"search#{i}\",
             \"el\": $('#element#{i}')
         }, {tokens: true, tokenNamespace: \"submitted\"}).render();
		")
				end
				
				f.write("
        //
        // VIEWS: FORM INPUTS
        //

        // This section is only included for forms
        // Initialize time tokens to default
        if (!defaultTokenModel.has('earliest') && !defaultTokenModel.has('latest')) {
            defaultTokenModel.set({ earliest: '0', latest: '' });
        }

        submitTokens();


        //
        // DASHBOARD READY
        //

        DashboardController.ready();
        pageLoading = false;

    }
);")
				f.close

		FileUtils::mkdir_p 'app_name/django/app_name/templates'
			f = File.open("app_name/django/app_name/templates/home.html", "w")
			f.write("<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"utf-8\" />
    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\" />
    <title>App Documentation Home</title>
    <link rel=\"shortcut icon\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/img/favicon.ico\" />
    <link rel=\"stylesheet\" type=\"text/css\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/css/build/bootstrap.min.css\" />
    <link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/css/build/pages/dashboard-simple-bootstrap.min.css\" />
    <link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/app/search/dashboard.css\" />
    <script src=\"{{SPLUNKWEB_URL_PREFIX}}/config?autoload=1\"></script>
    <script src=\"{{SPLUNKWEB_URL_PREFIX}}/static/js/i18n.js\"></script>
    <script src=\"{{SPLUNKWEB_URL_PREFIX}}/i18ncatalog?autoload=1\"></script>
    <script src=\"{{SPLUNKWEB_URL_PREFIX}}/static/js/build/simplexml.min/config.js\"></script>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"{{STATIC_URL}}{{app_name}}/custom.css\" />
    <script src=\"{{STATIC_URL}}{{app_name}}/custom.js\"></script>
    <script src=\"{{STATIC_URL}}{{app_name}}/override.js\"></script>
    <!--[if IE 7]><link rel=\"stylesheet\" href=\"{{SPLUNKWEB_URL_PREFIX}}/static/css/sprites-ie7.css\" /><![endif]-->
</head>
<body class=\"simplexml preload\">

<!-- 
BEGIN LAYOUT
This section contains the layout for the dashboard. Splunk uses proprietary
styles in <div> tags, similar to Bootstrap's grid system. 
-->
<a class=\"navSkip\" href=\"#navSkip\" tabindex=\"1\">Screen reader users, click here to skip the navigation bar</a>
<div class=\"header\">
    <div id=\"placeholder-splunk-bar\">
        <a href=\"{{SPLUNKWEB_URL_PREFIX}}/app/launcher/home\" class=\"brand\" title=\"splunk > listen to your data\">splunk<strong>></strong></a>
    </div>
    <div id=\"placeholder-app-bar\"></div>
</div>
<a id=\"navSkip\"></a>
    <div>
        <div class=\"main-area\">
        	")

			for i in 0..data.length - 5
				charttype = data[i].scan(/ChartType: "(.*)" RowType:/)[0][0]
				rowtype = data[i].scan(/RowType: "(.*)" PanelName:/)[0][0].to_s
				panelname = data[i].scan(/PanelName: "(.*)"/)[0][0]
				if rowtype.include? "Double"
					if tablecount == 0
						f.write("<table width=\"100%\">
			<tr>
			<td width=\"50%\">
			")
					end
				end
				f.write("<div class=\"panel-element-row\">
			    <div id=\"element#{i}\" class=\"dashboard-element chart\">
			        <div class=\"panel-head\">
			            <h3>#{panelname}</h3>
			        </div>
		        </div>
		    </div>
		    <br>
		    ")
				if rowtype.include? "Double"
					if tablecount == 0
						f.write("</td>
			<td>
			")
						tablecount += 1
					elsif tablecount == 1
						f.write("</td>
			</tr>
			</table>
			")
						tablecount = 0
					end
				end
			end

             f.write("
         </div>
     </div>
 <div class=\"footer\"></div>

 </body>
 </html>")
			f.close

		FileUtils::mkdir_p 'app_name/django/app_name/templatetags'
			f = File.open("app_name/django/app_name/templatetags/__init__.py", "w")
			f.write("")
			f.close

f = File.open("app_name/README", "w")
f.write("Introduction
------------
Describe your application here.

Installation
------------
Describe how to install your application here (if applicable).

Usage
-----
Describe how to use your application here.

TODO:
-----
If you intend to upload this application to Splunk Apps, we strongly recommend 
that you update the app.conf file (located in your app's /default directory) 
with your name, a one-sentence description of your application, and the
version number of your application.")
f.close

FileUtils::mkdir_p 'app_name/lookups'

FileUtils::mkdir_p 'app_name/static'

