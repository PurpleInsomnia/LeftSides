function onCreatePost()
    makeLuaSprite("black", "black", 0, 0);
    setObjectCamera("black", "video");
    setProperty("black.visible", false);
    addLuaSprite("black", true);
end

function onEvent(name, value1, value2)
    if name == "Toggle Screen" then
        if not getProperty("black.visible") then
            setProperty("black.visible", true);
            runTimer("showCheck", 0.1);
        else
            setProperty("black.visible", false);
            runTimer("hideCheck", 0.1);
        end
        -- funny compatability lol.
        if not getProperty("text.visible") then
			setProperty("text.visible", true);
			setProperty("bfIcon.visible", true);
		else
			setProperty("text.visible", false);
			setProperty("bfIcon.visible", false);
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