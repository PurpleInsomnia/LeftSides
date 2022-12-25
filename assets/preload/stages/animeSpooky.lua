function onCreate()
	makeLuaSprite('bg', 'anime/bgSPOOKY', 93, 75);
	scaleObject('bg', 3, 3);
	addLuaSprite('bg', false);

	makeLuaSprite('fg', 'anime/fgSpooky', 93, 75);
	scaleObject('fg', 3, 3);
	addLuaSprite('fg', false);

	makeLuaSprite('shader', 'anime/spookyShader', 0, 0);
	setGraphicSize('shader', 1280, 720);
	setObjetCamera('shader', 'camShader');
	setBlendMode('shader', 'multiply');
	addLuaSprite('shader', true);
end