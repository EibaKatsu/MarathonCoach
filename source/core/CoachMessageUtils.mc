using Toybox.Lang as Lang;
using Toybox.System as Sys;

module CoachMessageUtils {
    const CATEGORY_FIXED = "FIXED";
    const CATEGORY_FUNNY = "FUNNY";
    const CATEGORY_SALT = "SALT";
    const CATEGORY_ALCOHOL = "ALCOHOL";
    const CATEGORY_TOXIC = "TOXIC";
    const CATEGORY_PRAISE = "PRAISE";
    const CATEGORY_DIST = "DIST";
    const STATE_KEY_LAST_SPURT = "LAST_SPURT";
    const STATE_KEY_START = "START";

    const FUEL_STATE_NONE = "NONE";
    const FUEL_STATE_PREP = "PREP";
    const FUEL_STATE_NOW = "NOW";

    function resolveLanguage(systemLanguage) {
        if (systemLanguage == Sys.LANGUAGE_ENG) {
            return "en";
        }
        return "ja";
    }

    function defaultCategory() {
        return CATEGORY_FIXED;
    }

    function categories() as Lang.Array {
        return [
            CATEGORY_FIXED,
            CATEGORY_FUNNY,
            CATEGORY_SALT,
            CATEGORY_ALCOHOL,
            CATEGORY_TOXIC,
            CATEGORY_PRAISE,
            CATEGORY_DIST
        ];
    }

    function displayCategories() as Lang.Array {
        return [
            CATEGORY_FIXED,
            CATEGORY_FUNNY,
            CATEGORY_SALT,
            CATEGORY_ALCOHOL,
            CATEGORY_TOXIC,
            CATEGORY_PRAISE
        ];
    }

    function getMessagePool(language, category, fuelState, stateKey) as Lang.Array {
        var pool = [];
        if (_isSameText(fuelState, FUEL_STATE_NOW)) {
            pool = _getFuelNowPool(language, category);
        } else if (_isSameText(fuelState, FUEL_STATE_PREP)) {
            pool = _getFuelPrepPool(language, category);
        } else {
            pool = _getNormalPool(language, category, stateKey);
        }
        return _normalizePool(language, fuelState, stateKey, pool);
    }

    function _normalizePool(language, fuelState, stateKey, pool) as Lang.Array {
        if (pool == null or pool.size() == 0 or pool.size() >= 10) {
            return pool;
        }

        var fallback = [];
        if (_isSameText(fuelState, FUEL_STATE_NOW)) {
            fallback = _getGenericFuelNowPool(language);
        } else if (_isSameText(fuelState, FUEL_STATE_PREP)) {
            fallback = _getGenericFuelPrepPool(language);
        } else if (_isReasonSpecificStateKey(stateKey)) {
            fallback = _getGenericReasonSpecificPool(language, stateKey);
        } else {
            fallback = _getGenericNormalPool(language, stateKey);
        }
        return _mergePools(pool, fallback);
    }

    function _mergePools(primary as Lang.Array, fallback as Lang.Array) as Lang.Array {
        var merged = [];
        _appendUniqueMessages(merged, primary);
        _appendUniqueMessages(merged, fallback);
        return merged;
    }

    function _appendUniqueMessages(target as Lang.Array, source as Lang.Array) {
        if (source.size() == 0) {
            return;
        }

        for (var i = 0; i < source.size(); i += 1) {
            if (target.size() >= 10) {
                return;
            }

            var candidate = source[i];
            var exists = false;
            for (var j = 0; j < target.size(); j += 1) {
                if (_isSameText(target[j], candidate)) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                target.add(candidate);
            }
        }
    }

    function _isReasonSpecificStateKey(stateKey) {
        switch (stateKey) {
            case "UP_EASE_PACE":
            case "FL_EASE_PACE":
            case "DN_EASE_PACE":
            case "UP_EASE_HR":
            case "FL_EASE_HR":
            case "DN_EASE_HR":
            case "UP_EASE_BOTH":
            case "FL_EASE_BOTH":
            case "DN_EASE_BOTH":
                return true;
        }
        return false;
    }

    function _getGenericNormalPool(language, stateKey) as Lang.Array {
        if (_isSameText(language, "en")) {
            return _getGenericNormalPoolEn(stateKey);
        }
        return _getGenericNormalPoolJa(stateKey);
    }

    function _getGenericFuelPrepPool(language) as Lang.Array {
        if (_isSameText(language, "en")) {
            return _getGenericFuelPrepPoolEn();
        }
        return _getGenericFuelPrepPoolJa();
    }

    function _getGenericFuelNowPool(language) as Lang.Array {
        if (_isSameText(language, "en")) {
            return _getGenericFuelNowPoolEn();
        }
        return _getGenericFuelNowPoolJa();
    }

    function _getGenericReasonSpecificPool(language, stateKey) as Lang.Array {
        if (_isSameText(language, "en")) {
            return _getGenericReasonSpecificPoolEn(stateKey);
        }
        return _getGenericReasonSpecificPoolJa(stateKey);
    }

    function _getGenericNormalPoolJa(stateKey) as Lang.Array {
        switch (stateKey) {
            case "UP_PUSH": return ["腕でつなご", "登りで少し押そ", "登りは一歩ずつ前へ", "リズムを崩さず押そ", "呼吸に合わせて前へ", "焦らず登りを進めよ", "ここは丁寧に押し切ろ", "上りは静かに前へ", "脚より腕で運ぼ", "ひと呼吸ぶん前へ"];
            case "UP_HOLD": return ["登りは淡々と", "リズム優先で", "登りは落ち着いて刻も", "一定で運ぶのが正解", "呼吸を乱さず進めよ", "上りは静かに守ろ", "今は丁寧さを優先", "その流れで十分や", "焦らず巡航を守ろ", "上りの我慢が効く"];
            case "UP_EASE": return ["登りで抑えよ", "少し落とそ", "上りは一段ゆるめよ", "呼吸を先に整えよ", "ここは静かに戻そ", "力みを外していこ", "登りで無理せんとこ", "少しだけ余裕を作ろ", "熱量をひとつ下げよ", "落ち着いて立て直そ"];
            case "FL_PUSH": return ["少し前へ", "ここで少し上げよ", "巡航にひと押し足そ", "流れのまま前へ出よ", "半歩だけ攻めていこ", "リズムの中で上げよ", "なめらかに前へ運ぼ", "ここは軽く押していい", "呼吸ぶんだけ前へ", "静かに前進しよ"];
            case "FL_HOLD": return ["そのまま運ぼ", "いい流れやで", "今の巡航で十分や", "そのリズムを守ろ", "落ち着いて流そう", "安定したまま進も", "この流れを続けよ", "静かな巡航でいこ", "今は整ってるで", "ええ運びをキープ"];
            case "FL_EASE": return ["少し落ち着こ", "一段ゆるめよ", "少し熱を戻そ", "呼吸を整えていこ", "出力をひとつ下げよ", "前のめりを戻そ", "まだ静かにいこ", "力みを抜いて運ぼ", "いったん整え直そ", "落ち着き優先で"];
            case "DN_PUSH": return ["下りで丁寧に乗ろ", "脚を回していこ", "下りの流れを使お", "軽い接地で進めよ", "ここは足を回していこ", "重心だけ前へ乗せよ", "下りをなめらかに使お", "脚さばきで前へ出よ", "リズム良く転がそ", "流れに乗って進も"];
            case "DN_HOLD": return ["下りも丁寧に", "流れに乗ろ", "下りは静かに運ぼ", "接地を乱さずいこ", "この流れを保とう", "楽に回して進も", "下りで雑にならんとこ", "姿勢そのままでいこ", "力まず流そう", "丁寧な下りで十分"];
            case "DN_EASE": return ["下りで飛ばしすぎ", "少し抑えよ", "下りは一段戻そ", "足音を静かにしよ", "重心を落ち着けよ", "流れを少し整えよ", "まだ攻めすぎんでええ", "下りで使いすぎるな", "呼吸を整えて戻そ", "少しだけブレーキ"];
        }
        return ["そのままいこ", "落ち着いて運ぼ", "今の流れで十分や", "呼吸を整えていこ", "静かに前へ進も", "リズム優先でいこ", "焦らず運んでいこ", "丁寧にまとめよ", "今は崩さんとこ", "その調子でいこ"];
    }

    function _getGenericNormalPoolEn(stateKey) as Lang.Array {
        switch (stateKey) {
            case "UP_PUSH": return ["Use the arms", "Push the climb", "Step into the hill", "Press without rushing", "Move with the breath", "Climb one step at a time", "Stay smooth and push", "Quiet work uphill", "Carry it with the arms", "One breath more uphill"];
            case "UP_HOLD": return ["Steady uphill", "Keep the rhythm", "Stay calm on the climb", "This pace is enough here", "Keep the breathing steady", "Protect the flow uphill", "Patience works here", "Hold the line uphill", "No need to force it", "Keep the climb tidy"];
            case "UP_EASE": return ["Ease on the climb", "Back off uphill", "Take one gear off", "Settle the breathing", "Bring it down smoothly", "Drop the tension now", "No need to force the hill", "Make a little room", "Turn the heat down", "Reset the climb"];
            case "FL_PUSH": return ["Lift it a touch", "Press a little", "Add one small lift", "Move half a step up", "Push within the rhythm", "Roll it forward smoothly", "Take a calm step on", "One breath more here", "Nudge the cruise ahead", "Gentle pressure now"];
            case "FL_HOLD": return ["Hold this rhythm", "Good steady flow", "This cruise is enough", "Keep the line smooth", "Stay settled here", "Carry the pace calmly", "Keep the roll going", "This rhythm is working", "No need to change much", "Steady still looks strong"];
            case "FL_EASE": return ["Settle a little", "Ease one gear", "Take the heat down", "Let the breath settle", "Back off smoothly", "Relax the tension", "Keep it quieter here", "Reset the effort now", "Bring it down a touch", "Calm the rush"];
            case "DN_PUSH": return ["Roll the downhill", "Quick light steps", "Use the flow downhill", "Let the slope help", "Turn the legs over", "Carry the speed cleanly", "Flow forward here", "Light feet down the slope", "Ride the rhythm down", "Use the drop well"];
            case "DN_HOLD": return ["Stay smooth downhill", "Ride the flow", "Keep it neat downhill", "Hold the line here", "Calm feet on the drop", "Let the slope carry you", "Stay relaxed downhill", "Keep the rhythm clean", "No extra force needed", "Smooth is enough here"];
            case "DN_EASE": return ["Dont overcook downhill", "Ease the descent", "Take one gear off downhill", "Quiet the footstrike", "Bring the speed back", "Settle the drop a bit", "Do not spend it here", "Take the edge off", "Reset on the downhill", "Brake just a touch"];
        }
        return ["Stay steady", "Keep it calm", "Hold the flow", "Breathe and move", "Keep the rhythm first", "No need to rush", "Stay smooth here", "Carry it cleanly", "Keep it under control", "This pace is fine"];
    }

    function _getGenericFuelPrepPoolJa() as Lang.Array {
        return ["次で補給やで", "補給の準備しよ", "そろそろ入れどき", "次のタイミングで入れよ", "手元を確認しとこ", "今のうちに準備や", "補給の段取りしよ", "次で忘れず入れよ", "先に準備できたら強い", "補給ポイント近いで"];
    }

    function _getGenericFuelPrepPoolEn() as Lang.Array {
        return ["Fuel prep next", "Get fuel ready", "Fuel point coming", "Be ready for the next fuel", "Check it in your hand", "Prep it while you can", "Set up the fuel now", "Do not miss the next one", "Ready fuel stays strong", "Fuel timing is close"];
    }

    function _getGenericFuelNowPoolJa() as Lang.Array {
        return ["今、補給しよ", "ここで補給や", "今が入れどき", "このタイミングで入れよ", "忘れず今いこ", "一口でも入れとこ", "ここは補給優先や", "今入れたら楽になる", "手早く補給しよ", "この場面で補給やで"];
    }

    function _getGenericFuelNowPoolEn() as Lang.Array {
        return ["Fuel now", "Take fuel now", "This is the fuel point", "Take it right here", "Do not miss it now", "Even a small sip helps", "Fuel comes first here", "Take it and save the legs", "Quick fuel now", "This moment is for fuel"];
    }

    function _getGenericReasonSpecificPoolJa(stateKey) as Lang.Array {
        switch (stateKey) {
            case "UP_EASE_PACE":
            case "FL_EASE_PACE":
            case "DN_EASE_PACE":
                return ["少し戻す", "ペースだけ戻そ", "速さを半歩戻そ", "ペースを静かに下げよ", "いったん巡航へ戻そ", "焦らずペース修正", "出力を少し戻そ", "今はペース優先で調整", "一段だけ戻していこ", "落ち着く速さに戻そ"];
            case "UP_EASE_HR":
            case "FL_EASE_HR":
            case "DN_EASE_HR":
                return ["息を整えよ", "心拍落ち着こ", "呼吸優先で戻そ", "まずは心拍を待と", "少しだけ楽にしよ", "脈を静かに下げよ", "呼吸が整うまで待と", "今は負荷を逃がそ", "心拍を戻してからいこ", "まず落ち着きを作ろ"];
            case "UP_EASE_BOTH":
            case "FL_EASE_BOTH":
            case "DN_EASE_BOTH":
                return ["少し落ち着こ", "無理せんとこ", "呼吸もペースも整えよ", "ここはいったん戻そ", "熱も速さも下げよ", "一段静かにいこ", "立て直し優先や", "今は守って整えよ", "まとめてクールダウン", "落ち着き直していこ"];
        }
        return ["少し落ち着こ", "無理せんとこ", "呼吸を整えよ", "いったん戻そ", "熱を下げよ", "一段ゆるめよ", "静かに運ぼ", "ここは整えよ", "落ち着き優先", "立て直していこ"];
    }

    function _getGenericReasonSpecificPoolEn(stateKey) as Lang.Array {
        switch (stateKey) {
            case "UP_EASE_PACE":
            case "FL_EASE_PACE":
            case "DN_EASE_PACE":
                return ["Ease pace", "Bring pace back", "Take half a step off", "Lower the speed calmly", "Return to cruise pace", "Adjust pace without panic", "Dial the output back", "Pace first right now", "One gear softer", "Go back to settled speed"];
            case "UP_EASE_HR":
            case "FL_EASE_HR":
            case "DN_EASE_HR":
                return ["Settle the breath", "Let HR come down", "Breathing comes first", "Wait for the heart rate", "Make it a touch easier", "Bring the pulse down", "Stay here until it settles", "Take the load off now", "Let HR reset first", "Build calm before pace"];
            case "UP_EASE_BOTH":
            case "FL_EASE_BOTH":
            case "DN_EASE_BOTH":
                return ["Settle a little", "Back it off", "Reset pace and breathing", "Bring it back for now", "Turn down speed and heat", "Take one quieter gear", "Reset before you push", "Protect it and settle", "Cool it all down", "Calm it, then go"];
        }
        return ["Settle a little", "Back it off", "Reset the breathing", "Bring it down", "Turn the heat down", "Take one easier gear", "Keep it calm", "Reset here", "Control first", "Settle before moving on"];
    }

    function _getNormalPool(language, category, stateKey) as Lang.Array {
        if (_isSameText(language, "en")) {
            return _getNormalPoolEn(category, stateKey);
        }
        return _getNormalPoolJa(category, stateKey);
    }

    function _getFuelPrepPool(language, category) as Lang.Array {
        if (_isSameText(language, "en")) {
            return _getFuelPrepPoolEn(category);
        }
        return _getFuelPrepPoolJa(category);
    }

    function _getFuelNowPool(language, category) as Lang.Array {
        if (_isSameText(language, "en")) {
            return _getFuelNowPoolEn(category);
        }
        return _getFuelNowPoolJa(category);
    }

    function _isSameText(left, right) as Lang.Boolean {
        if (left == null or right == null) {
            return left == right;
        }
        return left.toString().equals(right.toString());
    }

    function _getNormalPoolJa(category, stateKey) as Lang.Array {
        if (_isSameText(stateKey, STATE_KEY_LAST_SPURT)) {
            return _getLastSpurtPoolJa(category);
        }
        if (_isSameText(stateKey, STATE_KEY_START)) {
            return _getStartPoolJa(category);
        }
        var reasonSpecificPool = _getReasonSpecificNormalPoolJa(category, stateKey);
        if (reasonSpecificPool != null) {
            return reasonSpecificPool;
        }

        switch (category) {
            case CATEGORY_FUNNY:
                switch (stateKey) {
                    case "UP_PUSH": return ["坂にも前向きや", "登りで仕事しよ"];
                    case "UP_HOLD": return ["坂は慌てんで", "登りは淡々勝ち"];
                    case "UP_EASE": return ["坂に全部は払わん", "登りで見栄いらん"];
                    case "FL_PUSH": return ["ここでひと押し", "少しだけ前へ", "巡航に軽く火を入れよ", "流れの中でひと伸び", "ここは半歩だけ前へ", "ええ流れに少し足そ", "軽く前へ転がそ", "巡航にひと粒スパイス", "ここでひと呼吸ぶん押そ", "少しだけノリ足そ"];
                    case "FL_HOLD": return ["その巡航、ええやん", "ええリズムやで", "その流れ、きれいや", "まだそれで十分や", "巡航がようまとまってる", "その安定感ええ感じ", "落ち着いた運びやで", "そのまま運べたら強い", "今のリズムようできてる", "ええ巡航つくれてる"];
                    case "FL_EASE": return ["熱なりすぎ", "いったん整えよ", "ちょい前のめりやで", "力みを半分ほどこ", "少しクールダウンしよ", "熱量だけ戻そ", "いったん息整えよ", "出力をひとつ落とそ", "まだ静かにいこ", "ちょい焦りすぎや"];
                    case "DN_PUSH": return ["下りのボーナス活用", "脚だけ軽く回そ"];
                    case "DN_HOLD": return ["下りで雑はあかん", "楽して丁寧に"];
                    case "DN_EASE": return ["下りで飛ばしすぎや", "ブレーキは少しだけ"];
                }
            case CATEGORY_SALT:
                switch (stateKey) {
                    case "UP_PUSH": return ["腕だけ使お", "力みは禁止"];
                    case "UP_HOLD": return ["登りで騒がん", "落ち着いて刻も"];
                    case "UP_EASE": return ["それは攻めすぎ", "少し下げよ"];
                    case "FL_PUSH": return ["遅れは小さく回収", "欲張り禁止で上げる"];
                    case "FL_HOLD": return ["普通が正解", "そのまま続けて"];
                    case "FL_EASE": return ["速すぎやで", "いったん冷静に"];
                    case "DN_PUSH": return ["下りでも雑はなし", "脚を散らすな"];
                    case "DN_HOLD": return ["丁寧に運ぶだけ", "その流れ維持"];
                    case "DN_EASE": return ["下りで無駄に飛ばすな", "少し戻して"];
                }
            case CATEGORY_ALCOHOL:
                switch (stateKey) {
                    case "UP_PUSH": return ["登りは薄めに押そ", "腕ふり一杯ぶん"];
                    case "UP_HOLD": return ["坂はちびちびで", "濃くせんでええ"];
                    case "UP_EASE": return ["坂で飲みすぎや", "少し水いこ"];
                    case "FL_PUSH": return ["一口だけ上げる", "軽く炭酸入れよ"];
                    case "FL_HOLD": return ["いい温度やで", "そのまま熟成"];
                    case "FL_EASE": return ["ちょい濃すぎる", "水で整えよ"];
                    case "DN_PUSH": return ["下りは口当たり軽く", "脚を軽めに回そ"];
                    case "DN_HOLD": return ["下りもなめらかに", "流れにまかせよ"];
                    case "DN_EASE": return ["下りで度数上げすぎ", "少し薄めよ"];
                }
            case CATEGORY_TOXIC:
                switch (stateKey) {
                    case "UP_PUSH": return ["登りで逃げるな", "ここは丁寧に押せ"];
                    case "UP_HOLD": return ["坂で焦るほど弱くない", "淡々と勝てる"];
                    case "UP_EASE": return ["その坂ペースは危ない", "落として立て直せ"];
                    case "FL_PUSH": return ["まだ余白あるやろ", "少しだけ取り返そ"];
                    case "FL_HOLD": return ["崩さんのが正義", "雑にならんで"];
                    case "FL_EASE": return ["熱くなりすぎ", "一回落ち着け"];
                    case "DN_PUSH": return ["下りで脚を遊ばすな", "軽く速くいこ"];
                    case "DN_HOLD": return ["雑な下りは負け筋", "丁寧に流せ"];
                    case "DN_EASE": return ["下りで壊しにいくな", "少し抑えろ"];
                }
            case CATEGORY_PRAISE:
                switch (stateKey) {
                    case "UP_PUSH": return ["登りで前向けてる", "ええ押しやで"];
                    case "UP_HOLD": return ["登りが安定してる", "我慢が上手い"];
                    case "UP_EASE": return ["抑える判断が強い", "守れてるのえらい"];
                    case "FL_PUSH": return ["いいとこで上げてる", "判断がきれいや"];
                    case "FL_HOLD": return ["その巡航、強いで", "安定感あるわ"];
                    case "FL_EASE": return ["整えるのも実力や", "落ち着けてるの強い"];
                    case "DN_PUSH": return ["下りを使えてる", "軽い脚さばきええやん"];
                    case "DN_HOLD": return ["下りも丁寧やで", "流れの乗り方が上手い"];
                    case "DN_EASE": return ["抑えて正解やで", "崩さないのが強さ"];
                }
            case CATEGORY_DIST:
                return [];
        }

        switch (stateKey) {
            case "UP_PUSH": return ["腕でつなご", "登りで少し押そ"];
            case "UP_HOLD": return ["登りは淡々と", "リズム優先で"];
            case "UP_EASE": return ["登りで抑えよ", "少し落とそ"];
            case "FL_PUSH": return ["少し前へ", "ここで少し上げよ"];
            case "FL_HOLD": return ["そのまま運ぼ", "いい流れやで"];
            case "FL_EASE": return ["少し落ち着こ", "一段ゆるめよ"];
            case "DN_PUSH": return ["下りで丁寧に乗ろ", "脚を回していこ"];
            case "DN_HOLD": return ["下りも丁寧に", "流れに乗ろ"];
            case "DN_EASE": return ["下りで飛ばしすぎ", "少し抑えよ"];
        }
        return ["そのままいこ"];
    }

    function _getNormalPoolEn(category, stateKey) as Lang.Array {
        if (_isSameText(stateKey, STATE_KEY_LAST_SPURT)) {
            return _getLastSpurtPoolEn(category);
        }
        if (_isSameText(stateKey, STATE_KEY_START)) {
            return _getStartPoolEn(category);
        }
        var reasonSpecificPool = _getReasonSpecificNormalPoolEn(category, stateKey);
        if (reasonSpecificPool != null) {
            return reasonSpecificPool;
        }

        switch (category) {
            case CATEGORY_FUNNY:
                switch (stateKey) {
                    case "UP_PUSH": return ["Climb with intent", "Uphill has work today"];
                    case "UP_HOLD": return ["No panic uphill", "Steady wins the climb"];
                    case "UP_EASE": return ["No hero climb now", "Dont spend it here"];
                    case "FL_PUSH": return ["Little nudge here", "One small lift here", "Add a touch to the roll", "Small spark in the rhythm", "Half-step forward here", "Give the cruise a lift", "Roll it a bit brighter", "Just a hint more now", "One breath of pressure", "Tiny boost, stay smooth"];
                    case "FL_HOLD": return ["Rhythm looks smooth", "Nice smooth cruise", "That flow looks clean", "This is enough right now", "Cruise is nicely settled", "Good calm carry there", "That rhythm is working", "Keep that smooth line", "Steady looks strong", "You built a nice roll"];
                    case "FL_EASE": return ["Got too spicy", "Reset the heat", "A bit too eager there", "Take half the tension out", "Cool it a touch", "Bring the effort down", "Let the breath settle", "One gear softer now", "Keep it quieter here", "Ease the rush a bit"];
                    case "DN_PUSH": return ["Use the downhill", "Quick easy feet"];
                    case "DN_HOLD": return ["Stay neat downhill", "Easy speed only"];
                    case "DN_EASE": return ["Downhill got greedy", "Brake just a touch"];
                }
            case CATEGORY_SALT:
                switch (stateKey) {
                    case "UP_PUSH": return ["Arms only, no drama", "No extra tension"];
                    case "UP_HOLD": return ["Quiet on the climb", "Just keep the rhythm"];
                    case "UP_EASE": return ["That is too much", "Back off uphill"];
                    case "FL_PUSH": return ["Recover the gap slowly", "Lift, dont lunge"];
                    case "FL_HOLD": return ["Normal is right", "Keep doing that"];
                    case "FL_EASE": return ["Too hot already", "Cool it down"];
                    case "DN_PUSH": return ["Dont waste the downhill", "Keep it controlled"];
                    case "DN_HOLD": return ["Just carry the flow", "Stay tidy downhill"];
                    case "DN_EASE": return ["Too much on downhill", "Bring it back"];
                }
            case CATEGORY_ALCOHOL:
                switch (stateKey) {
                    case "UP_PUSH": return ["Light sip uphill", "Push it lightly"];
                    case "UP_HOLD": return ["Easy pour on climbs", "Keep it mellow uphill"];
                    case "UP_EASE": return ["Too strong uphill", "Add some water"];
                    case "FL_PUSH": return ["Tiny top-up here", "A little sparkle here"];
                    case "FL_HOLD": return ["Good steady blend", "Let it age nicely"];
                    case "FL_EASE": return ["Too strong already", "Water it down"];
                    case "DN_PUSH": return ["Light feet downhill", "Roll it smooth"];
                    case "DN_HOLD": return ["Smooth pour downhill", "Let the flow work"];
                    case "DN_EASE": return ["Too much downhill proof", "Make it lighter"];
                }
            case CATEGORY_TOXIC:
                switch (stateKey) {
                    case "UP_PUSH": return ["Dont hide from the hill", "Push with control"];
                    case "UP_HOLD": return ["You dont need to rush", "Steady still wins"];
                    case "UP_EASE": return ["That climb pace bites", "Reset it now"];
                    case "FL_PUSH": return ["You still have room", "Take back a little"];
                    case "FL_HOLD": return ["Clean beats flashy", "Dont get sloppy"];
                    case "FL_EASE": return ["Too hot already", "Settle down once"];
                    case "DN_PUSH": return ["Use the slope well", "Fast feet, not chaos"];
                    case "DN_HOLD": return ["Messy downhill loses", "Flow with control"];
                    case "DN_EASE": return ["Dont break it downhill", "Ease the drop"];
                }
            case CATEGORY_PRAISE:
                switch (stateKey) {
                    case "UP_PUSH": return ["Strong climb choice", "Nice uphill intent"];
                    case "UP_HOLD": return ["Solid uphill control", "Great patience there"];
                    case "UP_EASE": return ["Smart to protect it", "Good restraint now"];
                    case "FL_PUSH": return ["Well timed lift", "That move is clean"];
                    case "FL_HOLD": return ["Strong steady cruise", "Great calm rhythm"];
                    case "FL_EASE": return ["Reset is a skill", "Good composure there"];
                    case "DN_PUSH": return ["Downhill used well", "Nice quick feet"];
                    case "DN_HOLD": return ["Smooth downhill work", "Youre carrying it well"];
                    case "DN_EASE": return ["Good call to ease", "Strong control there"];
                }
            case CATEGORY_DIST:
                return [];
        }

        switch (stateKey) {
            case "UP_PUSH": return ["Use the arms", "Push the climb"];
            case "UP_HOLD": return ["Steady uphill", "Keep the rhythm"];
            case "UP_EASE": return ["Ease on the climb", "Back off uphill"];
            case "FL_PUSH": return ["Lift it a touch", "Press a little"];
            case "FL_HOLD": return ["Hold this rhythm", "Good steady flow"];
            case "FL_EASE": return ["Settle a little", "Ease one gear"];
            case "DN_PUSH": return ["Roll the downhill", "Quick light steps"];
            case "DN_HOLD": return ["Stay smooth downhill", "Ride the flow"];
            case "DN_EASE": return ["Dont overcook downhill", "Ease the descent"];
        }
        return ["Stay steady"];
    }

    function _getStartPoolJa(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY:
                return ["今日はまだ試運転や", "最初は笑って入ろ", "飛び出しすぎ注意やで", "リズム探しの時間や", "まだ本気は預けとこ", "脚のネジは半分でええ", "序盤は静かに仕事しよ", "景色見る余裕で入ろ", "スタート貯金はいらん", "最初は軽口くらいで"];
            case CATEGORY_SALT:
                return ["最初は丁寧に入る", "まだ上げなくていい", "呼吸優先でいこ", "落ち着いて流れ作る", "突っ込みは禁止", "体を起こして進む", "まずは巡航を作る", "余計な力を抜こ", "入りで焦らない", "ここは様子見で十分"];
            case CATEGORY_ALCOHOL:
                return ["最初は薄めでいこ", "まだ一口目の温度や", "今日は香りから入ろ", "序盤は軽めに流そ", "濃さはまだいらん", "まずは口当たり良く", "ちびちび進めばええ", "最初はやさしく回そ", "まだ熟成前やで", "出だしは軽く合わせよ"];
            case CATEGORY_TOXIC:
                return ["最初から飛ばすな", "まだ見せ場ちゃうで", "焦って使うな", "入りで雑になるな", "ここで気負うな", "最初の暴走は禁止", "まだ借金作るな", "力みを置いていけ", "序盤で勝負するな", "まずは頭を冷やせ"];
            case CATEGORY_PRAISE:
                return ["落ち着いて入れてる", "丁寧な出だしええやん", "最初の我慢が強い", "静かな入り方うまい", "呼吸を整えられてる", "序盤の運びがきれい", "いいリズムを作れてる", "慌てないのが強さや", "出だしの判断ええで", "落ち着いた入りが光る"];
            case CATEGORY_DIST:
                return [];
        }
        return ["最初は丁寧に入ろ", "呼吸を整えていこ", "まだ慌てんでええ", "リズム優先でいこ", "落ち着いて流そ", "いい入りを作ろ", "出だしは静かに", "余計な力を抜こ", "まずは巡航づくり", "ここは丁寧さ優先"];
    }

    function _getStartPoolEn(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY:
                return ["Still in warm-up mode", "Start with a grin", "No launch mode yet", "Find the rhythm first", "Keep the lid on early", "Half a turn on the legs", "Quiet work to begin", "Start with some spare ease", "No need for hero speed", "Just roll into the day"];
            case CATEGORY_SALT:
                return ["Start under control", "No need to lift yet", "Let breathing lead", "Build the flow first", "No rushing this part", "Run tall and easy", "Settle into rhythm", "Drop the extra tension", "Stay patient early", "Easy start is enough"];
            case CATEGORY_ALCOHOL:
                return ["Start light today", "First sip effort only", "Open with good flavor", "Keep the pour easy", "No strong mix yet", "Smooth and light first", "Small sips forward", "Easy roll to start", "Let it age a little", "Start with a soft blend"];
            case CATEGORY_TOXIC:
                return ["Do not blast the start", "This is not the show yet", "Do not spend early", "Do not get sloppy now", "Leave the ego behind", "No wild opening move", "Do not build debt here", "Drop the tension now", "This is not race-winning pace", "Cool your head first"];
            case CATEGORY_PRAISE:
                return ["Nice calm start", "That opening control is strong", "Good patience already", "You are starting clean", "Breathing looks settled", "That early rhythm is good", "Strong calm decision", "Patience is a strength", "You opened this well", "Clean work right away"];
            case CATEGORY_DIST:
                return [];
        }
        return ["Start with control", "Settle the breathing", "No need to rush", "Build the rhythm first", "Keep the opening calm", "Make this a clean start", "Easy does it early", "Relax the extra tension", "Find the cruise first", "Start smooth and steady"];
    }

    function _getFuelPrepPoolJa(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY: return ["そろそろ補給の出番", "次で入れよ、忘れんと"];
            case CATEGORY_SALT: return ["補給準備しよ", "次で入れるだけ"];
            case CATEGORY_ALCOHOL: return ["次は水と補給や", "ちびっと入れとこ"];
            case CATEGORY_TOXIC: return ["補給を飛ばすな", "今のうちに準備"];
            case CATEGORY_PRAISE: return ["補給意識できててえらい", "準備できたら強いで"];
            case CATEGORY_DIST: return [];
        }
        return ["次で補給やで", "補給の準備しよ"];
    }

    function _getFuelPrepPoolEn(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY: return ["Fuel turn coming", "Next one, dont forget"];
            case CATEGORY_SALT: return ["Get fuel ready", "Fuel prep now"];
            case CATEGORY_ALCOHOL: return ["Water and fuel next", "Small sip and go"];
            case CATEGORY_TOXIC: return ["Dont skip the fuel", "Prep it now"];
            case CATEGORY_PRAISE: return ["Nice fuel awareness", "Ready fuel, stay strong"];
            case CATEGORY_DIST: return [];
        }
        return ["Fuel prep next", "Get fuel ready"];
    }

    function _getFuelNowPoolJa(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY: return ["今やで、補給タイム", "ここで入れとこ"];
            case CATEGORY_SALT: return ["今、補給", "入れないとあかん"];
            case CATEGORY_ALCOHOL: return ["今は水と補給", "ここで一口いこ"];
            case CATEGORY_TOXIC: return ["補給しろ、今", "後回し禁止"];
            case CATEGORY_PRAISE: return ["ここで入れられたら強い", "補給できたら完璧や"];
            case CATEGORY_DIST: return [];
        }
        return ["今、補給しよ", "ここで補給や"];
    }

    function _getFuelNowPoolEn(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY: return ["Fuel time now", "Take it right here"];
            case CATEGORY_SALT: return ["Fuel now", "Dont skip this"];
            case CATEGORY_ALCOHOL: return ["Water and fuel now", "Take a sip now"];
            case CATEGORY_TOXIC: return ["Take fuel now", "No more delay"];
            case CATEGORY_PRAISE: return ["Nail this fuel point", "Fuel now, stay strong"];
            case CATEGORY_DIST: return [];
        }
        return ["Fuel now", "Take fuel now"];
    }

    function _getReasonSpecificNormalPoolJa(category, stateKey) {
        switch (stateKey) {
            case "UP_EASE_PACE":
            case "FL_EASE_PACE":
            case "DN_EASE_PACE":
                return ["少し戻す", "ペースだけ戻そ"];
            case "UP_EASE_HR":
            case "FL_EASE_HR":
            case "DN_EASE_HR":
                return ["息を整えよ", "心拍落ち着こ"];
            case "UP_EASE_BOTH":
            case "FL_EASE_BOTH":
            case "DN_EASE_BOTH":
                return ["少し落ち着こ", "無理せんとこ"];
        }
        return null;
    }

    function _getReasonSpecificNormalPoolEn(category, stateKey) {
        switch (stateKey) {
            case "UP_EASE_PACE":
            case "FL_EASE_PACE":
            case "DN_EASE_PACE":
                return ["Ease pace", "Bring pace back"];
            case "UP_EASE_HR":
            case "FL_EASE_HR":
            case "DN_EASE_HR":
                return ["Settle the breath", "Let HR come down"];
            case "UP_EASE_BOTH":
            case "FL_EASE_BOTH":
            case "DN_EASE_BOTH":
                return ["Settle a little", "Back it off"];
        }
        return null;
    }

    function _getLastSpurtPoolJa(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY:
                return ["もうひと仕事いこ", "最後にひと伸び", "締めは気持ちよく", "ここから見せ場や", "脚の在庫つかお", "最後だけ前向こ", "ええ締めしよ", "残りは全部前へ", "ここでひと押し", "最後を整えて抜け"];
            case CATEGORY_SALT:
                return ["最後だけ押せ", "ここで終わらせよ", "脚を使い切れ", "もう守らんでいい", "締めにいこ", "ここは前だけ見ろ", "ラストは出し切れ", "最後の仕事や", "ここで終える", "最後だけ強く"];
            case CATEGORY_ALCOHOL:
                return ["最後は濃いめで", "締めの一杯ぶん", "ここで香り出そ", "最後だけ強めに", "締めは前へ", "最後のひと口いこ", "ここで味を出そ", "最後だけ炭酸", "締めの温度や", "最後にキレ足"];
            case CATEGORY_TOXIC:
                return ["ここで逃げるな", "最後に引くな", "もう出し切れ", "終わり方を決めろ", "ここで止まるな", "最後くらい押せ", "締めを甘くするな", "脚を残すな", "ここからが本番", "最後を雑にするな"];
            case CATEGORY_PRAISE:
                return ["最後まで強いで", "ええ締めいける", "ここで前向けるの強い", "最後の押しがええ", "締めまできれいや", "ここで出せるの強い", "最後の集中ええやん", "前に出る準備できてる", "終わり方うまいで", "ラストまでよう運べてる"];
            case CATEGORY_DIST:
                return [];
        }
        return ["最後だけ前へ", "ここでひと押し", "ラストをまとめよ", "最後まで運ぼ", "終わりまで押そ", "ここから前向こ", "締めにいこ", "最後を出し切ろ", "前へ前へ", "ここで抜けよ"];
    }

    function _getLastSpurtPoolEn(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY:
                return ["One more job", "Finish with a lift", "Close it with style", "This is the scene", "Spend the last legs", "Point it forward", "Nice strong finish", "All forward now", "One last shove", "Finish clean and go"];
            case CATEGORY_SALT:
                return ["Push to the line", "Time to finish it", "Use the legs now", "No need to save it", "Go close this out", "Eyes forward only", "Empty the tank", "Last bit of work", "Finish this well", "Strong to the end"];
            case CATEGORY_ALCOHOL:
                return ["Pour it stronger", "One last strong sip", "Let the flavor show", "Turn it up now", "Finish going forward", "Take the last sip", "Bring out the kick", "Final sparkle now", "This is the finish note", "Sharp feet to close"];
            case CATEGORY_TOXIC:
                return ["Do not fade here", "Dont back off now", "Spend it all", "Choose the finish", "No stopping here", "At least push now", "Dont soften the end", "No saving the legs", "Now is the point", "Dont waste the finish"];
            case CATEGORY_PRAISE:
                return ["Strong all the way", "You have a good finish", "That final push is strong", "Great focus to close", "Youre finishing clean", "You can still press", "Nice control to the line", "Ready to move now", "You close well", "Well carried to the end"];
            case CATEGORY_DIST:
                return [];
        }
        return ["Final push now", "One more lift", "Bring it home", "Keep pressing on", "Finish moving forward", "Close this out", "Push to the line", "Empty the tank", "Forward to the end", "Strong to the finish"];
    }
}
