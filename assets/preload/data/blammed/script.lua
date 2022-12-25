-- you can use this in your mods, just leave this last comment in if you do.
-- Dialogue Bg script by PurpleInsomnia
local loaded = false;
local inScene = false;
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

local allowCountdown = false
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
		inScene = true;
		award(6, 'You finished Week 3!', 'pico');
		runTimer('startAfterDialogue', 0.08);
		dialogueBg('dialogueBgs/pico2');
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

local isAfter = false;
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'hired-mercenary');
	end
	if tag == 'startAfterDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogueAfter', 'no-music');
		dialogueBg('dialogueBgs/black', true, false);
		isAfter = true;
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 5 and isAfter then
		playSound('dialogueSounds/gunCLICK');
	end
	if count == 19 and isAfter then
		dialogueBg('timeCards/5min', false, true);
	end
	if count == 20 and isAfter then
		dialogueBg('tower');
	end
	if count == 32 and isAfter then
		dialogueBg('timeCards/elevator', false, true);
	end
	if count == 33 and isAfter then
		playMusic('coupleChillout', 1, true);
		dialogueBg('pico3');
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

function onCreate()
	dialogueBg('black');
end

function onCountdownTick(counter)
	if counter == 0 then
		seenCutscene = false;
		bgAlpha(0, true, 0.5); 
	end
end
