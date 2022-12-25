local canPressDebug = true;
local debugger = false;
local speedOn = false;
local hideThing = false;
local dumbBotplay = false;
local ogIcon = false;
function onUpdate(elapsed)
	if canPressDebug then
		-- unused shit?!
	end
end

function onCreate()
	-- the cool stuff B)

	dumbBf = getProperty('boyfriend.curCharacter');
	dambDad = getProperty('dad.curCharacter');
	-- this next var might only be used for the thing below
	dumbGf = getProperty("gf.curCharacter");

	if dumbGf == 'speaker' and not isSecret then
		if not isMonster and not isFree then
			setProperty('introSoundsSuffix', '-bf');
		end
	end
end

function onBeatHit()
	-- cool thing tat makes gf bop her head slower if you're losing
	health = getProperty('health');
	if curBeat % 4 == 0 then
		if health < 0.21 and not speedOn then
			triggerEvent('Set Gf Speed', 4, '');
		elseif not speedOn then
			triggerEvent('Set Gf Speed', 1, '');
		end
	end
end

function onEvent(name, value1, value2)
	if name == 'Change Character' then
		dumbBf = getProperty('boyfriend.curCharacter');
		dambDad = getProperty('dad.curCharacter');
		dumbGf = getProperty("gf.curCharacter");
	end
	if name == 'Set Gf Speed' then
		-- basically fixes the thing in south.
		if value1 == 2 or value1 == 4 then
			speedOn = true;
		end
		if value1 == 1 and speedOn then
			speedOn = false;
		end 
	end
end

function onDestroy()
	-- I think I need this....
	if debugger then
		luaDebugMode = false;
	end
	if hideThing then
		setProperty('camGame.visible', true);	
	end
end
