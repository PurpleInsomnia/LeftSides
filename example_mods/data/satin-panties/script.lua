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
	doTweenColor('dadShading', 'dad', '6D7AD7', 0.001, 'linear');
	doTweenColor('gfShading', 'gf', '6D7AD7', 0.001, 'linear');
	doTweenColor('bfShading', 'boyfriend', '6D7AD7', 0.001, 'linear');
	doTweenColor('dancerShading', 'dancer', '6D7AD7', 0.001, 'linear');
	doTweenColor('carShading', 'fastCar', '6D7AD7', 0.001, 'linear');
	doTweenColor('limoShading', 'bgLimo', '6D7AD7', 0.001, 'linear');
	doTweenColor('goreShading', 'limoCorpse', '6D7AD7', 0.001, 'linear');
	doTweenColor('goreShadingTwo', 'limoCorpseTwo', '6D7AD7', 0.001, 'linear');

	dialogueBg('dialogueBgs/limo', false, false);
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

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'mommy');
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 6 then
		dialogueBg('dialogueBgs/timeCards/half', false, true);
	end
	if count == 7 then
		dialogueBg('dialogueBgs/limo');
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