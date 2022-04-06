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

function onMonsterCutsceneDone()
	if difficulty == 0 then
		startDialogue('dialogueEasy', 'spooky5');
	end
	if difficulty == 1 then
		startDialogue('dialogue', 'spooky5');
	end
	if difficulty == 2 then
		startDialogue('dialogueFucked', 'spooky5');
	end
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
	if tag == 'startAfterDialogue' then -- Timer completed, play dialogue
		doTweenAlpha('blackScreenAlpha', 'blackScreen', 1, 0.5, 'linear');
		removeLuaSprite('poisonIndicator', false);
		startAfterDialogue('dialogueAfter', 'no-music');
		isAfter = true;
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 5 and isAfter then
		doTweenAlpha('ddlcMoment', 'hug', 1, 0.7, 'linear');
		playMusic('thisIsSoSad', 1, true);
	end
	if count == 14 and isAfter then
		removeLuaSprite('hug', false);
		soundFadeOut('', 0.25, 0);
	end
	if count == 18 and isAfter then
		dialogueBg('dialogueBgs/timeCards/5min', false, true);
		playMusic('coupleChillout', 1, true);
	end
	if count == 19 and isAfter then
		dialogueBg('dialogueBgs/none');
		doTweenAlpha('ddlcBgMoment', 'outsideMall', 1, 0.7, 'linear');
	end
	if count == 30 and isAfter then
		removeLuaSprite('outsideMall', false);
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

local isMonster = true;
function onCreate()
	isMonster = true;
	makeLuaSprite('gfIsDead', 'lemon-man/ripBozo', 600, 530);
	addLuaSprite('gfIsDead', true);

	-- Funny Poison Thing

	makeLuaSprite('poisonIndicator', 'lemon-man/poison', 0, 0);
	setObjectCamera('poisonIndicator', 'hud');
	setPropertyLuaSprite('poisonIndicator', 'alpha', 0);
	addLuaSprite('poisonIndicator', true);

	changeIconP1('bf-monster');

	makeLuaSprite('blackScreen', 'black', 0, 0);
	setObjectCamera('blackScreen', 'hud');
	addLuaSprite('blackScreen', false);

	makeLuaSprite('hug', 'dialogueBgs/mall3', 0, 0);
	setObjectCamera('hug', 'hud');
	addLuaSprite('hug', false);

	makeLuaSprite('5min', 'dialogueBgs/timeCards/5min', 0, 0);
	setObjectCamera('5min', 'other');

	makeLuaSprite('outsideMall', 'dialogueBgs/mall4', 0, 0);
	setObjectCamera('outsideMall', 'hud');
	addLuaSprite('outsideMall', false);

	setProperty('blackScreen.alpha', 0);
	setProperty('hug.alpha', 0);
	setProperty('outsideMall.alpha', 0);
	setProperty('5min.visible', false);
end

local isPoison = true;
function onBeatHit()
	if isPoison then
		health = getProperty('health');
		setProperty('health', health- 0.03);
		if health < 0.12 then
			setProperty('health', 0.1);
		end
	end
end

function onUpdate(elapsed)
	if misses == 20 then
		setProperty('health', 0);
	end
end

function onStepHit()
	if curStep == 100 then
		isPoison = false;
		doTweenAlpha('poisonOff', 'poisonIndicator', 0.5, 0.5, 'linear');
	end
	if curStep == 351 then
		isPoison = true;
		doTweenAlpha('poisonOn', 'poisonIndicator', 1, 0.5, 'linear');
		playSound('poisonTrigger');
		changeIconP1('bf-monster-alt');
	end
		if curStep == 735 then
		isPoison = false;
		doTweenAlpha('poisonOff', 'poisonIndicator', 0.5, 0.5, 'linear');
	end
	if curStep == 864 then
		isPoison = true;
		doTweenAlpha('poisonOn', 'poisonIndicator', 1, 0.5, 'linear');
		playSound('poisonTrigger');
	end
	if curStep == 1248 then
		isPoison = false;
		doTweenAlpha('poisonOff', 'poisonIndicator', 0.5, 0.5, 'linear');
	end
end

function onCountdownTick(counter)
	if counter == 3 then
		doTweenAlpha('poisonOn', 'poisonIndicator', 1, 1, 'linear');
		playSound('poisonTrigger');
	end
end
