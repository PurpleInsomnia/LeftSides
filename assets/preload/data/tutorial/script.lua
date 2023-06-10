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
		runTimer('startDialogue', 0.08);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

local allowCountdown = false;
function onEndSong()
	if not allowCountdown and isStoryMode then
		setProperty('inCutscene', true);
		award(3, 'You finished the tutorial!', 'gf');
		runTimer('startAfterDialogue', 0.08);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

function onDialogueComplete(tag)
	if tag == 'hmu' then
		dialogueBg('timeCards/40min', false, true);
		runTimer('startVideo', 2);
	end
end

local isAfter = false;
local hmu = false;
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then
		hmu = true;
		loadDialogue('hmu');
		makeLuaSprite('pressEnter', 'pressHint', 0, 0);
		setObjectCamera('pressEnter', 'other');
		addLuaSprite('pressEnter', true);
		playSound('dialogueSounds/phoneNotification');
	end
	if tag == 'startVideo' then
		hmu = false;
		playMusic('littleStroll', 0.8, true);
		dialogueBg('black');
		coolVideo('Tutorial');
	end
	if tag == 'startDialogueReal' then -- Timer completed, play dialogue
		startDialogue('dialogue');
	end
	if tag == 'startAfterDialogue' then -- Timer completed, play dialogue
		dialogueBg('black', true, false);
		startAfterDialogue('dialogueAfter');
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 1 and hmu then
		dialogueBg('bfRoom');
		removeLuaSprite('pressEnter', true);
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

function onVideoDone()
	runTimer('startDialogueReal', 0.08);
end

function onCreate()
	if not encoreMode then
		changeIconP1('bf-nervous');
	end

	dialogueBg('black', false, true);

	precacheSound('dialogueSounds/phoneNotification');
end

function onEvent(name, val1, val2)
	if name == "Hey!" and val1 == "BF" then
		if not encoreMode then
			setProperty("dad.animSuffix", "");
			changeIconP1('bf');
			triggerEvent("Alt Idle Animation", "boyfriend", "-alt");
		end
	end
end

function onCountdownTick(counter)
	if counter == 0 then
		bgAlpha(0, true, 1);
		setProperty("bfZoom", false);
		if not encoreMode then
			setProperty("dad.animSuffix", "-direction");
		end
	end
end
