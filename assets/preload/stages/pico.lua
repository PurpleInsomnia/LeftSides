function onCreate()
    makeLuaSprite("bg", "philly/bg", 0, 0);
    addLuaSprite("bg", false);

    makeLuaSprite("shader1", "philly/shader1", 0, 0);
    setBlendMode("shader1", "multiply");
    addLuaSprite("shader1", true);

    makeLuaSprite("shader2", "philly/shader2", 0, 0);
    setBlendMode("shader2", "add");
    addLuaSprite("shader2", true);
end