module BeepUtils {
    const EVENT_NONE = 0;
    const EVENT_HR_OVER = 1;

    const LEVEL_INFO = 1;
    const LEVEL_CAUTION = 2;

    function resolveEventPriority(beepEvent) {
        if (beepEvent == EVENT_HR_OVER) {
            return 500;
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
        if (beepEvent == EVENT_HR_OVER) {
            return LEVEL_CAUTION;
        }
        return 0;
    }
}
