local lightsOn = true;
function onCreate()
	-- bg shit
	
	makeLuaSprite('bg', 'mattoBG', -200, -100);
	setLuaSpriteScrollFactor('bg', 0.9, 0.9);
	addLuaSprite('bg', false);
	
	makeLuaSprite('fg', 'mattoFG', -200, -100);
	addLuaSprite('fg', false);
	
	-- cool lights
	
	if not lowQuality then
		makeLuaSprite('light0', 'lights/default', -200, -100);
		addLuaSprite('light0', true);
		
		makeLuaSprite('light1', 'lights/down', -200, -100);
		addLuaSprite('light1', true);
		
		makeLuaSprite('light2', 'lights/left', -200, -100);
		addLuaSprite('light2', true);
		
		makeLuaSprite('light3', 'lights/right', -200, -100);
		addLuaSprite('light3', true);
		
		makeLuaSprite('light4', 'lights/up', -200, -100);
		addLuaSprite('light4', true);
		
		-- visibility
		
		setProperty('light0.visible', true);
		setProperty('light1.visible', false);
		setProperty('light2.visible', false);
		setProperty('light3.visible', false);
		setProperty('light4.visible', false);
	end
	
	makeLuaSprite('gamer', 'mattoCOMPUTER', -200, -100);
	addLuaSprite('gamer', true);

	ohkoCounterString = getProperty('deathCounter');
	
	if ohkoCounterString > 5 then
		ohkoCounterString = amogus;
	end
	
	makeLuaSprite('coolCounter', ohkoCounterString, 0, 0);
	-- addLuaSprite('coolCounter', false);
	setObjectCamera('coolCounter', 'hud');

	-- he counter is unused :(
end

function onUpdate(elapsed)
	if lightsOn then
        if not mustHitSection then
            if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
            		setProperty('light0.visible', false);
						setProperty('light1.visible', false);
						setProperty('light2.visible', true);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false);
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
               	setProperty('light0.visible', false);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', true);
						setProperty('light4.visible', false);
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
               	setProperty('light0.visible', false);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', true);
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
               	setProperty('light0.visible', false);
						setProperty('light1.visible', true);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false); 
            end
				if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
            		setProperty('light0.visible', false);
						setProperty('light1.visible', false);
						setProperty('light2.visible', true);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false);
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
               	setProperty('light0.visible', false);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', true);
						setProperty('light4.visible', false);
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
               	setProperty('light0.visible', false);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', true);
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
               	setProperty('light0.visible', false);
						setProperty('light1.visible', true);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false); 
            end
            if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
               	setProperty('light0.visible', true);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false);
            end
            if getProperty('dad.animation.curAnim.name') == 'idle' then
               	setProperty('light0.visible', true);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false); 
            end
		end
		if mustHitSection then
            if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
            		setProperty('light0.visible', false);
						setProperty('light1.visible', false);
						setProperty('light2.visible', true);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false);
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
               	setProperty('light0.visible', false);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', true);
						setProperty('light4.visible', false);
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
               	setProperty('light0.visible', false);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', true);
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
               	setProperty('light0.visible', false);
						setProperty('light1.visible', true);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false); 
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
               	setProperty('light0.visible', true);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false);
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
               	setProperty('light0.visible', true);
						setProperty('light1.visible', false);
						setProperty('light2.visible', false);
						setProperty('light3.visible', false);
						setProperty('light4.visible', false); 
            end
		end
	end
end
