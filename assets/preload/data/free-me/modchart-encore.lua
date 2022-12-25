function onStepHit()
    if curStep == 1 then
        doModchart();
    end
end

local out = 0;
local out2 = 0;

function doModchart()
    out = defaultPlayerStrumX0 - 100;
    out2 = defaultPlayerStrumX3;

    for i = 4, 8 do
        if i == 4 or i == 5 then
            noteTweenX("notes x" .. i, i, out + (100 * (i - 4)), 2, "sineInOut:pingpong");
        else
            noteTweenX("notes x" .. i, i, out2 + (100 * (i - 6)), 2, "sineInOut:pingpong");
        end
        if i == 5 or i == 6 then
            noteTweenY("notes y" .. i, i, 125, 1, "sineInOut:pingpong");
        else
            noteTweenY("notes y" .. i, i, 100, 1, "sineInOut:pingpong");
        end
    end
end