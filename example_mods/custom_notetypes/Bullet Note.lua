function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is a Bullet Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Bullet Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'pico/bullet_notes'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', 0.6); --Change amount of health to take when you miss like a fucking moron
		end
	end
	--debugPrint('Script started!')

	precacheSound('bullet');
	precacheSound('bulletDown');
	precacheSound('bulletUp');
	-- precacheSound('gunCOCK(sus)');
end

-- Function called when you hit a note (after note hit calculations)
-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
-- noteType: The note type string/tag
-- isSustainNote: If it's a hold note, can be either true or false

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Bullet Note' then
		characterPlayAnim('boyfriend', 'dodge', true);
		setProperty('boyfriend.specialAnim', true);

		if noteData == 0 then
			playSound('bullet');
		elseif noteData == 1 then
			playSound('bulletDown');
		elseif noteData == 2 then
			playSound('bulletUp');
		elseif noteData == 3 then
			playSound('bullet');
		end
		characterPlayAnim('dad', 'shoot', true);
		setProperty('dad.specialAnim', true);
	end
end

local healthDrain = 0;
function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Bullet Note' then
		playSound('madnessCombatGruntDies');
		if noteData == 0 then
			playSound('bullet', 2);
		elseif noteData == 1 then
			playSound('bulletDown', 2);
		elseif noteData == 2 then
			playSound('bulletUp', 2);
		elseif noteData == 3 then
			playSound('bullet', 2);
		end
		-- bf anim
		characterPlayAnim('boyfriend', 'hurt', true);
		setProperty('boyfriend.specialAnim', true);

		-- dad anim
		characterPlayAnim('dad', 'shoot', true);
		setProperty('dad.specialAnim', true);

		--setProperty('health', getProperty('health') - 0.6);
		healthDrain = healthDrain + 0.6;
	end
end

local diffNum = 0;
function onUpdate(elapsed)
	if difficulty == 0 then
		diffNum = 0.05;
	end
	if difficulty == 1 then
		diffNum = 0.1;
	end 
	if difficulty == 2 then
		diffNum = 0.2;
	end  
	if healthDrain > 0 then
		healthDrain = healthDrain - diffNum * elapsed;
		setProperty('health', getProperty('health') - diffNum * elapsed);
		if healthDrain < 0 then
			healthDrain = 0;
		end
	end
end
