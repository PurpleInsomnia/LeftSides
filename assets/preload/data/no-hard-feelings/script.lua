function onCreatePost()
    addShader("sprite", "boyfriend", "vcr");
    addShader("sprite", "gf", "vcr");

    makeLuaSprite("blackfadething", "black", 0, 0);
    setObjectCamera("blackfadething", "camHUD");
    addLuaSprite("blackfadething", true);
end

function onStepHit()
    if curStep == 1 then
        doTweenAlpha("thecooltween", "blackfadething", 0, 8.8, "linear");
    end
end