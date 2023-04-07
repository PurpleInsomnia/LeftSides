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
    if line == 17 then
        startMusic("fear");
    end
	if line == 30 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 31);
        doTrans();
	end
    if line == 56 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 57);
        doTrans();
	end
    if line == 57 then
        startMusic("visit");
    end
    if line == 80 then
		setProperty("luaControlNext", true);
        setProperty("curLine", 81);
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