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
	dialogueBg('black', false);

	setProperty('boppers.visible', true);

	setProperty("preventPCChange", true);
	setProperty("pauseCharacter", "dad");
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue');
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if count == 2 then
		dialogueBg('timeCards/45', false, true);
	end
	if count == 3 then
		dialogueBg('mall2');
	end
	if count == 16 then
		soundFadeOut('', 0.25, 0);
	end
	if count == 21 then -- 9 + 10
		dialogueBg('timeCards/45', false, true);
	end
	if count == 22 then
		dialogueBg('mall3');
		playMusic('confrontingAtTheMall', 1, true);
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

function onChristmasCountdown()
	playMusic('christmasShopping', 1, true);
	setProperty('inCutscene', true);
	runTimer('startDialogue', 0.8);
end

function opponentNoteHit(id, type, data, sus)
	if altSection then
		setProperty("pauseCharacter", "mom");
	else
		setProperty("pauseCharacter", "dad");
	end
end

function onStartCountdown()
	return Function_Continue;
end