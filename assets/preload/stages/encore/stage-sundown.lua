function onCreate()
	setProperty("bfZoom", true);
	-- background shit
	makeLuaSprite('stageback', 'encore/stagebackSUNDOWN', -600, -300);
	setScrollFactor('stageback', 0.9, 0.9);
	
	makeLuaSprite('stagefront', 'encore/stagefrontSUNDOWN', -650, 530);
	setScrollFactor('stagefront', 0.9, 0.9);
	scaleObject('stagefront', 1.1, 1.1);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		makeLuaSprite('stagelight_left', 'encore/stage_lightSUNDOWN', -125, -100);
		setScrollFactor('stagelight_left', 0.9, 0.9);
		scaleObject('stagelight_left', 1.1, 1.1);
		
		makeLuaSprite('stagelight_right', 'encore/stage_lightSUNDOWN', 1225, -100);
		setScrollFactor('stagelight_right', 0.9, 0.9);
		scaleObject('stagelight_right', 1.1, 1.1);
		setProperty('stagelight_right.flipX', true); --mirror sprite horizontally

		makeLuaSprite('stagecurtains', 'encore/stagecurtainsSUNDOWN', -400, -100);
		setScrollFactor('stagecurtains', 1.3, 1.3);
		scaleObject('stagecurtains', 0.9, 0.9);

		makeLuaSprite('stagelight', 'encore/stageShader', -600, -400);
		setProperty('stagelight.alpha', 0.5);
		setBlendMode('stagelight', 'hardlight');
	end

	addLuaSprite('stageback', false);
	addLuaSprite('stagefront', false);
	addLuaSprite('stagelight_left', false);
	addLuaSprite('stagelight_right', false);
	addLuaSprite('stagecurtains', true);
	addLuaSprite('stagelight', true);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end
