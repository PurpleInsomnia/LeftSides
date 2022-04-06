local dodging = false;
function onCreate()
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