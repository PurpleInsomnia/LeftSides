local canWarn = true;
function onCreate()
	makeLuaSprite('danger', 'limoBG/warning', 0, 0);
	setObjectCamera('danger', 'camHUD');
	addLuaSprite('danger', true);
	setProperty('danger.visible', false);
end

function onEvent(name, value1, value2)
	if name == 'Warning' then
		canWarn = true;
		playSound('warning', 0.2);
		setProperty('danger.visible', true);
		runTimer('hide', 0.14);
		runTimer('thePenis', 0.85);
	end
end

function onTimerCompleted(tag)
	if canWarn then
		if tag == 'hide' then
			setProperty('danger.visible', false);
			runTimer('show', 0.12)
		end
		if tag == 'show' then
			setProperty('danger.visible', true);
			runTimer('hide', 0.14);
		end
	end
	if tag == 'thePenis' then
		canWarn = false;
		setProperty('danger.visible', false);
	end
end
