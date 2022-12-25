function onCreate()
    makeLuaSprite("bg", "ron/bg", 0, 0);
    addLuaSprite("bg", false);

    makeLuaSprite("dumbfloor", "ron/hill", 0, 0);
    addLuaSprite("dumbfloor", false);

    makeLuaSprite("fg", "ron/fg", 0, 50);
    setScrollFactor("fg", 1.2, 1.2);
    addLuaSprite("fg", true);

    makeLuaSprite("shader", "ron/shader", 0, 0);
    setBlendMode("shader", "add");
    addLuaSprite("shader", true);
end