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
		runTimer('startAfterDialogue', 0.08);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

local isAfter = false;
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'spooky3');
		playSound('dialogueSounds/freeme');
	end
	if tag == 'startAfterDialogue' then -- Timer completed, play dialogue
		dialogueBg('dialogueBgs/spooky');
		startAfterDialogue('dialogueAfter', 'no-music');
		isAfter = true;
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 19 and isAfter then
		dialogueBg('dialogueBgs/timeCards/5min', false, true);
	end
	if count == 20 and isAfter then
		playMusic('littleStroll', 1, true);
		dialogueBg('dialogueBgs/black');
	end
	if count == 30 and isAfter then
		playMusic('thisIsSoSad', 1, true);
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

local bruh = false;
local isFree = true;
function onCreate()
    	makeLuaSprite('static','week2/static', -380, -90);
   	scaleLuaSprite('static', 10, 10);
   	addLuaSprite('static', true);
    	setPropertyLuaSprite('static', 'alpha', 0);

	setObjectCamera('static', 'hud');

	setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'shadowGameOver');
	setPropertyFromClass('GameOverSubstate', 'endSoundName', 'shadowEnd');
	
	if not middlescroll then
		setPropertyFromClass('ClientPrefs', 'middleScroll', true);
		bruh = true;
	end

	dialogueBg('dialogueBgs/spookyAlt');

	doTweenColor('bfShading', 'boyfriend', '5F5F5F', 0.001, 'linear');
	doTweenColor('dadShading', 'dad', '5F5F5F', 0.001, 'linear');
	doTweenColor('gfShading', 'gf', '5F5F5F', 0.001, 'linear');
end

function opponentNoteHit()
   	health = getProperty('health')
    	setProperty('health', health- 0.01);
    	if health < 0.02 then
		setProperty('health',0.02);
    	end
	dumbRandom = math.floor(math.random(1,20));
end

local outerInt = 200;
local innerInt = 100;
function onCountdownTick(counter)
	if counter == 3 then
		isWalt = true;
		doTweenZoom('jessePinkman', 'camGame', 1.1, 0.5, 'linear');
		noteTweenX('cum', 4, defaultPlayerStrumX0 - outerInt, 1.5, 'linear');
		noteTweenX('cum1', 5, defaultPlayerStrumX1 - innerInt, 1.5, 'linear');
		noteTweenX('cum2', 6, defaultPlayerStrumX2 + innerInt, 1.5, 'linear');
		noteTweenX('cum3', 7, defaultPlayerStrumX3 + outerInt, 1.5, 'linear');
	end
end

local startDeath = false;
function onUpdate(elapsed)
   misses = getProperty('songMisses');
   if misses == 20 and not startDeath then
	startDeath = true;
        doTweenAlpha('bfFuckingDies', 'static', 1, 15, 'linear');
	playSound('dieStatic');
	changeIconP2('freeme-alt');
   end
end

function onTweenCompleted(tag)
	if tag == 'bfFuckingDies' then
		setProperty('health', 0);
		playSound('shadowLaugh');
		soundFadeOut('', 0.25, 0);
	end
	if tag == 'cum' then
		noteTweenX('sussy', 4, defaultPlayerStrumX0, 1.5, 'linear');
		noteTweenX('sussy1', 5, defaultPlayerStrumX1, 1.5, 'linear');
		noteTweenX('sussy2', 6, defaultPlayerStrumX2, 1.5, 'linear');
		noteTweenX('sussy3', 7, defaultPlayerStrumX3, 1.5, 'linear');
	end
	if tag == 'shit' then
		noteTweenX('sussy', 4, defaultPlayerStrumX0, 1.5, 'linear');
		noteTweenX('sussy1', 5, defaultPlayerStrumX1, 1.5, 'linear');
		noteTweenX('sussy2', 6, defaultPlayerStrumX2, 1.5, 'linear');
		noteTweenX('sussy3', 7, defaultPlayerStrumX3, 1.5, 'linear');
	end
	if tag == 'sussy' then
		noteTweenX('cum', 4, defaultPlayerStrumX0 - outerInt, 1.5, 'linear');
		noteTweenX('cum1', 5, defaultPlayerStrumX1 - innerInt, 1.5, 'linear');
		noteTweenX('cum2', 6, defaultPlayerStrumX2 + innerInt, 1.5, 'linear');
		noteTweenX('cum3', 7, defaultPlayerStrumX3 + outerInt, 1.5, 'linear');
		doTweenAlpha('shit', 'boyfriend', 1, 0, 'linear');
	end
end

function onStepHit()
	dumbRandom = math.floor(math.random(1,20));
	if curStep == 1040 then
		doTweenAlpha('noMoreFortnite', 'camHUD', 0, 2.5, 'linear')
	end
end

function onBeatHit()
	dumbRandom = math.floor(math.random(1,20));
	if dumbRandom == 2 then
		-- triggerEvent('Jumpscare', 0, 0);
	end
end

function onCountdownTick(counter)
	if counter == 0 then
		bgAlpha(0, true, 1);
	end
end

function onDestroy()
	if bruh then
		setPropertyFromClass('ClientPrefs', 'middleScroll', false);
	end
	isFree = false;
end
