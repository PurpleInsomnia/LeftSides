local canStrike = true;
function onCreate()
	makeLuaSprite('sky','week2/spooky/sky', -200, -100);
	addLuaSprite('sky', false);
	setLuaSpriteScrollFactor('sky', 0.9, 0.9);

	makeLuaSprite('stars','week2/spooky/stars', -200, -100);
	addLuaSprite('stars', false);
	setLuaSpriteScrollFactor('stars', 0.9, 0.9);

	makeLuaSprite('moon','week2/spooky/the moon', -200, -100);
	addLuaSprite('moon', false);
	setLuaSpriteScrollFactor('moon', 0.9, 0.9);

	makeLuaSprite('trees','week2/spooky/trees', -200, -100);
	addLuaSprite('trees', false);
	setLuaSpriteScrollFactor('trees', 0.9, 0.9);

	makeLuaSprite('fg','week2/spooky/grass', -200, -100);
	addLuaSprite('fg', false);
	setLuaSpriteScrollFactor('fg', 0.9, 0.9);

	-- for cool lightning effect

	if lowQuality then
		removeLuaSprite('sky', true);
		removeLuaSprite('stars', true);
		removeLuaSprite('moon', true);
		removeLuaSprite('trees', true);
		removeLuaSprite('fg', true);

		makeLuaSprite('android', 'spookyBG', -200, -100);
		addLuaSprite('android', false);
	end

	makeLuaSprite('white', 'coolVisuals/white', 0, 0);
	addLuaSprite('white', true);
	setObjectCamera('white', 'hud');
	setProperty('white.alpha', 0);
end

function onStartCountdown()
	doTweenX('starMove', 'stars', 1000, 200, 'linear');
end

function onUpdate(elapsed)
	randomNum = getRandomInt(3, 5.5);
end

function onBeatHit()
	-- random number for cool lightning effect
	if canStrike then
		runTimer('thunder', randomNum);
		canStrike = false;
	end
end

function onStepHit()

end

function onTimerCompleted(tag)
	bruh = getRandomInt(1, 2);
	if bruh == 1 then
		ass = 'thunder1';
	end
	if bruh == 2 then
		ass = 'thunder2';
	end
	if tag == 'thunder' then
		if flashingLights then
			doTweenAlpha('flashOn', 'white', 1, 0.001, 'linear');
		end
		playSound(ass);
		characterPlayAnim('boyfriend', 'scared', true);
		characterPlayAnim('gf', 'scared', true);
		doTweenAlpha('flashOff', 'white', 0, 0.3, 'linear');
		runTimer('coolDown', 2.1);
	end
	if tag == 'coolDown' then
		canStrike = true;
	end		
end
