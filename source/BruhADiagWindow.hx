import flixel.math.FlxRect;
import flixel.text.FlxText;
import sys.FileSystem;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import sys.thread.Mutex;
import flixel.FlxG;
import flixel.system.FlxSound;
import sys.io.File;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;

using flixel.util.FlxSpriteUtil;
using StringTools;

typedef DiagLine =
{
	public var character:String;
	public var expression:String;
	public var text:String;
}

class BruhADiagWindow extends MusicBeatState
{
	public var arrows:Array<FlxSprite> = [];
	public var backgrounds:Map<String, FlxSprite> = [];
	public var sounds:Map<String, FlxSound> = [];

	public var arrowGroup:FlxTypedGroup<FlxSprite>;
	public var characterGroup:FlxTypedGroup<FlxSprite>;

	public var startMusicPath:String;

	public var lines:Array<String> = [];
	public var stop:Bool = false;

	public var lineIndex = 0;

	public var startVolume:Float = 1;

	public var section:Int = 0;

	public var waitingForDiag:Bool = false;
	public var diagFinished:Bool = false;
	public var waitingForFade:Bool = false;
	public var waitingOnUpdate:Bool = false;

	public var started:Bool = false;

	public var leftBox:FlxSprite;
	public var leftText:FlxText;

	public var rightBox:FlxSprite;
	public var rightText:FlxText;

	public var leftCharacter:FlxSprite;
	public var leftGraphic:FlxSprite;
	public var lastLeftChar:String = "";
	public var leftExp:String = "";
	public var rightExp:String = "";
	public var leftNameTag:FlxSprite;
	public var leftName:FlxSprite;

	public var leftClip:FlxRect;
	public var rightClip:FlxRect;

	public var rightNameTag:FlxSprite;
	public var rightName:FlxSprite;
	public var rightGraphic:FlxSprite;
	public var rightCharacter:FlxSprite;

	public var bottomTyped:FlxTypedGroup<FlxSprite>;

	public var arrowTyped:FlxTypedGroup<FlxSprite>;
	public var topMost:FlxTypedGroup<FlxSprite>;

	public var escapeText:FlxText;

	// helpers

	public function getLineSplit(line:String):Array<String>
	{
		return line.split(":");
	}

	public function tweenGroup(group:FlxTypedGroup<FlxSprite>, alpha, time)
	{
		for (i in group.members)
			FlxTween.tween(i, {alpha: alpha}, time);
	}

	// functions

	public function changeGraphic(char:String, expression:String, text:String)
	{
		if (char == "BF")
		{
			if (rightGraphic == null)
			{
				rightGraphic = new FlxSprite(0, 0).loadGraphic(Paths.image("dialogueSystem/color_bf", "hex"));
				rightGraphic.alpha = 0;
				FlxTween.tween(rightGraphic, {alpha: 1}, 0.08);
				bottomTyped.add(rightGraphic);
				rightNameTag = new FlxSprite(40, 0).loadGraphic(Paths.image("dialogueSystem/nametag_bf", "hex"));
				rightNameTag.alpha = 0;
				FlxTween.tween(rightNameTag, {alpha: 1, x: 0}, 0.08);
				bottomTyped.add(rightNameTag);
				rightName = new FlxSprite(40, 0).loadGraphic(Paths.image("dialogueSystem/name_bf", "hex"));
				rightName.alpha = 0;
				FlxTween.tween(rightName, {alpha: 1, x: 0}, 0.08);
				bottomTyped.add(rightName);
			}
			if (rightCharacter != null)
			{
				characterGroup.members.remove(rightCharacter);
				Main.dumpObject(rightCharacter.graphic);
			}
			rightCharacter = new FlxSprite(795, 110).loadGraphic(Paths.image("dialogue_sprites/bf/" + expression, "hex"));
			rightCharacter.alpha = 0;
			rightCharacter.antialiasing = true;
			// offset cuz yay!
			if (FileSystem.exists("assets/hex/images/dialogue_sprites/bf/" + expression + "_offset.txt"))
			{
				var offsets = File.getContent("assets/hex/images/dialogue_sprites/bf/" + expression + "_offset.txt")
					.replace("\n", "")
					.replace("\r", "")
					.replace("\t", "")
					.split(";");
				if (offsets[2] != null)
					rightCharacter.angle = Std.parseInt(offsets[2]);
				rightCharacter.offset.set(Std.parseInt(offsets[0]), Std.parseInt(offsets[1]));
			}
			rightExp = expression;
			FlxTween.tween(rightCharacter, {alpha: 1}, 0.1, {
				onComplete: function(tw)
				{
					actuallyShowIt(text, char, false);
				}
			});
		}
		else
		{
			if (lastLeftChar != char)
			{
				if (leftGraphic != null)
				{
					bottomTyped.members.remove(leftGraphic);
					Main.dumpObject(leftGraphic.graphic);
					bottomTyped.members.remove(leftName);
					Main.dumpObject(leftName.graphic);
					bottomTyped.members.remove(leftNameTag);
					Main.dumpObject(leftNameTag.graphic);
				}
				if (char == "??")
					leftGraphic = new FlxSprite(0, 0).loadGraphic(Paths.image("dialogueSystem/color_ir", "hex"));
				else
					leftGraphic = new FlxSprite(0, 0).loadGraphic(Paths.image("dialogueSystem/color_" + char.toLowerCase(), "hex"));
				leftGraphic.alpha = 0;
				FlxTween.tween(leftGraphic, {alpha: 1}, 0.08);
				bottomTyped.add(leftGraphic);
				if (char == "??")
					leftName = new FlxSprite(-40, 0).loadGraphic(Paths.image("dialogueSystem/name_unknown", "hex"));
				else
					leftName = new FlxSprite(-40, 0).loadGraphic(Paths.image("dialogueSystem/name_" + char.toLowerCase(), "hex"));
				leftName.alpha = 0;
				FlxTween.tween(leftName, {alpha: 1, x: 0}, 0.08);
				if (char == "??")
					leftNameTag = new FlxSprite(-40, 0).loadGraphic(Paths.image("dialogueSystem/nametag_ir", "hex"));
				else
					leftNameTag = new FlxSprite(-40, 0).loadGraphic(Paths.image("dialogueSystem/nametag_" + char.toLowerCase(), "hex"));
				leftNameTag.alpha = 0;
				FlxTween.tween(leftNameTag, {alpha: 1, x: 0}, 0.08);
				bottomTyped.add(leftNameTag);
				bottomTyped.add(leftName);
			}
			if (char == "??")
				char = "ir";
			if (leftCharacter != null)
			{
				characterGroup.members.remove(leftCharacter);
				Main.dumpObject(leftCharacter.graphic);
				leftCharacter = new FlxSprite(115, 160).loadGraphic(Paths.image("dialogue_sprites/" + char.toLowerCase() + "/" + expression, "hex"));
				leftCharacter.alpha = 0;
				FlxTween.tween(leftCharacter, {alpha: 1}, 0.1, {
					onComplete: function(tw)
					{
						actuallyShowIt(text, char, true);
					}
				});
			}
			else
			{
				leftCharacter = new FlxSprite(90, 160).loadGraphic(Paths.image("dialogue_sprites/" + char.toLowerCase() + "/" + expression, "hex"));
				leftCharacter.alpha = 0;
				FlxTween.tween(leftCharacter, {alpha: 1, x: 115}, 0.1, {
					onComplete: function(tw)
					{
						actuallyShowIt(text, char, true);
					}
				});
			}
			leftCharacter.antialiasing = true;
			// offset cuz yay!
			if (FileSystem.exists("assets/hex/images/dialogue_sprites/" + char.toLowerCase() + "/" + expression + "_offset.txt"))
			{
				var offsets = File.getContent("assets/hex/images/dialogue_sprites/" + char.toLowerCase() + "/" + expression + "_offset.txt")
					.replace("\n", "")
					.replace("\r", "")
					.replace("\t", "")
					.split(";");
				if (offsets[2] != null)
					leftCharacter.angle = Std.parseInt(offsets[2]);
				leftCharacter.offset.set(Std.parseInt(offsets[0]), Std.parseInt(offsets[1]));
			}
			leftExp = expression;

			lastLeftChar = char;
		}
		if (rightCharacter != null && char == "BF")
			characterGroup.add(rightCharacter);
		if (leftCharacter != null && char != "BF")
			characterGroup.add(leftCharacter);
	}

	public function actuallyShowIt(text:String, char:String, left:Bool)
	{
		if (left)
		{
			leftText = new FlxText(430, 515, 215);
			leftText.wordWrap = true;
			leftText.setFormat(Paths.font("Gotham_Black_Regular.ttf"), 20, FlxColor.BLACK, FlxTextAlign.CENTER);
			leftText.text = text;
			leftText.alpha = 0;
			if (leftBox == null)
			{
				leftBox = new FlxSprite(0, 0).loadGraphic(Paths.image("dialogueSystem/text_bubble_left", "hex"));
				leftBox.alpha = 0;
				FlxTween.tween(leftBox, {alpha: 1}, 0.14, {
					onComplete: function(tw)
					{
						FlxTween.tween(leftText, {alpha: 1}, 0.06, {
							onComplete: function(tw)
							{
								diagFinished = true;
								FlxG.sound.play(Paths.sound(char.toLowerCase(), "hex"));
							}
						});
					}
				});
				topMost.add(leftBox);
			}
			else
			{
				diagFinished = true;
				FlxG.sound.play(Paths.sound(char.toLowerCase(), "hex"));
				FlxTween.tween(leftText, {alpha: 1}, 0.06);
			}
			topMost.add(leftText);
		}
		else
		{
			rightText = new FlxText(695, 425, 215);
			rightText.wordWrap = true;
			rightText.setFormat(Paths.font("Gotham_Black_Regular.ttf"), 20, FlxColor.BLACK, FlxTextAlign.CENTER);
			rightText.text = text;
			rightText.alpha = 0;
			if (rightBox == null)
			{
				rightBox = new FlxSprite(0, 0).loadGraphic(Paths.image("dialogueSystem/text_bubble_right", "hex"));
				rightBox.alpha = 0;
				FlxTween.tween(rightBox, {alpha: 1}, 0.09, {
					onComplete: function(tw)
					{
						FlxTween.tween(rightText, {alpha: 1}, 0.06, {
							onComplete: function(tw)
							{
								diagFinished = true;
								FlxG.sound.play(Paths.sound(char.toLowerCase(), "hex"));
							}
						});
					}
				});
				topMost.add(rightBox);
			}
			else
			{
				diagFinished = true;
				FlxG.sound.play(Paths.sound(char.toLowerCase(), "hex"));
				FlxTween.tween(rightText, {alpha: 1}, 0.06);
			}
			topMost.add(rightText);
		}
	}

	public function showLine(diag:DiagLine)
	{
		if (diag.character == "??")
			Debug.logTrace("Showing " + diag.character + " that says " + diag.text + " with the expression: " + diag.expression);
		diagFinished = false;
		if (diag.character != "BF")
		{
			if (arrows[0].alpha != 1)
			{
				for (i in 0...4)
				{
					var arrow = arrows[i];
					switch (i % 4)
					{
						case 0:
							arrow.y = 40;
							FlxTween.tween(arrow, {alpha: 1, y: 0}, 0.6, {
								ease: FlxEase.cubeIn,
								onComplete: function(tw)
								{
									changeGraphic(diag.character, diag.expression, diag.text);
								}
							});
						case 1:
							arrow.x = 40;
							FlxTween.tween(arrow, {alpha: 1, x: 0}, 0.6, {ease: FlxEase.cubeIn});
						case 2:
							arrow.x = -40;
							FlxTween.tween(arrow, {alpha: 1, x: 0}, 0.6, {ease: FlxEase.cubeIn});
						case 3:
							arrow.y = -40;
							FlxTween.tween(arrow, {alpha: 1, y: 0}, 0.6, {ease: FlxEase.cubeIn});
					}
				}
			}
			else
			{
				changeGraphic(diag.character, diag.expression, diag.text);
			}

			if (leftText != null)
			{
				topMost.members.remove(leftText);
			}
		}
		else
		{
			if (arrows[4].alpha != 1)
			{
				for (i in 4...8)
				{
					var arrow = arrows[i];
					switch (i % 4)
					{
						case 0:
							arrow.y = 40;
							FlxTween.tween(arrow, {alpha: 1, y: 0}, 0.6, {
								ease: FlxEase.cubeIn,
								onComplete: function(tw)
								{
									changeGraphic(diag.character, diag.expression, diag.text);
								}
							});
						case 1:
							arrow.x = 40;
							FlxTween.tween(arrow, {alpha: 1, x: 0}, 0.6, {ease: FlxEase.cubeIn});
						case 2:
							arrow.x = -40;
							FlxTween.tween(arrow, {alpha: 1, x: 0}, 0.6, {ease: FlxEase.cubeIn});
						case 3:
							arrow.y = -40;
							FlxTween.tween(arrow, {alpha: 1, y: 0}, 0.6, {ease: FlxEase.cubeIn});
					}
				}
			}
			else
			{
				changeGraphic(diag.character, diag.expression, diag.text);
			}

			if (rightText != null)
			{
				topMost.members.remove(rightText);
			}
		}
	}

	public function skipDiag()
	{
		if (diagFinished)
		{
			waitingForDiag = false;
		}
	}

	public function parseLine(line:String)
	{
		if (line.startsWith("//"))
		{
			return;
		}

		if (line.contains(";"))
		{
			if (section < 1)
			{
				section++;
				return;
			}
			if (stop)
			{
				return;
			}
		}

		var line = line.replace("\n", "").replace("\r", "").replace("\t", "");

		var split = getLineSplit(line);
		if (split.length < 2)
		{
			switch (line)
			{
				case "fadeIntoNext":
					Debug.logTrace("fading lol");
					// this one is a lil complicated, but its cool
					lineIndex++;
					var nextLine = lines[lineIndex].replace("\n", "").replace("\r", "").replace("\t", "");
					var bgsToFadeTo:Array<FlxSprite> = [];
					tweenGroup(arrowGroup, 0, 1.9);
					tweenGroup(bottomTyped, 0, 2);
					tweenGroup(topMost, 0, 2);
					tweenGroup(characterGroup, 0, 2);
					while (nextLine != ";")
					{
						if (nextLine.startsWith("bg: "))
						{
							Debug.logTrace("fading to " + nextLine.split(": ")[1]);
							bgsToFadeTo.push(backgrounds[nextLine.split(": ")[1]]);
							backgrounds[nextLine.split(": ")[1]].alpha = 0;
							backgrounds[nextLine.split(": ")[1]].visible = true;
						}
						lineIndex++;
						nextLine = lines[lineIndex].replace("\n", "").replace("\r", "").replace("\t", "");
					}
					var done:Bool = false;
					waitingForFade = true;
					for (i in backgrounds.keys())
					{
						FlxTween.tween(backgrounds[i], {alpha: 0}, 2, {
							onComplete: function(tw)
							{
								if (!done)
								{
									done = true;
									lastLeftChar = "";
									tweenGroup(bottomTyped, 1, 2);
									tweenGroup(characterGroup, 1, 2);
									// HUGE JANK LOL!
									FlxTween.tween(topMost.members[0], {alpha: 1}, 2);
									FlxTween.tween(topMost.members[1], {alpha: 1}, 2);
									characterGroup.members.remove(leftCharacter);
									characterGroup.members.remove(rightCharacter);
									if (leftGraphic != null)
									{
										bottomTyped.members.remove(leftGraphic);
										bottomTyped.members.remove(leftNameTag);
										bottomTyped.members.remove(leftName);
										topMost.members.remove(leftBox);
									}
									if (rightGraphic != null)
									{
										bottomTyped.members.remove(rightGraphic);
										bottomTyped.members.remove(rightNameTag);
										bottomTyped.members.remove(rightName);
										topMost.members.remove(rightBox);
									}
									rightGraphic = null;
									leftBox = null;
									rightBox = null;
									leftGraphic = null;
									for (bg in bgsToFadeTo)
									{
										bg.visible = true;
										FlxTween.tween(bg, {alpha: 1}, 2, {
											onComplete: function(tww)
											{
												waitingForFade = false;
											}
										});
									}
								}
							}
						});
					}
				case "backToMenu":
					var state = new UnlockedState();
					state.unlockSprite = "unlock_screen_2";
					switchState(state);
				case "startSong":
					toPlaystate();
			}
			return;
		}
		split[1] = split[1].substr(1);
		if (section < 1) // header
		{
			switch (split[0])
			{
				case "startMusic":
					startMusicPath = split[1];
					Debug.logTrace("start music is " + startMusicPath);
				case "startMusicVolume":
					startVolume = Std.parseFloat(split[1]);
				case "addBackground":
					var otherSplit = split[1].split('#');
					var path = otherSplit[0];
					Debug.logTrace(otherSplit[1]);
					var visible = false;
					if (otherSplit[1].startsWith("tr"))
						visible = true;
					var sprite = new FlxSprite(0, 0).loadGraphic(Paths.image('dialogueSystem/${path}', "hex"));
					sprite.scrollFactor.set();
					sprite.visible = visible;
					backgrounds.set(split[1].split('#')[0], sprite);
					Debug.logTrace("added " + path + " vis: " + visible);
				case "addSound":
					var sound = new FlxSound().loadEmbedded(Paths.sound(split[1].replace(".ogg", ""), "hex"));
					FlxG.sound.list.add(sound);
					sounds.set(split[1].replace(".ogg", ""), sound);
					Debug.logTrace("added " + split[1] + " which is a sound");
			}
		}
		else
		{
			switch (split[0])
			{
				case "playSound":
					Debug.logTrace("playing " + line.split(": ")[1]);
					sounds[line.split(": ")[1]].play();
				case "playMusic":
					FlxG.sound.playMusic(Paths.music(line.split(": ")[1], "hex"));
					FlxG.sound.music.volume = startVolume;

				default:
					if (!line.contains(":")) // if it doesn't have anything, lets just skip it.
					{
						return;
					}
					// start diag

					// haha string manipulation
					var char = line.split(":")[0];
					var rplc = line.replace(char + ":", "");
					var txt = rplc.split(";")[0].substr(1);
					var exp = rplc.split(";")[1];

					waitingForDiag = true;

					showLine({character: char, text: txt, expression: exp});
			}
		}
	}

	public function toPlaystate()
	{
		tweenGroup(arrowGroup, 0, 1.9);
		tweenGroup(bottomTyped, 0, 2);
		tweenGroup(topMost, 0, 2);
		tweenGroup(characterGroup, 0, 2);

		var done = false;

		waitingForFade = true; // never stop it

		for (i in backgrounds.keys())
		{
			FlxTween.tween(backgrounds[i], {alpha: 0}, 2, {
				onComplete: function(tw)
				{
					if (!done)
					{
						done = true;
						switchState(new PlayState());
					}
				}
			});
		}
	}

	public function toMainMenu()
	{
		tweenGroup(arrowGroup, 0, 1.9);
		tweenGroup(bottomTyped, 0, 2);
		tweenGroup(topMost, 0, 2);
		tweenGroup(characterGroup, 0, 2);

		var done = false;

		waitingForFade = true; // never stop it

		for (i in backgrounds.keys())
		{
			FlxTween.tween(backgrounds[i], {alpha: 0}, 2, {
				onComplete: function(tw)
				{
					if (!done)
					{
						done = true;
						switchState(new HexMainMenu(HexMenuState.loadHexMenu("main-menu")));
					}
				}
			});
		}
	}

	public override function load()
	{
		super.load();
	}

	public var song:String = "";

	public function new(songName)
	{
		song = songName;
		super();
	}

	public override function create()
	{
		if (song == "detectedEnd")
			lines = File.getContent('assets/data/songs/detected/endDialogue.txt').split('\n');
		else
			lines = File.getContent('assets/data/songs/${song}/dialogue.txt').split('\n');
		while (section != 1)
		{
			parseLine(lines[lineIndex]);
			lineIndex++;
		}

		var arrow = null;
		arrows.push(arrow = new FlxSprite(0, 0).loadGraphic(Paths.image("dialogueSystem/arrow_left_left", "hex")));
		arrow.alpha = 0;
		arrows.push(arrow = new FlxSprite(0, 0).loadGraphic((Paths.image("dialogueSystem/arrow_left_down", "hex"))));
		arrow.alpha = 0;
		arrows.push(arrow = new FlxSprite(0, 0).loadGraphic((Paths.image("dialogueSystem/arrow_left_up", "hex"))));
		arrow.alpha = 0;
		arrows.push(arrow = new FlxSprite(0, 0).loadGraphic((Paths.image("dialogueSystem/arrow_left_right", "hex"))));
		arrow.alpha = 0;
		arrows.push(arrow = new FlxSprite(0, 0).loadGraphic((Paths.image("dialogueSystem/arrow_right_left", "hex"))));
		arrow.alpha = 0;
		arrows.push(arrow = new FlxSprite(0, 0).loadGraphic((Paths.image("dialogueSystem/arrow_right_down", "hex"))));
		arrow.alpha = 0;
		arrows.push(arrow = new FlxSprite(0, 0).loadGraphic((Paths.image("dialogueSystem/arrow_right_up", "hex"))));
		arrow.alpha = 0;
		arrows.push(arrow = new FlxSprite(0, 0).loadGraphic((Paths.image("dialogueSystem/arrow_right_right", "hex"))));
		arrow.alpha = 0;
		topMost = new FlxTypedGroup<FlxSprite>();
		topMost.add(arrow = new FlxSprite(0, 0).loadGraphic((Paths.image("dialogueSystem/top_screen_arrows", "hex"))));
		arrow.alpha = 0;
		topMost.add(arrow = new FlxSprite(0, 0).loadGraphic((Paths.image("dialogueSystem/down_screen_arrows", "hex"))));
		arrow.alpha = 0;

		Debug.logTrace("creating items");
		addItems();

		waitingOnUpdate = true;

		FlxG.sound.playMusic(Paths.music(startMusicPath.replace(".ogg", ""), "hex"));
		FlxG.sound.music.volume = startVolume;

		Debug.logTrace("bruhg!");
		super.create();
	}

	public var debug:FlxText;
	public var canvas:FlxSprite;

	public var skipToggle:Bool = false;

	public function addItems()
	{
		// layering is a bitch
		arrowGroup = new FlxTypedGroup<FlxSprite>();
		characterGroup = new FlxTypedGroup<FlxSprite>();
		bottomTyped = new FlxTypedGroup<FlxSprite>();
		for (hah in backgrounds.keys())
		{
			add(backgrounds[hah]);
		}
		for (i in arrows)
		{
			if (arrows.indexOf(i) == 1 || arrows.indexOf(i) == 5)
			{
				topMost.add(i);
			}
			else
				arrowGroup.add(i);
		}
		add(bottomTyped);
		add(arrowGroup);
		add(characterGroup);
		add(topMost);
		debug = new FlxText(0, 40, 0, "DEBUG MODE (OFFSETS, LEFT/RIGHT/UP/DOWN FOR OC, ADD SHIFT FOR BF. S TO SAVE, R TO RESET)");
		debug.setFormat(Paths.font("Gotham_Black_Regular.ttf"), 12, FlxColor.BLACK, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		debug.visible = false;
		add(debug);
		canvas = new FlxSprite();
		canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(canvas);

		escapeText = new FlxText(12, 740, 0, "Press escape again to skip!", 24);
		escapeText.setFormat(Paths.font("Gotham_Black_Regular.ttf"), 32, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		escapeText.borderSize = 2;
		add(escapeText);
		escapeText.alpha = 0;
	}

	public var escapeTween:FlxTween;

	public override function update(elapsed:Float)
	{
		if (!waitingForDiag && !waitingForFade && started)
		{
			lineIndex++;
			parseLine(lines[lineIndex]);
		}
		else if (waitingForDiag)
		{
			if (FlxG.keys.justPressed.ENTER)
			{
				skipDiag();
			}
		}

		// dawg this is the smoothest shit i've ever made

		if (skipToggle)
		{
			if (escapeText.alpha == 0)
				skipToggle = false;
			if (escapeText.alpha < 0.8)
			{
				escapeTween = FlxTween.tween(escapeText, {y: 740}, 1, {ease: FlxEase.elasticIn});
			}
			escapeText.alpha -= elapsed * 0.4;
		}

		if (FlxG.keys.justPressed.ESCAPE && escapeText.alpha == 0)
		{
			FlxTween.tween(escapeText, {alpha: 1, y: 680}, 3, {
				ease: FlxEase.elasticOut,
				onComplete: function(tw)
				{
					skipToggle = true;
				}
			});
		}
		else if (FlxG.keys.justPressed.ESCAPE && escapeText.alpha > 0)
		{
			if (escapeTween != null)
			{
				FlxTween.globalManager.completeTweensOf(escapeText);
				escapeText.y = 680;
			}
			skipToggle = false;
			escapeText.alpha = 1;
			if (song.contains("End"))
			{
				var state = new UnlockedState();
				state.unlockSprite = "unlock_screen_2";
				switchState(state);
			}
			else
				toPlaystate();
			FlxTween.tween(escapeText, {alpha: 0, y: 740}, 2, {ease: FlxEase.elasticIn});
		}

		if (FlxG.keys.justPressed.F1)
		{
			debug.visible = !debug.visible;
		}

		if (debug.visible)
		{
			if (FlxG.keys.pressed.LEFT)
			{
				if (FlxG.keys.pressed.SHIFT)
					rightCharacter.offset.x++
				else
					leftCharacter.offset.x++;
			}
			if (FlxG.keys.pressed.RIGHT)
			{
				if (FlxG.keys.pressed.SHIFT)
					rightCharacter.offset.x--;
				else
					leftCharacter.offset.x--;
			}
			if (FlxG.keys.pressed.DOWN)
			{
				if (FlxG.keys.pressed.SHIFT)
					rightCharacter.offset.y--;
				else
					leftCharacter.offset.y--;
			}
			if (FlxG.keys.pressed.UP)
			{
				if (FlxG.keys.pressed.SHIFT)
					rightCharacter.offset.y++;
				else
					leftCharacter.offset.y++;
			}

			if (FlxG.keys.pressed.A)
			{
				if (FlxG.keys.pressed.SHIFT)
					rightCharacter.angle++;
				else
					leftCharacter.angle++;
			}

			if (FlxG.keys.pressed.D)
			{
				if (FlxG.keys.pressed.SHIFT)
					rightCharacter.angle--;
				else
					leftCharacter.angle--;
			}

			if (FlxG.keys.justPressed.R)
			{
				if (leftCharacter != null)
				{
					leftCharacter.offset.x = 0;
					leftCharacter.offset.y = 0;
					leftCharacter.angle = 0;
				}
				if (rightCharacter != null)
				{
					rightCharacter.offset.x = 0;
					rightCharacter.offset.y = 0;
					rightCharacter.angle = 0;
				}
			}

			if (FlxG.keys.justPressed.S)
			{
				if (rightCharacter != null)
					File.saveContent(FileSystem.absolutePath("assets/hex/images/dialogue_sprites/bf/" + rightExp + "_offset.txt"),
						rightCharacter.offset.x
						+ ";"
						+ rightCharacter.offset.y
						+ ";"
						+ rightCharacter.angle);
				if (leftCharacter != null)
					File.saveContent(FileSystem.absolutePath("assets/hex/images/dialogue_sprites/" + lastLeftChar.toLowerCase() + "/" + leftExp +
						"_offset.txt"),
						leftCharacter.offset.x
						+ ";"
						+ leftCharacter.offset.y
						+ ";"
						+ leftCharacter.angle);
			}
		}

		if (waitingOnUpdate)
		{
			waitingOnUpdate = false;
			// do tweens

			var upArrow = topMost.members[0];
			var downArrow = topMost.members[1];

			upArrow.y = -40;
			FlxTween.tween(upArrow, {alpha: 1, y: 0}, 0.8, {ease: FlxEase.cubeIn});
			downArrow.y = 40;
			FlxTween.tween(downArrow, {alpha: 1, y: 0}, 0.8, {
				ease: FlxEase.cubeIn,
				onComplete: function(tw)
				{
					started = true;
				}
			});
		}
		super.update(elapsed);
	}
}
