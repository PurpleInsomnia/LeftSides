package;

import flixel.FlxG;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var songRating:Map<String, Float> = new Map();
	public static var weekRatings:Map<String, Int> = new Map();
	public static var songRanks:Map<String, Int> = new Map();
	public static var encoreSongRanks:Map<String, Int> = new Map();
	public static var encoreSongScores:Map<String, Int> = new Map();
	public static var encoreSongRating:Map<String, Float> = new Map();
	#else
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var weekRatings:Map<String, Int> = new Map<String, Int>();
	public static var songRanks:Map<String, Int> = new Map<String, Int>();
	public static var encoreSongRanks:Map<String, Int> = new Map<String, Int>();
	public static var encoreSongScores:Map<String, Int> = new Map<String, Int>();
	public static var encoreSongRating:Map<String, Float> = new Map<String, Float>();
	#end


	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
		setSongRank(daSong, 0);
	}

	public static function resetEncoreSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setEncoreScore(daSong, 0);
		setEncoreRating(daSong, 0);
		setEncoreSongRank(daSong, 0);
	}

	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
		setWeekRating(daWeek, 0);
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong)) {
			if (songScores.get(daSong) < score) {
				setScore(daSong, score);
				if(rating >= 0) setRating(daSong, rating);
			}
		}
		else {
			setScore(daSong, score);
			if(rating >= 0) setRating(daSong, rating);
		}
	}

	public static function saveEncoreScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1):Void
	{
		var daSong:String = formatSong(song, diff);

		if (encoreSongScores.exists(daSong)) {
			if (encoreSongScores.get(daSong) < score) {
				setEncoreScore(daSong, score);
				if(rating >= 0) setEncoreRating(daSong, rating);
			}
		}
		else {
			setEncoreScore(daSong, score);
			if(rating >= 0) setEncoreRating(daSong, rating);
		}
	}

	public static function saveSongRank(song:String, ?diff:Int = 0, rating:String):Void
	{
		var daSong:String = formatSong(song, diff);

		var num:Int = 0;

		switch(rating)
		{
			case 's':
				num = 10;
			case 'a':
				num = 8;
			case 'b':
				num = 6;
			case 'c':
				num = 4;
			case 'd':
				num = 2;
			case 'f':
				num = 1;
		}

		if (songRanks.exists(daSong))
		{
			if (songRanks.get(daSong) < num)
				setSongRank(daSong, num);
		}
		else
			setSongRank(daSong, num);
	}

	public static function saveEncoreSongRank(song:String, ?diff:Int = 0, rating:String):Void
	{
		var daSong:String = formatSong(song, diff);

		var num:Int = 0;

		switch(rating)
		{
			case 's':
				num = 10;
			case 'a':
				num = 8;
			case 'b':
				num = 6;
			case 'c':
				num = 4;
			case 'd':
				num = 2;
			case 'f':
				num = 1;
		}

		if (encoreSongRanks.exists(daSong))
		{
			if (encoreSongRanks.get(daSong) < num)
				setEncoreSongRank(daSong, num);
		}
		else
			setSongRank(daSong, num);
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setWeekScore(daWeek, score);
		}
		else
			setWeekScore(daWeek, score);
	}

	public static function saveWeekRating(week:String, ?diff:Int = 0, rating:String):Void
	{
		var daWeek:String = formatSong(week, diff);

		var num:Int = 0;

		switch(rating)
		{
			case 's':
				num = 10;
			case 'a':
				num = 8;
			case 'b':
				num = 6;
			case 'c':
				num = 4;
			case 'd':
				num = 2;
			case 'f':
				num = 1;
		}

		if (weekRatings.exists(daWeek))
		{
			if (weekRatings.get(daWeek) < num)
				setWeekRating(daWeek, num);
		}
		else
			setWeekRating(daWeek, num);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}
	static function setEncoreScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		encoreSongScores.set(song, score);
		FlxG.save.data.encoreSongScores = encoreSongScores;
		FlxG.save.flush();
	}
	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setWeekRating(week:String, num:Int):Void
	{
		weekRatings.set(week, num);
		FlxG.save.data.weekRatings = weekRatings;
		FlxG.save.flush();
	}

	static function setSongRank(song:String, rank:Int):Void
	{
		songRanks.set(song, rank);
		FlxG.save.data.songRanks = songRanks;
		FlxG.save.flush();
	}

	static function setEncoreSongRank(song:String, rank:Int):Void
	{
		encoreSongRanks.set(song, rank);
		FlxG.save.data.encoreSongRanks = encoreSongRanks;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}

	static function setEncoreRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		encoreSongRating.set(song, rating);
		FlxG.save.data.encoreSongRating = encoreSongRating;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.formatToSongPath(song) + CoolUtil.difficultyStuff[diff][1];
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getEncoreScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!encoreSongScores.exists(daSong))
			setEncoreScore(daSong, 0);

		return encoreSongScores.get(daSong);
	}

	public static function getSongRank(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songRanks.exists(daSong))
			setSongRank(daSong, 0);

		return songRanks.get(daSong);
	}

	public static function getEncoreSongRank(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!encoreSongRanks.exists(daSong))
			setEncoreSongRank(daSong, 0);

		return encoreSongRanks.get(daSong);
	}

	public static function getRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songRating.exists(daSong))
			setRating(daSong, 0);

		return songRating.get(daSong);
	}

	public static function getEncoreRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!encoreSongRating.exists(daSong))
			setEncoreRating(daSong, 0);

		return encoreSongRating.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function getWeekRating(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekRatings.exists(daWeek))
			setWeekRating(daWeek, 0);

		return weekRatings.get(daWeek);
	}

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
		{
			weekScores = FlxG.save.data.weekScores;
		}
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.encoreSongScores != null)
		{
			encoreSongScores = FlxG.save.data.encoreSongScores;
		}
		if (FlxG.save.data.songRating != null)
		{
			songRating = FlxG.save.data.songRating;
		}
		if (FlxG.save.data.weekRatings != null)
		{
			weekRatings = FlxG.save.data.weekRatings;
		}
		if (FlxG.save.data.songRanks != null)
		{
			songRanks = FlxG.save.data.songRanks;
		}
		if (FlxG.save.data.encoreSongRanks != null)
		{
			encoreSongRanks = FlxG.save.data.encoreSongRanks;
		}
		if (FlxG.save.data.encoreSongRating != null)
		{
			encoreSongRating = FlxG.save.data.encoreSongRating;
		}
	}

	public static function saveEverything()
	{
		FlxG.save.data.songScores = songScores;
		FlxG.save.data.encoreSongScores = encoreSongScores;
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.data.weekRatings = weekRatings;
		FlxG.save.data.songRanks = songRanks;
		FlxG.save.data.encoreSongRanks = encoreSongRanks;
		FlxG.save.data.songRating = songRating;
		FlxG.save.data.encoreSongRating = encoreSongRating;
		FlxG.save.flush();
	}
}
