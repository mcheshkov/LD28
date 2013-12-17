package;

import Bullet.BulletType;
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
    Mole;
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
        switchType(BulletType.Cat);
        play_floor();
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
        animation.add("fish_teleportIn",  [10, 11, 12, 13, 14, 15, 16, 17, 18, 19], 16, false);
        animation.add("fish_teleportOut", [19, 18, 17, 16, 15, 14, 13, 12, 11, 10], 16, false);
        animation.add("fish_fire", [48], 1, false);
        animation.add("fish_fire_up", [48], 1, false);
        animation.add("fish_fire_down", [48], 1, false);
        animation.add("fish_floor", [47, 48, 49, 48], 6);

        animation.add("cat_teleportIn",  [0,1,2,3,4,5,6,7,8,9], 16, false);
        animation.add("cat_teleportOut", [9,8,7,6,5,4,3,2,1,0], 16, false);
        animation.add("cat_fire", [35], 1, false);
        animation.add("cat_fire_up", [44], 1, false);
        animation.add("cat_fire_down", [39], 1, false);
        animation.add("cat_floor", [37,38,39,40], 6);

        animation.add("mole_teleportIn", [20,21,22,23,24,25,26,27,28,29], 16, false);
        animation.add("mole_teleportOut", [29,28,27,26,25,24,23,22,21,20], 16, false);
        animation.add("mole_fire", [58], 1, false);
        animation.add("mole_fire_up", [60], 1, false);
        animation.add("mole_fire_down", [59], 1, false);
        animation.add("mole_floor", [50,51,52,53,54,53,52,51,50], 6);
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

    public function play_floor(){
        switch (type){
            case BulletType.Cat: animation.play("cat_floor");
            case BulletType.Fish: animation.play("fish_floor");
            case BulletType.Mole: animation.play("mole_floor");
            case BulletType.Teleport:
        }
    }

    public function play_fire(){
        switch (type){
            case BulletType.Cat: animation.play("cat_fire");
            case BulletType.Fish: animation.play("fish_fire");
            case BulletType.Mole: animation.play("mole_fire");
            case BulletType.Teleport:
        }
    }

    public function play_fire_up(){
        switch (type){
            case BulletType.Cat: animation.play("cat_fire_up");
            case BulletType.Fish: animation.play("fish_fire_up");
            case BulletType.Mole: animation.play("mole_fire_up");
            case BulletType.Teleport:
        }
    }

    public function play_fire_down(){
        switch (type){
            case BulletType.Cat: animation.play("cat_fire_down");
            case BulletType.Fish: animation.play("fish_fire_down");
            case BulletType.Mole: animation.play("mole_fire_down");
            case BulletType.Teleport:
        }
    }

    public function play_teleportIn(){
        switch (type){
            case BulletType.Cat: animation.play("cat_teleportIn");
            case BulletType.Fish: animation.play("fish_teleportIn");
            case BulletType.Mole: animation.play("mole_teleportIn");
            case BulletType.Teleport:
        }
    }

    public function play_teleportOut(){
        switch (type){
            case BulletType.Cat: animation.play("cat_teleportOut");
            case BulletType.Fish: animation.play("fish_teleportOut");
            case BulletType.Mole: animation.play("mole_teleportOut");
            case BulletType.Teleport:
        }
    }

    public function teleportInHandler() {
        isTeleportInListen = false;
//        switchType(BulletType.Fish);
        play_floor();
        state = BulletState.Pickup;
    }

    public function teleportOutHandler() {
        isTeleportOutListen = false;
        spawn();
    }

    public function drop(isDeath:Bool = false) {
        velocity.x = velocity.y = 0;
        state = BulletState.Pickup;
        play_floor();

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
        lastDirection = d;
        switch(d){
            case Direction.Up:
                velocity.y = -SPEED;
                play_fire_up();
            case Direction.Down:
                velocity.y = SPEED;
                play_fire_down();
            case Direction.Left:
                facing = FlxObject.RIGHT; //hack
                if (type == BulletType.Fish) facing = FlxObject.LEFT;
                velocity.x = -SPEED;
                play_fire();
            case Direction.Right:
                facing = FlxObject.LEFT; //hack
                if (type == BulletType.Fish) facing = FlxObject.RIGHT;
                velocity.x = SPEED;
                play_fire();
        }


        state = BulletState.Fired;
    }

    public function spawn() {
//play_floor();
        state = BulletState.NotSpawn;
        visible = false;
        var newX:Float = 300;
        var newY:Float = 300;
        var p:FlxPoint = new FlxPoint(0, 0);
        var okPoint:Bool = false;
        do {
            newX = randomRange(0, lvl.width) * lvl.tileWidth + lvl.tileWidth / 2;
            newY = randomRange(0, lvl.height) * lvl.tileHeight + lvl.tileHeight / 2 ;
            p.set(newX, newY);
            okPoint = true;
            for(m in lvl.foregroundTiles.members){
                if(overlapsAt(newX,newY,cast(m, FlxObject))){
                    FlxG.log.add("BADSPAWN");
                    okPoint = false;
                    break;
                }
            }
        } while (!okPoint);

        FlxG.log.add("SPAWN",newX,newY);

        p = null;
        x = newX;
        y = newY;
        visible = true;
        var t = FlxRandom.intRanged(1,3);
        var tt = BulletType.Fish;
        FlxG.log.add("SPAWN TYPE",t);
        switch(t){
            case 1: tt = BulletType.Fish;
            case 2: tt = BulletType.Cat;
            case 3: tt = BulletType.Mole;
        }
        switchType(tt);
        play_teleportIn();
        isTeleportInListen = true;
    }

    function randomRange(minNum:Int, maxNum:Int):Int {
        return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
    }
}