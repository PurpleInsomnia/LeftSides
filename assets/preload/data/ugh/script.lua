function onCreatePost()
    makeLuaSprite("black", "black", 0, 0);
    setObjectCamera("black", "video");
    addLuaSprite("black", true);
end

function onStepHit()
    if curStep == 64 then
        setProperty("black.visible", false);
    end
    if curStep == 440 then
        triggerEvent("Lyrics", "Yeah!", "tankman");
    end
    if curStep == 944 then
        triggerEvent("Lyrics", "Heh.", "tankman");
    end
    if curStep == 952 then
        triggerEvent("Lyrics", "Heh. Pretty good!", "tankman");
    end
    if curStep == 447 or curStep == 959 then
        triggerEvent("Lyrics", "remove", "tankman");
    end
end