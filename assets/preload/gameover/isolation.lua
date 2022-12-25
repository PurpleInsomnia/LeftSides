function onCreate()
    makeLuaSprite("bruhmoment", "lonely/yougotgames", 0, 0);
    setProperty("bruhmoment.alpha", 0);
    addLuaSprite("bruhmoment");

    makeLuaSprite("huh", "lonely/huh", 0, 0);
    setProperty("huh.alpha", 0);
    addLuaSprite("huh");

    playSound("isolationDeath");

    setProperty("musicName", "isolationGameOver");

    doTweenAlpha("theTween", "bruhmoment", 1, 1.5, "linear");
end

function onTweenCompleted(tag)
    if tag == "theTween" then
        playMusic(1, true);
        setProperty("canPress", true);
        doTweenAlpha("bruh", "huh", 1, 1, "linear");
    end
end

local can = false;
function onUpdate(elapsed)
    can = getProperty("canPress");
    if keyJustPressed("accept") and can then
        setProperty("canPress", false);
        setProperty("bruhmoment.alpha", 0);
        setProperty("huh.alpha", 0);
        switchState("bruh");
        playSound("isolationConfirm");
        cameraFlash("FF0000", 1, true);
    end
    if keyJustPressed("back") and can then
        setProperty("canPress", false);
        user = username();
        textFile("You're leaving me too, Tess???\nWhy....\n...I thought you cared about me...\n \nI guess not though. You see me as this...this fucking monster with sick desires...\nYou know that don't you " .. user .. "?\nHelp me.", "why are you leaving");
        back("bruh");
    end
end