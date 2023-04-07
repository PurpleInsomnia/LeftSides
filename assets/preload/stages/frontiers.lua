function onCreatePost()
    setProperty("bfZoom", true);
    
    if not lowQuality then
        makeLuaSprite("bg", "starfall/bg", 0, 0);
        addLuaSprite("bg", false);

        makeLuaSprite("fg", "starfall/fg", 0, 0);
        addLuaSprite("fg", false); 
    else
        makeLuaSprite("bg", "starfall/bgLOWQUAL", 0, 0);
        addLuaSprite("bg", false);
    end

    makeLuaSprite("shader", "starfall/shader", 0, 0);
    setBlendMode("shader", "multiply");
    addLuaSprite("shader", true);
end