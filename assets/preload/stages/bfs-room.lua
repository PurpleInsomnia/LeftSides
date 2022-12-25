function onCreate()
	makeLuaSprite('bg','CasualFriday/roomWall', -200, -100);
	addLuaSprite('bg', false);

	makeLuaSprite('floorGang','CasualFriday/roomFloor', -200, -100);
	addLuaSprite('floorGang', false);

	makeLuaSprite('bed','CasualFriday/roomBed', -200, -100);
	addLuaSprite('bed', false);

	-- Care to explain why Gf's clothing is in there bf?
	makeLuaSprite('whatsInThere','CasualFriday/sussyBasket', -200, -100);
	addLuaSprite('whatsInThere', true);

	-- the covers make the bed look cool :sunglasses:
	makeLuaSprite('blankie','CasualFriday/covers', -200, -100);
	addLuaSprite('blankie', true);

	close(true);
end
