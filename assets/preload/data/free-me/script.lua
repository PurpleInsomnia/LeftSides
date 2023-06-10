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
		if encoreMode then
			removeWiggleEffect(0);
		end
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
		dialogueBg('spooky');
		startAfterDialogue('dialogueAfter', 'no-music');
		isAfter = true;
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 24 and not isAfter then
		dialogueBg('tips/killYourself', false, true);
	end
	if count == 19 and isAfter then
		dialogueBg('timeCards/5min', false, true);
	end
	if count == 20 and isAfter then
		playMusic('littleStroll', 1, true);
		dialogueBg('black');
	end
	if count == 32 and isAfter then
		playMusic('thisIsSoSad', 1, true);
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

function onCreate()
    makeLuaSprite('static','week2/static', -380, -90);
   	scaleLuaSprite('static', 10, 10);
   	addLuaSprite('static', true);
    setPropertyLuaSprite('static', 'alpha', 0);

	setObjectCamera('static', 'hud');

	setPropertyFromClass('GameOverSubstate', 'loopSoundName', 'shadowGameOver');
	setPropertyFromClass('GameOverSubstate', 'endSoundName', 'shadowEnd');

	dialogueBg('spookyAlt');

	if not encoreMode then
		setProperty('iconP2.visible', false);
	end
end

local canHit = false;
function opponentNoteHit(id, type, data, sus)
	if canHit and not sus then
   		health = getProperty('health')
    		setProperty('health', health - 0.01);
    		if health < 0.05 then
			setProperty('health',0.05);
    		end
		dumbRandom = math.floor(math.random(1,20));
	end
end

function onLengthSet()
	-- hee hee
	if not encoreMode then
		setLength(37500);
	end
end

function onBeatHit()
	if curBeat == 72 then
		if not encoreMode then
			triggerEvent('Real Time', '2.5', '');
			healthTween(2.5, 1);
			-- Reset Score ;)
			scoreTween(2.5);
			hitTween(2.5);
			missTween(2.5);
		end
	end
	if curBeat == 75 then
		-- funkyIcons();
	end
	if curBeat == 79 then
		canHit = true;
		if not encoreMode then
			setProperty('iconP2.visible', true);
		end
	end
end

local startDeath = false;
local funnyHealth = 0;
function onUpdate(elapsed)
	if getProperty("songMisses") == 40 then
		healthTween(2.5, 0);
	end
end

function onCountdownTick(counter)
	if counter == 0 then
		bgAlpha(0, true, 1);
	end
end