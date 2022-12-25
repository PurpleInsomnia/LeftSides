function onCreate()
	makeLuaSprite("bg", "lonely/bg", 0, 0);
	addLuaSprite("bg", false);

	makeLuaSprite("fg", "lonely/ground", 0, 0);
	addLuaSprite("fg", false);
end

function onCreatePost()
	setProperty("gf.visible", false);
end

function onMoveCamera(focus)
    if focus == 'dad' then
		triggerEvent("Cam Tween Zoom", "0.9", "0.5");
	end
    if focus == 'boyfriend'then
		triggerEvent("Cam Tween Zoom", "1.1", "0.65");
    end
end

local zoomshit = 0;
function onUpdate(elapsed)
	-- goofy ahh 3d
    zoomshit = (getProperty('camGame.zoom')/0.75);
    setProperty('boyfriend.scale.x',zoomshit);
    setProperty('boyfriend.scale.y',zoomshit);
end