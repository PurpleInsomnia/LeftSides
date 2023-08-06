function onCreate()
    makeLuaSprite("bs", "blackScreen", 0, 0);
	setProperty("bs.alpha", 0);
	addLuaSprite("bs", true);

    startMusic("visit");
end

function onNextLinePost(line)
	if getProperty("luaControlNext") then
        setProperty("text.visible", true);
		setProperty("luaControlNext", false);
    end
    if line == 8 then
        playSound("phoneNotif", 0.8);
    end
    if line == 10 then
        textMessages("shopMessage1");
    end
    if line == 13 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 14);
        doTrans();
    end
    if line == 18 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 19);
        doTrans();
    end
    if line == 30 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 31);
        doTrans();
	end
    if line == 50 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 51);
        doTrans();
	end
    if line == 66 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 67);
        doTrans();
        stopMusic(1);
    end
    if line == 79 then
        startMusic("waterworks");
    end
    if line == 88 then
        stopMusic(1);
    end
    if line == 108 then
        startMusic("worries");
    end
end

function doTrans()
	blackFade("in", 3);
	startTimer("transTimer", 3);
end

function onTimerCompleted(tag)
	if tag == "transTimer" then
		preloadShit("sussybaka");
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