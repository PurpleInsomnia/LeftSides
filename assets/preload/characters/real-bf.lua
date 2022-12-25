function opponentNoteHit(id, type, data, sussy)
	if not sussy then
		health = getProperty('health');
		if health > 0.046 then
			setProperty('health', health - 0.023);
		end
	end
end