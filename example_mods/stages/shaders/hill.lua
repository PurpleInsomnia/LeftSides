function onCreate()
	doTweenColor('bfShading', 'boyfriend', '7F7F7F', 0.001, 'linear');
	doTweenColor('dadShading', 'dad', '7F7F7F', 0.001, 'linear');
	doTweenColor('gfShading', 'gf', '7F7F7F', 0.001, 'linear');

	makeLuaSprite('light', 'week2/spooky/streetlight', -200, -100);
	setObjectCamera("light", "camShader");
	setBlendMode('light', 'hardlight');
end