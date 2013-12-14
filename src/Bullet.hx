package;

import flixel.system.debug.FlxDebugger;
import Direction;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Bullet.BulletState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

enum BulletState{
    Pickup;
    Equip;
    Fired;
}

/**
 * A FlxState which can be used for the actual gameplay.
 */
class Bullet extends FlxSprite
{
    public static var SPEED:Int = 500;
    public static var COLOR:Int = 0xff407740;
    public static var size:Int = 8;

    public var state:BulletState;
    public var lastDirection:Direction;
    public function new(){
        super();

        makeGraphic(size,size,COLOR);
        state = BulletState.Pickup;
    }

    override public function update():Void {
        super.update();
    }

    public function drop(){
        state = BulletState.Pickup;
        var newX:Float = x;
        var newY:Float = y;

        switch(lastDirection){
            case Direction.Up:
                newY += 5;
            case Direction.Down:
                newY -= 5;
            case Direction.Left:
                newX += 5;
            case Direction.Right:
                newX -= 5;
        }

        FlxTween.linearMotion(this, x, y,newX, newY, .1, true, {ease:FlxEase.bounceIn, type:FlxTween.ONESHOT});

    }

    public function fire(d:Direction){
        lastDirection = d;
        switch(d){
        case Direction.Up:
            velocity.y = -SPEED;
        case Direction.Down:
            velocity.y = SPEED;
        case Direction.Left:
            velocity.x = -SPEED;
        case Direction.Right:
            velocity.x = SPEED;
        }



       FlxG.log.notice(state);

        state = BulletState.Fired;
    }
}