local notChanged = true;
function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is a Bullet Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Bullet Note Grey' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'pico/bullet_notes_grey'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', 0.25); --Change amount of health to take when you miss like a fucking moron
		end
	end
	--debugPrint('Script started!')

	precacheSound('bullet');
	precacheSound('bulletDown');
	precacheSound('bulletUp');
	-- precacheSound('gunCOCK(sus)');

	makeLuaSprite('screen', 'dialogueBgs/white', 0, 0);
	setObjectCamera('screen', 'hud');
	setProperty('screen.alpha', 0);
	addLuaSprite('screen', false);
end

-- Function called when you hit a note (after note hit calculations)
-- id: The note member id, you can get whatever variable you want from this note, example: "getPropertyFromGroup('notes', id, 'strumTime')"
-- noteData: 0 = Left, 1 = Down, 2 = Up, 3 = Right
-- noteType: The note type string/tag
-- isSustainNote: If it's a hold note, can be either true or false

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Bullet Note Grey' then
		triggerEvent('Screen Shake', '0.15, 0.005', '0.15, 0.005');
		if noteData == 0 then
			characterPlayAnim('boyfriend', 'dodgeLeft', true);
		end
		if noteData == 1 then
			characterPlayAnim('boyfriend', 'dodgeDown', true);
		end
		if noteData == 2 then
			characterPlayAnim('boyfriend', 'dodgeUp', true);
		end
		if noteData == 3 then
			characterPlayAnim('boyfriend', 'dodgeRight', true);
		end
		doTweenAlpha('dodgeFlash', 'screen', 0.15, 0.00000001, 'linear');
		setProperty('boyfriend.specialAnim', true);

		playSound('bullet', 0.5);

		characterPlayAnim('dad', 'shoot', true);
		setProperty('dad.specialAnim', true);

		characterPlayAnim('gf', 'scared', true);
		setProperty('gf.specialAnim', true);
	end
end

local healthDrain = 0;
function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Bullet Note Grey' then
		-- playSound('madnessCombatGruntDies');

		playSound('bullet');

		-- bf anim
		characterPlayAnim('boyfriend', 'hurt', true);
		setProperty('boyfriend.specialAnim', true);

		-- dad anim
		characterPlayAnim('dad', 'shoot', true);
		setProperty('dad.specialAnim', true);

		characterPlayAnim('gf', 'scared', true);
		setProperty('gf.specialAnim', true);

		--setProperty('health', getProperty('health') - 0.6);
		-- bruj that was some fucking shitty ass code right there.
		healthDrain = 0.6;
	end
end

local diffNum = 0;
function onUpdate(elapsed)
	diffNum = 0.075;
	if healthDrain > 0 then
		healthDrain = healthDrain - diffNum * elapsed;
		setProperty('health', getProperty('health') - (diffNum) * elapsed);
		if healthDrain < 0 then
			healthDrain = 0;
		end
	end

	if getProperty('boyfriend.animation.curAnim.name') == 'idle' or getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' or getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' or getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' or getProperty('boyfriend.animation.curAnim.name') == 'singUP' then 
		if getProperty('gf.animation.curAnim.name') == 'scared' then
			characterPlayAnim('gf', 'danceLeft', false);
			setProperty('gf.specialAnim', false);
			characterDance('gf');
		end
	end
end

function onTweenCompleted(tag)
	if tag == 'dodgeFlash' then
		doTweenAlpha('flashFade', 'screen', 0, 0.15, 'linear');
	end
end
