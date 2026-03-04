using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class MarathonCoachApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new MarathonCoachField() ];
    }

    function onSettingsChanged() {
        Ui.requestUpdate();
    }
}
