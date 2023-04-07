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
    if line == 14 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 15);
        doTrans();
    end
    if line == 21 then
        startMusic("fear");
    end
    if line == 31 then
        startMusic("stress");
    end
    if line == 40 then
        playSound("headache", 1, false);
    end
    if line == 47 then
        FADsound("headache", 1);
    end
    if line == 53 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 54);
        doTrans();
    end
    if line == 71 then
        setProperty("luaControlNext", true);
        setProperty("curLine", 72);
        doTrans();
    end
    if line == 72 then
        startMusic("fear");
    end
    if line == 78 then
        startMusic("stress");
        playSound("heartbeat", 1, true);
    end
    if line == 82 then
        FADsound("heartbeat", 2);
    end
    if line == 86 then
        playSound("heartbeat", 1, true);
        startMusic("stress");
    end
    if line == 94 then
        FADsound("heartbeat", 2);
    end
    if line == 105 then
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