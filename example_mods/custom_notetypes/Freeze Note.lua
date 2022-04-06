local healthFrozen = false;
local outlineVisible = false;
function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Freeze Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'christmas/freezeNotes');

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has no penalties
			end
		end
	end
	
	makeLuaSprite('cloud', 'freezeCloud', 0, 0);
	addLuaSprite('cloud', false);
	
	makeLuaSprite('outline', 'freezeOutline', 0, 0);
	addLuaSprite('outline', true);

	makeLuaSprite('bar', 'frozenHealthBar', getProperty('healthBar.x'), getProperty('healthbar.y'));
	addLuaSprite('bar', true);
	-- he he he ha
	
	setObjectCamera('cloud', 'hud');
	setObjectCamera('outline', 'hud');
	setObjectCamera('bar', 'hud');
	
	setPropertyLuaSprite('cloud', 'alpha', 0);
	setPropertyLuaSprite('outline', 'alpha', 0);
	setPropertyLuaSprite('bar', 'alpha', 0);
end


function goodNoteHit(id, noteData, noteType, isSustainNote)
	health = getProperty('health');
	if noteType == 'Freeze Note' then
		setProperty('outline.visible', true);
		outlineVisible = true;
		doTweenAlpha('freezeOn', 'cloud', 1, 0.1, 'linear');
		doTweenAlpha('outlineOn', 'outline', 1, 0.75, 'linear');
		doTweenAlpha('eggman', 'bar', 1, 0.75, 'linear');
		if gfSing then
			setProperty('health', health - 0.05);
		end
		if duet then
			setProperty('health', health - 0.1);
		end
		if not gfSing then
			setProperty('health', health - 0.15);
		end
		if not duet then
			setProperty('health', health - 0.15);
		end
		
		-- Other Funny Stuff
		
		playSound('freeze');

		healthFrozen = true;

		runTimer('healthBarThaw', 10);
	end
end

function onUpdate(elapsed)
	health = getProperty('health');
	if healthFrozen then
		if health >= 1.5 then
			setProperty('health', 1.5);
		end
	end
end

function onTimerCompleted(tag)
	if tag == 'healthBarThaw' then
		outlineVisible = false;
		doTweenAlpha('cock', 'outline', 0, 1, 'linear');
		doTweenAlpha('shadow', 'bar', 0, 1, 'linear');
		healthFrozen = false;
		playSound('thaw')
	end
end

function onTweenCompleted(tag)
	if outlineVisible then
		if tag == 'outlineOn' then
			doTweenAlpha('outlineOff', 'outline', 0.5, 1, 'linear');
		end
		if tag == 'outlineOff' then
			doTweenAlpha('outlineOn', 'outline', 1, 1, 'linear')
		end
	end
	if tag == 'freezeOn' then
		doTweenAlpha('freezeOff', 'cloud', 0, 5, 'linear');
	end
end
