function onCreate()
	makeLuaSprite("bs", "blackScreen", 0, 0);
	setProperty("bs.alpha", 0);
	addLuaSprite("bs", true);

	makeLuaSprite("note", "note", 0, 0);
	setProperty("note.alpha", 0);
	addLuaSprite("note", true);
end

function onNextLinePost(line)
	if line == 18 then
		startMusic("waterworks");
	end
	if line == 23 then
		setProperty("luaControlNext", true);
		setProperty("curLine", 24);
		doTrans();
	end
	if line == 24 then
		setProperty("text.visible", true);
		setProperty("luaControlNext", false);
	end
	if line == 30 then
		setProperty("luaControlNext", true);
		setProperty("curLine", 31);
		doTrans();
	end
	if line == 31 then
		startMusic("monsterLair");
		setProperty("text.visible", true);
		setProperty("luaControlNext", false);
		setProperty("port.visible", true);
	end
	if line == 55 then
		setProperty("luaControlNext", true);
		setProperty("bs.alpha", 1);
		setProperty("curLine", 56);
		playSound("monsterKillsTess");
		startTimer("cutsceneFinish", 6.85);
	end
	if line == 56 then
		playSound("tessScream");
		setProperty("curLine", 57);
		startTimer("cutsceneFinish", 6);
	end
	if line == 57 then
		setProperty("bs.alpha", 0);
		setProperty("luaControlNext", false);
	end
	if line == 61 then
		startMusic("waterworks");
	end
	if line == 84 then
		setProperty("luaControlNext", true);
		setProperty("curLine", 85);
		doTrans();
	end
	if line == 85 then
		setProperty("text.visible", true);
		setProperty("luaControlNext", false);
	end
	if line == 90 then
		setProperty("canPress", false);
		showNote();
	end
	if line == 91 then
		doTweenAlpha("bruhTween", "note", 0, 0.5, "linear");
	end
end

function doTrans()
	blackFade("in", 3);
	startTimer("transTimer", 3);
end

function showNote()
	doTweenAlpha("noteTween", "note", 1, 1, "linear");
end

function onTimerCompleted(tag)
	if tag == "transTimer" then
		preloadShit("sussybaka");
		if curLine == 24 then
			loadBg("benRoomNight");
		end
		if curLine == 31 then
			loadBg("monsterLair");
			setProperty("port.visible", false);
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
	if tag == "cutsceneFinish" then
		nextLine();
	end
end

function onTweenCompleted(tag)
	if tag == "noteTween" then
		setProperty("canPress", true);
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