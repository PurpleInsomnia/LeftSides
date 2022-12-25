function opponentNoteHit(id, type, data, sus)
    triggerEvent("Screen Shake", 0.005, 0.25);
    -- goofy ahh uncle production.
    if not sus then
        arrowAngle(360, 0.25, data);
    end
end