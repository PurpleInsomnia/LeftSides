function onCreate()
	makeLuaSprite('bg','CasualFriday/night/roomWall', -200, -100);
	addLuaSprite('bg', false);

	makeLuaSprite('floorGang','CasualFriday/night/roomFloor', -200, -100);
	addLuaSprite('floorGang', false);

	makeLuaSprite('bed','CasualFriday/night/roomBed', -200, -100);
	addLuaSprite('bed', false);

	-- Care to explain why Gf's clothing is in there bf?
	makeLuaSprite('whatsInThere','CasualFriday/night/sussyBasket', -200, -100);
	addLuaSprite('whatsInThere', true);

	-- the covers make the bed look cool :sunglasses:
	makeLuaSprite('blankie','CasualFriday/night/covers', -200, -100);
	addLuaSprite('blankie', true);

	-- close(true);
end

function onStartCountdown()
	doTweenColor('bfShading', 'boyfriend', '7F7F7F', 0.001, 'linear');
	doTweenColor('dadShading', 'dad', '7F7F7F', 0.001, 'linear');
	doTweenColor('gfShading', 'gf', '7F7F7F', 0.001, 'linear');
end

function onUpdate(elapsed)
	if not mustHitSection then
		triggerEvent('Camera Follow Pos', 390, 325);
	else
		triggerEvent('Camera Follow Pos', 430, 325);
	end
end
