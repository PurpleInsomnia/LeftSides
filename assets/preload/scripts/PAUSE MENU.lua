-- THIS SCRIPT IS FOR THE PAUSE MENU!!!
-- DO NOT MESS WITH THIS!!!
-- PurpleInsomnia.
local pcc = false;
function onStartCountdown()
    pauseChar = getPropertyFromClass("PlayState", "SONG.player2");
    pcc = getProperty("preventPCChange");
    if not pcc then
        setProperty("pauseCharacter", pauseChar);
    end
end

function onEvent(name, value1, value2)
    if name == "Change Character" then
        pcc = getProperty("preventPCChange");
        if not pcc then
            setProperty("pauseCharacter", value2);
        end
    end
end