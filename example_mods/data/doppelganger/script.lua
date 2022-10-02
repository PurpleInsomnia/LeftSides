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
	if not allowCountdown and not seenCutscene then
		setProperty('inCutscene', true);
		runTimer('startDialogue', 0.8);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

local allowCountdown = false;
function onEndSong()
	if not allowCountdown then
		setProperty('inCutscene', true);
		runTimer('startAfterDialogue', 0.08);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

local isAfter = false;
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'rain');
	end
	if tag == 'startAfterDialogue' then -- Timer completed, play dialogue
		dialogueBg('black', true, false);
		loadDialogue('dialogueAfter');
		playMusic('rain', 1, true);
		isAfter = true;
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	if count == 7 and not isAfter then
		dialogueBg('timeCards/5min', false, true);
	end
	if count == 8 and not isAfter then
		dialogueBg('black');
	end
	if count == 4 and isAfter then
		soundFadeOut('', 0.5, 0);
		dialogueBg('timeCards/wakeUp', false, true);
	end
	if count == 5 and isAfter then
		dialogueBg('couch1');
	end
	if count == 15 and isAfter then
		dialogueBg('timeCards/glitch', false, true);
	end
	if count == 16 and isAfter then
		dialogueBg('couch1');
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

function onDialogueComplete(tag)
	if tag == 'dialogueAfter' then
		dialogueBg('black', false, true);
		startVideo('HESPULLINGHISCOCKOU');
	end
end

function onCreate()
	dialogueBg('black');
end

function onCountdownTick(counter)
	if counter == 0 then
		setProperty("camHUD.alpha", 0);
		bgAlpha(0, true, 1);
	end
end

function onStepHit()
	if curStep == 1 then
		setProperty("camHUD.alpha", 1);
	end
end