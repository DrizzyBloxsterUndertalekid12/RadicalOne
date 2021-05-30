package;

import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import Discord.DiscordClient;

class ExtrasMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var controlsStrings:Array<String> = ['SETTINGS', 'WEEKENDS', 'LEVEL RANDOMIZER', 'CREDITS', 'CHARACTERS'];

	private var grpControls:FlxTypedGroup<Alphabet>;

	var everySongEver:Array<String> = [];

	override function create()
	{
		DiscordClient.changePresence("In Menus", null, 'sussy', 'racialdiversity');

		var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/UI/menuDesat.png');
		menuBG.color = 0xFFffc348;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		for (i in 0...StoryMenuState.weekData.length)
		{
			var dreamsBallsAreOnFire:Array<String> = StoryMenuState.weekData[i];
			for (i in dreamsBallsAreOnFire)
			{
				everySongEver.push(i);
			}
		}

		for (i in 0...WeekendMenuState.weekendData.length)
		{
			var dreamsBallsAreOnFire:Array<String> = WeekendMenuState.weekendData[i];
			for (i in dreamsBallsAreOnFire)
			{
				everySongEver.push(i);
			}
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.ACCEPT)
		{
			switch(curSelected) {
				case 0:
					FlxG.switchState(new OptionsMenu());
				case 1:
					FlxG.switchState(new WeekendMenuState());	
				case 2:
					PlayState.initModes();
					PlayState.randomLevel = true;
					var daSong:String = everySongEver[FlxG.random.int(0, everySongEver.length)].toLowerCase();
					trace(daSong);
					PlayState.SONG = Song.loadFromJson(daSong, daSong);
					FlxG.switchState(new PlayState());
				case 3:
					FlxG.openURL("https://sites.google.com/view/radicalone/home");
				
			}
		//	var funnystring = Std.string(curSelected);
		//	FlxG.openURL(funnystring); 
		}

		if (isSettingControl)
			waitingInput();
		else
		{
			if (controls.BACK)
				FlxG.switchState(new MainMenuState());
			if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);
		}
	}

	function waitingInput():Void
	{
		if (FlxG.keys.getIsDown().length > 0)
		{
			PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxG.keys.getIsDown()[0].ID, null);
		}
		// PlayerSettings.player1.controls.replaceBinding(Control)
	}

	var isSettingControl:Bool = false;

	function changeBinding():Void
	{
		if (!isSettingControl)
		{
			isSettingControl = true;
		}
	}

	function changeSelection(change:Int = 0)
	{
//		#if !switch
		//NGio.logEvent('Fresh');
//		#end

		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}