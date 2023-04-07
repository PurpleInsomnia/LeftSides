function onCreate()
	makeLuaSprite("mickeyDeez", "too-fest/md", -200, -100);
	addLuaSprite("mickeyDeez", false);
end


-- stage shit ligma haha funny
function onEvent(name, penis, sex)
	if name == "Change Character" then
		if sex == "nuckle" then
			setProperty("dad.x", 700);
			setProperty("dad.y", 700);
		end
		if sex == "finger" then
			setProperty("dad.x", 575);
			setProperty("dad.y", 600);
		end
	end
end