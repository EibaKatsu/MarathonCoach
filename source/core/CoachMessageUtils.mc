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

    const FUEL_STATE_NONE = "NONE";
    const FUEL_STATE_PREP = "PREP";
    const FUEL_STATE_NOW = "NOW";

    function resolveLanguage(systemLanguage) {
        if (systemLanguage == Sys.LANGUAGE_JPN) {
            return "ja";
        }
        return "en";
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
        var reasonSpecificPool = _getReasonSpecificNormalPoolJa(category, stateKey);
        if (reasonSpecificPool != null) {
            return reasonSpecificPool;
        }

        switch (category) {
            case CATEGORY_FUNNY:
                switch (stateKey) {
                    case "UP_PUSH": return ["坂にも前向きや", "登りで仕事しよ", "その坂ええ顔", "登りも味方や", "腕ふりで勝と", "坂でちょい前", "登りは小さく", "坂となかよし", "上りも連れこ", "坂でも刻める"];
                    case "UP_HOLD": return ["坂は慌てんで", "登りは淡々勝ち", "坂は落ち着こ", "登りで騒がん", "坂とは仲良く", "ゆるっと前へ", "登りは静かに", "坂に付き合うな", "登りは平常や", "坂さばきええ"];
                    case "UP_EASE": return ["坂に全部は払わん", "登りで見栄いらん", "坂でフル課金せんで", "その坂に全力不要", "登りは割引運転で", "坂で熱くならんとこ", "上りは少しケチろ", "坂の請求は後でええ", "ここで全部使わん", "登りは節約モードや"];
                    case "FL_PUSH": return ["平地でひと押し", "ここで少しだけ", "追い風借りよ", "今だけ前へ", "平地で一歩前", "ここは軽めで", "平地ボーナス", "少し前借り", "平地で仕事や", "今のうち伸び"];
                    case "FL_HOLD": return ["平地が味方やで", "その巡航ええ", "平地ええ相棒", "巡航きれいや", "自然に運べる", "流れかなり良い", "平地と仲ええ", "巡航に味あり", "淡々が強い", "平地で無駄ゼロ"];
                    case "FL_EASE": return ["平地で熱い", "いったん整えよ", "平地で高ぶる", "ちょい前のめり", "平地ちょい辛", "ここはひと息", "平地で空回り", "一回戻そ", "平地で温度高い", "少し落ち着こ"];
                    case "DN_PUSH": return ["下りのボーナス活用", "脚だけ軽く回そ", "下りのサービス使お", "坂の貯金を回収や", "下りで足音小さく", "楽してちょい前へ", "下りの風に乗ろ", "脚を転がしていこ", "ここは下りに任せよ", "下りで小さく稼ご"];
                    case "DN_HOLD": return ["下りで雑はあかん", "楽して丁寧に", "下りは上品にいこ", "ラクでも雑は禁止", "下りも育ちが出るで", "丁寧な下りは強い", "楽でも線はきれいに", "下りで大人の運び", "ここは流して上品に", "下りもきちんといこ"];
                    case "DN_EASE": return ["下りで飛ばしすぎ", "少しブレーキ", "下りでご機嫌", "その下り欲張り", "坂の取り分多い", "少し冷静に", "下りで前のめり", "控えめでええ", "下りで得すぎ", "少し抑えよ"];
                }
            case CATEGORY_SALT:
                switch (stateKey) {
                    case "UP_PUSH": return ["腕だけ使お", "力みは禁止", "坂で肩上げるな", "押すけど雑はなし", "その坂、腕で足せ", "脚で暴れるな", "上りでフォーム守れ", "気合いより腕ふり", "坂でも静かに押せ", "力むなら一回やめ"];
                    case "UP_HOLD": return ["登りで騒がん", "落ち着いて刻も", "坂で見栄不要", "静かに進め", "登りでバタつくな", "そのままで正解", "上りは平常心", "坂で余計すな", "我慢して刻め", "落ち着いて登れ"];
                    case "UP_EASE": return ["それは攻めすぎ", "少し下げよ", "坂で盛りすぎや", "その登り雑や", "上りで無駄打ち", "一段落とせ", "今の坂高すぎ", "少し冷静に", "脚を残せ", "登りで張るな"];
                    case "FL_PUSH": return ["遅れは小回収", "欲張らず上げよ", "平地で地味詰め", "一気に返すな", "小さく前借り", "雑に上げるな", "静かに上げよ", "平地でちょい回収", "少しだけ返せ", "じわっとで十分"];
                    case "FL_HOLD": return ["普通が正解", "そのまま続けて", "派手さいらん", "今の巡航で足りる", "余計なことするな", "流れを壊すな", "普通に走れ", "今は何も足すな", "そのまま最強", "崩さず続けろ"];
                    case "FL_EASE": return ["速すぎやで", "いったん冷静", "平地で強すぎ", "一回頭冷やせ", "平地で熱いな", "速さに酔うな", "少し戻せ", "巡航思い出せ", "いまの勢い不要", "落ち着いて運べ"];
                    case "DN_PUSH": return ["下りでも雑なし", "脚を散らすな", "下りで遊ぶな", "フリー速度雑", "軽く回せ", "下りで暴れるな", "整えて速く", "足音大きい", "脚をばらまくな", "下りは丁寧に"];
                    case "DN_HOLD": return ["丁寧に運ぶ", "その流れ維持", "味付けいらん", "下りで騒ぐな", "そのまま最良", "触るな維持や", "流れを壊すな", "下りはそのまま", "丁寧だけで十分", "雑にいじるな"];
                    case "DN_EASE": return ["下りで飛ばすな", "少し戻して", "下りで得気分", "その速度いらん", "坂の勢い浪費", "ちょい戻せ", "欲張るな", "下りでやりすぎ", "少し抑えろ", "無駄な加速やめ"];
                }
            case CATEGORY_ALCOHOL:
                switch (stateKey) {
                    case "UP_PUSH": return ["登りは薄めで", "腕で一杯ぶん", "坂は香りだけ", "登りは軽めで", "上りはちび押し", "坂は度数ひかえ", "薄めで前いこ", "登りは一口で", "坂は軽く押そ", "登りは水割り"];
                    case "UP_HOLD": return ["坂はちびちび", "濃くせんでええ", "登りは熟成", "坂は香りで", "薄めで巡航", "ちび飲みで", "坂は丁寧に", "上りは静かに", "坂はそのまま", "落ち着き熟成"];
                    case "UP_EASE": return ["坂で飲みすぎ", "少し水いこ", "登りは薄めよ", "坂で濃すぎる", "少し割ろか", "上りは冷まそ", "坂は一口休み", "ちょい薄めよ", "坂は熱すぎ", "水で戻そ"];
                    case "FL_PUSH": return ["平地で一口", "軽く炭酸", "ここで一杯ぶん", "平地は軽めで", "少しだけ注ご", "泡だけ足そ", "平地は薄め押し", "軽く回して", "ここで香り足し", "ちびっと前へ"];
                    case "FL_HOLD": return ["いい温度やで", "そのまま熟成", "平地はまろやか", "この味でいこ", "今が飲み頃", "平地は静かに", "流れを熟成", "まろやか巡航", "ちょうどええ", "このまま寝かそ"];
                    case "FL_EASE": return ["平地で濃すぎ", "水で整えよ", "少し薄めよ", "平地は割ろか", "熱を冷まそ", "一口休も", "濃さを戻そ", "平地は軽めで", "ちょい水足そ", "落ち着き割り"];
                    case "DN_PUSH": return ["下りは軽口で", "脚を軽めに", "下りは薄めで", "軽く回そ", "口当たり軽く", "流れで一口", "下りは炭酸", "軽さで進も", "下りは香りで", "脚は水割り"];
                    case "DN_HOLD": return ["下りもなめらか", "流れにまかせ", "下りは熟成", "そのまま流そ", "下りもまろやか", "軽く寝かそ", "流れでええ", "下りは静かに", "なめらか維持", "その味でいこ"];
                    case "DN_EASE": return ["下りで度数高い", "少し薄めよ", "下りは割ろか", "熱を冷まそ", "濃さを戻そ", "下りで飲みすぎ", "一口休も", "水で整えよ", "少し軽めで", "下りは抑えめ"];
                }
            case CATEGORY_TOXIC:
                switch (stateKey) {
                    case "UP_PUSH": return ["登りで逃げるな", "ここは丁寧に", "坂でサボるな", "押して進め", "登りは詰めろ", "脚を止めるな", "坂で負けるな", "ここは前出ろ", "腕で押し切れ", "登りは働け"];
                    case "UP_HOLD": return ["坂で焦るな", "淡々と勝てる", "登りで騒ぐな", "そのまま刻め", "坂はまだ平常", "落ち着いていけ", "余計なことすな", "今は我慢や", "静かに運べ", "登りは普通で"];
                    case "UP_EASE": return ["その坂危ない", "落として戻せ", "登りで盛るな", "少し引け", "坂で無駄打ち", "脚を残せ", "今は下げろ", "ここは守れ", "登りで張るな", "坂は熱すぎ"];
                    case "FL_PUSH": return ["まだ余白ある", "少し回収しろ", "平地で詰めろ", "ここで少し返せ", "一気に行くな", "静かに上げろ", "小さく前出ろ", "まだ行ける", "平地で拾え", "少しだけ詰め"];
                    case "FL_HOLD": return ["崩さんのが正義", "雑にならんで", "そのまま維持", "普通で勝てる", "余計なことすな", "今は触るな", "流れを壊すな", "静かに運べ", "崩すな続けろ", "その巡航でええ"];
                    case "FL_EASE": return ["熱くなりすぎ", "一回落ち着け", "平地で盛るな", "少し戻せ", "勢いいらん", "頭を冷やせ", "平地で無駄", "巡航思い出せ", "いま速すぎ", "落として運べ"];
                    case "DN_PUSH": return ["下りで遊ぶな", "軽く速くいこ", "流れを使え", "脚を散らすな", "下りは拾え", "雑に踏むな", "下りで回せ", "軽く前出ろ", "フリー使え", "下りは丁寧に"];
                    case "DN_HOLD": return ["雑な下り負け", "丁寧に流せ", "そのまま運べ", "下りで触るな", "流れを壊すな", "静かに下ろせ", "今は維持や", "下りは整えろ", "雑にいじるな", "その線でいけ"];
                    case "DN_EASE": return ["下りで壊すな", "少し抑えろ", "下りで盛るな", "欲張るな", "落として戻せ", "無料に酔うな", "下りでやりすぎ", "少し引け", "流されるな", "脚を守れ"];
                }
            case CATEGORY_PRAISE:
                switch (stateKey) {
                    case "UP_PUSH": return ["登りで前向けてる", "ええ押しやで", "坂で仕事できる", "押しどころ良い", "登り使いうまい", "前向きさ強い", "坂で崩れへん", "登り判断ええ", "上りで流れ出る", "押し方かなり良い"];
                    case "UP_HOLD": return ["登りが安定してる", "我慢が上手い", "坂で慌てへん", "登りのリズムええ", "その我慢は価値", "坂で丁寧や", "登りの落ち着き", "安定して刻める", "上りでぶれへん", "坂さばき上手い"];
                    case "UP_EASE": return ["抑え判断が強い", "守れててえらい", "坂で引ける強さ", "その我慢良い", "登りで守れる", "少し戻せる強さ", "抑え判断きれい", "崩れる前に戻す", "守り精度高い", "その冷静さええ"];
                    case "FL_PUSH": return ["いいとこで上げる", "判断がきれい", "平地の押し上手", "上げ幅ちょうど", "余裕使い上手", "押しどころ見える", "平地で前に出る", "その一歩効く", "上げ方落ち着く", "きれいな押し"];
                    case "FL_HOLD": return ["その巡航強い", "安定感あるわ", "この巡航ええ", "平地で無駄なし", "落ち着きが強い", "流れ作り上手", "巡航きれい", "安定して運べる", "そのまま強い", "丁寧さ光る"];
                    case "FL_EASE": return ["整える実力", "落ち着けて強い", "平地で戻せる", "その冷静さええ", "整え判断きれい", "少し引ける強さ", "巡航へ戻せる", "焦らず整える", "落ち着きが武器", "戻し方かなり良い"];
                    case "DN_PUSH": return ["下りを使えてる", "軽い脚さばき", "下りの乗り上手", "脚が軽く回る", "下り処理ええ", "フリー使い上手", "下りの流れ乗る", "軽さ出てる", "下りの押しきれい", "脚運びかなり良い"];
                    case "DN_HOLD": return ["下りも丁寧やで", "流れの乗り上手", "下りでぶれへん", "その落ち着きええ", "下りでも丁寧", "流れ壊さへん", "そのまま維持", "下りの安定感", "流し方きれい", "下りでも大人"];
                    case "DN_EASE": return ["抑えて正解や", "崩さぬ強さ", "下りで引ける", "守り判断ええ", "欲張らぬ強さ", "崩す前に戻す", "下りの冷静さ", "抑え精度高い", "戻し方かなり良い", "整えられて強い"];
                }
            case CATEGORY_DIST:
                return [];
        }

        switch (stateKey) {
            case "UP_PUSH": return ["腕でつなご", "登りで少し押そ", "坂は腕で運ぼ", "登りは小さく押す", "一段だけ前へ", "坂で脚を止めん", "リズム保って押そ", "坂でも淡々前へ", "ここは少しだけ", "腕振りでつなご"];
            case "UP_HOLD": return ["登りは淡々と", "リズム優先で", "坂は落ち着いて", "その登り方でええ", "今は整えて運ぼ", "我慢して刻も", "力まずそのまま", "坂でも慌てんで", "呼吸で整えよ", "丁寧に進も"];
            case "UP_EASE": return ["登りで抑えよ", "少し落とそ", "坂は使いすぎん", "ここは守っていこ", "登りは整え直そ", "一段ゆるめよ", "坂で熱くならん", "脚を残していこ", "少し戻していこ", "抑えて立て直そ"];
            case "FL_PUSH": return ["少し前へ", "ここで少し上げよ", "平地でひと押し", "一段だけ前へ", "余裕ぶんだけ上げよ", "リズム保って前へ", "ほんの少し押そ", "脚を回して前へ", "焦らず少し上げよ", "ここで小さく進も"];
            case "FL_HOLD": return ["そのまま運ぼ", "いい流れやで", "このリズムでいこ", "今の巡航で十分", "淡々と運べてる", "その感覚を維持", "無駄なく進めてる", "落ち着いてそのまま", "今の流れが正解", "その調子で運ぼ"];
            case "FL_EASE": return ["少し落ち着こ", "一段ゆるめよ", "平地で少し整えよ", "ここは抑えていこ", "少し戻していこ", "熱くなりすぎん", "一回リズム戻そ", "落ち着いて運び直そ", "無理に刻まんでええ", "平地は整えていこ"];
            case "DN_PUSH": return ["下りで丁寧に乗ろ", "脚を回していこ", "下りを少し使お", "流れに乗って前へ", "小さく前へ進も", "軽く回していこ", "下りを生かしていこ", "脚を転がしていこ", "雑にならず前へ", "ここは軽く進も"];
            case "DN_HOLD": return ["下りも丁寧に", "流れに乗ろ", "下りはそのままで", "楽に運んでいこ", "脚を散らさずいこ", "下りも落ち着いて", "今の流れで十分", "無駄なく乗れてる", "丁寧にそのまま", "下りも整えていこ"];
            case "DN_EASE": return ["下りで飛ばしすぎ", "少し抑えよ", "下りは少し戻そ", "ここは欲張らん", "ブレーキは少しだけ", "一段落ち着こ", "流されすぎんで", "下りで使いすぎん", "少し整えていこ", "抑えて立て直そ"];
        }
        return ["そのままいこ", "落ち着いていこ", "このままでええ", "今は維持や", "流れでいこ", "無理せんでええ", "その線でいこ", "丁寧にいこ", "静かにいこ", "今はそのまま"];
    }

    function _getNormalPoolEn(category, stateKey) as Lang.Array {
        var reasonSpecificPool = _getReasonSpecificNormalPoolEn(category, stateKey);
        if (reasonSpecificPool != null) {
            return reasonSpecificPool;
        }

        switch (category) {
            case CATEGORY_FUNNY:
                switch (stateKey) {
                    case "UP_PUSH": return ["Climb with intent", "Uphill has work today", "Smile at the hill", "Give the climb a job", "Small brave uphill move", "This hill is invited", "Climb with a grin", "One tidy uphill push", "Let the hill know", "Uphill is in play"];
                    case "UP_HOLD": return ["No panic uphill", "Steady wins the climb", "Keep it chill uphill", "Calm beats drama here", "Hill says stay smooth", "Quiet climb, good climb", "No need to wrestle", "Stay mellow uphill", "Glide the climb", "Easy does it uphill"];
                    case "UP_EASE": return ["No hero climb now", "Dont spend it here", "This hill gets no bonus", "Save the fireworks", "Climb without the drama", "No full-price uphill", "Take less from this hill", "Keep the receipt closed", "Do not tip the climb", "Easy on the mountain"];
                    case "FL_PUSH": return ["Little flat push", "One small lift here", "Borrow a tiny gear", "Flat says nudge it", "Just a dab more", "Tiny push on cruise", "Flat bonus unlocked", "Move the dial a bit", "One neat little press", "A touch more now"];
                    case "FL_HOLD": return ["Flat is your friend", "Nice smooth cruise", "This flat likes you", "Cruise is looking good", "That rhythm has style", "Keep the roll pretty", "Flat and flowy now", "Smooth is winning", "This line is clean", "Cruise like that"];
                    case "FL_EASE": return ["Flat got too spicy", "Reset the heat", "Flat needs less sauce", "That got a bit loud", "Turn down the spice", "Cruise got punchy", "Lower the drama", "Take the fizz out", "Settle the flat mood", "A calmer flat now"];
                    case "DN_PUSH": return ["Use the downhill", "Quick easy feet", "Free speed, polite use", "Let gravity help out", "Downhill says go gently", "Soft fast feet now", "Take the gift lightly", "Roll the drop well", "Easy speed is here", "Glide the descent"];
                    case "DN_HOLD": return ["Stay neat downhill", "Easy speed only", "Downhill with manners", "Keep the descent tidy", "Let the hill do it", "Smooth downhill roll", "Polite speed only", "Hold the easy drop", "Neat feet downhill", "Ride the hill nicely"];
                    case "DN_EASE": return ["Downhill got greedy", "Brake just a touch", "Hill got too excited", "Pocket some of that", "Too much free candy", "Easy there, gravity", "Leave some downhill out", "Trim the greed", "The drop is extra today", "Back off the bonus"];
                }
            case CATEGORY_SALT:
                switch (stateKey) {
                    case "UP_PUSH": return ["Arms only, no drama", "No extra tension", "Do not fight the hill", "Push, dont flail", "Keep the shoulders calm", "No noisy climbing", "Use form, not ego", "Steady uphill pressure", "Save the theatrics", "Control the push"];
                    case "UP_HOLD": return ["Quiet on the climb", "Just keep the rhythm", "No need to impress uphill", "Normal is enough here", "Stay calm and climb", "Hold it, no fuss", "The hill wants patience", "Smooth is the move", "Keep it boring", "That is the right gear"];
                    case "UP_EASE": return ["That is too much", "Back off uphill", "You are overspending", "Drop the climb ego", "Too much for this hill", "Take a gear off", "That pace is loud", "Save the legs now", "Back it down uphill", "You do not need this"];
                    case "FL_PUSH": return ["Recover the gap slowly", "Lift, dont lunge", "Take it back quietly", "No wild flat move", "Small gain only", "Raise it, not rush it", "One clean step up", "A little, not a lot", "Measured flat press", "Control the pickup"];
                    case "FL_HOLD": return ["Normal is right", "Keep doing that", "Do not decorate this", "That pace is enough", "Stay plain and good", "Leave it alone", "Cruise, dont perform", "This is the right boring", "Hold the simple line", "Keep the clean rhythm"];
                    case "FL_EASE": return ["Too hot on flat", "Cool it down", "That flat pace is extra", "Back the heat off", "Youre doing too much", "Settle the ego", "Return to cruise", "Lower the volume", "Take it down a notch", "Bring the pace back"];
                    case "DN_PUSH": return ["Dont waste the downhill", "Keep it controlled", "Use it, dont spray it", "Fast feet, calm head", "Take the speed cleanly", "Downhill is not chaos", "Carry it with control", "No downhill circus", "Use the hill well", "Stay sharp on the drop"];
                    case "DN_HOLD": return ["Just carry the flow", "Stay tidy downhill", "Do not touch it", "Let the hill do the work", "Smooth is enough here", "Hold the descent neatly", "Nothing extra needed", "Keep it clean downhill", "That line is fine", "Stay disciplined"];
                    case "DN_EASE": return ["Too much on downhill", "Bring it back", "You are overusing gravity", "Back off the free speed", "That descent is sloppy", "Take a little off", "Do less downhill", "Hold some back", "Stop donating the legs", "Ease the drop"];
                }
            case CATEGORY_ALCOHOL:
                switch (stateKey) {
                    case "UP_PUSH": return ["Light sip uphill", "Push it lightly", "Easy pour uphill", "Climb on the rocks", "Just a taste uphill", "Keep it light uphill", "One small uphill sip", "Low-proof uphill push", "Soft pour on climbs", "Small uphill toast"];
                    case "UP_HOLD": return ["Easy pour on climbs", "Keep it mellow uphill", "Slow sip uphill", "Let it breathe uphill", "Easy climb blend", "Hold the mellow pour", "Keep it neat uphill", "Gentle uphill mix", "Stay smooth uphill", "Let it age uphill"];
                    case "UP_EASE": return ["Too strong uphill", "Add some water", "Water the climb down", "Back off the proof", "Climb got too bold", "Thin it out uphill", "Take the strength down", "Easy on uphill proof", "Cut it with water", "Less heat on the climb"];
                    case "FL_PUSH": return ["Tiny flat top-up", "A little sparkle here", "Small sip on flat", "Light pour on flat", "Flat gets a splash", "Just a taste now", "Add a little fizz", "Tiny neat top-up", "Light up the flat", "One quick flat sip"];
                    case "FL_HOLD": return ["Good steady blend", "Let it age nicely", "Nice mellow mix", "Hold this smooth pour", "Keep the blend easy", "Flat is drinking well", "Stay with this mix", "Let the flat breathe", "Smooth steady pour", "That blend is right"];
                    case "FL_EASE": return ["Too strong on flat", "Water it down", "Flat needs more water", "Back off the proof", "Take some bite out", "Thin the flat pour", "Less heat on flat", "Cut it with water", "Ease the strong mix", "Bring the proof down"];
                    case "DN_PUSH": return ["Light feet downhill", "Roll it smooth", "Easy pour downhill", "Let the hill breathe", "Downhill with a splash", "Soft sip on the drop", "Light quick downhill", "Keep the descent neat", "Take the downhill neat", "Glide with a light pour"];
                    case "DN_HOLD": return ["Smooth pour downhill", "Let the flow work", "Keep it silky down", "Hold the easy pour", "Stay mellow downhill", "Let it roll smooth", "Downhill drinks neat", "Keep the drop smooth", "Gentle downhill mix", "Easy smooth descent"];
                    case "DN_EASE": return ["Too much downhill proof", "Make it lighter", "Cut the downhill proof", "Less heat on the drop", "Water that down now", "Bring the proof down", "Easy on the descent", "Downhill got too strong", "Take some strength off", "Thin the downhill mix"];
                }
            case CATEGORY_TOXIC:
                switch (stateKey) {
                    case "UP_PUSH": return ["Dont hide from the hill", "Push with control", "Climb and do the work", "No ducking uphill", "Face the hill cleanly", "Stop dodging the grade", "Push, dont panic", "Own this uphill", "Get over the hill", "Climb like you mean it"];
                    case "UP_HOLD": return ["You dont need to rush", "Steady still wins", "Calm still beats chaos", "Hold it and keep moving", "No panic on this climb", "Stay boring uphill", "Keep the hill honest", "Smooth still wins here", "Just hold the line", "Patience beats flailing"];
                    case "UP_EASE": return ["That climb pace bites", "Reset it now", "This hill can hurt you", "Back off uphill now", "Too much for this climb", "Stop forcing the grade", "Climb got too hot", "Take the edge off", "Ease before it cracks", "Reset the uphill mess"];
                    case "FL_PUSH": return ["You still have room", "Take back a little", "There is more here", "Use the spare margin", "Recover some ground", "Take a small bite back", "Pick up a little now", "Stop being too polite", "Use the flat better", "There is pace to take"];
                    case "FL_HOLD": return ["Clean beats flashy", "Dont get sloppy", "Boring still wins", "Hold the clean line", "Do not ruin this", "Simple pace is enough", "Stay neat and useful", "Leave it alone", "That clean pace works", "Keep it controlled"];
                    case "FL_EASE": return ["Too hot already", "Settle down once", "That pace is sloppy", "Back it off now", "Youre cooking this", "Stop forcing flat speed", "Take one step down", "Ease before it breaks", "Reset the mess", "Lower the heat now"];
                    case "DN_PUSH": return ["Use the slope well", "Fast feet, not chaos", "Take free speed clean", "Downhill is not recess", "Use the drop properly", "Quick feet, calm head", "Carry speed, dont spray", "Stop wasting the hill", "Take the gift cleanly", "Control the descent"];
                    case "DN_HOLD": return ["Messy downhill loses", "Flow with control", "Keep the drop clean", "Downhill needs brains", "Do not get sloppy", "Stay neat on descent", "Hold the descent line", "Let it roll cleanly", "Calm feet downhill", "Clean beats messy here"];
                    case "DN_EASE": return ["Dont break it downhill", "Ease the drop", "This downhill can wreck", "Take less from the drop", "Stop burning downhill", "Back off the descent", "Youre spilling speed", "Do less downhill", "Hold something back", "Ease before it snaps"];
                }
            case CATEGORY_PRAISE:
                switch (stateKey) {
                    case "UP_PUSH": return ["Strong climb choice", "Nice uphill intent", "That push is well judged", "Good uphill commitment", "Youre using the hill well", "Clean climb decision", "Strong but tidy uphill", "Nice work on the grade", "Good uphill timing", "That was a smart push"];
                    case "UP_HOLD": return ["Solid uphill control", "Great patience there", "Youre climbing calmly", "Uphill rhythm is strong", "Nice restraint uphill", "Very tidy uphill work", "Youre holding this well", "Strong steady climb", "Good control on the grade", "That patience is paying"];
                    case "UP_EASE": return ["Smart to protect it", "Good restraint now", "Nice save on the hill", "That ease was well timed", "That is strong control", "Good call to reset", "Protecting well uphill", "Excellent restraint there", "Smart uphill patience", "You kept it together"];
                    case "FL_PUSH": return ["Well timed lift", "That move is clean", "Nice flat pickup", "Good timing on that press", "Strong little move there", "That was efficient", "You chose the spot well", "Clean use of the flat", "Good measured lift", "That was nicely judged"];
                    case "FL_HOLD": return ["Strong steady cruise", "Great calm rhythm", "That cruise looks good", "Youre carrying this well", "Nice composed pace", "Strong simple rhythm", "Good steady work", "That calm is powerful", "Youre pacing this cleanly", "Very controlled cruise"];
                    case "FL_EASE": return ["Reset is a skill", "Good composure there", "Nice call to settle", "That was controlled", "You reset it well", "Strong calm response", "Good job taking it down", "That ease was smart", "Excellent composure", "You handled that well"];
                    case "DN_PUSH": return ["Downhill used well", "Nice quick feet", "Great use of the slope", "Descent move was neat", "Youre rolling downhill", "Strong downhill timing", "Nice light steps there", "You used free speed well", "Good downhill control", "That was smooth and quick"];
                    case "DN_HOLD": return ["Smooth downhill work", "Youre carrying it well", "Nice steady descent", "Downhill line is neat", "Youre flowing really well", "Good relaxed downhill", "That control is strong", "Very tidy descent", "You hold the drop well", "Strong calm downhill"];
                    case "DN_EASE": return ["Good call to ease", "Strong control there", "Nice restraint downhill", "You protected it well", "That was a smart reset", "Good downhill composure", "You took just enough off", "Great control downhill", "Smart to settle there", "You kept descent honest"];
                }
            case CATEGORY_DIST:
                return [];
        }

        switch (stateKey) {
            case "UP_PUSH": return ["Use the arms", "Push the climb", "Small climb push", "Move it uphill", "One gear forward", "Lean in lightly", "Carry it uphill", "Steady push now", "Just a touch more", "Keep it moving"];
            case "UP_HOLD": return ["Steady uphill", "Keep the rhythm", "Hold the climb", "Stay calm uphill", "Just keep rolling", "No rush uphill", "Smooth and steady", "Hold this effort", "Settle and climb", "Keep it tidy"];
            case "UP_EASE": return ["Ease on the climb", "Back off uphill", "Save it uphill", "Settle the climb", "One gear easier", "Dont spend it", "Reset uphill", "Take a little off", "Climb with control", "Protect the legs"];
            case "FL_PUSH": return ["Lift it a touch", "Press a little", "Move up a bit", "One small push", "Nudge it forward", "Add a little", "Take one step up", "Carry more speed", "Use the flat now", "Push just a touch"];
            case "FL_HOLD": return ["Hold this rhythm", "Good steady flow", "Keep this pace", "Cruise like this", "Stay right here", "Nice smooth roll", "Let it flow", "Hold the line", "This is enough", "Keep it tidy"];
            case "FL_EASE": return ["Settle a little", "Ease one gear", "Back it off", "Reset the pace", "Take a breath", "Bring it down", "Smooth it out", "Relax the pace", "Ease the heat", "Steady it now"];
            case "DN_PUSH": return ["Roll the downhill", "Quick light steps", "Use the slope", "Carry it forward", "Let it roll", "Move with the hill", "Fast easy feet", "Take the free speed", "Flow downhill", "Keep it light"];
            case "DN_HOLD": return ["Stay smooth downhill", "Ride the flow", "Hold this roll", "Keep it tidy", "Let the hill work", "Stay relaxed", "Easy downhill flow", "Hold the descent", "Smooth and easy", "Keep the line"];
            case "DN_EASE": return ["Dont overcook downhill", "Ease the descent", "Back off downhill", "Hold a little back", "Too much free speed", "Settle the drop", "Stay in control", "Dont chase it", "Ease the hill", "Bring it back"];
        }
        return ["Stay steady", "Hold this line", "Keep it smooth", "Just stay here", "Keep it simple", "Steady does it", "Hold the rhythm", "Stay right there", "Let it roll", "Keep it calm"];
    }

    function _getReasonSpecificNormalPoolJa(category, stateKey) as Lang.Array or Null {
        var slopeKey = _extractSlopeKey(stateKey);
        if (slopeKey == null) {
            return null;
        }
        if (_hasSuffix(stateKey, "_EASE_PACE")) {
            return _getEasePacePoolJa(category, slopeKey);
        }
        if (_hasSuffix(stateKey, "_EASE_HR")) {
            return _getNormalPoolJa(category, slopeKey + "_EASE");
        }
        if (_hasSuffix(stateKey, "_EASE_BOTH")) {
            return _getEaseBothPoolJa(category, slopeKey);
        }
        return null;
    }

    function _getReasonSpecificNormalPoolEn(category, stateKey) as Lang.Array or Null {
        var slopeKey = _extractSlopeKey(stateKey);
        if (slopeKey == null) {
            return null;
        }
        if (_hasSuffix(stateKey, "_EASE_PACE")) {
            return _getEasePacePoolEn(category, slopeKey);
        }
        if (_hasSuffix(stateKey, "_EASE_HR")) {
            return _getNormalPoolEn(category, slopeKey + "_EASE");
        }
        if (_hasSuffix(stateKey, "_EASE_BOTH")) {
            return _getEaseBothPoolEn(category, slopeKey);
        }
        return null;
    }

    function _getEasePacePoolJa(category, slopeKey) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY:
                switch (slopeKey) {
                    case "UP": return ["坂で使いすぎ", "登りは少し戻そ", "坂に課金しすぎ", "上りは節約で", "坂で熱くなるな", "登りは一口戻し", "坂は軽めで", "ここは割引坂", "上りは控えめ", "坂は後で払お"];
                    case "FL": return ["平地で前のめり", "少しだけ戻そ", "平地が元気すぎ", "巡航へ戻そ", "平地で熱いで", "少し整えよ", "平地ボナ過多", "一口下げよ", "前のめり注意", "平地は静かに"];
                    case "DN": return ["下りで得すぎ", "少し戻して", "下りで貰いすぎ", "ちょい返却や", "下りでご祝儀", "少し整えて", "下りで盛りすぎ", "ここは引いとこ", "坂のオマケ過多", "下りは一口戻し"];
                }
            case CATEGORY_SALT:
                switch (slopeKey) {
                    case "UP": return ["登りで急ぐな", "少し戻そ", "坂で盛るな", "上りは一段下げ", "その坂高い", "登りで張るな", "ここで使うな", "坂は静かに", "脚を残せ", "少し引け"];
                    case "FL": return ["速いぶん過多", "少し戻して", "平地で盛るな", "巡航戻せ", "その速さ不要", "少し整えよ", "平地で熱い", "いま速すぎ", "一段落とせ", "落ち着け"];
                    case "DN": return ["下りで盛りすぎ", "少し戻そ", "その得いらん", "少し引け", "下りで使うな", "無料に酔うな", "下りは控えろ", "欲張るな", "一段戻せ", "少し整えよ"];
                }
            case CATEGORY_ALCOHOL:
                switch (slopeKey) {
                    case "UP": return ["坂で濃くしすぎ", "少し薄めよ", "登りは水割り", "坂は軽めで", "上りは薄口で", "少し割ろか", "坂は一口で", "登りは薄めに", "濃さを戻そ", "坂は香りだけ"];
                    case "FL": return ["平地で濃いめ", "少し水入れよ", "平地は薄めで", "少し割ろか", "濃さを戻そ", "水で整えよ", "平地は軽口で", "一口休も", "泡を抜こか", "平地は薄口で"];
                    case "DN": return ["下りで度数高い", "少し薄めよ", "下りは水割り", "濃さを戻そ", "少し割ろか", "水で整えよ", "下りは薄口で", "一口休も", "下りは軽めで", "熱を冷まそ"];
                }
            case CATEGORY_TOXIC:
                switch (slopeKey) {
                    case "UP": return ["その登り先払い", "少し戻せ", "坂で使うな", "少し引け", "登りで盛るな", "一段下げろ", "脚を残せ", "ここは守れ", "坂で無駄打ち", "登りは控えろ"];
                    case "FL": return ["その速さ不要", "少し戻せ", "平地で盛るな", "巡航戻せ", "一段下げろ", "いま速すぎ", "落として運べ", "ここは抑えろ", "熱くなるな", "少し引け"];
                    case "DN": return ["下りで捨てるな", "少し戻せ", "無料を吐くな", "少し引け", "下りで盛るな", "一段下げろ", "脚を守れ", "下りは控えろ", "落として戻せ", "得しすぎ"];
                }
            case CATEGORY_PRAISE:
                switch (slopeKey) {
                    case "UP": return ["登りで守れる", "少し戻して正解", "抑え判断ええ", "守れて強い", "上りで戻せる", "少し引けて偉い", "登りで整えた", "その我慢ええ", "坂で戻せる", "守りが上手い"];
                    case "FL": return ["戻せる判断ええ", "少し整えよ", "平地で戻せる", "整え方うまい", "少し引けて強い", "その冷静さええ", "巡航戻し上手", "平地で整えた", "戻し判断きれい", "落ち着き上手"];
                    case "DN": return ["下りを抑えられる", "少し戻して正解", "下りで守れる", "その引き方ええ", "抑え判断ええ", "戻し方うまい", "下りで整えた", "守りが強い", "下りで冷静", "崩す前に戻す"];
                }
            case CATEGORY_DIST:
                return [];
        }

        switch (slopeKey) {
            case "UP": return ["登りは少し戻そ", "ここでは使いすぎん", "坂は少し整えよ", "一段だけ戻そ", "脚を残していこ", "登りは少し守ろ", "熱くならず戻そ", "ここは抑えて運ぼ", "登りで無理せん", "少しゆるめていこ"];
            case "FL": return ["ペース少し戻そ", "少し整えていこ", "平地は少し戻そ", "いったん整えよ", "ここはひと呼吸", "平地で使いすぎん", "少しだけ抑えよ", "巡航に戻していこ", "ちょい戻しで十分", "一段落ち着こ"];
            case "DN": return ["下りは少し戻そ", "ここは抑えていこ", "下りで使いすぎん", "流されすぎんで", "少しだけ戻そ", "下りは整えていこ", "ここは欲張らん", "少し抑えて十分", "一段戻していこ", "落ち着いて下ろ"];
        }
        return ["少し戻そ", "少し整えよ", "一段戻そ", "少し引こか", "巡航戻そ", "ここは戻そ", "落ち着こ", "少し下げよ", "ひと呼吸", "整えていこ"];
    }

    function _getEaseBothPoolJa(category, slopeKey) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY:
                switch (slopeKey) {
                    case "UP": return ["坂で欲張りすぎ", "ペースも整え", "坂で熱すぎ", "少し冷まそ", "上りで全部盛り", "両方戻そ", "坂で辛口すぎ", "一口休も", "登りは欲張るな", "熱も下げよ"];
                    case "FL": return ["平地で熱も高い", "いったん整えよ", "平地で盛りすぎ", "両方戻そ", "前のめり注意", "少し冷まそ", "平地が元気すぎ", "熱も下げよ", "一口休も", "巡航戻そ"];
                    case "DN": return ["下りで乗りすぎ", "心拍も戻そ", "下りで熱すぎ", "両方戻そ", "ご祝儀多すぎ", "少し冷まそ", "下りで盛りすぎ", "熱も下げよ", "一口休も", "下りは引いとこ"];
                }
            case CATEGORY_SALT:
                switch (slopeKey) {
                    case "UP": return ["登りで上げすぎ", "心拍も抑えよ", "坂で熱すぎ", "少し戻せ", "上りで盛るな", "両方下げろ", "その坂高い", "一段落とせ", "脚も熱も守れ", "少し冷静に"];
                    case "FL": return ["速いし熱い", "一回戻して", "平地で盛るな", "両方下げろ", "いま熱すぎ", "少し整えよ", "速さも過多", "熱も抑えろ", "一段落とせ", "落ち着いて"];
                    case "DN": return ["下りで飛ばしすぎ", "まとめて戻せ", "下りで熱い", "両方下げろ", "無料に酔うな", "少し冷静に", "下りで使うな", "熱も抑えろ", "一段落とせ", "欲張るな"];
                }
            case CATEGORY_ALCOHOL:
                switch (slopeKey) {
                    case "UP": return ["坂で濃くて熱い", "少し水入れ", "登りは薄めで", "熱も冷まそ", "坂は水割りで", "両方薄めよ", "上りは軽口で", "少し割ろか", "濃さを戻そ", "熱を下げよ"];
                    case "FL": return ["平地で濃いし熱い", "薄めて整えよ", "少し水入れ", "平地は薄めで", "熱も冷まそ", "両方薄めよ", "少し割ろか", "濃さを戻そ", "平地は軽口で", "熱を下げよ"];
                    case "DN": return ["下りで熱も高い", "少し薄めよ", "下りは水割り", "熱も冷まそ", "両方薄めよ", "少し割ろか", "濃さを戻そ", "水で整えよ", "下りは軽めで", "熱を下げよ"];
                }
            case CATEGORY_TOXIC:
                switch (slopeKey) {
                    case "UP": return ["その登り高い", "心拍も落とせ", "坂で盛るな", "両方戻せ", "上りで危ない", "少し引け", "熱も高い", "坂は一段下げ", "脚を残せ", "今は落とせ"];
                    case "FL": return ["速さも熱も高い", "今すぐ整えろ", "平地で盛るな", "両方戻せ", "いま危ない", "少し引け", "巡航戻せ", "熱も下げろ", "一段落とせ", "ここは守れ"];
                    case "DN": return ["下りで全部使うな", "少し落として戻せ", "下りで盛るな", "両方戻せ", "熱も高い", "少し引け", "脚を守れ", "一段下げろ", "流されるな", "ここは守れ"];
                }
            case CATEGORY_PRAISE:
                switch (slopeKey) {
                    case "UP": return ["守り切替が強い", "心拍も整えよ", "登りで戻せる", "両方見れてる", "その冷静さええ", "坂で整え上手", "守り判断きれい", "崩れる前に戻す", "熱も抑え上手", "その我慢強い"];
                    case "FL": return ["ここで戻せる", "整え判断が強い", "平地で整えた", "両方見れてる", "その冷静さええ", "巡航戻し上手", "熱も抑え上手", "戻し方きれい", "少し引けて強い", "整え力高い"];
                    case "DN": return ["下りで抑えられる", "崩す前に整えよ", "下りで戻せる", "両方見れてる", "その冷静さええ", "熱も抑え上手", "守り判断きれい", "整え方うまい", "下りで引ける", "戻し方きれい"];
                }
            case CATEGORY_DIST:
                return [];
        }

        switch (slopeKey) {
            case "UP": return ["登りで使いすぎ", "ペースも整え", "坂で熱も高い", "一回落ち着こ", "ここは両方戻そ", "登りで攻めすぎ", "熱も抑えよ", "坂は整えて", "一段守って戻そ", "ここで立て直そ"];
            case "FL": return ["少し速いし熱い", "一回整えよ", "平地で熱も高い", "ここは両方戻そ", "少し落ち着こ", "平地は整え優先", "一段ゆるめよ", "熱も速さも抑えよ", "巡航へ戻そ", "ここで立て直そ"];
            case "DN": return ["下りで飛ばしすぎ", "心拍も少し高い", "下りで熱も出てる", "ここは両方戻そ", "少し整えて下ろ", "下りで使いすぎ", "熱も抑えよ", "流されすぎん", "一段落として戻そ", "ここで立て直そ"];
        }
        return ["少し整えよ", "一回戻そ", "両方戻そ", "少し冷まそ", "一段下げよ", "ここは整えよ", "落ち着こ", "少し守ろ", "整えていこ", "立て直そ"];
    }

    function _getEasePacePoolEn(category, slopeKey) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY:
                switch (slopeKey) {
                    case "UP": return ["Climb coupon not cash", "Ease it just a touch", "Too much hill shopping", "Spend less uphill", "That hill costs extra", "Climb on a budget", "Take a little off", "Save some for later", "Ease the climb bill", "Do not tip the hill"];
                    case "FL": return ["Flat got a bit eager", "Bring it back a touch", "Flat is too excited", "Return to cruise", "Take a little off", "That pace is peppy", "Calm the flat down", "Small reset on flat", "Ease the eager flat", "Take the fizz out"];
                    case "DN": return ["Downhill bonus overused", "Pocket some of it", "Too much free downhill", "Leave some on the hill", "Take a little off", "The drop got greedy", "Calm the bonus down", "Do not spend it all", "Ease the gift back", "Trim the downhill gift"];
                }
            case CATEGORY_SALT:
                switch (slopeKey) {
                    case "UP": return ["No need to chase uphill", "Bring it back a touch", "That hill is too rich", "Take less uphill", "Back it off now", "Climb without oversell", "Save the legs here", "One gear easier", "Stop forcing the hill", "Ease it uphill"];
                    case "FL": return ["Fine until too fast", "Ease it back", "That pace is extra", "Return to cruise", "Take one step down", "Back it off now", "You do not need that", "Lower the flat heat", "Calm this flat down", "Bring pace back"];
                    case "DN": return ["Downhill got a bit extra", "Back it off a touch", "Too much free speed", "Take less downhill", "Stop overspending here", "Hold some in hand", "Ease the drop back", "Back off the slope", "Keep some downhill out", "Trim the free speed"];
                }
            case CATEGORY_ALCOHOL:
                switch (slopeKey) {
                    case "UP": return ["Climb pour is too strong", "Add a little water", "Thin the uphill pour", "Keep it low-proof", "Less bite uphill", "Water the climb down", "Easy on the proof", "Make the hill lighter", "Take the strength down", "Ease the uphill mix"];
                    case "FL": return ["Flat got chuggy there", "Water it down a touch", "Flat is too strong", "Thin the flat pour", "Take some bite out", "Make the mix lighter", "Less proof on flat", "Cut it with water", "Ease the flat blend", "Bring the proof down"];
                    case "DN": return ["Downhill proof too high", "Make it a little lighter", "Cut the downhill proof", "Take the strength off", "Less heat on the drop", "Water the drop down", "Keep the proof low", "Thin the downhill mix", "Ease the descent blend", "Take some bite out"];
                }
            case CATEGORY_TOXIC:
                switch (slopeKey) {
                    case "UP": return ["That climb overspends", "Bring it back now", "Too much for this hill", "Back off uphill", "Stop burning here", "Take one step down", "Ease the climb back", "Save your legs now", "Do less on the hill", "Reset the uphill pace"];
                    case "FL": return ["You do not need that pace", "Ease it back", "That speed is wasted", "Return to cruise", "Back it off now", "Take one step down", "Stop forcing pace", "Hold some back", "Calm the flat pace", "Bring it down"];
                    case "DN": return ["Dont donate free speed", "Bring it back", "Too much free downhill", "Take less from the drop", "Back off the descent", "Hold some in hand", "Do less downhill", "Ease the slope back", "Stop wasting the legs", "Trim the downhill"];
                }
            case CATEGORY_PRAISE:
                switch (slopeKey) {
                    case "UP": return ["Nice call to protect", "Ease it back a touch", "Strong uphill control", "Good save on the hill", "That reset was smart", "You read the climb well", "Strong restraint there", "Good call to ease", "Smart climb patience", "You protected it well"];
                    case "FL": return ["Good control, ease back", "Small reset is strong", "Nice flat restraint", "That reset was smart", "Good call to settle", "You handled that well", "Strong calm response", "Nice cruise reset", "Good composure there", "Smart pace control"];
                    case "DN": return ["Strong call downhill", "Ease it back a touch", "Nice downhill restraint", "Good call to settle", "That reset was smart", "Strong descent control", "You protected it well", "Good composure there", "Smart to ease there", "Strong calm downhill"];
                }
            case CATEGORY_DIST:
                return [];
        }

        switch (slopeKey) {
            case "UP": return ["Ease the climb pace", "Dont spend it here", "Back it off uphill", "One gear easier", "Save some uphill", "Settle the climb", "Protect the legs", "Take a little off", "Climb a touch easier", "Reset uphill pace"];
            case "FL": return ["Ease the pace a touch", "Bring it back a little", "Back off a touch", "Settle the pace", "One gear easier", "Take a breath", "Return to cruise", "Hold a little back", "Smooth it out", "Reset the pace"];
            case "DN": return ["Ease the downhill pace", "Hold a little back", "Back off downhill", "Dont spend the hill", "Take a little off", "Settle the descent", "Stay a touch calmer", "Keep some in hand", "Downhill one gear easy", "Bring it back"];
        }
        return ["Ease the pace", "Back it off", "Settle a bit", "Take a little off", "Return to cruise", "One gear easier", "Hold a bit back", "Bring it down", "Smooth it out", "Reset the pace"];
    }

    function _getEaseBothPoolEn(category, slopeKey) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY:
                switch (slopeKey) {
                    case "UP": return ["Climb got extra spicy", "Cool both dials down", "Hill turned too hot", "Back both off uphill", "Too much on both", "Settle the whole climb", "Take both down", "Calm both uphill", "Ease heat and pace", "Reset both here"];
                    case "FL": return ["Flat went full chili", "Reset pace and heat", "Flat is hot and fast", "Back both off", "Too much on both", "Settle the whole flat", "Bring both back", "Cool the whole effort", "Ease pace and heat", "Reset both now"];
                    case "DN": return ["Downhill had too much", "Back both off", "The drop got too hot", "Ease pace and strain", "Too much on both", "Settle the descent", "Bring both down", "Cool the whole drop", "Reset both downhill", "Calm both now"];
                }
            case CATEGORY_SALT:
                switch (slopeKey) {
                    case "UP": return ["Too much pace and strain", "Back both off", "Climb is too hot", "Take both down", "Too much on both", "Reset the whole climb", "Bring both back", "Ease speed and strain", "Settle both uphill", "Cool both now"];
                    case "FL": return ["Fast and hot now", "Bring both back", "Pace and heat are up", "Back both off", "Too much on both", "Settle both now", "Reset this effort", "Ease both down", "Cool the whole thing", "Take both down"];
                    case "DN": return ["Too much downhill", "Ease both down", "Drop is fast and hot", "Back both off", "Too much on both", "Settle the descent", "Bring both back", "Reset both now", "Cool the whole drop", "Take both down"];
                }
            case CATEGORY_ALCOHOL:
                switch (slopeKey) {
                    case "UP": return ["Climb is strong and hot", "Add water and back off", "Too much proof and heat", "Thin both down", "Water the climb now", "Take both lighter", "Less heat, less proof", "Ease the uphill mix", "Cool and thin it", "Bring both down"];
                    case "FL": return ["Flat got strong and warm", "Water it down now", "Too much proof and heat", "Thin both down", "Cool the flat blend", "Take both lighter", "Less heat, less proof", "Ease the whole mix", "Bring both down", "Water the effort"];
                    case "DN": return ["Downhill proof too hot", "Make both lighter", "Too much proof and heat", "Thin both down", "Cool the drop now", "Take both lighter", "Less heat, less proof", "Ease the descent mix", "Water the effort", "Bring both down"];
                }
            case CATEGORY_TOXIC:
                switch (slopeKey) {
                    case "UP": return ["Too hot to race smart", "Drop both now", "Climb is breaking you", "Back both off", "Too much speed and heat", "Reset the whole climb", "Take both down", "Ease pace and strain", "Cool both uphill", "Fix both now"];
                    case "FL": return ["Speed and heat sloppy", "Fix it now", "Too much on both", "Back both off", "Flat is hot and fast", "Reset the whole pace", "Take both down", "Ease speed and heat", "Cool this effort", "Bring both back"];
                    case "DN": return ["Burning matches downhill", "Back both off", "Too much on the drop", "Ease speed and strain", "Downhill is too hot", "Reset the descent", "Take both down", "Bring both back", "Cool this downhill", "Fix both now"];
                }
            case CATEGORY_PRAISE:
                switch (slopeKey) {
                    case "UP": return ["Smart save before pain", "Ease both a touch", "Strong uphill composure", "Great call to reset", "You protected both well", "Good calm decision", "That was smart control", "Nice restraint uphill", "Strong save there", "You handled it well"];
                    case "FL": return ["Strong call to reset both", "Good composure here", "Nice calm response", "That was smart control", "You handled both well", "Good call to settle", "Strong reset there", "Great steady choice", "Nice pace control", "Good calm reset"];
                    case "DN": return ["Great restraint early", "Ease both a touch", "Strong descent control", "Good call to settle", "You protected both well", "Nice downhill composure", "That was smart control", "Strong calm reset", "Good restraint there", "You handled it well"];
                }
            case CATEGORY_DIST:
                return [];
        }

        switch (slopeKey) {
            case "UP": return ["Climb is hot and fast", "Ease both pace and effort", "Too much uphill heat", "Settle both down", "Back both off uphill", "Speed and strain high", "Reset both dials", "Take both down", "Protect the climb", "Calm both now"];
            case "FL": return ["A bit fast and hot", "Settle both down", "Pace and heat are up", "Back both off", "Reset both now", "Too much in both", "Calm the whole effort", "Bring both back", "Smooth both out", "Ease speed and heat"];
            case "DN": return ["Downhill got too greedy", "Ease pace and effort", "Too much free speed", "Back both off", "Settle the whole effort", "Bring both down", "Dont burn it downhill", "Reset both on the drop", "Ease speed and strain", "Calm both now"];
        }
        return ["Settle both down", "Back both off", "Ease both now", "Take both down", "Calm both now", "Reset both here", "Bring both back", "Cool the effort", "Ease speed and heat", "Hold both lower"];
    }

    function _extractSlopeKey(stateKey) as Lang.String or Null {
        if (stateKey == null) {
            return null;
        }
        var keyText = stateKey.toString();
        if (keyText.length() < 2) {
            return null;
        }
        var slopeKey = keyText.substring(0, 2);
        if (_isSameText(slopeKey, "UP") or _isSameText(slopeKey, "FL") or _isSameText(slopeKey, "DN")) {
            return slopeKey;
        }
        return null;
    }

    function _hasSuffix(textValue, suffix) as Lang.Boolean {
        if (textValue == null or suffix == null) {
            return false;
        }
        var text = textValue.toString();
        var suffixText = suffix.toString();
        if (text.length() < suffixText.length()) {
            return false;
        }
        return text.substring(text.length() - suffixText.length(), text.length()).equals(suffixText);
    }

    function _getFuelPrepPoolJa(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY: return ["そろそろ補給", "次で入れよ", "補給が近い", "次の補給や", "ポケット出番", "そろそろ入れよ", "補給の順番や", "次は補給会議", "補給待機や", "そろそろ燃料"];
            case CATEGORY_SALT: return ["補給準備しよ", "次で入れるだけ", "今のうち持て", "補給まだか確認", "次は入れろ", "先に出しとけ", "手元を整えろ", "準備しとけ", "補給忘れるな", "次の段取りや"];
            case CATEGORY_ALCOHOL: return ["次は水と補給", "ちびっと入れよ", "次は一口や", "水割り準備", "補給を冷やそ", "次で薄めよ", "燃料と水や", "次は軽く入れ", "一口待機や", "次は給水や"];
            case CATEGORY_TOXIC: return ["補給を飛ばすな", "今のうちに準備", "次で入れろ", "手元を出せ", "準備して待て", "補給忘れるな", "先に構えろ", "次は補給や", "段取りしとけ", "持ち替え急げ"];
            case CATEGORY_PRAISE: return ["補給意識えらい", "準備できたら強い", "補給意識かなり良い", "先に準備が強い", "補給見れてえらい", "先回り上手い", "準備の丁寧さ", "補給まで見えてる", "その意識効く", "準備できて強い"];
            case CATEGORY_DIST: return [];
        }
        return ["次で補給やで", "補給の準備しよ", "そろそろ補給や", "次の補給を用意", "補給ポイント近いで", "今のうちに準備", "補給の手元確認", "次で入れる準備", "補給を思い出しとこ", "もうすぐ補給や"];
    }

    function _getFuelPrepPoolEn(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY: return ["Fuel turn coming", "Next one, dont forget", "Fuel is walking over", "Snack moment ahead", "Pocket food says hello", "Get the calories ready", "Next stop, fuel", "Your gel has a date", "Fuel is warming up", "Soon the snack cue"];
            case CATEGORY_SALT: return ["Get fuel ready", "Fuel prep now", "Have fuel in hand", "Set up the next fuel", "Be ready to take it", "Prep fuel early", "Line up the fuel", "Get the gel ready", "Fuel is your next job", "Set the fuel up"];
            case CATEGORY_ALCOHOL: return ["Water and fuel next", "Small sip and go", "Next stop, water", "Get the drink ready", "Fuel and water soon", "Ready the next sip", "Set up water and fuel", "Next comes a small sip", "Prep the next drink", "Water and gel soon"];
            case CATEGORY_TOXIC: return ["Dont skip the fuel", "Prep it now", "Get fuel in hand", "Set up the next fuel", "Be ready to eat", "Fuel is the next job", "Get the gel ready", "Line up the fuel", "Do the prep now", "Prepare that fuel"];
            case CATEGORY_PRAISE: return ["Nice fuel awareness", "Ready fuel, stay strong", "Great eye, nice and early", "Strong prep mindset", "Youre managing fuel well", "Nice early fuel setup", "That awareness is strong", "Good job preparing ahead", "Smart fuel discipline", "You set this up well"];
            case CATEGORY_DIST: return [];
        }
        return ["Fuel prep next", "Get fuel ready", "Fuel is coming", "Prep the next fuel", "Next fuel point soon", "Get ready to take fuel", "Fuel turn is close", "Soon it is fuel time", "Prepare the fuel now", "Ready fuel soon"];
    }

    function _getFuelNowPoolJa(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY: return ["今やで補給", "ここで入れよ", "ジェルの時間", "ここで放りこも", "補給さん本番", "今がモグモグ", "燃料投下や", "ここで回収や", "今こそ補給", "食べるなら今"];
            case CATEGORY_SALT: return ["今、補給", "入れないとあかん", "ここで入れろ", "今が補給所", "補給を優先", "今すぐ食え", "ここで回収や", "今が入れ時", "後では遅い", "ここで決めろ"];
            case CATEGORY_ALCOHOL: return ["今は水と補給", "ここで一口いこ", "今が水割り", "ここで入れよ", "今は給水や", "ここで流しこも", "今こそ一口", "補給と水や", "ここで薄めよ", "今が飲み時"];
            case CATEGORY_TOXIC: return ["補給しろ、今", "後回し禁止", "今すぐ入れろ", "ここで食え", "補給を飛ばすな", "今が最後や", "今ここでやれ", "入れずに行くな", "ここで決めろ", "今が補給時"];
            case CATEGORY_PRAISE: return ["ここで入れたら強い", "補給できたら完璧", "この補給大事や", "今入れられる強さ", "ここで整えたら完璧", "補給で流れ続く", "補給判断ええやん", "ここで入れる上手さ", "この一口が効く", "今ここで決めよ"];
            case CATEGORY_DIST: return [];
        }
        return ["今、補給しよ", "ここで補給や", "この時点で入れよ", "今が補給所", "ここは補給優先", "今ここで入れよ", "補給するなら今", "ここで補給しよ", "今のうちに入れよ", "ここで補給完了"];
    }

    function _getFuelNowPoolEn(category) as Lang.Array {
        switch (category) {
            case CATEGORY_FUNNY: return ["Fuel time now", "Take it right here", "Gel oclock now", "Snack window open", "Calories, stage left", "Time to feed the engine", "The gel is calling", "Take the tasty shortcut", "Fuel is on the mic", "This is the chew cue"];
            case CATEGORY_SALT: return ["Fuel now", "Dont skip this", "Take the fuel here", "Do the fuel now", "Eat now", "This is the fuel cue", "Take it right now", "Fuel this point", "Now, not later", "Get the fuel in"];
            case CATEGORY_ALCOHOL: return ["Water and fuel now", "Take a sip now", "Drink and fuel now", "Take the next sip", "Water now", "Fuel with water now", "Sip and go now", "Now is drink time", "Take water and fuel", "Drink here now"];
            case CATEGORY_TOXIC: return ["Take fuel now", "No more delay", "Do the fuel now", "Eat right now", "Take it here", "Fuel at this point", "Get it in now", "Now is the cue", "Stop delaying fuel", "Fuel, right now"];
            case CATEGORY_PRAISE: return ["Nail this fuel point", "Fuel now, stay strong", "Great time to fuel here", "This fuel move matters", "Strong runners take this", "You can lock this in now", "Fuel here, keep rolling", "Nice chance to stay sharp", "Take this and stay smooth", "Strong fuel call here"];
            case CATEGORY_DIST: return [];
        }
        return ["Fuel now", "Take fuel now", "Take the fuel here", "This is the fuel point", "Fuel at this moment", "Get the fuel in now", "Do the fuel now", "Take it right here", "Now is the fuel cue", "Fuel here, dont skip"];
    }
}
