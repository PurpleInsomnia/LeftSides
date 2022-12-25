local isScary = false;
function onCreate()
	-- free me jumpscares
	makeLuaSprite('shadowSmile', 'jumpscares/freemeGRIN', 0, 0);
	setObjectCamera('shadowSmile', 'other');
	addLuaSprite('shadowSmile', true);

	makeLuaSprite("redJump", "cinnabar/jumpscare", 0, 0);
	setObjectCamera("redJump", "other");
	addLuaSprite("redJump", true);

	-- might add more, might not~

	-- coolswag properties
	setProperty('shadowSmile.visible', false);
	setProperty("redJump.visible", false);
end

local volume = 0.1;
function onEvent(name, value1, value2)
	-- value 1: Scare Image (Starts at 0)
	-- value 2: Sound (Leave 0 for random)
	image = tonumber(value1);
	sound = tonumber(value2);
	-- volume var because the scary sound is VERY VERY LOUD
	if name == 'Jumpscare' and jumpscares and not isScary then
		-- assets
		if image == 0 then
			setProperty('shadowSmile.visible', true);
			spriteString = 'shadowSmile.visible';
		end
		if image == 1 then
			setProperty("redJump.visible", true);
			spriteString = "redJump.visible";
		end
		-- sounds
		if sound == '' or sound == 0 then
			soundThing = math.floor(math.random(1, 2))
			if soundThing == 1 then
				playSound(jumpscares/scream1, volume);
			end
			if soundThing == 2 then
				playSound('jumpscares/scream2', volume);
			end
		end
		if sound == 1 then
			playSound('jumpscares/scream1', volume);
		end
		if sound <= 2 then
			playSound('jumpscares/scream2', volume);
		end
		isScary = true;

		runTimer('scareHide', 0.3);
		runTimer('fuckShit', 0.3);
		runTimer('cooldown', 5);
	end
	if name == 'Jumpscare' and not jumpscares and not isScary then
		runTimer('fuckShit', 0.3);
	end
end

function onTimerCompleted(tag)
	if tag == 'scareHide' then
		setProperty(spriteString, false);
	end
	if tag == 'cooldown' then
		isScary = false;
	end
	if tag == 'fuckShit' then
		arrowAngle(90);
	end
end