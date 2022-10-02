function onCreate()
	makeLuaSprite('sky','meth/labWall', -200, -100);
	addLuaSprite('sky', false);

	makeLuaSprite('fg','meth/labFloor', -200, -200);
	addLuaSprite('fg', false);

	makeLuaSprite('ref', 'meth/labTank', -200, -100);
	addLuaSprite('ref', true);

	makeLuaSprite('sky2','meth/houseWall', -200, -100);
	addLuaSprite('sky2', false);

	makeLuaSprite('fg2','meth/houseFloor', -200, -100);
	addLuaSprite('fg2', false);

	makeLuaSprite('ref2', 'meth/housePeter', -200, -100);
	addLuaSprite('ref2', true);

	makeLuaSprite('sky3','meth/saulWall', -200, -100);
	addLuaSprite('sky3', false);

	makeLuaSprite('fg3','meth/saulFloor', -200, -100);
	addLuaSprite('fg3', false);

	walt();
end

function onEvent(n, v1, v2)
	if n == 'Change Character' then
		if v2 == 'walt' then
			walt();
		end
		if v2 == 'jesse' then
			jesse();
		end
		if v2 == 'saul' then
			saul();
		end
	end
end

function walt()
	setProperty('sky.visible', true);
	setProperty('fg.visible', true);
	setProperty('ref.visible', true);
	setProperty('sky2.visible', false);
	setProperty('fg2.visible', false);
	setProperty('ref2.visible', false);
	setProperty('sky3.visible', false);
	setProperty('fg3.visible', false);
end

function jesse()
	setProperty('sky2.visible', true);
	setProperty('fg2.visible', true);
	setProperty('ref2.visible', true);
	setProperty('sky.visible', false);
	setProperty('fg.visible', false);
	setProperty('ref.visible', false);
	setProperty('sky3.visible', false);
	setProperty('fg3.visible', false);
end

function saul()
	setProperty('sky3.visible', true);
	setProperty('fg3.visible', true);
	setProperty('sky2.visible', false);
	setProperty('fg2.visible', false);
	setProperty('ref2.visible', false);
	setProperty('sky.visible', false);
	setProperty('fg.visible', false);
	setProperty('ref.visible', false);
end