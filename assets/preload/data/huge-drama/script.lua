local chad = false;
function onCreate()
	chad = downscroll;
	if chad then
		setPropertyFromClass('ClientPrefs', 'downScroll', false);
	end
end

function onDestroy()
	if chad then
		setPropertyFromClass('ClientPrefs', 'downScroll', true);
	end
end

function onStartCountdown()
    playSound("skylar", 0);
end

function onBeatHit()
    if curBeat == 175 then
        playSound("skylar");
        setProperty("reverseSectionCamera", true);
    end
    if curBeat == 319 then
        setProperty("reverseSectionCamera", false);
    end
end