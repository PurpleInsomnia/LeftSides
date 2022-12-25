function onCreate()
	makeLuaSprite("bs", "blackScreen", 0, 0);
	setProperty("bs.alpha", 0);
	addLuaSprite("bs", true);

	startMusic("casualSaturday");
end

function onNextLinePost(line)
	if line == 15 then
		timeCard("five");
	end
	if line == 24 then
		setProperty("luaControlNext", true);
		setProperty("curLine", 25);
		doTrans();
	end
	if line == 25 then
		setProperty("text.visible", true);
		setProperty("luaControlNext", false);
		startMusic("remember");
	end
	if line == 46 then
		setProperty("luaControlNext", true);
		setProperty("curLine", 47);
		doTrans();
	end
	if line == 47 then
		setProperty("text.visible", true);
		setProperty("luaControlNext", false);
	end
	if line == 52 then
		startMusic("waterworks");
	end
	if line == 59 then
		setProperty("luaControlNext", true);
		setProperty("curLine", 60);
		doTrans();
	end
	if line == 60 then
		setProperty("text.visible", true);
		setProperty("luaControlNext", false);
	end
end

function onEnded(line)
	if line == 35 then
		setProperty("canPress", false);
		funnyJumpscare();
	end
end

function funnyJumpscare()
	loadBg("bloody");
	setProperty("box.visible", false);
	setProperty("text.visible", false);
	playSound("jumpscare");
	startTimer("jumpTime", 1);
end

function doTrans()
	blackFade("in", 3);
	startTimer("transTimer", 3);
end

function onTimerCompleted(tag)
	if tag == "transTimer" then
		preloadShit("sussybaka");
		if curLine == 25 then
			loadBg("benKitchen");
		end
		setProperty("curChar", "none");
		setProperty("text.visible", false);
		reloadPort("piss");
		blackFade("out", 3);
		startTimer("outTimer", 3);
	end
	if tag == "outTimer" then
		nextLine();
	end
	if tag == "jumpTime" then
		setProperty("curLine", 36);
		setProperty("canPress", true);
		nextLine();
		loadBg("none");
		setProperty("box.visible", true);
		setProperty("text.visible", true);
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