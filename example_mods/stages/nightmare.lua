function onCreate()
	if not lowQuality then
		makeLuaSprite('bg', 'nightmare/bg', -200, -100);
		addLuaSprite('bg', false);

		makeLuaSprite('clouds', 'nightmare/clouds', -200, -100);
		setScrollFactor('couds', 0.9, 0.9);
		addLuaSprite('couds', false);

		doTweenX('cloud', 'clouds', -3000, 180, 'linear');

		makeLuaSprite('hills', 'nightmare/hills', -200, -100);
		setScrollFactor('hills', 0.95, 0.95);
		addLuaSprite('hills', false);

		makeLuaSprite('floor', 'nightmare/floor', -200, -100);
		addLuaSprite('floor', false);
	else
		makeLuaSprite('bgLowQual', 'nightmare/bgLOWQUAL', -200, -100);
		addLuaSprite('bgLowQual', false);
	end

	makeLuaSprite('black', 'black', -200, -100);
	setProperty('black.alpha', 0);
	setGraphicSize('black', 3000, 2000);
	addLuaSprite('black', false);
end

bA = 0;
function onUpdate(elapsed)
	bA = getProperty('black.alpha');

	if bA == 1 then
		setProperty('health', 0);
	end
end

math = 0;
function noteMiss()
	math =  0.05;
	setProperty('black.alpha', bA + math);
end

math2 = 0;
function goodNoteHit()
	math2 = 0.05 / 2;
	setProperty('black.alpha', bA - math2);
end