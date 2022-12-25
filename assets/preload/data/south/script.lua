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

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'spooky2');
	end
end

-- Dialogue (When a dialogue is finished, it calls startCountdown again)
function onNextDialogue(count)
	-- triggered when the next dialogue line starts, 'line' starts with 1
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

function onCreate()
	makeLuaSprite('funnyEffect', 'black', 0, 0);
	setObjectCamera('funnyEffect', 'camHUD');
	setProperty('funnyEffect.alpha', 0);
	addLuaSprite('funnyEffect', true);
end

function onStepHit()
	if curStep == 832 then
		doTweenAlpha('sussssssssssyyyyy', 'funnyEffect', 0.5, 5.81, 'linear');
		triggerEvent("Can Tween Zoom", "1.15", "5.81");
		triggerEvent("Screen VG", "5.81", "5.81");
	end
end

function onTweenCompleted(tag)
	if tag == "sussssssssssyyyyy" then
		setProperty("funnyEffect.alpha", 1);
	end
end