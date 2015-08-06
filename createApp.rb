require 'fileutils'

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
version = 1.0.0
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

		f = File.open("app_name/django/app_name/__init__.pyo", "w")
		f.write("03f3 0d0a dd65 a655 6300 0000 0000 0000
0001 0000 0040 0000 0073 0400 0000 6400
0053 2801 0000 004e 2800 0000 0028 0000
0000 2800 0000 0028 0000 0000 734a 0000
002f 4170 706c 6963 6174 696f 6e73 2f53
706c 756e 6b2f 6574 632f 6170 7073 2f74
656d 706c 6174 655f 6170 702f 646a 616e
676f 2f74 656d 706c 6174 655f 6170 702f
5f5f 696e 6974 5f5f 2e70 7974 0800 0000
3c6d 6f64 756c 653e 0100 0000 7300 0000
00")
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

@render_to('template_app:home.html')
@login_required
def home(request):
    return {
        \"message\": \"Hello World from template_app!\",
        \"app_name\": \"template_app\"
    }")
		f.close

		f = File.open("app_name/django/app_name/urls.pyo", "w")
		f.write("03f3 0d0a dd65 a655 6300 0000 0000 0000
0007 0000 0040 0000 0073 4e00 0000 6400
0064 0100 6c00 006d 0100 5a01 006d 0200
5a02 006d 0300 5a03 0001 6400 0064 0200
6c04 006d 0500 5a06 0001 6501 0064 0300
6503 0064 0400 6405 0064 0600 6407 0083
0201 8302 005a 0700 6408 0053 2809 0000
0069 ffff ffff 2803 0000 0074 0800 0000
7061 7474 6572 6e73 7407 0000 0069 6e63
6c75 6465 7403 0000 0075 726c 2801 0000
0074 0f00 0000 7265 6e64 6572 5f74 656d
706c 6174 6574 0000 0000 7307 0000 005e
686f 6d65 2f24 7317 0000 0074 656d 706c
6174 655f 6170 702e 7669 6577 732e 686f
6d65 7404 0000 006e 616d 6574 0400 0000
686f 6d65 4e28 0800 0000 7410 0000 0064
6a61 6e67 6f2e 636f 6e66 2e75 726c 7352
0000 0000 5201 0000 0052 0200 0000 7416
0000 0073 706c 756e 6b64 6a2e 7574 696c
6974 792e 7669 6577 7352 0300 0000 7406
0000 0072 656e 6465 7274 0b00 0000 7572
6c70 6174 7465 726e 7328 0000 0000 2800
0000 0028 0000 0000 7346 0000 002f 4170
706c 6963 6174 696f 6e73 2f53 706c 756e
6b2f 6574 632f 6170 7073 2f74 656d 706c
6174 655f 6170 702f 646a 616e 676f 2f74
656d 706c 6174 655f 6170 702f 7572 6c73
2e70 7974 0800 0000 3c6d 6f64 756c 653e
0100 0000 7306 0000 001c 0110 0206 01")
		f.close

		f = File.open("app_name/django/app_name/views.pyo", "w")
		f.write("03f3 0d0a dd65 a655 6300 0000 0000 0000
0003 0000 0040 0000 0073 3f00 0000 6400
0064 0100 6c00 006d 0100 5a01 0001 6400
0064 0200 6c02 006d 0300 5a03 0001 6503
0064 0300 8301 0065 0100 6404 0084 0000
8301 0083 0100 5a04 0064 0500 5328 0600
0000 69ff ffff ff28 0100 0000 740e 0000
006c 6f67 696e 5f72 6571 7569 7265 6428
0100 0000 7409 0000 0072 656e 6465 725f
746f 7316 0000 0074 656d 706c 6174 655f
6170 703a 686f 6d65 2e68 746d 6c63 0100
0000 0100 0000 0300 0000 4300 0000 7312
0000 0069 0200 6401 0064 0200 3664 0300
6404 0036 5328 0500 0000 4e73 1e00 0000
4865 6c6c 6f20 576f 726c 6420 6672 6f6d
2074 656d 706c 6174 655f 6170 7021 7407
0000 006d 6573 7361 6765 740c 0000 0074
656d 706c 6174 655f 6170 7074 0800 0000
6170 705f 6e61 6d65 2800 0000 0028 0100
0000 7407 0000 0072 6571 7565 7374 2800
0000 0028 0000 0000 7347 0000 002f 4170
706c 6963 6174 696f 6e73 2f53 706c 756e
6b2f 6574 632f 6170 7073 2f74 656d 706c
6174 655f 6170 702f 646a 616e 676f 2f74
656d 706c 6174 655f 6170 702f 7669 6577
732e 7079 7404 0000 0068 6f6d 6504 0000
0073 0600 0000 0003 0301 0701 4e28 0500
0000 741e 0000 0064 6a61 6e67 6f2e 636f
6e74 7269 622e 6175 7468 2e64 6563 6f72
6174 6f72 7352 0000 0000 741a 0000 0073
706c 756e 6b64 6a2e 6465 636f 7261 746f
7273 2e72 656e 6465 7252 0100 0000 5206
0000 0028 0000 0000 2800 0000 0028 0000
0000 7347 0000 002f 4170 706c 6963 6174
696f 6e73 2f53 706c 756e 6b2f 6574 632f
6170 7073 2f74 656d 706c 6174 655f 6170
702f 646a 616e 676f 2f74 656d 706c 6174
655f 6170 702f 7669 6577 732e 7079 7408
0000 003c 6d6f 6475 6c65 3e01 0000 0073
0600 0000 1001 1002 0901")
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

        var search1 = new SearchManager({
            \"id\": \"search1\",
            \"search\": \"| inputlookup musicdata.csv | search bc_uri=/sync/addtolibrary* | stats count by artist_name | sort count desc | table artist_name count | head 5\",
            \"latest_time\": \"\",
            \"cancelOnUnload\": true,
            \"status_buckets\": 0,
            \"earliest_time\": \"\",
            \"app\": utils.getCurrentApp(),
            \"auto_cancel\": 90,
            \"preview\": true,
            \"runWhenTimeIsUndefined\": false
        }, {tokens: true, tokenNamespace: \"submitted\"});

        var search2 = new SearchManager({
            \"id\": \"search2\",
            \"search\": \"| inputlookup musicdata.csv | search bc_uri=/sync/addtolibrary* | stats count by track_name | sort count desc | table track_name count \",
            \"latest_time\": \"\",
            \"cancelOnUnload\": true,
            \"status_buckets\": 0,
            \"earliest_time\": \"\",
            \"app\": utils.getCurrentApp(),
            \"auto_cancel\": 90,
            \"preview\": true,
            \"runWhenTimeIsUndefined\": false
        }, {tokens: true, tokenNamespace: \"submitted\"});

        var search3 = new SearchManager({
            \"id\": \"search3\",
            \"search\": \"| inputlookup musicdata.csv | search eventtype=* | stats count by eventtype\",
            \"latest_time\": \"\",
            \"cancelOnUnload\": true,
            \"status_buckets\": 0,
            \"earliest_time\": \"0\",
            \"app\": utils.getCurrentApp(),
            \"auto_cancel\": 90,
            \"preview\": true,
            \"runWhenTimeIsUndefined\": false
        }, {tokens: true, tokenNamespace: \"submitted\"});

        var search4 = new SearchManager({
            \"id\": \"search4\",
            \"search\": \"| inputlookup musicdata.csv | search bc_uri=/sync/addtolibrary* | sort artist_name by eventtype | fields - _time | fields - bc_uri | fields - search_terms\",
            \"latest_time\": \"\",
            \"cancelOnUnload\": true,
            \"status_buckets\": 0,
            \"earliest_time\": \"\",
            \"app\": utils.getCurrentApp(),
            \"auto_cancel\": 90,
            \"preview\": true,
            \"runWhenTimeIsUndefined\": false
        }, {tokens: true, tokenNamespace: \"submitted\"});

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
        
        var element1 = new ChartElement({
            \"id\": \"element1\",
            \"charting.legend.labelStyle.overflowMode\": \"ellipsisMiddle\",
            \"charting.axisY2.scale\": \"inherit\",
            \"charting.chart.stackMode\": \"default\",
            \"charting.axisLabelsX.majorLabelStyle.rotation\": \"0\",
            \"charting.axisTitleY2.visibility\": \"visible\",
            \"charting.chart.nullValueMode\": \"gaps\",
            \"charting.layout.splitSeries\": \"0\",
            \"charting.chart\": \"pie\",
            \"charting.chart.bubbleMinimumSize\": \"10\",
            \"charting.chart.bubbleMaximumSize\": \"50\",
            \"charting.axisLabelsX.majorLabelStyle.overflowMode\": \"ellipsisNone\",
            \"resizable\": false,
            \"charting.axisY.scale\": \"linear\",
            \"charting.legend.placement\": \"right\",
            \"charting.drilldown\": \"all\",
            \"charting.chart.sliceCollapsingThreshold\": \"0.01\",
            \"charting.chart.style\": \"shiny\",
            \"charting.axisX.scale\": \"linear\",
            \"charting.axisTitleY.visibility\": \"visible\",
            \"charting.axisTitleX.visibility\": \"visible\",
            \"charting.chart.bubbleSizeBy\": \"area\",
            \"charting.axisY2.enabled\": \"false\",
            \"managerid\": \"search1\",
            \"el\": $('#element1')
        }, {tokens: true, tokenNamespace: \"submitted\"}).render();

        var element2 = new TableElement({
            \"id\": \"element2\",
            \"drilldown\": \"row\",
            \"rowNumbers\": \"undefined\",
            \"wrap\": \"undefined\",
            \"managerid\": \"search2\",
            \"el\": $('#element2')
        }, {tokens: true, tokenNamespace: \"submitted\"}).render();

        var element3 = new ChartElement({
            \"id\": \"element3\",
            \"charting.legend.labelStyle.overflowMode\": \"ellipsisMiddle\",
            \"charting.axisY2.scale\": \"inherit\",
            \"charting.chart.stackMode\": \"default\",
            \"charting.axisLabelsX.majorLabelStyle.rotation\": \"0\",
            \"charting.axisTitleY2.visibility\": \"visible\",
            \"charting.chart.nullValueMode\": \"gaps\",
            \"charting.layout.splitSeries\": \"0\",
            \"charting.chart\": \"column\",
            \"charting.chart.bubbleMinimumSize\": \"10\",
            \"charting.chart.bubbleMaximumSize\": \"50\",
            \"charting.axisTitleY.visibility\": \"visible\",
            \"resizable\": false,
            \"charting.axisY.scale\": \"linear\",
            \"charting.legend.placement\": \"right\",
            \"charting.drilldown\": \"all\",
            \"charting.chart.sliceCollapsingThreshold\": \"0.01\",
            \"charting.chart.style\": \"shiny\",
            \"charting.axisX.scale\": \"linear\",
            \"charting.axisLabelsX.majorLabelStyle.overflowMode\": \"ellipsisNone\",
            \"charting.axisTitleX.visibility\": \"visible\",
            \"charting.chart.bubbleSizeBy\": \"area\",
            \"charting.axisY2.enabled\": \"undefined\",
            \"charting.axisTitleX.text\": \"Device\",
            \"charting.axisTitleY.text\": \"Downloads\",
            \"charting.legend.placement\": \"top\",
            \"charting.axisLabelsY.majorUnit\": \"100\",
            \"managerid\": \"search3\",
            \"el\": $('#element3')
        }, {tokens: true, tokenNamespace: \"submitted\"}).render();

        var element4 = new TableElement({
            \"id\": \"element4\",
            \"drilldown\": \"row\",
            \"rowNumbers\": \"undefined\",
            \"wrap\": \"undefined\",
            \"managerid\": \"search4\",
            \"el\": $('#element4')
        }, {tokens: true, tokenNamespace: \"submitted\"}).render();
    
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
            <table width=\"100%\">
                <tr>
                	<td width=\"50%\">
		            	<div class=\"panel-element-row\">
		                    <div id=\"element1\" class=\"dashboard-element chart\" style=\"width: 100%\">
		                        <div class=\"panel-body\"></div>
		                    </div>
		                </div>
                	</td>
                	<td>
	                	<div class=\"panel-element-row\">
	                    	<div id=\"element2\" class=\"dashboard-element table\"></div>
	                	</div>
                	</td>
                </tr>
            </table>
            <br><br>
            <div class=\"panel-element-row\">
            	<div id=\"element3\" class=\"dashboard-element chart\">
            	</div>
            </div>
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

			f = File.open("app_name/django/app_name/templatetags/__init__.pyo", "w")
			f.write("03f3 0d0a dd65 a655 6300 0000 0000 0000
0001 0000 0040 0000 0073 0400 0000 6400
0053 2801 0000 004e 2800 0000 0028 0000
0000 2800 0000 0028 0000 0000 7357 0000
002f 4170 706c 6963 6174 696f 6e73 2f53
706c 756e 6b2f 6574 632f 6170 7073 2f74
656d 706c 6174 655f 6170 702f 646a 616e
676f 2f74 656d 706c 6174 655f 6170 702f
7465 6d70 6c61 7465 7461 6773 2f5f 5f69
6e69 745f 5f2e 7079 7408 0000 003c 6d6f
6475 6c65 3e01 0000 0073 0000 0000")
			f.close

f = File.open("app_name/README", "w")
f.write("This is the first line\nSecond line")
f.close

FileUtils::mkdir_p 'app_name/lookups'

FileUtils::mkdir_p 'app_name/static'

