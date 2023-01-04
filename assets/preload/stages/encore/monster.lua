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

	makeLuaSprite("fakebg", "encore/monster/dumbbg", -200, -100);
	setProperty("fakebg.visible", false);
	addLuaSprite("fakebg", false);

	-- lmao Tv
	makeAnimatedLuaSprite("Tv", "encore/monster/screen", -310, -1250);
	addAnimationByPrefix("Tv", "idle", "Idle", 24, false);
	addAnimationByPrefix("Tv", "down", "Down", 24, false);
	addAnimationByPrefix("Tv", "left", "Left", 24, false);
	addAnimationByPrefix("Tv", "right", "Right", 24, false);
	addAnimationByPrefix("Tv", "up", "Up", 24, false);
	objectPlayAnimation("Tv", "idle", true);
	setProperty("Tv.visible", false);
	addLuaSprite("Tv", false);
end

function onCreatePost()
	-- cache maybe?
	showBack();
end

function onStepHit()
	if curStep == 464 then
		triggerEvent("Change Character", "0", "bf-spooky-mad");
		showReal();
	end
	if curStep == 1295 then
		triggerEvent("Change Character", "1", "bad-thoughts");
		showFake();
	end
	if curStep == 1744 then
		triggerEvent("Change Character", "1", "freeme");
		showReal();
	end
end

function showFake()
	triggerEvent("Cam Tween Zoom", "0.8", "0.001");
	setProperty("dad.x", 200);
	setProperty("dad.y", 775);
	setProperty("boyfriend.x", 1170);
	setProperty("boyfriend.y", 625);
	setProperty("fakebg.visible", true);
	setProperty("fakeshader.visible", true);
	setProperty("real.visible", true);
	unfunnyColours();
end

function showReal()
	isTv = false;
	setProperty("bfZoom", true);
	callOnLuas("onChangeStage", false);
	triggerEvent("Cam Tween Zoom", "0.8", "0.001");
	setProperty("dad.x", 0);
	setProperty("dad.y", 460);
	setProperty("boyfriend.x", 1070);
	setProperty("boyfriend.y", 350);
	setProperty("dad.visible", true);
	setProperty("Tv.visible", false);
	setProperty("fakebg.visible", false);
	setProperty("fakeshader.visible", false);
	setProperty("real.visible", true);
	funnyColours();
end

function showBack()
	isTv = true;
	callOnLuas("onChangeStage", true);
	triggerEvent("Cam Tween Zoom", "0.55", "0.001");
	setProperty("dad.x", 120);
	setProperty("dad.y", -500);
	setProperty("dad.visible", false);
	setProperty("Tv.visible", true);
	setProperty("real.visible", false);
end

function onMoveCamera(focus)
    if focus == 'dad' and isTv then
		triggerEvent("Cam Tween Zoom", "0.6", "0.5");
	end
    if focus == 'boyfriend' and isTv then
		triggerEvent("Cam Tween Zoom", "0.8", "0.65");
		triggerEvent("Cam Follow Pos", "1", "-1250");
    end
end

function onUpdate(elapsed)
	if isTv then
	end
end

function onBeatHit()
	if curBeat % 2 == 0 and isTv then
		if getProperty("Tv.animation.curAnim.name") == "down" or getProperty("Tv.animation.curAnim.name") == "right" or getProperty("Tv.animation.curAnim.name") == "left" or getProperty("Tv.animation.curAnim.name") == "up" then
			if getProperty(Tv.animation.curAnim.finished) then
				objectPlayAnimation("Tv", "idle", true);
			else
				-- :)
			end
			-- no idles?
		else
			objectPlayAnimation("Tv", "idle", true);
		end
	end
end

function opponentNoteHit(type, data)
	if isTv then
		if data == 0 then
			objectPlayAnimation("Tv", "left", true);
		end
		if data == 1 then
			objectPlayAnimation("Tv", "down", true);
		end
		if data == 2 then
			objectPlayAnimation("Tv", "up", true);
		end
		if data == 3 then
			objectPlayAnimation("Tv", "right", true);
		end
	end
end

function funnyColours()
	doTweenColor('bfShading', 'boyfriend', '7F7F7F', 0.001, 'linear');
	doTweenColor('dadShading', 'dad', '7F7F7F', 0.001, 'linear');
end

function unfunnyColours()
	doTweenColor('bfShading', 'boyfriend', 'FFFFFF', 0.001, 'linear');
	doTweenColor('dadShading', 'dad', 'FFFFFF', 0.001, 'linear');
end