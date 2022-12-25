function onCreate()
    makeLuaSprite("bg", "endless/bg", 0, 0);
    addLuaSprite("bg", false);

    if not lowQuality then
        makeLuaSprite("backdrop", "endless/backdrop", 0, 0);
        addLuaSprite("backdrop", false);

        doTweenX("bdtx", "backdrop", -2560, 2, "sineInOut:pingpong");
        doTweenY("bdty", "backdrop", -1440, 2, "sineInOut:pingpong");
    end

    makeLuaSprite("fg", "endless/floor", 0, 0);
    addLuaSprite("fg", false);

    makeLuaSprite("shader", "endless/shader", 0, 0);
    setBlendMode("shader", "multiply");
    addLuaSprite("shader", true);
end