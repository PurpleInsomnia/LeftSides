function onCreate()
	makeAnimatedLuaSprite("costume", "halloween/costume", 0, 0);
	addAnimationByPrefix("costume", "idle", "idle", 24, true);
	addLuaSprite("costume", true);
	setProperty("costume.visible", false);

	makeLuaSprite("bs", "blackScreen", 0, 0);
	setProperty("bs.alpha", 0);
	addLuaSprite("bs", true);
end

function onNextLinePost(line)
	if line == 0 then
		startMusic("halloween");
	end
	if line == 10 then
		timeCard("20");
	end
	if line == 13 then
		-- tess is the one who knocks.
		playSound("knock");
	end
	if line == 25 then
		setProperty("nextOnFinish", true);
	end
	if line == 35 then
		setProperty("nextOnFinish", false);
	end
	if line == 46 then
		timeCard("movie");
	end
	if line == 61 then
		timeCard("25cuddle");
	end
	if line == 70 then
		setProperty("costume.visible", true);
	end
	if line == 71 then
		setProperty("costume.visible", false);
	end
	if line == 75 then
		portMovement("moveDown", false);
	end
	if line == 80 then
		timeCard("week2");
	end
	if line == 96 then
		timeCard("seven");
	end
	if line == 101 then
		setProperty("luaControlNext", true);
		setProperty("curLine", 102);
		doTrans();
	end
	if line == 102 then
		setProperty("text.visible", true);
		setProperty("luaControlNext", false);
	end
	if line == 118 then
		startMusic("phoneRingtone", 0.8);
	end
end

function doTrans()
	blackFade("in", 3);
	startTimer("transTimer", 3);
end

function onTimerCompleted(tag)
	if tag == "transTimer" then
		preloadShit("sussybaka");
		loadBg("streetNight");
		reloadBox("tess");
		setProperty("curChar", "none");
		setProperty("text.visible", false);
		reloadPort("piss");
		blackFade("out", 3);
		startTimer("outTimer", 3);
	end
	if tag == "outTimer" then
		nextLine();
	end
end

function blackFade(type, sec)
	if type == "in" then
		doTweenAlpha("bsti", "bs", 1, sec, "linear");
	end
	if type == "out" then
		doTweenAlpha("bsto", "bs", 0, sec, "linear");
	end
end