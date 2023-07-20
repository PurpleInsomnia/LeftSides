function onCreate()
    makeLuaSprite("kyleCrane", "fortniteBoots/crane", 0, 0);
    setObjectCamera("kyleCrane", "camHUD");
    setProperty("kyleCrane.visible", false);
    addLuaSprite("kyleCrane", true);

    setFCRanks("YAY!!11!!", "Close Enough", "Rigged");

    setProperty("gameoverscript", "manipulation");
end

function onBeatHit()
    if curBeat > 32 then
        if curStep < 943 then
            if curBeat % 2 == 0 then
                triggerEvent("Add Camera Zoom", "0.02", "0.02");
            end
        end
    end
end

function onStepHit()
    if curStep == 943 then
        setProperty("kyleCrane.visible", true);
    end
end