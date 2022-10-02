function onCreate()
	if not lowQuality then
		makeLuaSprite('bg', 'moonPiss/bg', -200, -100);
		addLuaSprite('bg', false);

		makeLuaSprite('city', 'moonPiss/city', -200, -100);
		setLuaSpriteScrollFactor('city', 0.95, 0.95);
		addLuaSprite('city', false);

		if shaders then
			makeLuaSprite('windowGLOW', 'moonPiss/lights', -200, -100);
			setLuaSpriteScrollFactor('windowGLOW', 0.95, 0.95);
			addLuaSprite('windowGLOW', false);
		end
		makeLuaSprite('windows', 'moonPiss/windows', -200, -100);
		setLuaSpriteScrollFactor('windows', 0.95, 0.95);
		addLuaSprite('windows', false);

		makeLuaSprite('blurBuild', 'moonPiss/frontBuildings', -200, -100);
		addLuaSprite('blurBuild', true);
	else
		makeLuaSprite('fakeBG', 'moonPiss/bgLOWQUAL', -200, -100);
		addLuaSprite('fakeBG', true);
	end

	makeAnimatedLuaSprite('eggman', 'moonPiss/eggman', -200, -100);
	addAnimationByPrefix('eggman', 'idle', 'Idle', 24, false);
	addAnimationByPrefix('eggman', 'down', 'Down', 24, false);
	addAnimationByPrefix('eggman', 'left', 'Left', 24, false);
	addAnimationByPrefix('eggman', 'right', 'Right', 24, false);
	addAnimationByPrefix('eggman', 'up', 'Up', 24, false);
	objectPlayAnimation('eggman', 'idle', true);
	if not lowQuality then
		setLuaSpriteScrollFactor('eggman', 0.95, 0.95);
	end
	addLuaSprite('eggman', false);

	makeLuaSprite('tv', 'moonPiss/tv', -200, -100);
	if not lowQuality then
		setLuaSpriteScrollFactor('tv', 0.95, 0.95);
	end
	addLuaSprite('tv', false);

	makeLuaSprite('overlay', 'moonPiss/ovrlBuilding', -300, -200);
	addLuaSprite('overlay', true);

	setProperty('followChars', false);
end

local isSinging = false;
function onBeatHit()
	if curBeat % 4 == 2 then
		if not isSinging then
			objectPlayAnimation('eggman', 'idle', true);
		end
	end
end

function opponentNoteHit(type, data)
	isSinging = true;
	if data == 0 then
		objectPlayAnimation('eggman', 'left', true);
	end
	if data == 1 then
		objectPlayAnimation('eggman', 'down', true);
	end
	if data == 2 then
		objectPlayAnimation('eggman', 'right', true);
	end
	if data == 3 then
		objectPlayAnimation('eggman', 'up', true);
	end
	runTimer('stopSing', 0.5);
end

local moved = false;
function onMoveCamera(char)
	if char == 'dad' then
		if not moved then
			moved = true;
			triggerEvent('Cam Tween Zoom', 0.85, 0.67);
			runTimer("resetMove", 0.67);
		end
	else
		if not moved then
			moved = true;
			triggerEvent('Cam Tween Zoom', 1.35, 0.67);
			runTimer("resetMove", 0.67);
		end
	end
end

function onTimerCompleted(tag)
	if tag == 'stopSing' then
		isSinging = false;
	end
	if tag == "resetMove" then
		moved = false;
	end
end

local vidStat = "nonExistant";
function onUpdate(elapsed)
	if not mustHitSection then
		triggerEvent('Camera Follow Pos', 600, 352);
	else
        triggerEvent('Camera Follow Pos', 900, 506);
	end
end

function doDeathVideo()
	if vidStat == "nonExistant" then
		vidStat = "playing";
		coolVideo("Piss");
	end
	if vidStat == "playing" then
		return Function_Stop;
	end
	if vidStat == "stopped" then
		return Function_Continue;
	end
end

function onVideoDone()
	vidStat = "stopped";
	setProperty("health", 0);
	return Function_Continue;
end