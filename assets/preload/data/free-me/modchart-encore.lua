function onStepHit()
    if curStep == 1 and not tpm then
        doModchart();
    end
end

local out = 0;
local out2 = 0;
local trueY = 0;
local daMult = 0;

function doModchart()
    out = defaultPlayerStrumX0 - 100;
    out2 = defaultPlayerStrumX3;
    trueY = defaultPlayerStrumY0;
    if downscroll then
        daMult = -1;
    else
        daMult = 1;
    end

    for i = 4, 8 do
        if i == 4 or i == 5 then
            noteTweenX("notes x" .. i, i, out + (100 * (i - 4)), 2, "sineInOut:pingpong");
        else
            noteTweenX("notes x" .. i, i, out2 + (100 * (i - 6)), 2, "sineInOut:pingpong");
        end
        if i == 5 or i == 6 then
            noteTweenY("notes y" .. i, i, (trueY + (55 * daMult)), 1, "sineInOut:pingpong");
        else
            noteTweenY("notes y" .. i, i, (trueY + (30 * daMult)), 1, "sineInOut:pingpong");
        end
    end
end