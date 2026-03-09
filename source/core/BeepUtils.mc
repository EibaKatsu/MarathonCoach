module BeepUtils {
    const EVENT_NONE = 0;
    const EVENT_DISTANCE_SPLIT = 1;
    const EVENT_DISTANCE_MILESTONE = 2;
    const EVENT_FUEL_SOON = 3;
    const EVENT_DRIFT_ON = 4;
    const EVENT_HR_OVER = 5;
    const EVENT_FUEL_NOW = 6;

    const LEVEL_INFO = 1;
    const LEVEL_CAUTION = 2;
    const LEVEL_URGENT = 3;

    function resolveEventPriority(beepEvent) {
        if (beepEvent == EVENT_FUEL_NOW) {
            return 600;
        }
        if (beepEvent == EVENT_HR_OVER) {
            return 500;
        }
        if (beepEvent == EVENT_DRIFT_ON) {
            return 400;
        }
        if (beepEvent == EVENT_FUEL_SOON) {
            return 350;
        }
        if (beepEvent == EVENT_DISTANCE_MILESTONE) {
            return 300;
        }
        if (beepEvent == EVENT_DISTANCE_SPLIT) {
            return 200;
        }
        return 0;
    }

    function selectHigherPriorityEvent(currentEvent, candidateEvent) {
        if (resolveEventPriority(candidateEvent) > resolveEventPriority(currentEvent)) {
            return candidateEvent;
        }
        return currentEvent;
    }

    function resolveBeepLevel(beepEvent) {
        if (beepEvent == EVENT_DISTANCE_SPLIT) {
            return LEVEL_INFO;
        }
        if (
            beepEvent == EVENT_DISTANCE_MILESTONE or
            beepEvent == EVENT_FUEL_SOON or
            beepEvent == EVENT_HR_OVER or
            beepEvent == EVENT_DRIFT_ON
        ) {
            return LEVEL_CAUTION;
        }
        if (beepEvent == EVENT_FUEL_NOW) {
            return LEVEL_URGENT;
        }
        return 0;
    }
}
