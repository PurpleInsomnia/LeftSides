function onCreate()
    makeLuaSprite("bs", "blackScreen", 0, 0);
	setProperty("bs.alpha", 0);
	addLuaSprite("bs", true);
end

function onNextLinePost(line)
    if getProperty("luaControlNext") then
        setProperty("text.visible", true);
		setProperty("luaControlNext", false);
    end
    if line == 0 then
        startMusic("visit");
    end
    if line == 13 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 14);
        doTrans();
    end
    if line == 26 then
        timeCard("few");
    end
    if line == 49 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 50);
        doTrans();
    end
    if line == 71 then
        startMusic("waterworks");
    end
    if line == 79 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 80);
        doTrans();
    end
    if line == 109 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 110);
        doTrans();
    end
    if line == 110 then
        startMusic("fear");
    end
    if line == 118 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 119);
        doTrans();
    end
    if line == 139 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 140);
        doTrans();
    end
    if line == 140 then
        startMusic("softRain");
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