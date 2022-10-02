local xx = 0;
local yy = 0;
local xx2 = 0;
local yy2 = 0;
local ofs = 35;
local divNum = 4;
local divNumB = 1.8;
local divNumC = 3;
local addXX = 0;
local addYY = 0;
local addXX2 = 0;
local addYY2 = 0;
function onCreate()
	-- nothing here :(
	-- this is absolutely funny.
	-- parker is drawing my dad.
	-- very cool, very swag.
end

function onCreatePost()
	if getProperty('dadName') == 'freeme' then
		addYY = (getProperty('dad.height') / 2) * -1;
	end
end

function onUpdate(elapsed)
	xx = getProperty('dad.x') + (getProperty('dad.width') / divNumB) + addXX;
	yy = getProperty('dad.y') + (getProperty('dad.height') / divNumC) + addYY; 
	xx2 = getProperty('boyfriend.x') + (getProperty('boyfriend.width') / divNum) + addXX2;
	yy2 = getProperty('boyfriend.y') + (getProperty('boyfriend.height') / divNum) + addYY2;
	if followchars then
		if not mustHitSection then
           		if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                			triggerEvent('Camera Follow Pos',xx-ofs,yy)
            		end
            		if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                			triggerEvent('Camera Follow Pos',xx+ofs,yy)
            		end
            		if getProperty('dad.animation.curAnim.name') == 'singUP' then
                			triggerEvent('Camera Follow Pos',xx,yy-ofs)
           		end
            		if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                			triggerEvent('Camera Follow Pos',xx,yy+ofs)
            		end
            		if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                			triggerEvent('Camera Follow Pos',xx-ofs,yy)
            		end
            		if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                			triggerEvent('Camera Follow Pos',xx+ofs,yy)
            		end
            		if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                			triggerEvent('Camera Follow Pos',xx,yy-ofs)
            		end
            		if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                			triggerEvent('Camera Follow Pos',xx,yy+ofs)
           		end
            		if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                			triggerEvent('Camera Follow Pos',xx,yy)
            		end
            		if getProperty('dad.animation.curAnim.name') == 'idle' then
                			triggerEvent('Camera Follow Pos',xx,yy)
            		end
        		else
            		if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                			triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
            		end
            		if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                			triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
            		end
            		if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                			triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
            		end
            		if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                			triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
            		end
            		if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT-alt' then
                			triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
            		end
            		if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT-alt' then
                			triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
            		end
            		if getProperty('boyfriend.animation.curAnim.name') == 'singUP-alt' then
                			triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
            		end
            		if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN-alt' then
                			triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
            		end
            		if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
                			triggerEvent('Camera Follow Pos',xx2,yy2)
            		end
            		if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                			triggerEvent('Camera Follow Pos',xx2,yy2)
            		end
        		end
    	else
        		triggerEvent('Camera Follow Pos','','')
    	end
end