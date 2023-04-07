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

function onEvent(name, value1, value2)
    if name == "Blammed Lights" and not value1 == "0" then
       doTweenAlpha("s1tweenin", "shader1", 0, 1, "linear");
       doTweenAlpha("s2tweenin", "shader2", 0, 1, "linear"); 
    end
    if name == "Blammed Lights" and value1 == "0" then
        doTweenAlpha("s1tweenout", "shader1", 1, 1, "linear");
       doTweenAlpha("s2tweenout", "shader2", 1, 1, "linear"); 
    end
end