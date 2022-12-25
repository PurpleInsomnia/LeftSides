function onCreate()
	if not lowQuality then
		makeLuaSprite('bg', 'nevada/sky', -200, -100);
		addLuaSprite('bg', false);

		makeLuaSprite('city', 'nevada/city', -200, -100);
		setScrollFactor('city', 0.9, 0.9);
		addLuaSprite('city', false);

		makeLuaSprite('decor', 'nevada/decor', -200, -100);
		setScrollFactor('decor', 0.95, 0.95);
		addLuaSprite('decor', false);

		makeLuaSprite('road', 'nevada/road', -200, -100);
		addLuaSprite('road', false);
	else
		makeLuaSprite('bg', 'nevada/bgLOWQUAL', -200, -100);
		addLuaSprite('bg', false);
	end

	makeLuaSprite('rocks', 'nevada/overlayStuff', -200, -100);
	addLuaSprite('rocks', true);

	makeLuaSprite('comicDots', 'madness/comicDots', 0, 0);
	setObjectCamera('comicDots', 'camHUD');
	setProperty('comicDots.alpha', 0);
	addLuaSprite('comicDots', true);
end

function onStartCountdown()
	doTweenAlpha('shitPiss', 'comicDots', 1, 0.25, 'linear');
end