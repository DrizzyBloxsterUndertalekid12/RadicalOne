package;

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

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitLeftPixel:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic('assets/music/HelloGood' + TitleState.soundExt, 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'north':
				FlxG.sound.playMusic('assets/music/Lunchbox' + TitleState.soundExt, 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'namebe':
				FlxG.sound.playMusic('assets/music/Lunchbox' + TitleState.soundExt, 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic('assets/music/LunchboxScary' + TitleState.soundExt, 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'monster':
				FlxG.sound.playMusic('assets/music/MonkeySprite' + TitleState.soundExt, 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'the-backyardagains':
				FlxG.sound.playMusic('assets/music/HelloGood' + TitleState.soundExt, 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'funny':
				FlxG.sound.playMusic('assets/music/intensity' + TitleState.soundExt, 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		portraitLeft = new FlxSprite(232, 229);
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitRight = new FlxSprite((532 + 285), 229);
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		portraitLeftPixel = new FlxSprite(-20, 40);
		portraitLeftPixel.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/chars/senpaiPortrait.png', 'assets/images/dialogueJunk/chars/senpaiPortrait.xml');
		portraitLeftPixel.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitLeftPixel.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitLeftPixel.updateHitbox();
		portraitLeftPixel.scrollFactor.set();
		add(portraitLeftPixel);
		portraitLeftPixel.visible = false;

		box = new FlxSprite(-20, 45);

		switch (PlayState.sheShed)
		{
			case 'senpai':
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/dialogueBox-pixel.png',
					'assets/images/dialogueJunk/dialogueBox-pixel.xml');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByPrefix('normal', 'Text Box Appear', 24, false);
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
			case 'roses':
				FlxG.sound.play('assets/sounds/ANGRY_TEXT_BOX' + TitleState.soundExt);

				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/dialogueBox-senpaiMad.png',
					'assets/images/dialogueJunk/dialogueBox-senpaiMad.xml');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
			case 'monkey-sprite':
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/scary.png', 'assets/images/dialogueJunk/dialogueBox-evil.xml');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
			case 'thorns':
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/dialogueBox-evil.png', 'assets/images/dialogueJunk/dialogueBox-evil.xml');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic('assets/images/dialogueJunk/spiritFaceForward.png');
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
            case 'radical-vs-masked-babbys':
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/dialogueBox-pixel.png',
					'assets/images/dialogueJunk/dialogueBox-pixel.xml');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
            case 'north':
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/dialogueBox-pixel.png',
					'assets/images/dialogueJunk/dialogueBox-pixel.xml');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
			case 'bonnie-song':
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/dialogueBox-bawn.png',
					'assets/images/dialogueJunk/dialogueBox-bawn.xml');
				box.animation.addByPrefix('normalOpen', 'NAMEBE', 24, false);
				box.animation.addByPrefix('normal', 'NAMEBE', 24, false);
				box.setGraphicSize(Std.int(box.width * 0.9));
				box.y += 358;
			case 'without-you':
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/dialogueBox-bawn.png',
					'assets/images/dialogueJunk/dialogueBox-bawn.xml');
				box.animation.addByPrefix('normalOpen', 'NAMEBE', 24, false);
				box.animation.addByPrefix('normal', 'NAMEBE', 24, false);
				box.setGraphicSize(Std.int(box.width * 0.9));
				box.y += 358;
			case 'bonbon-loool':
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/dialogueBox-bawn.png',
					'assets/images/dialogueJunk/dialogueBox-bawn.xml');
				box.animation.addByPrefix('normalOpen', 'NAMEBE', 24, false);
				box.animation.addByPrefix('normal', 'NAMEBE', 24, false);
				box.setGraphicSize(Std.int(box.width * 0.9));
				box.y += 358;
            default:
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/dialogueJunk/dialogueBox-namebe.png',
					'assets/images/dialogueJunk/dialogueBox-namebe.xml');
				box.animation.addByPrefix('normalOpen', 'NAMEBE', 24, false);
				box.animation.addByPrefix('normal', 'NAMEBE', 24, false);
				box.setGraphicSize(Std.int(box.width * 0.9));
				box.y += 358;
		}

		box.animation.play('normalOpen');
		box.updateHitbox();
		add(box);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic('assets/images/UI/pixelUI/hand_textbox.png');
		add(handSelect);

		box.screenCenter(X);
	/*	portraitZBab.screenCenter(X);
		portraitCBab.screenCenter(X); */

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load('assets/sounds/pixelText' + TitleState.soundExt, 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);

		this.dialogueList = dialogueList;
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

       /*       if (PlayState.SONG.song.toLowerCase() != 'namebe' || PlayState.SONG.song.toLowerCase() != 'fnaf-at-phillys' || PlayState.SONG.song.toLowerCase() != 'destructed')
				        box.animation.play('normal');
				                                        */

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY)
		{
			remove(dialogue);

			FlxG.sound.play('assets/sounds/clickText' + TitleState.soundExt, 0.8);

			if (dialogueList[1] == null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns' || PlayState.SONG.song.toLowerCase() == 'north')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitLeftPixel.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
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

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'dad':
			    trace('dad');
				portraitRight.visible = false;
				portraitLeft.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeftPixel.visible = true;
					portraitLeftPixel.animation.play('enter');
				}
			case 'radical':
			    trace('bf');
				rightPort('Racial');
			case 'gaming':
			    trace('bf');
				rightPort('Gaming');
			case 'bab':
			    trace('bab');
                leftPort('Babby_Pissed_Off');
            case 'bob':
			    trace('bab');
                leftPort('Babby_Pissed_On');
            case 'monkey':
			    trace('monkey');
                leftPort('Funny_Monkey');
			case 'namebe':
			    trace('namebe');
                leftPort('Nambe_Pissed_Off');
			case 'boygirl':
			    trace('namebe boy-girl');
                leftPort('Boy_Girl');
			case 'wtf':
			    trace('namebe gf face');
                leftPort('wtf');
			case 'gspot':
			    trace('gandhi');
                leftPort('G_Spot');
			case 'bon':
			    trace('bonbon');
                leftPort('LANCEY_IS_GOING_TO_DO_A_TEST_CHART_OF_OIL_ZIG_ZAG_BEING_SWAGGER');
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}

	function leftPort(char:String, flip:Bool = false)
	{
		portraitRight.visible = false;
		portraitLeftPixel.visible = false;
		portraitLeft.loadGraphic('assets/images/dialogueJunk/chars/' + char + '.png');
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.5));
		portraitLeft.updateHitbox();
		portraitLeft.flipX = flip;
		portraitLeft.visible = true;
	}

	function rightPort(char:String, flip:Bool = false)
	{
		portraitLeft.visible = false;
		portraitLeftPixel.visible = false;
		portraitRight.loadGraphic('assets/images/dialogueJunk/chars/' + char + '.png');
		portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.5));
		portraitRight.updateHitbox();
		portraitRight.flipX = flip;
		portraitRight.visible = true;
	}
}