function onCreate()
	makeAnimatedLuaSprite('snowFall', 'christmas/fallingSnow', 0, 0);
	addAnimationByPrefix('snowFall', 'idle', 'bad', 24, true);
	objectPlayAnimation('snowFall', 'idle');
	addLuaSprite('snowFall', false);
	setObjectCamera('snowFall', 'hud');
	-- heheheha
end