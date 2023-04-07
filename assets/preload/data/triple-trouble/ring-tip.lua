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

local allowCountdown = false;
local inTip = false;
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene then
		setProperty('inCutscene', true);
		runTimer('tip', 0.8);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'tip' then -- Timer completed, play dialogue
		dialogueBg("tips/ring", false, true);
	end
end

function onUpdate(elapsed)
    if inTip then
        if keyJustPressed("accept") then
            inTip = false;
            playSound("exe/accept");
            cameraFlash("other", "FFFFFF", 1, true);
            bgAlpha(0, true, 1.5);
        end
    end
end

function onTweenCompleted(tag)
    if tag == "bgFade" then
        startCountdown();
    end
end