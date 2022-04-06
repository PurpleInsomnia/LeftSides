local zoomBool = false; 
function onEvent(name, value1, value2)
	doodoo = tonumber(value1);
	shit = tonumber(value2);
	if name == 'Cam Tween Zoom' then
		if shit == '' then
			zoomBool = false;
			doTweenZoom('theUnfunnyZoom', 'camGame', doodoo, 0.5, 'sineIn');
		else
			zoomBool = false;  
			doTweenZoom('theFunnyZoom', 'camGame', doodoo, shit, 'linear');
		end
	end
end


function onTweenCompleted(tag)
	if tag == 'theFunnyZoom' then
		battlePass = getProperty('camGame.zoom');
		zoomBool = true;
	end
end

function onUpdate(elapsed)
	if zoomBool then
		setProperty('camGame.zoom', battlePass);
	end
end
