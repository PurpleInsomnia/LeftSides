local coolFlashOn = false;
local coolBeat = false;
local secThing = 0.2
function onEvent(name, value1, value2)
	if name == 'Cool Flash' then
		trigger = tonumber(value1);
		beatThing = tonumber(value2);
		if trigger > 0 then
			coolFlashOn = true;
			doTweenAlpha('dimScreen', 'black', 0.7, 0.25, 'linear');
		else
			coolFlashOn = false;
			doTweenAlpha('left', 'left', 0, secThing, 'linear');
			doTweenAlpha('down', 'down', 0, secThing, 'linear');
			doTweenAlpha('up', 'up', 0, secThing, 'linear');
			doTweenAlpha('right', 'right', 0, secThing, 'linear');
			doTweenAlpha('undimScreen', 'black', 0, 0.25, 'linear');
		end
		if beatThing == 1 then
			coolBeat = true;
		end
	end
end

function onCreate()
	-- the funny glows that show up on the flash thing & the black screen

	makeLuaSprite('black', 'coolVisuals/black', -1000, -1000);
	scaleObject('black', 6, 6);
	addLuaSprite('black', true);

	makeLuaSprite('left', 'screenGlows/left', 0, 0);
	makeLuaSprite('down', 'screenGlows/down', 0, 0);
	makeLuaSprite('up', 'screenGlows/up', 0, 0);
	makeLuaSprite('right', 'screenGlows/left', 0, 0);

	setObjectCamera('left', 'hud');
	setObjectCamera('down', 'hud');
	setObjectCamera('up', 'hud');
	setObjectCamera('right', 'hud');

	addLuaSprite('left', true);
	addLuaSprite('down', true);
	addLuaSprite('up', true);
	addLuaSprite('right', true);

	setProperty('left.alpha', 0);
	setProperty('down.alpha', 0);
	setProperty('up.alpha', 0);
	setProperty('right.alpha', 0);

	setPropertyLuaSprite('black', 'alpha', 0);
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if coolFlashOn and flashingLights then
		if noteData == 0 then
			doTweenAlpha('left', 'left', 1, secThing, 'linear');
			doTweenAlpha('down', 'down', 0, secThing, 'linear');
			doTweenAlpha('up', 'up', 0, secThing, 'linear');
			doTweenAlpha('right', 'right', 0, secThing, 'linear');
		end
		if noteData == 1 then
			doTweenAlpha('left', 'left', 0, secThing, 'linear');
			doTweenAlpha('down', 'down', 1, secThing, 'linear');
			doTweenAlpha('up', 'up', 0, secThing, 'linear');
			doTweenAlpha('right', 'right', 0, secThing, 'linear');
		end
		if noteData == 2 then
			doTweenAlpha('left', 'left', 0, secThing, 'linear');
			doTweenAlpha('down', 'down', 0, secThing, 'linear');
			doTweenAlpha('up', 'up', 1, secThing, 'linear');
			doTweenAlpha('right', 'right', 0, secThing, 'linear');
		end
		if noteData == 3 then
			doTweenAlpha('left', 'left', 0, secThing, 'linear');
			doTweenAlpha('down', 'down', 0, secThing, 'linear');
			doTweenAlpha('up', 'up', 0, secThing, 'linear');
			doTweenAlpha('right', 'right', 1, secThing, 'linear');
		end	
	end
end

function onUpdate(elapsed)
	if coolFlashOn then
		if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
			doTweenAlpha('left', 'left', 0, secThing, 'linear');
			doTweenAlpha('down', 'down', 0, secThing, 'linear');
			doTweenAlpha('up', 'up', 0, secThing, 'linear');
			doTweenAlpha('right', 'right', 0, secThing, 'linear');
		end
		if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
			doTweenAlpha('left', 'left', 0, secThing, 'linear');
			doTweenAlpha('down', 'down', 0, secThing, 'linear');
			doTweenAlpha('up', 'up', 0, secThing, 'linear');
			doTweenAlpha('right', 'right', 0, secThing, 'linear');
		end
	end
end

function onBeatHit()
	if coolFlashOn and coolBeat then
		if curBeat % 2 == 0 then
			doTweenZoom('sus', 'camGame', getProperty('camGame.zoom') + 0.1, 0.001, 'sineIn');
		end
	end
end
