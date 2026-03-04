using Toybox.Application as App;

class MarathonCoachApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new MarathonCoachField() ];
    }
}
