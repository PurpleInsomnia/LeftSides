function onCreate()
	makeLuaSprite("bs", "blackScreen", 0, 0);
	setProperty("bs.alpha", 0);
	addLuaSprite("bs", true);
end

function onNextLinePost(line)
    if line == 0 then
        startMusic("badThoughts");
    end
    if line == 11 then
        setProperty("nextOnFinish", true);
    end
    if line == 12 then
        playSound("knock");
        setProperty("nextOnFinish", false);
    end
    if line == 14 then
        setProperty("luaControlNext", true);
		setProperty("curLine", 15);
		doTrans();
    end
    if line == 15 then
        setProperty("text.visible", true);
		setProperty("luaControlNext", false);
        startMusic("visit");
    end
    if line == 29 then
        setProperty("luaControlNext", true);
		setProperty("curLine", 30);
		doTrans();
    end
    if line == 30 then
        setProperty("text.visible", true);
		setProperty("luaControlNext", false);
    end
    if line == 38 then
        setProperty("luaControlNext", true);
		setProperty("curLine", 39);
		doTrans();
    end
    if line == 39 then
        setProperty("text.visible", true);
		setProperty("luaControlNext", false);
    end
    if line == 48 then
        setProperty("luaControlNext", true);
		setProperty("curLine", 49);
		doTrans();
    end
    if line == 49 then
        setProperty("text.visible", true);
		setProperty("luaControlNext", false);
        startMusic("dream");
    end
    if line == 54 then
        startMusic("visit");
    end
    if line == 70 then
        setProperty("luaControlNext", true);
		setProperty("curLine", 71);
		doTrans();
    end
    if line == 71 then
        setProperty("text.visible", true);
		setProperty("luaControlNext", false);
    end
end

function doTrans()
	blackFade("in", 3);
	startTimer("transTimer", 3);
end

function onTimerCompleted(tag)
	if tag == "transTimer" then
        preloadShit("sussybaka");
		setProperty("text.visible", false);
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