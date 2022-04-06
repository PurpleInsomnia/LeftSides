local heDead = false;
local isFlashing = false;
local bool = false;
local dodging = false;
local canPress = true;
-- basically the funny from FNF HD
function onCreate()
	makeLuaSprite('sign', 'limoBG/dangerSign', -269 * 2, 0);
	setProperty('sign.visible', true);
	addLuaSprite('sign', true);
	doTweenColor('signShading', 'sign', '6D7AD7', 0.001, 'linear');
end

function onEvent(name, value1, value2)
	if name == 'Limo Dodge' then
		setProperty('sign.visible', true);
		setProperty('sign.x', -269 * 2);
		doTweenX('theThingGoWee', 'sign', 1040, 0.55, 'linear');
	end
end

function onUpdate(elapsed)
	if getPropertyFromClass('flixel.FlxG', 'keys.pressed.SPACE') then
		if canPress then
			characterPlayAnim('boyfriend', 'dodge', false);
		end
	end
	if getProperty('boyfriend.animation.curAnim.name') == 'dodge' then
		dodging = true;
	else
		dodging = false;
	end
end

function onTweenCompleted(tag)
	signX = getProperty('sign.x');
	health = getProperty('health');
	if tag == 'theThingGoWee' then
		if not dodging then
			setProperty('health', health - 2);
			deathShit();
		else
			playSound('dramaticSting', 0.2);
			canPress = false;
			runTimer('hey', 0.6);
			runTimer('cooldown', 0.6);
		end
		-- need math because
		doTweenX('sus', 'sign', 1280 + 269, 0.55 / 3, 'linear');
	end
	if tag == 'sus' then
		setProperty('sign.visible', false);
	end
end

function onTimerCompleted(tag)
	if tag == 'cooldown' then
		canPress = true;
	end
	if tag == 'hey' then
		characterPlayAnim('boyfriend', 'hey', true);
	end
end

function deathShit()
	-- BIG SEX
end
