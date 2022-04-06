function onCreate()
	doTweenColor('dadShading', 'dad', '6D7AD7', 0.001, 'linear');
	doTweenColor('gfShading', 'gf', '6D7AD7', 0.001, 'linear');
	doTweenColor('bfShading', 'boyfriend', '6D7AD7', 0.001, 'linear');
	doTweenColor('dancerShading', 'dancer', '6D7AD7', 0.001, 'linear');
	doTweenColor('carShading', 'fastCar', '6D7AD7', 0.001, 'linear');
	doTweenColor('limoShading', 'bgLimo', '6D7AD7', 0.001, 'linear');
	doTweenColor('goreShading', 'limoCorpse', '6D7AD7', 0.001, 'linear');
	doTweenColor('goreShadingTwo', 'limoCorpseTwo', '6D7AD7', 0.001, 'linear');

	-- dumb Countdown Sprites
	makeLuaSprite('ready', 'limoBG/ready', 0, 0);
	setObjectCamera('ready', 'hud');

	makeLuaSprite('readySmol', 'limoBG/readySmol', 0, 0);
	setObjectCamera('readySmol', 'hud');

	makeLuaSprite('set', 'limoBG/set', 0, 0);
	setObjectCamera('set', 'hud');

	makeLuaSprite('go', 'limoBG/go', 0, 0);
	setObjectCamera('go', 'hud');
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
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

function onBeatHit()
	if curBeat == 164 then
		addLuaSprite('ready', false);
	end
	if curBeat == 165 then
		addLuaSprite('readySmol', false);
	end
	if curBeat == 166 then
		addLuaSprite('set', false);
	end
	if curBeat == 167 then
		addLuaSprite('go', false);
	end
	if curBeat == 168 then
		doTweenAlpha('zzz', 'go', 0, 0.25, 'linear');
	end
end

function onStepHit()
	-- I typed this in at 3 am B)
	if curStep == 666 then
		doTweenAlpha('sex', 'set', 0, 0.25, 'linear');
	end
	if curStep == 658 then
		doTweenAlpha('yeet', 'ready', 0, 0.25, 'linear');
	end
	if curStep == 661 then
		doTweenAlpha('bcs', 'readySmol', 0, 0.25, 'linear');
	end
end

function onTweenCompleted(tag)
	if tag == 'yeet' then
		removeLuaSprite('ready', false);
	end
	if tag == 'sex' then
		removeLuaSprite('set', false);
	end
	if tag == 'zzz' then
		removeLuaSprite('go', false);
	end
	if tag == 'bcs' then
		removeLuaSprite('readySmol', false);
	end
end