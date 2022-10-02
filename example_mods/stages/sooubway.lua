function onCreate()
	-- sooubway
	makeLuaSprite('bg', 'sooubway/bg', -200, -100);
	addLuaSprite('bg', false);

	makeLuaSprite('goofyAhh', 'sooubway/goofyAhhPerson', -200, -100);
	addLuaSprite('goofyAhh', false);

	makeLuaSprite('counter', 'sooubway/counters', -200, -100);
	addLuaSprite('counter', false);

	addLuaSprite('lights', 'sooubway/lights', -200, -100);
	addLuaSprite('lights', false);

	makeLuaSprite('fg', 'sooubway/floor', -200, -100);
	addLuaSprite('fg', false);
end

function onBeatHit()
	if curBeat % 4 == 2 then
		doTweenY('piss1', 'goofyAhh', -50, 0.25, 'linear');
	end
end

function onTweenCompleted(tag)
	if tag == 'piss1' then
		doTweenY('piss2', 'goofyAhh', -100, 0.75, 'linear');
	end
end