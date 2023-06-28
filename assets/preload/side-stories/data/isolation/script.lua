function onCreate()
    makeLuaSprite("bs", "blackScreen", 0, 0);
	setProperty("bs.alpha", 0);
	addLuaSprite("bs", true);

    setProperty("stopClose", true);
end

function onNextLinePost(line)
    if getProperty("luaControlNext") then
        setProperty("text.visible", true);
		setProperty("luaControlNext", false);
    end
    if line == 6 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 7);
        doTrans();
    end
    if line == 7 then
        startMusic("fear");
    end
end

function doTrans()
	blackFade("in", 3);
	startTimer("transTimer", 3);
end

function onEnd()
    loadSong("Isolation", false, true);
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