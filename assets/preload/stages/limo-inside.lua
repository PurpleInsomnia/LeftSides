local canKachow = true;
function onCreate()
	-- yes this is a copy of week 2 stage. am I ashamed of it? no.
	makeLuaSprite('fortniteBattlePass','limoInside/limoFortniteBattlePass', -200, -100);
	addLuaSprite('fortniteBattlePass', false);
	setLuaSpriteScrollFactor('fortniteBattlePass', 0.9, 0.9);

	makeLuaSprite('castingCouch','limoInside/limoCouch', -200, -100);
	addLuaSprite('castingCouch', false);
	setLuaSpriteScrollFactor('castingCouch', 0.9, 0.9);
end

function onUpdate(elapsed)
	randomNum = math.floor(math.random(3, 5.5));
end

function onBeatHit()
	-- random number for vroom vroom
	if canKachow then
		runTimer('mcqueen', randomNum);
		canKachow = false;
	end
end

function onStepHit()

end

function onTimerCompleted(tag)
	bruh = math.floor(math.random(1, 2));
	if bruh == 1 then
		ass = 'car1';
	end
	if bruh == 2 then
		ass = 'car2';
	end
	if tag == 'mqueen' then
		playSound(ass);
		runTimer('coolDown', 2.1);
	end
	if tag == 'coolDown' then
		canKachow = true;
	end		
end
