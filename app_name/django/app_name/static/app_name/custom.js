var urlprefix = document.URL.substr(0, document.URL.search("/dj"));

require.config({
    baseUrl: urlprefix + "/static/js",
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
    "splunkjs/mvc",
    "splunkjs/mvc/utils",
    "splunkjs/mvc/tokenutils",
    "underscore",
    "jquery",
    "splunkjs/mvc/simplexml",
    "splunkjs/mvc/headerview",
    "splunkjs/mvc/footerview",
    "splunkjs/mvc/simplexml/dashboardview",
    "splunkjs/mvc/simplexml/element/chart",
    "splunkjs/mvc/simplexml/element/event",
    "splunkjs/mvc/simplexml/element/html",
    "splunkjs/mvc/simplexml/element/list",
    "splunkjs/mvc/simplexml/element/map",
    "splunkjs/mvc/simplexml/element/single",
    "splunkjs/mvc/simplexml/element/table",
    "splunkjs/mvc/simpleform/formutils",
    "splunkjs/mvc/simpleform/input/dropdown",
    "splunkjs/mvc/simpleform/input/radiogroup",
    "splunkjs/mvc/simpleform/input/multiselect",
    "splunkjs/mvc/simpleform/input/checkboxgroup",
    "splunkjs/mvc/simpleform/input/text",
    "splunkjs/mvc/simpleform/input/timerange",
    "splunkjs/mvc/simpleform/input/submit",
    "splunkjs/mvc/searchmanager",
    "splunkjs/mvc/savedsearchmanager",
    "splunkjs/mvc/postprocessmanager",
    "splunkjs/mvc/simplexml/urltokenmodel"
    // Add comma-separated libraries and modules manually here, for example:
    // ..."splunkjs/mvc/simplexml/urltokenmodel",
    // "splunkjs/mvc/checkboxview"
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
        var search0 = new SearchManager({
            "id": "search0",
            "search": "| inputlookup musicdata.csv | search bc_uri=/sync/addtolibrary* | stats count by artist_name | sort count desc | table artist_name count | head $field1$",
            "latest_time": "",
            "cancelOnUnload": true,
            "status_buckets": 0,
            "earliest_time": "",
            "app": utils.getCurrentApp(),
            "auto_cancel": 90,
            "preview": true,
            "runWhenTimeIsUndefined": false
        }, {tokens: true, tokenNamespace: "submitted"});
        
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
        var element0 = new ChartElement({
                "id": "element0",
                "charting.chart": "pie",
                "resizable": false,
                "managerid": "search0",
                "el": $('#element0')
            }, {tokens: true, tokenNamespace: "submitted"}).render();
            
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
);