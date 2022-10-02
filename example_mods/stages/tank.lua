function onCreate()
	makeLuaSprite('bg', 'tank/tankSky', -400, -350);
	setScrollFactor('bg', 0, 0);
	addLuaSprite('bg', false);

	makeLuaSprite('moon', 'tank/moonAndStars', -400, -350);
	setScrollFactor('moon', 0, 0);
	addLuaSprite('moon', false);

	makeLuaSprite('clouds', 'tank/tankClouds', math.floor(math.random(-700, -100)), math.floor(math.random(-20, 20)));
	setScrollFactor('clouds', 0.1, 0.1);
	addLuaSprite('clouds', false);

	makeLuaSprite('mountains', 'tank/tankMountains', -150, -20);
	setScrollFactor('mountains', 0.2, 0.2);
	addLuaSprite('mountains', false);

	if not lowQuality then
		makeLuaSprite('ruins', 'tank/tankRuins', -200, 50);
		setScrollFactor('ruins', 0.35, 0.35);
		addLuaSprite('ruins', false);

		addLuaSprite('smokeLeft', false);
		addLuaSprite('smokeRight', false);
	end

	makeAnimatedLuaSprite('tower', 'tank/tankWatchtower', 100, 50);
	addAnimationByPrefix('tower', 'idle', 'watchtower gradient color', 24, false);
	setScrollFactor('tower', 0.5, 0.5);
	addLuaSprite('tower', false);

	makeAnimatedLuaSprite('steve', 'tank/tankRolling', 300, 300);
	addAnimationByPrefix('steve', 'idle', 'BG tank w lighting', 24, true);
	objectPlayAnimation('steve', 'idle');
	setScrollFactor('steve', 0.5, 0.5);
	addLuaSprite('steve', false);

	-- for stress
	if not lowQuality then
		makeAnimatedLuaSprite('tankrunLeft', 'tank/tankmanKilled1', 0, 0);
		addAnimationByPrefix('tankrunLeft', 'run', 'tankman running', 24, true);
		addAnimationByPrefix('tankrunLeft', 'shot', 'John Shot', 24, false);
		objectPlayAnimation('tankrunLeft', 'run');
		addLuaSprite('tankrunLeft', false);

		makeAnimatedLuaSprite('tankrunRight', 'tank/tankmanKilled1', 0, 0);
		addAnimationByPrefix('tankrunRight', 'run', 'tankman running', 24, true);
		addAnimationByPrefix('tankrunRight', 'shot', 'John Shot', 24, false);
		objectPlayAnimation('tankrunRight', 'run');
		addLuaSprite('tankrunRight', false);

		setProperty('tankrunRight.flipX', true);

		setProperty('tankrunLeft.visible', false);
		setProperty('tankrunRight.visible', false);
	end

	makeLuaSprite('ground', 'tank/tankGround', -470, -150);
	addLuaSprite('ground', false);

	-- the funny people at the bottom :)
	if not lowQuality then
		makeAnimatedLuaSprite('tankPeep', 'tank/tankPeep', -420, 550);
		addAnimationByPrefix('tankPeep', 'idle', 'fg bop', 24, false);
		setScrollFactor('tankPeep', 2, 0.2);
		addLuaSprite('tankPeep', true);
		setProperty('tankPeep.visible', false);
	end

	-- moveTank();

	-- coolswag stuff B)
	gX = getProperty('ground.x');
	gW = getProperty('ground.width');

	setProperty('steve.x', gX - 200);
	setProperty('steve.angle', 10);	
end

local tweening = false;
function onBeatHit()
	objectPlayAnimation('tower', 'idle', true);
	objectPlayAnimation('tankPeep', 'idle', true);
	if not tweening then
		moveTank();
	end
end

function moveTank()
	doTweenX('tankX', 'steve', gW, 15, 'linear');
	tweening = true;
end

function onTweenCompleted(tag)
	if tag == 'tankX' then
		tweening = false;
		setProperty('steve.x', gX - 200);
	end
end