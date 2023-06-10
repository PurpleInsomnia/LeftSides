function onCreatePost()
    makeLuaSprite("black", "black", 0, 0);
    setObjectCamera("black", "video");
    setProperty("black.visible", false);
end

function onEvent(name, value1, value2)
    if name == "Toggle Screen" then
        if value1 == "false" then
            addLuaSprite("black", false);
        else
            addLuaSprite("black", true);
        end
        if not getProperty("black.visible") then
            setProperty("black.visible", true);
            runTimer("showCheck", 0.1);
        else
            setProperty("black.visible", false);
            removeLuaSprite("black", false);
            runTimer("hideCheck", 0.1);
        end
        triggerEvent("Screen Flash", "", "");
    end
end

function onTimerCompleted(tag)
    if tag == "hideCheck" and getProperty("black.visible") then
        setProperty("black.visible", false);
    end
    if tag == "showCheck" and not getProperty("black.visible") then
        setProperty("black.visible", true);
    end
end