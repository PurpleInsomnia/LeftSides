-- you can use this in your mods, just leave this last comment in if you do.
-- Dialogue Bg script by PurpleInsomnia
local loaded = false;
local dialogueBg = function (bg, tween, other)
	if loaded then
		removeLuaSprite('dialogueBg', true);
	end
	makeLuaSprite('dialogueBg', 'dialogueBgs/' .. bg, 0, 0);
	if other then
		setObjectCamera('dialogueBg', 'camOther');
	else
		setObjectCamera('dialogueBg', 'camHUD');
	end
	addLuaSprite('dialogueBg', false);
	setProperty('dialogueBg.alpha', 0);
	if tween then
		doTweenAlpha('tweenIsTrue', 'dialogueBg', 1, 1, 'linear');
	else
		setProperty('dialogueBg.alpha', 1);
	end
	loaded = true;
end

local bgAlpha = function (val, tween, sec)
	if tween then
		doTweenAlpha('bgFade', 'dialogueBg', val, sec, 'linear');
	else
		setProperty('dialogueBg.alpha', val);
	end
end

local created = false;
function onCreatePost()
	setProperty("health", 2);

	-- hide tess
	setProperty("gf.visible", false);

	--makeLuaSprite("bfIcon", "encore/monster/bfIcon", 0, 0);

	--loadGraphic("bfIcon", "encore/monster/bfIcon", true, 150, 150);
	--addGraphicAnimation("bfIcon", "idle", "0", 1, true);
	--addGraphicAnimation("bfIcon", "dying", "1", 1, true);
	--addGraphicAnimation("bfIcon", "death", "2", 1, true);
	--objectPlayAnimation("bfIcon", "idle", true);

	--setObjectCamera("bfIcon", "camHUD");
	--setProperty("bfIcon.y", getProperty("healthBarBG.y") - 75);
	--setProperty("bfIcon.x", (getProperty("healthBarBG.x") + getProperty("healthBarBG.width")) - 75);
	--setProperty("bfIcon.angle", -2);
	--setProperty("bfIcon.alpha", 0);
	--addLuaSprite("bfIcon", true);

	makeLuaSprite("monsterVG", "encore/monster/vg", 0, 0);
	setObjectCamera("monsterVG", "camHUD");
	setProperty("monsterVG.alpha", 0);
	addLuaSprite("monsterVG", true);

	doTweenAlpha("monsterTextAlpha", "text", 0.5, 1, "sineInOut:pingpong");
	
	setProperty("customScoreTxt", true);

	makeWiggleEffect('camera|camhud', 'dreamy', 1, 10, 0.005);
	created = true;

	setFCRanks("[FLAWLESS]", "[LOSER]", "[BURDEN]");
end

local setAlpha = 0;
local funny = 2;
function calculateAlpha()
	setAlpha = ((getProperty("health") * -1) + 2) * 0.5;
end

function updateScoreTxt()
	ratingThing = ratingFC;
	setProperty("scoreTxt.text", "[MISTAKES] Left: " .. ((misses * -1) + 40) .. " | Score: " .. (score * -1) .. " | " .. ratingThing);
end

function onUpdate(elapsed)
	calculateAlpha();
	setProperty("monsterVG.alpha", setAlpha);
	funny = getProperty("health");
	updateScoreTxt();

	-- the icon system from wish be like:
	if getProperty("songMisses") < 40 then
		if funny > 1 then
			objectPlayAnimation("bfIcon", "idle", true);
		else
			objectPlayAnimation("bfIcon", "dying", true);
		end
	else
		objectPlayAnimation("bfIcon", "death", true);
	end

	if not funny <= 0.1 then
		setProperty("health", funny - 0.01);
	end

	if created then
		moveWiggleEffect(elapsed);
	end
end

function onUpdatePost(elapsed)
	updateScoreTxt();
	if created then
		moveWiggleEffect(elapsed);
	end
end

function onEvent(name, v1, v2)
	if name == "Add Dialogue Bg" then
		dialogueBg(v1);
	end
end

function onCountdownTick(counter)
	if counter == 2 then
		triggerEvent('Alt Idle Animation', 'boyfriend', '-alt');
		characterPlayAnim("boyfriend", "flip-hat", true);
	end
end

function onEndSong()
	if getProperty("monsterVG.visible") then
		setProperty("monsterVG.visible", false);
	end
end