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
        if (_isSameText(fuelState, FUEL_STATE_NOW)) {
            return _getFuelNowPool(language, category);
        }
        if (_isSameText(fuelState, FUEL_STATE_PREP)) {
            return _getFuelPrepPool(language, category);
        }
        return _getNormalPool(language, category, stateKey);
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
                    case "FL_PUSH": return ["平地でひと押し", "ここで少しだけ"];
                    case "FL_HOLD": return ["平地が味方やで", "その巡航、ええやん"];
                    case "FL_EASE": return ["平地で熱なりすぎ", "いったん整えよ"];
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
                    case "FL_PUSH": return ["平地で一口だけ上げる", "軽く炭酸入れよ"];
                    case "FL_HOLD": return ["いい温度やで", "そのまま熟成"];
                    case "FL_EASE": return ["平地で濃すぎる", "水で整えよ"];
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
                    case "FL_PUSH": return ["Little flat push", "One small lift here"];
                    case "FL_HOLD": return ["Flat is your friend", "Nice smooth cruise"];
                    case "FL_EASE": return ["Flat got too spicy", "Reset the heat"];
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
                    case "FL_EASE": return ["Too hot on flat", "Cool it down"];
                    case "DN_PUSH": return ["Dont waste the downhill", "Keep it controlled"];
                    case "DN_HOLD": return ["Just carry the flow", "Stay tidy downhill"];
                    case "DN_EASE": return ["Too much on downhill", "Bring it back"];
                }
            case CATEGORY_ALCOHOL:
                switch (stateKey) {
                    case "UP_PUSH": return ["Light sip uphill", "Push it lightly"];
                    case "UP_HOLD": return ["Easy pour on climbs", "Keep it mellow uphill"];
                    case "UP_EASE": return ["Too strong uphill", "Add some water"];
                    case "FL_PUSH": return ["Tiny flat top-up", "A little sparkle here"];
                    case "FL_HOLD": return ["Good steady blend", "Let it age nicely"];
                    case "FL_EASE": return ["Too strong on flat", "Water it down"];
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
