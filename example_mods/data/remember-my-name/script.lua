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

function onCountdownTick(counter)
	if counter == 0 then
		bgAlpha(0, true, 1);
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
		startDialogue('dialogue', 'no-music');
	end
	if tag == 'startAfterDialogue' then -- Timer completed, play dialogue
		dialogueBg('black', true, false);
		startAfterDialogue('dialogueAfter', 'no-music');
		isAfter = true;
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end


local bfX = 0;
local gfX = 0;
function onCreate()
	dialogueBg('black', false, false);

	bfX = getProperty('boyfriend.x');
	gfX = getProperty('gf.x');

	makeLuaSprite('blackThing', 'black', 0, 0);
	setObjectCamera('blackThing', 'hud');
	setProperty('blackThing.alpha', 0);
	addLuaSprite('blackThing', false);
end

function onStepHit()
	if curStep == 511 then
		doTweenAlpha('blackThing', 'blackThing', 1, 6.19, 'linear');
		doTweenX('benLeaves', 'boyfriend', bfX + 1440, 6.39, 'sineIn');
		doTweenX('tessLeaves', 'gf', gfX + 1440, 6.39, 'sineIn');
	end
	if curStep == 621 then
		setProperty('blackThing.alpha', 0);
	end
	if curStep == 636 then
		setProperty('boyfriend.x', bfX);
		setProperty('gf.x', gfX);	
	end
end