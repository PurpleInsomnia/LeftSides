function onCreate()
	--setProperty("bfZoom", true);

	coolSong = getPropertyFromClass("PlayState", 'SONG.song');
	
	if coolSong == "Eggnog" then
		makeLuaSprite('androidBg', 'christmas/bg-alt', -1200, -500);
	else
		makeLuaSprite('androidBg', 'christmas/androidBg', -1200, -500);
	end
	addLuaSprite('androidBg', false);

	makeLuaSprite('tree', 'christmas/tree', 470, -250);
	addLuaSprite('tree', false);

	if coolSong == "Eggnog" then
		makeAnimatedLuaSprite('bottomBoppers', 'christmas/bottomBopALT', 900, 220);
		addAnimationByPrefix('bottomBoppers', 'idle', 'Bottom Level Boppers Alt', 24, false);
		addLuaSprite('bottomBoppers', false);
	else
		makeAnimatedLuaSprite('bottomBoppers', 'christmas/bottomBop', 900, 220);
		addAnimationByPrefix('bottomBoppers', 'idle', 'Bottom Level Boppers', 24, false);
		addLuaSprite('bottomBoppers', false);
	end

	makeLuaSprite('darkBg', 'christmas/black',  -540, -90);
	addLuaSprite('darkBg', false);
	setProperty('darkBg.alpha', 0);

	makeLuaSprite('dumbSnow', 'christmas/floorSnow', -800, 890);
	addLuaSprite('dumbSnow', false);

	makeLuaSprite('fgSnow', 'christmas/floorSnow', -800, 690);
	addLuaSprite('fgSnow', false);
	
	makeAnimatedLuaSprite('santa', 'christmas/santa', -640, 150);
	addAnimationByPrefix('santa', 'idle', 'santaNeedsTheFortniteBattlePass', 24, false);
	addLuaSprite('santa', false);

	makeLuaSprite('hue', 'christmas/hue', -1200, -500);
	addLuaSprite('hue', false);
end

function onBeatHit()
	if curBeat % 1 == 0 then
		objectPlayAnimation('bottomBoppers', 'idle', true);
		objectPlayAnimation('santa', 'idle', true);
	end
end