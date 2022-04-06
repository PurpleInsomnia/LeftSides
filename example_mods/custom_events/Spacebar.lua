function onCreate()
	makeAnimatedLuaSprite('spacebar', 'Spacebar', 320, 130);
	addAnimationByPrefix('spacebar', 'idle', 'Idle', 24, false);
	addAnimationByPrefix('spacebar', 'press', 'Press', 24, false);
	objectPlayAnimation('spacebar', 'idle', true);
	setObjectCamera('spacebar', 'camHUD');
	setProperty('spacebar.alpha', 0);
	addLuaSprite('spacebar', false);
end

function onEvent(name, value1, value2)
	if name == 'Spacebar' then
		doTweenAlpha('sexualIntercourse', 'spacebar', 1, value1, 'linear');
		runTimer('spacePress', value2);
	end
end

function onTimerCompleted(tag)
	if tag == 'spacePress' then
		objectPlayAnimation('spacebar', 'press', true);
		doTweenAlpha('godIsGoodGodIsGreatGodIsGoOOoooOOooOOOooooooAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-hahahahaaaaaaaaaa', 'spacebar', 0, 1, 'linear');
	end
end