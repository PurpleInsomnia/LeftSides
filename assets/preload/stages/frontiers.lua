function onCreatePost()
    if not lowQuality then
        makeLuaSprite("bg", "starfall/bg", 0, 0);
        addLuaSprite("bg", false);

        makeLuaSprite("fg", "starfall/fg", 0, 0);
        addLuaSprite("fg", false); 
    else
        makeLuaSprite("bg", "starfall/bgLOWQUAL", 0, 0);
        addLuaSprite("bg", false);
    end
    
    -- goofy ahh speakers
    makeAnimatedLuaSprite("speakers", "characters/Speakers", getProperty("gf.x"), 0);
    addAnimationByPrefix("speakers", "idle", "Speakers Idle", 24, false);
    objectPlayAnimation("speakers", "idle", true);
    addLuaSprite("speakers", false);

    setProperty("boyfriend.alpha", 0.5);

    setProperty("gf.x", getProperty("gf.x") + 200);
    setProperty("speakers.y", getProperty("gf.y") + 360);
    setProperty("gf.y", getProperty("gf.y") + 20);

    makeLuaSprite("shader", "starfall/shader", 0, 0);
    setBlendMode("shader", "multiply");
    addLuaSprite("shader", true);
end