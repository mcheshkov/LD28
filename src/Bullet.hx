package;

import flash.geom.Point;
import flixel.util.FlxPoint;
import flixel.util.FlxMisc;
import flixel.util.FlxRandom;
import flixel.system.debug.FlxDebugger;
import Direction;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Bullet.BulletState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flash.display.BitmapData;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import openfl.Assets;

enum BulletState {
    NotSpawn;
    Pickup;
    Equip;
    Fired;
}

enum BulletType {
    Teleport;
    Fish;
    Cat;
}

/**
 * A FlxState which can be used for the actual gameplay.
 */
class Bullet extends FlxSprite {
    public static var SPEED:Int = 500;
    public static var size:Int = 8;
    public var state:BulletState;
    public var type:BulletType;
    public var ownedBy:Character;
    public var firedBy:Character;
    public var lastDirection:Direction;
    public var i1:BitmapData;
    public var assestLoaded:Bool = false;
    public var lvl:TiledLevel;

    public var isTeleportInListen:Bool = false;
    public var isTeleportOutListen:Bool = false;

    public function new(lvl:TiledLevel) {
        super();
        this.lvl = lvl;
        loadAssets();

        loadGraphic(i1, true, true, 64, 64);

        loadAnimations();
        switchType(BulletType.Fish);
        animation.play("floor");
        isTeleportInListen = true;
        state = BulletState.NotSpawn;
        visible = true;

        height = 8;
        width = 8;
        _offset.x = 28;
        _offset.y = 56;
    }

    public function switchType(type:BulletType) {
        this.type = type;
    }

    public function loadAssets() {
        if (assestLoaded) return;

        i1 = Assets.getBitmapData("assets/images/teleportAll.png");
    }

    public function loadAnimations() {
        animation.add("teleportIn", [10, 11, 12, 13, 14, 15, 16, 17, 18, 19], 18, false);
        animation.add("teleportOut", [19, 18, 17, 16, 15, 14, 13, 12, 11, 10], 18, false);
        animation.add("fire", [48], 1, false);
        animation.add("floor", [47, 48, 49, 48], 6);
    }

    override public function update():Void {
        super.update();

        if (animation.finished) {
            if (isTeleportInListen) {
                teleportInHandler();
            } else if (isTeleportOutListen) {
                teleportOutHandler();
            }
        }
    }

    public function teleportInHandler() {
        isTeleportInListen = false;
        switchType(BulletType.Fish);
        animation.play("floor");
        state = BulletState.Pickup;
    }

    public function teleportOutHandler() {
        isTeleportOutListen = false;
        spawn();
    }

    public function drop(isDeath:Bool = false) {
        velocity.x = velocity.y = 0;
        state = BulletState.Pickup;
        animation.play("floor");

        if (isDeath) {
//spawn();
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

    public function spawn() {
//animation.play("floor");
        state = BulletState.NotSpawn;
        visible = false;
        var newX:Float = 300;
        var newY:Float = 300;
        var p:FlxPoint = new FlxPoint(0, 0);
        var okPoint:Bool = false;
        do {
//            newX = randomRange(0, lvl.width) * lvl.tileHeight;
//            newY = randomRange(0, lvl.height) * lvl.tileHeight;
//            p.set(newX, newY);
//            okPoint = true;
//            for(i in 0...lvl.foregroundTiles.members.length){
//                if(cast(lvl.foregroundTiles.members[i], FlxObject).overlapsPoint(new FlxPoint(newX, newY))){
//                    okPoint = false;
//                    break;
//                }
//            }
        } while (okPoint);

        p = null;
        x = newX;
        y = newY;
        visible = true;
        switchType(BulletType.Teleport);
        animation.play("teleportIn");
        isTeleportInListen = true;
    }

    function randomRange(minNum:Int, maxNum:Int):Int {
        return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
    }
}