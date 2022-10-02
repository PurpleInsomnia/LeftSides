local showed = false;
function onCreate()
	setProperty('isScary', true);
	makeLuaSprite('stageback','week2/bg', -200, -100);
	addLuaSprite('stageback',false);

	makeLuaSprite('stageback2','week2/bg', -200 - 2114, -100);
	addLuaSprite('stageback2', false);

	makeLuaSprite('pissballsfartpeepoopoo', 'week2/spookyPole', -200, -100);
	addLuaSprite('pissballsfartpeepoopoo', false);

	makeLuaSprite('white', 'dialogueBgs/white', -200 - 2114, -100);
	setGraphicSize('white', 2114 * 2, 1075);
	addLuaSprite('white', false);

	makeLuaSprite('overlay', 'week2/spookyOverlay', -200, -50);
	setProperty('overlay.visible', false);
	addLuaSprite('overlay', true);
end

function onBeatHit()
	if curBeat == 79 then
		show();
	end
end

function onStepHit()

end

-- fixes lag :)
function onUpdate(elapsed)
	if curBeat > 79 and not showed then
		show();
	end
end

function show()
	showed = true;
	doTweenColor('bf', 'boyfriend', '5F5F5F', 0.00001, 'linear');
	doTweenColor('gf', 'gf', '5F5F5F', 0.00001, 'linear');
	doTweenColor('dad', 'dad', '5F5F5F', 0.00001, 'linear');
	setProperty('white.visible', false);
	setProperty('overlay.visible', true);
end
