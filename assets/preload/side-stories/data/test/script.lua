function onNextLinePost(line)
	if line == 3 then
		portMovement("spazz");
		playSound("vineboom");
	end
	if line == 4 then
		resetCharPos();
	end
	if line == 7 then
		portMovement("moveDown", false);
	end
end

function onNextLine(line)
	if line == 4 then
		cancelPortMovement("spazz");
	end
	if line == 8 then
		cancelPortMovement("moveDown");
	end
end