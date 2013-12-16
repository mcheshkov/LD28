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
    public var i0:BitmapData;
    public var assestLoaded:Bool = false;
    public var lvl:TiledLevel;

    public var isTeleportInListen:Bool = false;
    public var isTeleportOutListen:Bool = false;

    public function new(lvl:TiledLevel) {
        super();
        this.lvl = lvl;
        loadAssets();

        switchType(BulletType.Teleport);
        animation.play("teleportIn");
        isTeleportInListen = true;
        state = BulletState.NotSpawn;
        visible = true;
    }

    public function switchType(type:BulletType){
        switch(type){
            case BulletType.Teleport:
                loadGraphic(i0, true, true, 64, 64);
            case BulletType.Cat:

            case BulletType.Fish:
                loadGraphic(i1, true, true, 15, 8);
        }

        loadAnimations(type);
        this.type = type;
    }

    public function loadAssets() {
        if (assestLoaded) return;

        i1 = Assets.getBitmapData("assets/images/fish.png");
        i0 = Assets.getBitmapData("assets/images/teleport.png");
    }

    public function loadAnimations(type:BulletType) {

        switch(type){
            case BulletType.Teleport:
                animation.add("teleportIn", [0,1,2,3,4,5,6,7,8,9], 18, false);
                animation.add("teleportOut", [9,8,7,6,5,4,3,2,1,0], 12, false);
            case BulletType.Cat:

            case BulletType.Fish:
                animation.add("fire", [1], 1, false);
                animation.add("floor", [0, 1, 2, 1], 6);
        }
    }

    override public function update():Void {
        super.update();

        if(animation.finished){
            if(isTeleportInListen){
                teleportInHandler();
            } else if(isTeleportOutListen){
                teleportOutHandler();
            }
        }
    }

    public function teleportInHandler(){
        isTeleportInListen = false;
        switchType(BulletType.Fish);
        animation.play("floor");
        state = BulletState.Pickup;
    }
    public function teleportOutHandler(){
        isTeleportOutListen = false;
    }

    public function drop(isDeath:Bool = false) {
        velocity.x = velocity.y = 0;
        state = BulletState.Pickup;
        animation.play("floor");

        if (isDeath) {
            spawn();
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
        animation.play("floor");
        state = BulletState.NotSpawn;
        visible = false;
        var newX:Int = 300;
        var newY:Int = 300;
        var p:FlxPoint = new FlxPoint(0,0);
        var okPoint:Bool = false;
        do{
//            newX = randomRange(0, lvl.width) * lvl.tileHeight;
//            newY = randomRange(0, lvl.height) * lvl.tileHeight;
//            p.set(newX + _halfWidth, newY + _halfHeight);
//            okPoint = true;
//            for(i in 0...lvl.foregroundTiles.members.length){
//                if(cast(lvl.foregroundTiles.members[i], FlxObject).overlapsPoint(new FlxPoint(newX, newY))){
//                    okPoint = false;
//                    break;
//                }
//            }
        } while(okPoint);

        p = null;
        x = newX;
        y = newY;
        visible = true;
        animation.play("floor");
        state = BulletState.Pickup;
    }

    public function teleportOut(){

    }

    function randomRange(minNum:Int, maxNum:Int):Int {
        return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
    }
}