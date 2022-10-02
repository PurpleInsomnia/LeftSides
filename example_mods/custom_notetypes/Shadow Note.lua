function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Shadow Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'monster/shadowNotes');
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', 0.25);

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has no penalties
			end
		end
	end
end

function goodNoteHit(id, data, type, sussy)
	if type == "Shadow Note" then
		arrowAngle(45, 0.25, -1);
	end
end