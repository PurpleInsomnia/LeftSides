function onStepHit()
    if curStep == 1 then
        doTweenY("dad", "dad", getProperty("dad.y") - 125, crochet / 250, "sineInOut");
    end
end

function onTweenCompleted(tag)
    if tag == "dad" then
        doTweenY("dadDown", "dad", getProperty("dad.y") + 125, crochet / 250, "sineInOut");
    end
    if tag == "dadDown" then
        doTweenY("dad", "dad", getProperty("dad.y") - 125, crochet / 250, "sineInOut");
    end
end