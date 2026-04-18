using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class GateCheckerApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new GateCheckerField()];
    }

    function onSettingsChanged() {
        Ui.requestUpdate();
    }
}
