function onCreatePost()
	if not allowCountdown and isStoryMode and not seenCutscene then
 		setProperty("dad.alpha", 0);
	end

	makeLuaSprite("wutduhhelllllllllllllllllll", "ron/bruh", 0, 0);
	setObjectCamera("wutduhhelllllllllllllllllll", "camHUD");
	setProperty("wutduhhelllllllllllllllllll.alpha", 0);
	addLuaSprite("wutduhhelllllllllllllllllll", false);
end

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
function onStartCountdown()
	if not allowCountdown and isStoryMode and not seenCutscene then
		setProperty('inCutscene', true);
		runTimer('startDialogue', 0.8);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

local allowCountdown = false;
function onEndSong()
	if not allowCountdown and isStoryMode then
		setProperty('inCutscene', true);
		award(23, 'You finished Week 7!', 'ron');
		runTimer('startAfterDialogue', 0.08);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

function goofyahh()
    if getProperty("inCutscene") then
        runTimer("goofy ahh", 1);
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		loadDialogue('doyouknowwhoelse');
	end
	if tag == 'startDialogue2' then
		startDialogue('dialogue', 'ron');
	end
    if tag == "startAfterDialogue" then
        dialogueBg("black", true);
        startAfterDialogue("help", "ron");
    end
    if tag == "goofy ahh" then
        setProperty("dad.alpha", 1);
        playSound("ronAppear");
        runTimer("startDialogue2", 1.25);
    end
end

function onCountdownTick(counter)
	if counter == 0 then
		bgAlpha(0, true, 1);
	end
end

function onDialogueComplete(tag)
	if tag == 'doyouknowwhoelse' then
		cameraSetTarget("dad");
        goofyahh();
	end
end

function onStepHit()
	if curStep == 122 then
		masonTroyAdams();
	end
end

function masonTroyAdams()
    setProperty("wutduhhelllllllllllllllllll.alpha", 1);
    doTweenAlpha("certified", "wutduhhelllllllllllllllllll", 0, 0.5, "linear");
end