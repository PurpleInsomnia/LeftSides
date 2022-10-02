-- you can use this in your mods, just leave this last comment in if you do.
-- Dialogue Bg script by PurpleInsomnia
local loaded = false;
local dialogueBg = function (bg, tween, other)
	if loaded then
		removeLuaSprite('dialogueBg', true);
	end
	makeLuaSprite('dialogueBg', bg, 0, 0);
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

function onCreate()
	dialogueBg('dialogueBgs/couch1', false, false);
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
	if not allowCountdown and isStoryMode then
		setProperty('inCutscene', true);
		runTimer('startAfterDialogue', 0.08);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

local isAfter = false;
local isSex = true;
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		loadDialogue('sex');
	end
	if tag == 'startAfterDialogue' then -- Timer completed, play dialogue
		startAfterDialogue('dialogueAfter');
		isAfter = true;
	end
	if tag == 'men' then
		isSex = false;
		loadDialogue('preDialogue', 'spooky3');
		bgAlpha(0, false, 0);
	end
	if tag == 'cutscene' then
		startDialogue('dialogue', 'spooky5');
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 2 and isSex then
		dialogueBg('dialogueBgs/timeCards/sexy', false, true);
	end
	if count == 3 and isSex then
		bgAlpha(0, false, 0);
		dialogueBg('dialogueBgs/bfRoomNight');
		playMusic('violetTrance', 0.5, true);
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

function onDialogueComplete(tag)
	if tag == 'sex' then
		dialogueBg('black', false, true);
		soundFadeOut('', 5, 0);
		runTimer('men', 5);
	end
	if tag == 'preDialogue' then
		bgAlpha(0, true, 0.5);
		doCutscene();
	end
end

function doCutscene()
	runTimer('cutscene', 7);
end