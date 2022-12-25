local isGod = true;
function onCreate()
	if not lowQuality then
		makeLuaSprite("bg", "god/bg", 0, 0);
		addLuaSprite("bg", false);

		makeLuaSprite("island", "god/islands", 0, 0);
		addLuaSprite("island", false);

		doTweenY("islandTween", "island", 100, 5, "linear:pingpong");
	else
		makeLuaSprite("bg", "god/bgLOWQUAL", 0, 0);
		addLuaSprite("bg", false);
	end

	makeLuaSprite("fg", "god/floor", 0, 0);
	addLuaSprite("fg", false);

	makeLuaSprite("fg2", "god/fg", 0, 0);
	setScrollFactor("fg2", 1.2, 1.2);
	addLuaSprite("fg2", true);

	makeLuaSprite('stageback', 'stageback', -600, -300);
	setScrollFactor('stageback', 0.9, 0.9);
	
	makeLuaSprite('stagefront', 'stagefront', -650, 530);
	setScrollFactor('stagefront', 0.9, 0.9);
	scaleObject('stagefront', 1.1, 1.1);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		makeLuaSprite('stagelight_left', 'stage_light', -125, -100);
		setScrollFactor('stagelight_left', 0.9, 0.9);
		scaleObject('stagelight_left', 1.1, 1.1);
		
		makeLuaSprite('stagelight_right', 'stage_light', 1225, -100);
		setScrollFactor('stagelight_right', 0.9, 0.9);
		scaleObject('stagelight_right', 1.1, 1.1);
		setProperty('stagelight_right.flipX', true); --mirror sprite horizontally

		makeLuaSprite('stagecurtains', 'stagecurtains', -400, -100);
		setScrollFactor('stagecurtains', 1.3, 1.3);
		scaleObject('stagecurtains', 0.9, 0.9);
	end

	addLuaSprite('stageback', false);
	addLuaSprite('stagefront', false);
	addLuaSprite('stagelight_left', false);
	addLuaSprite('stagelight_right', false);
	addLuaSprite('stagecurtains', true);

	setProperty("stageback.visible", false);
	setProperty("stagefront.visible", false);
	setProperty("stagelight_left.visible", false);
	setProperty("stagelight_right.visible", false);
	setProperty("stagecurtains.visible", false);
end

function changeStage(on)
	if on then
		setProperty("defaultCamZoom", 0.9);
		setProperty("dad.x", 400);
		setProperty("dad.y", 130);
		setProperty("boyfriend.x", 770);
		setProperty("boyfriend.y", 100);
		setProperty("stageback.visible", true);
		setProperty("stagefront.visible", true);
		setProperty("stagelight_left.visible", true);
		setProperty("stagelight_right.visible", true);
		setProperty("stagecurtains.visible", true);
	else
		setProperty("defaultCamZoom", 0.6);
		setProperty("dad.x", 400);
		setProperty("dad.y", 130);
		setProperty("boyfriend.x", 770);
		setProperty("boyfriend.y", 100);
		setProperty("stageback.visible", false);
		setProperty("stagefront.visible", false);
		setProperty("stagelight_left.visible", false);
		setProperty("stagelight_right.visible", false);
		setProperty("stagecurtains.visible", false);
	end
end