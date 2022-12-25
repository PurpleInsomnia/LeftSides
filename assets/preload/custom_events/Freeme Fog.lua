function onCreate()
	makeLuasprite('freeMeFog', 'coolVisuals/fog', 0, 0);
	setObjectCamera('freeMeFog', 'camHUD');
	setProperty('freeMeFog.alpha', 0);
	addLuaSprite('freeMeFog', false);
end

function onEvent(name, value1, value2)
	fogTime = tonumber(value2);
	if value1 > 0 then
		doTweenAlpha('fogBallin', 'freeMeFog', 1, fogTime, 'linear');
		playSound('fog');
	else
		doTweenAlpha('fogNotBallin', 'freeMeFog', 0, fogTime, 'linear');
	end
end
