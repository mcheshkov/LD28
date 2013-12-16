package;

import flixel.util.FlxRandom;
import flixel.system.debug.FlxDebugger;
import Direction;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Bullet.BulletState;
import flixel.FlxG;
import flixel.FlxSprite;
import flash.display.BitmapData;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import openfl.Assets;

enum BulletState {
    Pickup;
    Equip;
    Fired;
}

/**
 * A FlxState which can be used for the actual gameplay.
 */
class Bullet extends FlxSprite {
    public static var SPEED:Int = 500;
    public static var size:Int = 8;
    public var state:BulletState;
    public var ownedBy:Character;
    public var firedBy:Character;
    public var lastDirection:Direction;
    public var i1:BitmapData;
    public var assestLoaded:Bool = false;

    public function new() {
        super();

        loadAssets();
        loadGraphic(i1, true, true, 15, 8);

        loadAnimations();

        animation.play("floor");
        state = BulletState.Pickup;
    }


    public function loadAssets() {
        if (assestLoaded) return;

        i1 = Assets.getBitmapData("assets/images/fish.png");
    }

    public function loadAnimations() {
        animation.add("fire", [1], 1, false);
        animation.add("floor", [0, 1, 2, 1], 6);
    }

    override public function update():Void {
        super.update();
    }

    public function drop(isDeath:Bool = false) {
        velocity.x = velocity.y = 0;
        state = BulletState.Pickup;
        animation.play("floor");

        if (isDeath) {
            // TODO: spawn bullet
        } else {
            FlxG.sound.play("assets/sounds/punch.mp3", 1);
            var newX:Float = x;
            var newY:Float = y;

            var dropBy:Int = FlxRandom.intRanged(size, size * 3);

            switch(lastDirection){
                case Direction.Up:
                    newY += dropBy;
                case Direction.Down:
                    newY -= dropBy;
                case Direction.Left:
                    newX += dropBy;
                case Direction.Right:
                    newX -= dropBy;
            }

            FlxTween.linearMotion(this, x, y, newX, newY, .3, true, {ease:FlxEase.quintOut, type:FlxTween.ONESHOT, complete: function(a:FlxTween) {
                immovable = false;
            }});
        }
    }

    public function fire(d:Direction) {
        animation.play("fire");
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


        state = BulletState.Fired;
    }
}