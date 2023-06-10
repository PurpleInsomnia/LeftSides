function onStepHit()
    if curStep == 940 then
        setProperty("tessHead.visible", true);
        doTweenY("nooo", "tessHead", getProperty("tessHead.y") + 1108, crochet / 1000, "linear");
        characterPlayAnim("gf", "yoink", true);
        setProperty('gf.specialAnim', true);
        setProperty("gf.idleSuffix", "-alt");
    end
    if curStep == 960 then
        setProperty("tessHead.visible", false);
        setProperty('gf.specialAnim', false);
        triggerEvent("Change Character", "dad", "freeme-corpse");
    end
    if curStep == 1216 then
        triggerEvent("Change Character", "dad", "freeme-christmas");
    end
end