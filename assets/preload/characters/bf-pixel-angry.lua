function noteMiss()
	doTweenColor('pissShit', 'boyfirend', '8271A7', 0.00000000001, 'linear');
end

function goodNoteHit()
	doTweenColor('pissShit', 'boyfirend', 'FFFFFF', 0.00000000001, 'linear');
end

function onUpdate(elpased)
	if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
		doTweenColor('pissShit', 'boyfirend', 'FFFFFF', 0.00000000001, 'linear');
	end
	if getProperty('boyfriend.animation.curAnim.name') == 'death' then
		doTweenColor('pissShit', 'boyfirend', 'FFFFFF', 0.00000000001, 'linear');
	end
end