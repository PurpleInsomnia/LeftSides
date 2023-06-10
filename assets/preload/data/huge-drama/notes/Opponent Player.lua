function onCreate()
    for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Opponent Player' then
            setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true);
        end
    end
end

function goodNoteHit(id, data, type, sussy)
    if type == "Opponent Player" then
        if data == 0 then
            characterPlayAnim("dad", "singLEFT", true);
        end
        if data == 1 then
            characterPlayAnim("dad", "singDOWN", true);
        end
        if data == 2 then
            characterPlayAnim("dad", "singUP", true);
        end
        if data == 3 then
            characterPlayAnim("dad", "singRIGHT", true);
        end
    end
end

function noteMiss(id, data, type, sussy)
    if type == "Opponent Player" then
        if data == 0 then
            characterPlayAnim("dad", "singLEFTmiss", true);
        end
        if data == 1 then
            characterPlayAnim("dad", "singDOWNmiss", true);
        end
        if data == 2 then
            characterPlayAnim("dad", "singUPmiss", true);
        end
        if data == 3 then
            characterPlayAnim("dad", "singRIGHTmiss", true);
        end
    end
end