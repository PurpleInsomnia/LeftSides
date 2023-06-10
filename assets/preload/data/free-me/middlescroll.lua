-- This script controls the middle scroll functions
local chad = false;
function onCreate()
	chad = middlescroll;
	if not chad and not tpm then
		setPropertyFromClass('ClientPrefs', 'middleScroll', true);
	end
end

function onDestroy()
	if not chad and not tpm then
		setPropertyFromClass('ClientPrefs', 'middleScroll', false);
	end
end