function onCreate()
    makeLuaSprite("sky", "exe/cycles/sky", 0, 0);
    addLuaSprite("sky", false);
    
    makeLuaSprite("ground", "exe/cycles/ground", 0, 0);
    addLuaSprite("ground", false);
end

function onCreatePost()
    setProperty("gf.visible", false);
    onMoveCamera("bf");
end

local moved = false;
function onMoveCamera(char)
	if char == 'dad' then
		if not moved then
			moved = true;
			triggerEvent('Cam Tween Zoom', 0.8, 0.67);
			runTimer("resetMove", 0.67);
		end
	else
		if not moved then
			moved = true;
			triggerEvent('Cam Tween Zoom', 0.9, 0.67);
			runTimer("resetMove", 0.67);
		end
	end
end

function onTimerCompleted(tag)
	if tag == "resetMove" then
		moved = false;
	end
end