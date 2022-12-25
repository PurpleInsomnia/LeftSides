function onCreate()
	makeLuaSprite('bg', 'pool/back', -200, -100);
	addLuaSprite('bg', false);

	makeLuaSprite('fg', 'pool/floor', -200, -100);
	addLuaSprite('fg', false);

	makeLuaSprite('front', 'pool/front', -200, -100);
	addLuaSprite('front', true);
end