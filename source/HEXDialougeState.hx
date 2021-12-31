package;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class HEXDialogueBox extends FlxSpriteGroup // copied I know but fuck you
{
	var box:FlxSprite;

	var background:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeftHex:FlxSprite;
	var portraitLeftMyst:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitRightGF:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var black:FlxSprite;

	var sound:FlxSound;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>, ?startingBackground:FlxSprite)
	{
		super();

		trace(dialogueList);
		sound = new FlxSound().loadEmbedded(Paths.music('givinALittle', 'shared'), true);
		sound.volume = 0;
		FlxG.sound.list.add(sound);
		sound.fadeIn(1, 0, 0.8);

		black = new FlxSprite(-200, -200).makeGraphic(9000, 9000, FlxColor.BLACK); // make a big graphic so people cant see gameplay shit
		add(black);

		background = startingBackground;

		add(background);

		box = new FlxSprite(-20, 45).loadGraphic(Paths.image('dialoguebox', 'hex'));
		box.screenCenter(X);
		box.y = FlxG.height * 0.64;

		this.dialogueList = dialogueList;

		portraitLeftHex = new FlxSprite(box.x, box.y - 105).loadGraphic(Paths.image('hex_nametag', 'hex'));
		portraitLeftHex.updateHitbox();
		portraitLeftHex.scrollFactor.set();
		portraitLeftHex.setGraphicSize(Std.int(portraitLeftHex.width * 0.7));
		add(portraitLeftHex);
		portraitLeftHex.visible = false;

		portraitLeftMyst = new FlxSprite(box.x, box.y - 105).loadGraphic(Paths.image('question_nametag', 'hex'));
		portraitLeftMyst.updateHitbox();
		portraitLeftMyst.scrollFactor.set();
		portraitLeftMyst.setGraphicSize(Std.int(portraitLeftMyst.width * 0.7));
		add(portraitLeftMyst);
		portraitLeftMyst.visible = false;

		portraitRight = new FlxSprite(box.width + box.x - 340, box.y - 105).loadGraphic(Paths.image('bf_nametag', 'hex'));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.7));
		add(portraitRight);
		portraitRight.visible = false;

		portraitRightGF = new FlxSprite(box.width + box.x - 340, box.y - 105).loadGraphic(Paths.image('gf_nametag', 'hex'));
		portraitRightGF.updateHitbox();
		portraitRightGF.scrollFactor.set();
		portraitRightGF.setGraphicSize(Std.int(portraitRightGF.width * 0.7));
		add(portraitRightGF);
		portraitRightGF.visible = false;

		box.updateHitbox();
		add(box);

		swagDialogue = new FlxTypeText(240, box.y + 115, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Gotham Black';
		swagDialogue.color = FlxColor.BLACK;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('hx', 'hex'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);

		portraitLeftHex.visible = false;
		portraitLeftMyst.visible = false;
		portraitRight.visible = false;
		portraitRightGF.visible = false;

		dialogueOpened = true;
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true)
		{
			remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText', "shared"), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					remove(black);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						portraitLeftHex.visible = false;
						portraitLeftMyst.visible = false;
						portraitRight.visible = false;
						portraitRightGF.visible = false;
						swagDialogue.alpha -= 1 / 5;
						background.alpha -= 0.2;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		var cleaned = false;

		while (!cleaned)
		{
			if (dialogueList[0].contains(':'))
				cleanDialog();
			else
				cleaned = true;
		}
		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		portraitLeftHex.visible = false;
		portraitLeftMyst.visible = false;
		portraitRight.visible = false;
		portraitRightGF.visible = false;

		switch (curCharacter)
		{
			case 'myst':
				portraitLeftMyst.visible = true;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('hx', 'hex'), 0.6)];
			case 'hex':
				portraitLeftHex.visible = true;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('hx', 'hex'), 0.6)];
			case 'bf':
				portraitRight.visible = true;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bf', 'hex'), 0.6)];
			case 'gf':
				portraitRightGF.visible = true;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('gf', 'hex'), 0.6)];
		}
	}

	function fadeOutBackgroundThenNextOneThisIsAReallyLongFunctionNameIKnowButYouCanJustCryAboutIt(nextBg:String)
	{
		remove(background);
		Main.dumpObject(background.graphic);
		background = new FlxSprite(background.x, background.y).loadGraphic(Paths.image(nextBg, 'hex'));
		background.setGraphicSize(Std.int(background.width * 0.8));
		background.antialiasing = true;
		add(background);
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		if (splitName[1] == 'BGCHANGE')
		{
			trace('BG CHANGE ' + splitName[2]);
			fadeOutBackgroundThenNextOneThisIsAReallyLongFunctionNameIKnowButYouCanJustCryAboutIt(splitName[2]);
			dialogueList.remove(dialogueList[0]);
		}
		else if (splitName[1] == 'PLAYSOUND')
		{
			trace('SOUND LOL ' + splitName[2]);
			var snd:FlxSound = new FlxSound().loadEmbedded(Paths.sound(splitName[2], 'hex'));
			snd.play();
			dialogueList.remove(dialogueList[0]);
		}
		else if (splitName[1] == 'BGTRACK')
		{
			trace('BG TRACK ' + splitName[2]);
			sound.fadeOut();
			FlxG.sound.list.remove(sound);
			sound = new FlxSound().loadEmbedded(Paths.music(splitName[2], 'hex'));
			sound.volume = 0;
			FlxG.sound.list.add(sound);
			sound.fadeIn(1, 0, 0.8);
			dialogueList.remove(dialogueList[0]);
		}
		else
		{
			trace('TALK ' + splitName[2]);
			curCharacter = splitName[1];
			dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
		}
	}
}
