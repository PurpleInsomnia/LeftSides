function onCreate()
	if not lowQuality then
		makeAnimatedLuaSprite('christmasBg', 'christmas/christmasBg', -1200, -500);
		addAnimationByPrefix('christmasBg', 'idle', 'snowFall', 24, true);
		objectPlayAnimation('christmasBg', 'idle');
		addLuaSprite('christmasBg', false);
	else
		makeLuaSprite('androidBg', 'christmas/androidBg', -1200, -500);
		addLuaSprite('androidBg', false);
	end

	if not lowQuality then
		makeAnimatedLuaSprite('boppers', 'christmas/upperBoppers', -540, -90);
		addAnimationByPrefix('boppers', 'idle', 'Upper Crowd Bob', 24, false);
		addLuaSprite('boppers', false);

		makeAnimatedLuaSprite('boppersAlt', 'christmas/upperBoppersALT', -540, -90);
		addAnimationByPrefix('boppersAlt', 'idle', 'Upper Crowd Bob', 24, false);
		addLuaSprite('boppersAlt', false);

		makeLuaSprite('escalator', 'christmas/bgEscalator', -1400, -600);
		addLuaSprite('escalator', false);

		-- dumb things
		setProperty('boppers.visible', false);
		setProperty('boppersAlt.visible', false);
	end

	makeLuaSprite('tree', 'christmas/tree', 270, -250);
	addLuaSprite('tree', false);

	makeAnimatedLuaSprite('bottomBoppers', 'christmas/bottomBop', -300, 140);
	addAnimationByPrefix('bottomBoppers', 'idle', 'boppers bop', 24, false);
	addLuaSprite('bottomBoppers', false);

	makeAnimatedLuaSprite('bottomBoppersAlt', 'christmas/bottomBopALT', -300, 140);
	addAnimationByPrefix('bottomBoppersAlt', 'idle', 'boppers bop', 24, false);
	addLuaSprite('bottomBoppersAlt', false);
	setProperty('bottomBoppersAlt.visible', false);

	makeLuaSprite('darkBg', 'christmas/black',  -540, -90);
	addLuaSprite('darkBg', false);
	setProperty('darkBg.alpha', 0);

	makeLuaSprite('dumbSnow', 'christmas/floorSnow', -800, 890);
	addLuaSprite('dumbSnow', false);

	makeLuaSprite('fgSnow', 'christmas/floorSnow', -800, 690);
	addLuaSprite('fgSnow', false);
	
	makeAnimatedLuaSprite('santa', 'christmas/santa', -840, 150);
	addAnimationByPrefix('santa', 'idle', 'santaNeedsTheFortniteBattlePass', 24, false);
	addLuaSprite('santa', false);

	makeLuaSprite('hue', 'christmas/hue', -1200, -500);
	addLuaSprite('hue', false);

	makeLuaSprite('ethanIsHotAndSmexy', 'christmas/fgSnow', '-800', '780');
	addLuaSprite('ethanIsHotAndSmexy', true);
	-- aaaaaaaaaa theres snow in da speaker.

	makeAnimatedLuaSprite('snowFall', 'christmas/fallingSnow', 0, 0);
	addAnimationByPrefix('snowFall', 'idle', 'bad', 24, true);
	objectPlayAnimation('snowFall', 'idle');
	addLuaSprite('snowFall', false);
	setObjectCamera('snowFall', 'hud');
	setProperty('snowFall.alpha', 0);
	-- heheheha
end

function onBeatHit()
	if curBeat % 1 == 0 then
		objectPlayAnimation('boppers', 'idle', true);
		objectPlayAnimation('boppersAlt', 'idle', true);
		objectPlayAnimation('bottomBoppers', 'idle', true);
		objectPlayAnimation('bottomBoppersAlt', 'idle', true);
		objectPlayAnimation('santa', 'idle', true);
	end
end