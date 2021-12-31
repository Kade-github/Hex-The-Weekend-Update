import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import Song.SongData;

using StringTools;

typedef FreeplayDiff =
{
	var data:SongData;
	var rating:Float;
}

typedef FreeplaySong =
{
	var songIndex:Int;
	var songId:String;
	var diffs:Map<String, FreeplayDiff>;
}

class HexFreeplayMenu extends HexMenuState
{
	public var songs:Array<FreeplaySong> = [];

	public var diffsAvailable:Array<String> = ["-easy", "", "-hard", "-funky"];

	public var selectedDiff = 2;

	public var bad:Bool = false;

	public var TitleText:FlxText;
	public var ArtistText:FlxText;
	public var TimeText:FlxText;
	public var RecordText:FlxText;
	public var RatingText:FlxText;

	public var selectedIndex = 0;

	public function getSongLength(id:Int):Float
	{
		switch (id)
		{
			case 0:
				return 2.32;
			case 1:
				return 2.08;
			case 2:
				return 2.10;
			case 3:
				return 2.46;
			case 4:
				return 3.02;
			case 5:
				return 2.58;
			case 6:
				return 2.34;
			case 7:
				return 3.23;
			case 8:
				return 3.50;
			case 9:
				return 3.20;
		}
		return 0;
	}

	public function loadAllSongs()
	{
		var list = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));
		var index = 0;
		for (i in list)
		{
			var s = i.split(':');

			var song:FreeplaySong = {
				songId: s[0],
				songIndex: index,
				diffs: []
			};

			FlxG.sound.cache(Paths.inst(song.songId));

			for (i in diffsAvailable)
			{
				if (Paths.doesTextAssetExist(Paths.json('songs/${song.songId}/${song.songId}' + i)))
				{
					var diff = i;
					var data:SongData = Song.loadFromJson(song.songId, diff);

					var diffName = diff.replace("-", "");
					if (diffName == "")
						diffName = "normal";

					var f = DiffCalc.CalculateDiff(data);

					var fD:FreeplayDiff = {data: data, rating: f};

					song.diffs.set(diffName, fD);
				}
			}

			songs.push(song);

			index++;
			LoadingScreen.progress = Std.int(((songs.length - 1) / index) * 100);
			Debug.logTrace(LoadingScreen.progress);
		}
	}

	override function load()
	{
		loadAllSongs();
		super.load();
	}

	function move(left:Bool, dontMove:Bool = false)
	{
		// gonna be honest, this is super bad.

		// you could totally do this better but im super lazy and it's not that important.

		if (!dontMove)
		{
			if (left)
				selectedIndex--;
			else
				selectedIndex++;

			if (selectedIndex < 0)
				selectedIndex = songs.length - 1;
			if (selectedIndex > songs.length - 1)
				selectedIndex = 0;
		}

		var leftTwo = [];

		var rightTwo = [];

		if (songs[selectedIndex - 2] != null)
			leftTwo.push(songs[selectedIndex - 2].songIndex);
		else
			leftTwo.push(-1);

		if (songs[selectedIndex - 1] != null)
			leftTwo.push(songs[selectedIndex - 1].songIndex);
		else
			leftTwo.push(-1);

		if (songs[selectedIndex + 1] != null)
			rightTwo.push(songs[selectedIndex + 1].songIndex);
		else
			rightTwo.push(-1);

		if (songs[selectedIndex + 2] != null)
			rightTwo.push(songs[selectedIndex + 2].songIndex);
		else
			rightTwo.push(-1);

		Debug.logTrace("selected " + songs[selectedIndex].songId.toUpperCase());

		getItemByName("diff").visible = true;
		getItemByName("selectUp").visible = true;
		getItemByName("selectDown").visible = true;
		Debug.logTrace("selected " + songs[selectedIndex].songId.toUpperCase());

		getItemByName("timeDisplay").visible = true;
		getItemByName("recordDisplay").visible = true;
		getItemByName("ratingDisplay").visible = true;

		Debug.logTrace("selected " + songs[selectedIndex].songId.toUpperCase());

		TimeText.visible = true;
		RecordText.visible = true;
		RatingText.visible = true;

		if (selectedIndex >= 5)
			selectedDiff = 3;
		else if (selectedIndex < 5 && selectedDiff == 3)
			selectedDiff = 2;

		Debug.logTrace("selected " + songs[selectedIndex].songId.toUpperCase());

		if ((!bad && selectedIndex >= 5) || (!FlxG.save.data.weekxBeat && selectedIndex == 4))
		{
			getItemByName("art").changeOutGraphic("freeplay/album_cover_unknown");
			getItemByName("diff").visible = false;
			getItemByName("selectUp").visible = false;
			getItemByName("selectDown").visible = false;
			getItemByName("timeDisplay").visible = false;
			getItemByName("recordDisplay").visible = false;
			getItemByName("ratingDisplay").visible = false;
			TimeText.visible = false;
			RecordText.visible = false;
			RatingText.visible = false;
		}
		else if (bad && selectedIndex >= 5)
		{
			getItemByName("art").changeOutGraphic("freeplay/album_cover_2");
			getItemByName("selectUp").visible = false;
			getItemByName("selectDown").visible = false;
			getItemByName("diff").changeOutGraphic("freeplay/difficulty_funky");
		}
		else
		{
			getItemByName("art").changeOutGraphic("freeplay/album_cover_1");
			getItemByName("diff").changeOutGraphic("freeplay/difficulty_" + CoolUtil.difficultyFromInt(selectedDiff).toLowerCase());
		}
		Debug.logTrace("selected " + songs[selectedIndex].songId.toUpperCase());

		if (leftTwo[0] != -1)
		{
			getItemByName("position1").visible = true;
			if ((!bad && leftTwo[0] >= 5) || (!FlxG.save.data.weekxBeat && leftTwo[0] == 4))
				getItemByName("position1").changeOutGraphic("freeplay/mini_song_unknown");
			else
				getItemByName("position1").changeOutGraphic("freeplay/mini_song_" + (leftTwo[0] + 1));
		}
		else
			getItemByName("position1").visible = false;

		if (leftTwo[1] != -1)
		{
			getItemByName("position2").visible = true;
			if ((!bad && leftTwo[1] >= 5) || (!FlxG.save.data.weekxBeat && leftTwo[1] == 4))
				getItemByName("position2").changeOutGraphic("freeplay/mini_song_unknown");
			else
				getItemByName("position2").changeOutGraphic("freeplay/mini_song_" + (leftTwo[1] + 1));
		}
		else
			getItemByName("position2").visible = false;

		if (rightTwo[0] != -1)
		{
			getItemByName("position3").visible = true;
			if ((!bad && rightTwo[0] >= 5) || (!FlxG.save.data.weekxBeat && rightTwo[0] == 4))
				getItemByName("position3").changeOutGraphic("freeplay/mini_song_unknown");
			else
				getItemByName("position3").changeOutGraphic("freeplay/mini_song_" + (rightTwo[0] + 1));
		}
		else
			getItemByName("position3").visible = false;

		if (rightTwo[1] != -1)
		{
			getItemByName("position4").visible = true;
			if ((!bad && rightTwo[1] >= 5) || (!FlxG.save.data.weekxBeat && rightTwo[1] == 4))
				getItemByName("position4").changeOutGraphic("freeplay/mini_song_unknown");
			else
				getItemByName("position4").changeOutGraphic("freeplay/mini_song_" + (rightTwo[1] + 1));
		}
		else
			getItemByName("position4").visible = false;

		Debug.logTrace("got");

		if (!bad && selectedIndex >= 5)
		{
			TitleText.text = "???";
			ArtistText.text = "???";
		}
		else if (!FlxG.save.data.weekxBeat && selectedIndex == 4)
		{
			TitleText.text = "???";
			ArtistText.text = "???";
		}
		else
		{
			if (songs[selectedIndex].songId == "ram")
				TitleText.text = "R.A.M";
			else if (songs[selectedIndex].songId == "hello-world")
				TitleText.text = "HELLO WORLD!";
			else if (songs[selectedIndex].songId == "glitcher-remix")
				TitleText.text = "GLITCHER (REMIX)";
			else if (songs[selectedIndex].songId == "lcd")
				TitleText.text = "LCD";
			else
				TitleText.text = songs[selectedIndex].songId.toUpperCase().replace("-", " ");
			ArtistText.text = "YINGYANG48";
		}
		TimeText.text = ("" + getSongLength(selectedIndex)).replace(".", ":");
		var rating = songs[selectedIndex].diffs.get(CoolUtil.difficultyFromInt(selectedDiff).toLowerCase()).rating;
		var highScore = Highscore.getScore(songs[selectedIndex].songId, selectedDiff);
		if (highScore == 0)
			RecordText.text = "0"; // will just show nothing otherwise
		else
			RecordText.text = highScore + "";
		if (rating == 0)
			RatingText.text = "0";
		else
			RatingText.text = rating + "";
		if (TimeText.text == "2:1")
			TimeText.text = "2:10";
		FlxG.sound.play(Paths.sound("scrollMenu"));
		TitleText.x = (FlxG.width / 2) - (TitleText.fieldWidth / 2);
		ArtistText.x = (FlxG.width / 2) - (ArtistText.fieldWidth / 2);
		if (!bad && selectedIndex >= 5)
			return;
		if (!FlxG.save.data.weekxBeat && selectedIndex == 4)
			return;
		FlxG.sound.playMusic(Paths.inst(songs[selectedIndex].songId));
		FlxG.sound.music.fadeIn();
		if (songs[selectedIndex].songId == "ram")
			HexMainMenu.currentSong = "R.A.M";
		else if (songs[selectedIndex].songId == "hello-world")
			HexMainMenu.currentSong = "Hello World!";
		else if (songs[selectedIndex].songId == "glitcher-remix")
			HexMainMenu.currentSong = "Glitcher (Remix)";
		else
			HexMainMenu.currentSong = songs[selectedIndex].songId;
	}

	override function create()
	{
		superCreate();

		bad = FlxG.save.data.weekendxBeat;
		#if debug
		bad = true;
		#end

		var yeah = new FlxBackdrop(Paths.image('freeplay/background', 'hexMenu'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah.setPosition(0, 0);
		yeah.antialiasing = true;
		yeah.scrollFactor.set();
		add(yeah);
		yeah.velocity.set(20, 0);
		super.create();
		Items.members.remove(getItemByName("bg"));

		TitleText = new FlxText(FlxG.width / 2, (FlxG.height / 2) + 84);
		TitleText.setFormat(Paths.font("nasalization free.ttf"), 52, FlxColor.fromRGB(21, 21, 38));
		add(TitleText);

		ArtistText = new FlxText(FlxG.width / 2, (FlxG.height / 2) + 130);
		ArtistText.setFormat(Paths.font("nasalization free.ttf"), 30, FlxColor.fromRGB(21, 21, 38));
		add(ArtistText);

		TimeText = new FlxText((FlxG.width / 2) - 165, ArtistText.y + 65);
		TimeText.setFormat(Paths.font("nasalization free.ttf"), 26, FlxColor.fromRGB(21, 21, 38));
		add(TimeText);

		RecordText = new FlxText((FlxG.width / 2) - 108, ArtistText.y + 100);
		RecordText.setFormat(Paths.font("nasalization free.ttf"), 26, FlxColor.fromRGB(21, 21, 38));
		add(RecordText);

		RatingText = new FlxText((FlxG.width / 2) - 118, ArtistText.y + 138);
		RatingText.setFormat(Paths.font("nasalization free.ttf"), 26, FlxColor.fromRGB(21, 21, 38));
		add(RatingText);

		move(true, true);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
			switchState(new HexMainMenu(HexMenuState.loadHexMenu("main-menu")));
		if (FlxG.keys.justPressed.LEFT)
			move(true);
		if (FlxG.keys.justPressed.RIGHT)
			move(false);
		super.update(elapsed);

		if (FlxG.keys.justPressed.UP)
		{
			if (selectedIndex >= 5)
				return;
			selectedDiff--;

			if (selectedDiff < 0)
				selectedDiff = 2;
			var rating = songs[selectedIndex].diffs.get(CoolUtil.difficultyFromInt(selectedDiff).toLowerCase()).rating;
			var highScore = Highscore.getScore(songs[selectedIndex].songId, selectedDiff);
			if (highScore == 0)
				RecordText.text = "0"; // will just show nothing otherwise
			else
				RecordText.text = highScore + "";
			if (rating == 0)
				RatingText.text = "0";
			else
				RatingText.text = rating + "";
			FlxG.sound.play(Paths.sound("scrollMenu"));
			getItemByName("diff").changeOutGraphic("freeplay/difficulty_" + CoolUtil.difficultyFromInt(selectedDiff).toLowerCase());
		}

		if (FlxG.keys.justPressed.DOWN)
		{
			if (selectedIndex >= 5)
			{
				FlxG.sound.play(Paths.sound("error", "hexMenu"));
				return;
			}
			selectedDiff++;

			if (selectedDiff > 2)
				selectedDiff = 0;
			var rating = songs[selectedIndex].diffs.get(CoolUtil.difficultyFromInt(selectedDiff).toLowerCase()).rating;
			var highScore = Highscore.getScore(songs[selectedIndex].songId, selectedDiff);
			if (highScore == 0)
				RecordText.text = "0"; // will just show nothing otherwise
			else
				RecordText.text = highScore + "";
			if (rating == 0)
				RatingText.text = "0";
			else
				RatingText.text = rating + "";
			FlxG.sound.play(Paths.sound("scrollMenu"));
			getItemByName("diff").changeOutGraphic("freeplay/difficulty_" + CoolUtil.difficultyFromInt(selectedDiff).toLowerCase());
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			if (selectedIndex >= 5 && !bad)
			{
				FlxG.sound.play(Paths.sound("error", "hexMenu"));
				return;
			}
			PlayState.SONG = songs[selectedIndex].diffs.get(CoolUtil.difficultyFromInt(selectedDiff).toLowerCase()).data;
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = selectedDiff;
			PlayState.storyWeek = 10;

			switchState(new PlayState());
		}
	}
}
