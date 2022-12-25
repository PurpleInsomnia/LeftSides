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

	makeAnimatedLuaSprite('rain', 'rain/rain', 0, 0);
	addAnimationByPrefix('rain', 'idle', 'idle', 24, true);
	objectPlayAnimation('rain', 'idle', true);
	setObjectCamera('rain', 'camShader');
	addLuaSprite('rain', true);
end

local timeThing = 0;
function onCountdownTick()
	timeThing = beat;
	setProperty('lights.alpha', 1);
	doTweenAlpha('lightAlpha', 'lights', 0, timeThing, 'linear');
end

function onEvent(name)
	if name == "Add Camera Zoom" then
		setProperty('lights.alpha', 1);
		doTweenAlpha('lightAlphaThing', 'lights', 0, timeThing, 'linear');
	end
end