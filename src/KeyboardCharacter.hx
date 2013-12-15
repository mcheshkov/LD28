package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flash.display.BitmapData;
import openfl.Assets;
import flash.display.Bitmap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class KeyboardCharacter extends Character
{
    override public function control():Void {
        if (FlxG.keyboard.pressed("DOWN")){
            goDown();
        }
        else if (FlxG.keyboard.pressed("UP")){
            goUp();
        }

        if (FlxG.keyboard.pressed("LEFT")){
            goLeft();
        }
        else if (FlxG.keyboard.pressed("RIGHT")){
            goRight();
        }

        if(FlxG.keyboard.pressed("SHIFT")){
            fire();
        }
    }
}