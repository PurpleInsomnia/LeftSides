local canStrike = true;
function onCreate()
	makeLuaSprite("sky", "spooky/sky", -1314, -475);
	addLuaSprite("sky", false);

	makeLuaSprite('android', 'spooky/spookyBG', -200, -100);
	addLuaSprite('android', false);

	makeLuaSprite('android2', 'spooky/spookyBG', -2314, -100);
	addLuaSprite('android2', false);

	makeLuaSprite('android3', 'spooky/spookyBG', 1914, -100);
	addLuaSprite('android3', false);

	makeLuaSprite('pole', 'week2/spooky/streetpole', -200, -100);
	addLuaSprite('pole', false);

	-- vroom vroom
	makeLuaSprite('car', 'week2/spooky/spookyCar', -1649, -100);
	setProperty("car.visible", false);
	addLuaSprite('car', true);

	makeLuaSprite('overlay', 'week2/spookyOverlay', -200, -50);
	addLuaSprite('overlay', true);

	makeLuaSprite('white', 'coolVisuals/white', 0, 0);
	addLuaSprite('white', true);
	setObjectCamera('white', 'hud');
	setProperty('white.alpha', 0);

	if encoreMode then
		moveNum = 175;
		moveNumY = 75;
		setProperty("sky.x", getProperty("sky.x") - moveNum);
		setProperty("sky.y", getProperty("sky.y") + moveNumY);
		setProperty("android.x", getProperty("android.x") - moveNum);
		setProperty("android.y", getProperty("android.y") + moveNumY);
		setProperty("android2.x", getProperty("android2.x") - moveNum);
		setProperty("android2.y", getProperty("android2.y") + moveNumY);
		setProperty("android3.x", getProperty("android3.x") - moveNum);
		setProperty("android3.y", getProperty("android3.y") + moveNumY);
		setProperty("pole.x", getProperty("pole.x") - moveNum);
		setProperty("pole.y", getProperty("pole.y") + moveNumY);
		setProperty("overlay.x", getProperty("overlay.x") - moveNum);
		setProperty("overlay.y", getProperty("overlay.y") + moveNumY);
	end
end

function onCreatePost()
	if encoreMode then
		setProperty("dad.y", getProperty("dad.y") - 25);
	end
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

	if curBeat % 28 == 0 then
		playSound('spookyDrive');
		runTimer('carTimer', 0.96);
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
	if tag == 'carTimer' then
		moveCar();
	end	
end

-- beep beep :)
function moveCar()
	setProperty("car.visible", true);
	doTweenX('carTween', 'car', 2114, 0.5, 'linear');
end

function onTweenCompleted(tag)
	if tag == 'carTween' then
		setProperty("car.visible", false);
		setProperty('car.x', -1649);
	end
end
