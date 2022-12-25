function onCreatePost()
	makeLuaSprite("vg", "encore/monster/vg", 0, 0);
	setObjectCamera("vg", "camHUD");
	setProperty("vg.alpha", 0.5);
	addLuaSprite("vg", true);

	setProperty("health", 2);
end

local setAlpha = 0;
function onUpdate(elapsed)
	setAlpha = (getProperty("health") / 2);
	for i = 0, getProperty('unspawnNotes.length')-1 do
		setPropertyFromGroup('unspawnNotes', i, "alpha", setAlpha);
	end
	for i = 0, 3 do
		setPropertyFromGroup('playerStrums', i, "alpha", setAlpha);
	end
end