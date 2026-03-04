using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class MarathonCoachField extends Ui.DataField {
    var _step1Status = "STEP1 READY";

    function initialize() {
        DataField.initialize();
        _step1Status = Ui.loadResource(Rez.Strings.Step1Status);
    }

    function compute(info) {
        // Step 1: metrics are not wired yet; show fixed status only.
        return;
    }

    function onUpdate(dc as Gfx.Dc) {
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Gfx.FONT_SMALL,
            _step1Status,
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
    }
}
