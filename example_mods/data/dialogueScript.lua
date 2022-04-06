function onCreate()
	makeAnimatedLuaSprite('button', 'button_press', 1152, 592);
	addAnimationByPrefix('button', 'idle', 'button', 24, true);
	setObjectCamera('button', 'other');
	addLuaSprite('button', true);
	setProperty('button.visible', false);

	makeLuaSprite('skip', 'dialogueTip', 0, 0);
	setObjectCamera('skip', 'other');
	setProperty('skip.alpha', 0)
	-- addLuaSprite('skip', true);

	-- i need a timer because this is poopoo
	runTimer('alphaHud', 0.001);
end

function onDialogueOpen()
	setProperty('dialogueCount', 0);
	setProperty('button.visible', true);
	setProperty('button.alpha', 1);
	setProperty('skip.alpha', 1);
	setProperty('healthBar.alpha', 0);
	setProperty('iconP1.alpha', 0);
	setProperty('iconP2.alpha', 0);
	setProperty('strumLine.alpha', 0);
	doTweenAlpha('asshole3', 'camHUD', 1, 0.0001, 'linear');
end

-- for some reason, this wont be called (mabye) even though it SHOULD.
function onDialogueClick()
	setProperty('button.alpha', 0);
	-- >:(
end

function onCountdownTick(counter)
	if counter == 0 then
		doTweenAlpha('asshole', 'button', 0, 0.001, 'linear');
		doTweenAlpha('asshole2', 'skip', 0, 0.001, 'linear');
		doTweenAlpha('asshole3', 'camHUD', 1, 1, 'linear');
		doTweenAlpha('asshole4', 'healthBar', 1, 1, 'linear');
		doTweenAlpha('asshole5', 'iconP1', 1, 1, 'linear');
		doTweenAlpha('asshole6', 'iconP2', 1, 1, 'linear');
		doTweenAlpha('asshole7', 'strumLine', 1, 1, 'linear');
		seenCutscene = false;
	end
end

function onNextDialogue(count)
	setProperty('button.alpha', 0);
	doTweenAlpha('fard', 'button', 1, 0.2, 'linear');
	setProperty('healthBar.alpha', 0);
	setProperty('iconP1.alpha', 0);
	setProperty('iconP2.alpha', 0);
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
	setProperty('strumLine.alpha', 0);
end

function onTimerCompleted(tag)
	if tag == 'alphaHud' then
		setProperty('iconP1.alpha', 0);
		setProperty('iconP2.alpha', 0);
		setProperty('strumLine.alpha', 0);
	end
end