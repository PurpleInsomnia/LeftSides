local created = false;
function onCreate()
    -- image width should roughly be defaulted to 2880 x 1620

    makeLuaSprite("bg", "fortniteBoots/bg", 0, 0);
    addLuaSprite("bg", false);

    makeLuaSprite("fg", "fortniteBoots/fg", 0, 0);
    addLuaSprite("fg", false);

    makeWiggleEffect('sprite|bg', 'dreamy', 1, 10, 0.05);
	created = true;
end

function onUpdate(elapsed)
    if created then
        moveWiggleEffect(elapsed);
    end
end