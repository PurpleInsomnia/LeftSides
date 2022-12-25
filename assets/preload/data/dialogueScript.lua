function onCreate()
	makeLuaSprite('skip', 'dialogueTip', 0, 0);
	setObjectCamera('skip', 'other');
	setProperty('skip.alpha', 0);
	addLuaSprite('skip', false);

	-- i need a timer because this is poopoo
	runTimer('alphaHud', 0.001);
end

function onDialogueOpen()
	setProperty('dialogueCount', 0);
	setProperty('skip.alpha', 1);
	setProperty('healthBar.alpha', 0);
	setProperty("barBG.alpha", 0);
	setProperty('iconP1.alpha', 0);
	setProperty('iconP2.alpha', 0);
	setProperty("scoreTxt.alpha", 0);
	setProperty('strumLine.alpha', 0);
	doTweenAlpha('asshole3', 'camHUD', 1, 0.0001, 'linear');
end

function onCountdownTick(counter)
	if counter == 0 then
		doTweenAlpha('asshole2', 'skip', 0, 0.001, 'linear');
		doTweenAlpha('asshole3', 'camHUD', 1, 1, 'linear');
		doTweenAlpha('asshole4', 'healthBar', 1, 1, 'linear');
		doTweenAlpha('asshole5', 'iconP1', 1, 1, 'linear');
		doTweenAlpha('asshole6', 'iconP2', 1, 1, 'linear');
		doTweenAlpha('asshole7', 'strumLine', 1, 1, 'linear');
		doTweenAlpha('asshole8', 'barBG', 1, 1, 'linear');
		doTweenAlpha('asshole9', 'scoreTxt', 1, 1, 'linear');
		seenCutscene = false;
	end
end

function onNextDialogue(count)
	if count > 0 then
		removeLuaSprite('skip', true);
	end
	doTweenAlpha('fard', 'button', 0.25, 0.2, 'linear');
	setProperty('healthBar.alpha', 0);
	setProperty('iconP1.alpha', 0);
	setProperty('iconP2.alpha', 0);
	setProperty("barBG.alpha", 0);
	setProperty("scoreTxt.alpha", 0);
	setProperty('strumLine.alpha', 0);
	-- oh boy...
end

function onDestroy()
	setPropertyFromClass('Alphabet', 'textSound', 'dialogue');
end

function bgAlpha(val, tween, sec)
	if tween then
		doTweenAlpha('bgFade', 'dialogueBg', val, sec, 'linear');
	else
		setProperty('dialogueBg.alpha', val);
	end
end

function onTweenCompleted(tag)
	if tag == 'bgFade' then
		removeLuaSprite('dialogueBg', true);
	end
end

-- endsong shit bc
function onEndSong()
	setProperty('iconP1.alpha', 0);
	setProperty('iconP2.alpha', 0);
	setProperty("barBG.alpha", 0);
	setProperty("scoreTxt.alpha", 0);
	setProperty('strumLine.alpha', 0);
end

function onTimerCompleted(tag)
	if tag == 'alphaHud' then
		setProperty('iconP1.alpha', 0);
		setProperty('iconP2.alpha', 0);
		setProperty("barBG.alpha", 0);
		setProperty("scoreTxt.alpha", 0);
		setProperty('strumLine.alpha', 0);
	end
end