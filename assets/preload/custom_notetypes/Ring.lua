function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Ring' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'ring');
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true);
			-- setPropertyFromGroup('unspawnNotes', i, 'noteSplashTexture', 'ringSplashes');

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has no penalties
			end
		end
	end

	setProperty('isRing', true);

	setProperty('isSonicLua', true);

	precacheSound('ringCollect');
end


function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Ring' then
		playSound('ringCollect');
		changeRingCount(1);
	end
end