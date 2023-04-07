local isTv = false;
local bfx = 0;
local bfy = 0;
local zoomshit = 0;
local minamount = 0;
function onCreate()
	-- real sprites
	minamount = 2114 /2;
	makeLuaSprite("real", "encore/monster/goofy ahh bg", -200 - minamount, -100);
	setProperty("real.visible", false);
	addLuaSprite("real", false);
end

function onCreatePost()
	-- cache maybe?
	showReal();
end

function showReal()
	isTv = false;
	callOnLuas("onChangeStage", false);
	setProperty("dad.x", 0);
	setProperty("dad.y", 460);
	setProperty("boyfriend.x", 1070);
	setProperty("boyfriend.y", 350);
	setProperty("dad.visible", true);
	setProperty("real.visible", true);
	funnyColours();
end

function funnyColours()
	doTweenColor('bfShading', 'boyfriend', '7F7F7F', 0.001, 'linear');
	doTweenColor('dadShading', 'dad', '7F7F7F', 0.001, 'linear');
end