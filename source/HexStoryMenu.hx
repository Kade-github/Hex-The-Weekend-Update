import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera.FlxCameraFollowStyle;
import HexMenuState.HexMenuItem;
import flixel.FlxG;

using StringTools;

class HexStoryMenu extends HexMenuState
{
	var selectedIndex = 0;

	var weekXHighScore:Int;
	var weekendHighScore:Int;

	var weekendXUnlocked:Bool = false;

	var curDifficulty = 2;

	var weekXScore:FlxText;
	var weekendXScore:FlxText;
	var yeah:FlxBackdrop;
	var yeah2:FlxBackdrop;

	public function select()
	{
		FlxG.sound.play(Paths.sound("scrollMenu"));
		getItemByName("normal_up").changeOutGraphic("story/normal_week");
		if (weekendXUnlocked)
			getItemByName("normal_down").changeOutGraphic("story/normal_weekend");
		else
			getItemByName("normal_down").changeOutGraphic("story/normal_unknown");
		FlxTween.globalManager.clear();

		switch (selectedIndex)
		{
			case 0:
				if (alphaLerp1 == 1)
					alphaLerp1 = 0;
				FlxTween.color(weekXScore, 0.7, weekXScore.color, FlxColor.fromRGB(21, 21, 38));
				FlxTween.color(weekendXScore, 0.7, weekendXScore.color, FlxColor.fromRGB(21, 21, 38));
				getItemByName("normal_up").changeOutGraphic("story/focus_week");
			case 1:
				if (alphaLerp2 == 1)
					alphaLerp2 = 0;
				FlxTween.color(weekXScore, 0.7, weekXScore.color, FlxColor.fromRGB(0, 255, 246));
				FlxTween.color(weekendXScore, 0.7, weekendXScore.color, FlxColor.fromRGB(0, 255, 246));
				if (weekendXUnlocked)
					getItemByName("normal_down").changeOutGraphic("story/focus_weekend");
				else
					getItemByName("normal_down").changeOutGraphic("story/focus_unknown");
		}
	}

	override function create()
	{
		superCreate();

		weekXHighScore = Highscore.getWeekScore(10, curDifficulty);
		weekendHighScore = Highscore.getWeekScore(11, curDifficulty);

		yeah = new FlxBackdrop(Paths.image('story/background_1', 'hexMenu'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah.setPosition(0, 0);
		yeah.antialiasing = true;
		yeah.scrollFactor.set();
		add(yeah);
		yeah.velocity.set(20, 0);

		yeah2 = new FlxBackdrop(Paths.image('story/background_2', 'hexMenu'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah2.setPosition(0, 0);
		yeah2.antialiasing = true;
		yeah2.scrollFactor.set();
		add(yeah2);
		yeah2.velocity.set(20, 0);
		yeah2.alpha = 0;

		weekendXUnlocked = FlxG.save.data.weekxBeat;
		super.create();

		Items.members.remove(getItemByName("bg"));

		alphaLerp1 = 1;

		weekXScore = new FlxText(990, 120, 0, "" + weekXHighScore);
		weekXScore.setFormat(Paths.font("nasalization free.ttf"));
		weekXScore.scrollFactor.set();
		weekXScore.color = FlxColor.fromRGB(21, 21, 38);
		weekXScore.size = 30;
		add(weekXScore);

		weekendXScore = new FlxText(70, 460, 0, "" + weekendHighScore);
		weekendXScore.setFormat(Paths.font("nasalization free.ttf"));
		weekendXScore.scrollFactor.set();
		weekendXScore.color = FlxColor.fromRGB(21, 21, 38);
		weekendXScore.size = 30;
		add(weekendXScore);

		if (!weekendXUnlocked)
		{
			getItemByName("weekendX").visible = false;
			getItemByName("bottomDiff").visible = false;
			weekendXScore.visible = false;
		}

		getItemByName("windowDark").alpha = 0;
		getItemByName("windowDownDark").alpha = 0;
		getItemByName("windowUnknown").alpha = 0;
		getItemByName("darkSelectLeft").alpha = 0;
		getItemByName("darkSelectRight").alpha = 0;

		if (weekendXUnlocked)
		{
			getItemByName("windowDown").changeOutGraphic("story/window_down_1");
		}

		Debug.logTrace('bruh!');
	}

	public function changeDiff()
	{
		weekXHighScore = Highscore.getWeekScore(10, curDifficulty);
		switch (curDifficulty)
		{
			case 0:
				getItemByName("upperDiff").changeOutGraphic("story/difficulty_easy");
			case 1:
				getItemByName("upperDiff").changeOutGraphic("story/difficulty_normal");
			case 2:
				getItemByName("upperDiff").changeOutGraphic("story/difficulty_hard");
		}
	}

	public function returnWeekData():Array<String>
	{
		if (selectedIndex == 0)
			return ['dunk', 'ram', 'hello-world', 'glitcher'];
		return ['cooling', 'detected'];
	}

	override function stepHit()
	{
		super.stepHit();
	}

	override function beatHit()
	{
		super.beatHit();
	}

	var alphaLerp1:Float = 0;
	var alphaLerp2:Float = 0;

	var stopSelecting = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE && !stopSelecting)
			switchState(new HexMainMenu(HexMenuState.loadHexMenu("main-menu")));

		if (FlxG.keys.justPressed.DOWN && !stopSelecting)
		{
			selectedIndex++;
			if (selectedIndex > 1)
				selectedIndex = 0;
			select();
		}
		if (FlxG.keys.justPressed.UP && !stopSelecting)
		{
			selectedIndex--;
			if (selectedIndex < 0)
				selectedIndex = 1;
			select();
		}
		if (selectedIndex == 0)
		{
			if (FlxG.keys.justPressed.LEFT && !stopSelecting)
			{
				curDifficulty--;
				if (curDifficulty < 0)
					curDifficulty = 2;
				FlxG.sound.play(Paths.sound("scrollMenu"));
				changeDiff();
			}

			if (FlxG.keys.justPressed.RIGHT && !stopSelecting)
			{
				curDifficulty++;
				if (curDifficulty > 2)
					curDifficulty = 0;
				FlxG.sound.play(Paths.sound("scrollMenu"));
				changeDiff();
			}
		}

		if (FlxG.keys.justPressed.ENTER && !stopSelecting)
		{
			var diff:String = ["-easy", "", "-hard"][curDifficulty];
			if (selectedIndex == 1)
			{
				diff = "-funky";
				if (!weekendXUnlocked)
				{
					FlxG.sound.play(Paths.sound("error", "hexMenu"));
					super.update(elapsed);
					return;
				}
			}
			stopSelecting = true;
			PlayState.storyPlaylist = returnWeekData();
			PlayState.isStoryMode = true;
			PlayState.songMultiplier = 1;
			PlayState.isSM = false;
			PlayState.storyDifficulty = curDifficulty;
			if (selectedIndex == 1)
				PlayState.storyDifficulty = 3;

			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.storyPlaylist[0], diff));
			PlayState.storyWeek = selectedIndex == 0 ? 10 : 11;
			PlayState.campaignScore = 0;
			if (selectedIndex == 1)
				switchState(new BruhADiagWindow(PlayState.SONG.songId));
			else
				switchState(new PlayState());
		}

		weekXScore.text = weekXHighScore + "";

		switch (selectedIndex)
		{
			case 0:
				if (alphaLerp1 < 1)
					alphaLerp1 += elapsed * 1.4;
				if (alphaLerp2 > 0)
					alphaLerp2 -= elapsed * 1.4;

			case 1:
				if (alphaLerp1 > 0)
					alphaLerp1 -= elapsed * 1.4;
				if (alphaLerp2 < 1)
					alphaLerp2 += elapsed * 1.4;
		}

		if (alphaLerp1 != 1)
		{
			yeah.alpha = FlxMath.lerp(0, 1, alphaLerp1);
			getItemByName("window").alpha = FlxMath.lerp(0, 1, alphaLerp1);
			getItemByName("windowDown").alpha = FlxMath.lerp(0, 1, alphaLerp1);
			getItemByName("selectLeft").alpha = FlxMath.lerp(0, 1, alphaLerp1);
			getItemByName("selectRight").alpha = FlxMath.lerp(0, 1, alphaLerp1);
		}
		if (alphaLerp2 != 1)
		{
			yeah2.alpha = FlxMath.lerp(0, 1, alphaLerp2);
			getItemByName("windowDark").alpha = FlxMath.lerp(0, 1, alphaLerp2);
			if (weekendXUnlocked)
				getItemByName("windowDownDark").alpha = FlxMath.lerp(0, 1, alphaLerp2);
			else
				getItemByName("windowUnknown").alpha = FlxMath.lerp(0, 1, alphaLerp2);
			getItemByName("darkSelectLeft").alpha = FlxMath.lerp(0, 1, alphaLerp2);
			getItemByName("darkSelectRight").alpha = FlxMath.lerp(0, 1, alphaLerp2);
		}

		super.update(elapsed);
	}
}
