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

function onCreate()
	-- its that simple to kill the car :skull:
	setProperty('fastCar.active', false);
	setProperty('fastCarCanDrive', false);

	-- this one dumb city lmao
	-- skyX = getProperty('skyBG.x');
	-- skyY = getProperty('skyBG.y');
	-- these vals wouldn't work :(

	-- dialouge bgs
	dialogueBg('limoAlt', false, false);
end

function onStepHit()
	if curStep == 1055 then
		doTweenColor('dadShading', 'dad', '6D7AD7', 0.001, 'linear');
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
		runTimer('startAfterDialogue', 0.08);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

local isAfter = false;
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'no-music');
	end
	if tag == 'startAfterDialogue' then -- Timer completed, play dialogue
		startAfterDialogue('dialogueAfter', 'no-music');
		dialogueBg('dialogueBgs/black', true, false);
		isAfter = true;
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 23 and not isAfter then
		-- playMusic('mommyIntense', 0.5);
		-- meh
	end
	if count == 15 and isAfter then
		dialogueBg('timeCards/nextDay', false, true);
	end
	if count == 16 and isAfter then
		dialogueBg('bfRoom');
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

function onCountdownTick(counter)
	if counter == 0 then
		bgAlpha(0, true, 1);
	end
end
