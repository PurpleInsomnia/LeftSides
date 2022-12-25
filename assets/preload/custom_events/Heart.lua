local iconOn = false;
local canTween = false;
function onEvent(name, value1, value2)
	if name == 'Heart' then
		trigger = tonumber(value1);
		time = tonumber(value2);
		if trigger > 0 then
			setProperty('hearts.visible', true);
			setProperty('hearts.y', 720);
			doTweenY('goinUp', 'hearts', -720, time, 'linear');
			doTweenX('doTheFunny', 'hearts', 10, 5, 'linear');
		else
			setProperty('hearts.visible', false);
			setProperty('hearts.y', 720);
		end
	end
end

function onCreate()
	makeLuaSprite('hearts', 'particleHEARTS', 0, 720);
	setObjectCamera('hearts', 'hud');
	addLuaSprite('hearts', true);
	setProperty('hearts.alpha', 0.5);
	setProperty('hearts.visible', false);
end

function onTweenCompleted(tag)
	if tag == 'doTheFunny' then
		doTweenX('vineBoom', 'hearts', -10, 2, 'linear');
	end
	if tag == 'vineBoom' then
		doTweenX('doTheFunny', 'hearts', 10, 2, 'linear');
	end
	if tag == 'goinUp' then
		triggerEvent('Heart', 0, '');
	end
end
