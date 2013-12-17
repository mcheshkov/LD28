package;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

import openfl.Assets;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the game's menu.
 */
class LoseState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.hide();
		#end
        FlxG.sound.playMusic("assets/music/LD_5.mp3", 1);
        var a:FlxSprite = new FlxSprite();
        a.loadGraphic(Assets.getBitmapData("assets/images/lose.png"));
        add(a);


//        mixing();

		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();

        if(FlxG.keyboard.pressed("R")){
            FlxG.switchState(new MenuState());
        }
	}	
}