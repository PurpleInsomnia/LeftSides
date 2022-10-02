function onCreate()
	if lowQuality then
		makeLuaSprite('bgAndroid', 'rain/bgLowqual', -200, -100);
		addLuaSprite('bgAndroid', false);
	else
		makeLuaSprite('bg', 'rain/bg', -200, -100);
		addLuaSprite('bg', false);

		makeLuaSprite('city', 'rain/city', -200, -100);
		setLuaSpriteScrollFactor('city', 0.95, 0.95);
		addLuaSprite('city', false);

		if shaders then
			makeLuaSprite('lights', 'rain/lights', -200, -100);
		else
			makeLuaSprite('lights', 'rain/no', -200, -100);
		end
		setLuaSpriteScrollFactor('lights', 0.95, 0.95);
		addLuaSprite('lights', false);

		makeLuaSprite('fg', 'rain/fg', -200, -100);
		addLuaSprite('fg', false);
	end

	-- rain stuff
	makeLuaSprite('rainShader', 'rain/shader', 0, 0);
	setBlendMode('rainShader', 'multiply');
	setObjectCamera('rainShader', 'camShader');
	addLuaSprite('rainShader', false);

	makeAnimatedLuaSprite('rain', 'rain/rain', 0, 0);
	addAnimationByPrefix('rain', 'idle', 'idle', 24, true);
	objectPlayAnimation('rain', 'idle', true);
	setObjectCamera('rain', 'camHUD');
	addLuaSprite('rain', false);
end

function onStartCountdown()
	doTweenAlpha('lightAlpha', 'lights', 0.25, 1, 'linear');
end

function onBeatHit()
	if flashing then
		if curBeat % 4 == 0 then
			setProperty('lights.alpha', 1);
			doTweenAlpha('lightAlphaThing', 'lights', 0.25, 0.5, 'linear');
		end
	end
end