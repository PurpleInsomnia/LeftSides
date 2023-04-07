function onCreate()
    makeLuaSprite("bruhmoment", "fortniteBoots/death", 0, 0);
    setProperty("bruhmoment.alpha", 0);
    addLuaSprite("bruhmoment");

    playSound("VINEBOOM");

    setProperty("musicName", "gameOver");

    doTweenAlpha("theTween", "bruhmoment", 1, 1.5, "linear");

    cameraFlash("FF0000", 1, true);
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
        switchState("bruh");
        playSound("vConfirm");
    end
    if keyJustPressed("back") and can then
        setProperty("canPress", false);
        back("bruh");
    end
end