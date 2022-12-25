-- This Script Controls The Song Info Tweens Durring The Begining of Songs.
-- PurpleInsomnia
function onCountdownTick(counter)
	if counter == 3 and not getProperty('delayedInfo') then
		doTweenX('camInfoMove', 'camInfo', 0, 0.75, 'quintOut');
	end
	if counter == 3 and getProperty('delayedInfo') then
		switchSongName();
	end
end

local setStep = 0;
function switchSongName()
	songName = getProperty('SONG.song');
	if songName == 'Too Slow' then
		-- fart lololololol
	end
end

function onStepHit()
	if curStep == setStep and getProperty('delayedInfo') then
		doTweenX('camInfoMove', 'camInfo', 0, 0.75, 'quintOut');
	end
end

function onTweenCompleted(tag)
	if tag == 'camInfoMove' then
		runTimer('infoTimer', 1);
	end
end

function onTimerCompleted(tag)
	if tag == 'infoTimer' then
		cinematicTrans();
	end
end

function cinematicTrans()
	doTweenX('camInfoMoveTwo', 'camInfo', -640, 0.75, 'expoIn');
end