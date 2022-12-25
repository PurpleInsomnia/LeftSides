function onCreate()
    makeLuaSprite("yougoodbro", "endless/bro", 0, 0);
    setProperty("yougoodbro.alpha", 0);
    addLuaSprite("yougoodbro");

    makeLuaSprite("selector", "endless/selector", 0, 0);
    loadGraphic("selector", "endless/selector", true, 1280, 720);
    addGraphicAnimation("selector", "animation0", "0", 1, true);
    addGraphicAnimation("selector", "animation1", "1", 1, true);
    objectPlayAnimation("selector", "animation0", true);
    addLuaSprite("selector");

    playSound("deathCD");
    setProperty("musicName", "gameOverCD");

    doTweenAlpha("the tween", "yougoodbro", 1, 1, "linear");
    doTweenAlpha("selectorTween", "selector", 1, 1, "linear");

    cameraFlash("FF7200", 1, true);
end

function onTweenCompleted(tag)
    if tag == "the tween" then
        setProperty("canPress", true);
        playMusic(1, true);
    end
end

local can = false;
local curSelected = 0;
function onUpdate(elapsed)
    can = getProperty("canPress");
    if keyJustPressed("accept") and can then
        setProperty("canPress", false);
        if curSelected == 0 then
            switchState("bruh");
            playSound("CDcontinue");
            doTweenAlpha("the tween 2", "yougoodbro", 0, 1, "linear");
            doTweenAlpha("selectorTween", "selector", 0, 1, "linear");
        else
            back("bruh");
        end
    end

    if keyJustPressed("left") and can then
        playSound("CDscroll");
        changeSelection(-1);
    end
    if keyJustPressed("right") and can then
        playSound("CDscroll");
        changeSelection(1);
    end
end

function changeSelection(huh)
    curSelected = curSelected + huh;

    if curSelected > 1 then
        curSelected = 0;
    elseif curSelected < 0 then
        curSelected = 1;
    end

    objectPlayAnimation("selector", "animation" .. curSelected, true);
end