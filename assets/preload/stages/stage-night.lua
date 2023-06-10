function onCreate()
	setProperty("bfZoom", true);
	
	-- background shit
	makeLuaSprite('stageback', 'stageNight/stageback', -600, -300);
	setScrollFactor('stageback', 0.9, 0.9);
	
	makeLuaSprite('stagefront', 'stageNight/stagefront', -650, 530);
	setScrollFactor('stagefront', 0.9, 0.9);
	scaleObject('stagefront', 1.1, 1.1);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		makeLuaSprite('stagelight_left', 'stageNight/stage_light', -125, -100);
		setScrollFactor('stagelight_left', 0.9, 0.9);
		scaleObject('stagelight_left', 1.1, 1.1);
		
		makeLuaSprite('stagelight_right', 'stageNight/stage_light', 1225, -100);
		setScrollFactor('stagelight_right', 0.9, 0.9);
		scaleObject('stagelight_right', 1.1, 1.1);
		setProperty('stagelight_right.flipX', true); --mirror sprite horizontally

		makeLuaSprite('stagecurtains', 'stageNight/stagecurtains', -400, -100);
		setScrollFactor('stagecurtains', 1.3, 1.3);
		scaleObject('stagecurtains', 0.9, 0.9);

		makeLuaSprite('stagelight', 'stageShader', -600, -400);
		setBlendMode('stagelight', 'hardlight');
		setProperty('stagelight.alpha', 0.75);

		makeLuaSprite('p', 'stageNight/stagefront', -650, 530);
		setScrollFactor('p', 0.9, 0.9);
		scaleObject('p', 1.1, 1.1);
		setProperty("p.alpha", 0);
		setProperty("p.particles", true);
		setProperty("p.particleColors", "0xFF4B85C2|0xFFFF00AA|0xFFFAC405|0xFF9339F8");
	end

	addLuaSprite('stageback', false);
	addLuaSprite('stagefront', false);
	addLuaSprite('stagelight_left', false);
	addLuaSprite('stagelight_right', false);
	addLuaSprite('stagecurtains', true);
	addLuaSprite('stagelight', true);
	addLuaSprite('p', true);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end
