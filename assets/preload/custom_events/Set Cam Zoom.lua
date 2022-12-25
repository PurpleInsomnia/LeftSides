local instantramen = false;
local tweenRamen = false;
-- tween ramen needs to be modified by lua!!!
-- if you want to make a normal tween after a ramen zoom , add "tweenRamen = false" to your lua script.
function onEvent(name, value1, value2)
	if name == "Set Cam Zoom" then      
	        if value2 == '' then
		  cancelTween('camz');
		  instantramen = true;
	      	  setProperty(camera.zoom, value1);
		else
		    instantramen = false;
	            doTweenZoom('camz', 'camGame', tonumber(value1), tonumber(value2), 'sineIn');
		    -- runTimer('dumb', tonumber(value2));
		end            
	end
end

function onUpdate(elapsed)
	if instantramen then
		setProperty('camGame.zoom', tonumber(value1));
	end
end
