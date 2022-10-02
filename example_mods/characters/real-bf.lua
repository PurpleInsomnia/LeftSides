function opponentNoteHit()
	health = getProperty('health');
	if health > 0.046 then
		setProperty('health', health - 0.023);
	end
end