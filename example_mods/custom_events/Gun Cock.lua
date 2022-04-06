function onCreate()
	precacheSound('gunCOCK(sus)');
	addCharacterToList('pico-gun-cock', 'dad');
end

function onEvent(name, value1, value2)
	if name == 'Gun Cock' then
		soundBool = tonumber(value1);
		dumbTimer = tonumber(value2);
		triggerEvent('Change Character', 1, 'pico-gun-cock');
		characterPlayAnim('dad', 'cock', true);
		if soundBool == 0 then
			playSound('gunCOCK(sus)');
		end
		runTimer('sususamogus', dumbTimer);
	end
end

function onTimerCompleted(tag)
	triggerEvent('Change Character', 1, 'pico');
end
