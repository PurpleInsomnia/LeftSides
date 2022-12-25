function onCrete()
	-- other value stuff :/
	strumY = defaultPlayerStrumY0;
end

local virgin = false;
local isEnding = false;
-- I dont know why. BUT THE FUCKING STRUMS GO SLIGHTLY HIGHER THAN THEY NEED TO BE WHEN THE THING FUCKING RESETS!!! WHY?!?!?!?!?!?!
-- I'm not gonna move the strums now >:(
function onEvent(name, value1, value2)
	if name == 'Note Center' then
		trigger = tonumber(value1);
		chad = middlescroll;
		if trigger > 0 then
			if not chad then
				setPropertyFromClass('ClientPrefs', 'middleScroll', true);
				virgin = true;
			end
			doTweenAlpha('the_w', 'camGame', 0, 0.5, 'linear');
			doTweenAlpha('stfu', 'healthBar', 0, 0.5, 'linear');
			-- dumb icons
			doTweenAlpha('icon1', 'iconP1', 0, 0.5, 'linear');
			doTweenAlpha('icon2', 'iconP2', 0, 0.5, 'linear');
		else
			doTweenAlpha('not_the_w', 'camGame', 1, 0.5, 'linear');
			doTweenAlpha('the', 'healthBar', 1, 0.5, 'linear');
			doTweenAlpha('iconSus1', 'iconP1', 1, 0.5, 'linear');
			doTweenAlpha('iconSus2', 'iconP2', 1, 0.5, 'linear');
			if virgin then
				setPropertyFromClass('ClientPrefs', 'middleScroll', false);
			end
		end
			
	end
end
