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

function onMonsterCutsceneDone()
	startDialogue('dialogue', 'spooky5');
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
local isGaming = false;
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startAfterDialogue' then -- Timer completed, play dialogue
		doTweenAlpha('blackScreenAlpha', 'blackScreen', 1, 0.5, 'linear');
		removeLuaSprite('poisonIndicator', false);
		loadDialogue('dialogueAfter');
		isAfter = true;
		if bruh and not tpm then
			setPropertyFromClass('ClientPrefs', 'middleScroll', false);
		end
	end
end

function onDialogueComplete(tag)
	if tag == 'dialogueAfter' then
		isAfter = false;
		startAfterDialogue('gaming');
		dialogueBg('timeCards/bus', false, true);
		isGaming = true;
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 29 and not isAfter then
		dialogueBg('tips/ice', false, true);
	end
	if count == 5 and isAfter then
		doTweenAlpha('ddlcMoment', 'hug', 1, 0.7, 'linear');
		playMusic('thisIsSoSad', 1, true);
	end
	if count == 14 and isAfter then
		removeLuaSprite('hug', false);
		soundFadeOut('', 0.25, 0);
	end
	if count == 18 and isAfter then
		dialogueBg('timeCards/5min', false, true);
		playMusic('coupleChillout', 1, true);
		dialogueBg('timeCards/5min', false, true);
	end
	if count == 19 and isAfter then
		dialogueBg('dialogueBgs/none');
		doTweenAlpha('ddlcBgMoment', 'outsideMall', 1, 0.7, 'linear');
	end
	if count == 27 and isAfter then
		removeLuaSprite('outsideMall', false);
		playMusic('thisIsSoSad', 1, true);
	end
	if count == 1 and isGaming then
		dialogueBg('couch1');
	end
	if count == 7 and isGaming then
		dialogueBg('timeCards/4min', false, true);
	end
	if count == 8 and isGaming then
		dialogueBg('couch1');
	end
	if count == 13 and isGaming then
		dialogueBg('timeCards/10min', false, true);
	end
	if count == 14 and isGaming then
		dialogueBg('couch1');
	end
	if count == 15 and isGaming then
		dialogueBg('couch2');
		playSound('rest');
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

local isMonster = true;
function onCreate()
	isMonster = true;

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

	setProperty("skipCountdown", true);

	if not middlescroll and not tpm then
		setPropertyFromClass('ClientPrefs', 'middleScroll', true);
		bruh = true;
	end
end

function onCountdownTick(counter)
	if counter == 0 then
		bgAlpha(0, true, 1);
	end
	if counter == 3 then
		doTweenAlpha('poisonOn', 'poisonIndicator', 1, 1, 'linear');
		playSound('poisonTrigger');
	end
end
