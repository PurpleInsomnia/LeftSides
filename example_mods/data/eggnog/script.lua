function onCreate()
	changeIconP2('parents-alt');

	setProperty('boppersAlt.visible', true);

	-- doTweenY('theFortnite', 'gf',  gfY + gfTweenVal, 0.001, 'sineIn');

	setProperty('bottomBoppersAlt.visible', true);
	setProperty('bottomBoppers.visible', false);
end

function onChristmasCountdown()
	runTimer('startDialogue', 0.8);
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDialogue('dialogue', 'no-music');
	end
end