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
        startMusic("goodMood");
    end
    if line == 15 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 16);
        doTrans();
    end
    if line == 25 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 26);
        doTrans();
    end
    if line == 34 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 35);
        doTrans();
    end
    if line == 42 then
        playSound("knockAngry");
    end
    if line == 43 then
        playSound("heartbeat", 1, true);
        startMusic("stress");
    end
    if line == 62 then
        FADsound("heartbeat", 2);
    end
    if line == 68 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 69);
        doTrans();
    end
    if line == 69 then
        startMusic("visit");
    end
    if line == 73 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 74);
        doTrans();
    end
    if line == 74 then
        startMusic("phoneRingtone");
    end
    if line == 75 then
        startMusic("casualSaturday");
    end
    if line == 88 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 89);
        doTrans();
    end
    if line == 108 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 109);
        doTrans();
    end
    if line == 133 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 134);
        doTrans();
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