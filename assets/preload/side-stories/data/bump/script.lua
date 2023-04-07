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
        startMusic("morningWalk");
    end
	if line == 18 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 19);
        doTrans();
	end
    if line == 25 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 26);
        doTrans();
	end
    if line == 43 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 44);
        doTrans();
	end
    if line == 65 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 66);
        doTrans();
	end
    if line == 83 then
        startMusic("visit");
    end
    if line == 88 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 89);
        doTrans();
	end
    if line == 98 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 99);
        doTrans();
	end
    if line == 99 then
        startMusic("waterworks");
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