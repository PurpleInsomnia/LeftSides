function onCreate()
	makeLuaSprite('bg', 'mazin/bg', 93, 75);
	scaleObject('bg', 3, 3);
	addLuaSprite('bg', false);

	makeLuaSprite('fg', 'mazin/fg', 93, 75);
	scaleObject('fg', 3, 3);
	addLuaSprite('fg', false);

	makeLuaSprite('vg', 'mazin/vg', 0, 0);
	setObjectCamera('vg', 'other');
	setProperty('vg.alpha', 0.75);
	addLuaSprite('vg', true);

	makeLuaSprite('shader', 'mazin/shader', 0, 0);
	setProperty('shader.alpha', 0.8);
	setObjectCamera('shader', 'camShader');
	setBlendMode('shader', 'multiply');
	addLuaSprite('shader', true);
end