function onCreate()
    if not lowQuality then
        makeLuaSprite("sky", "more christmas/sky", 0, 0);
        addLuaSprite("sky", false);

        makeAnimatedLuaSprite('snowFall', 'christmas/fallingSnow', 0, 0);
	    addAnimationByPrefix('snowFall', 'idle', 'bad', 24, true);
	    objectPlayAnimation('snowFall', 'idle');
        screenCenter("snowFall", "xy");
	    addLuaSprite('snowFall', false);

        makeLuaSprite("bg", "more christmas/walls", 0, 0);
        addLuaSprite("bg", false);

        makeLuaSprite("floor", "more christmas/floor", 0, 0);
        addLuaSprite("floor", false);

        makeLuaSprite("bed", "more christmas/bed", 0, 0);
        addLuaSprite("bed", false);
    else
        makeLuaSprite("bg", "more christmas/bgLOWQUAL", 0, 0);
        addLuaSprite("bg", false);
    end

    makeLuaSprite("covers", "more christmas/covers", 0, 0);
    addLuaSprite("covers", true);

    makeLuaSprite("shader1", "more christmas/shaders1", 0, 0);
    setBlendMode("shader1", "add");
    addLuaSprite("shader1", true);

    makeLuaSprite("tree", "more christmas/tree", 0, 0);
    addLuaSprite("tree", true);

    makeLuaSprite("shader2", "more christmas/shaders2", 0, 0);
    setBlendMode("shader2", "add");
    addLuaSprite("shader2", true);
end

function onCreatePost()
    setProperty("gf.visible", false);
end