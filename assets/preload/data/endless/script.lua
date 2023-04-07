local created = false;
function onCreatePost()
	makeLuaSprite("redVG", "endless/vg", 0, 0);
	setProperty("redVG.alpha", 0);
	setObjectCamera("redVG", "camHUD");
	addLuaSprite("redVG", true);

	setProperty("botplayTxt.text", "FUN IS INFINITE");
	setProperty("customScoreTxt", true);

	makeWiggleEffect("sprite|iconP1", 'dreamy', 10, 10, 0.005);
	makeWiggleEffect("sprite|iconP2", 'dreamy', 10, 10, 0.005);
	created = true;

	setProperty("gameoverscript", "endless");
end

function onUpdate(elapsed)
	updateScoreTxt();
	if created then
		moveWiggleEffect(elapsed);
	end
end

function onUpdatePost(elapsed)
	updateScoreTxt();
	if created then
		moveWiggleEffect(elapsed);
	end
end

function updateScoreTxt()
	setProperty("scoreTxt.text", "FUN IS INFINITE: " .. score.. " | FUN IS INFINITE: " .. misses);
end

function onBeatHit()
	if curBeat % 4 == 0 then
		setProperty("redVG.alpha", 1);
		doTweenAlpha("redBGTween", "redVG", 0, getProperty("crochet") / 2000, "linear");
	end
end