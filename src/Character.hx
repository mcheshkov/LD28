package;

import flixel.util.FlxPoint;
import Bullet.BulletState;
import Direction;
import Bullet.BulletType;
import Direction;
import Direction;
import Direction;
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
class Character extends FlxSprite {
    public static var SPEED:Int = 300;
    public static var size:Int = 32;

    public var id:Int = 0;

    public var i1:BitmapData;
    public var i2:BitmapData;
    public var i3:BitmapData;
    public var i4:BitmapData;
    public var i5:BitmapData;

    public var charged:Bool;
    public var walking:Bool = false;
    public var isDead:Bool = false;
    public var bullet:Bullet;
    public var lastDirection:Direction;

    public var headSpr:FlxSprite;

    public var isDeadListen:Bool = false;

    public function new(skin:Int, bullet:Bullet) {
        super();

        loadAssets();

        headSpr = new FlxSprite();
        headSpr.scrollFactor = new FlxPoint(0, 0);

        switch(skin){
            case 1:
                loadChar1();
            case 2:
                loadChar2();
            case 3:
                loadChar3();
            case 4:
                loadChar4();
            case 5:
                loadChar5();
            default:
                loadChar1();
        }


        height = 32;
        width = 32;
        _offset.x = 16;
        _offset.y = 1;

        lastDirection = Direction.Right;
        charged = false;

        this.bullet = bullet;
    }

    public var assestLoaded:Bool = false;

    public function loadAssets() {
        if (assestLoaded) return;

        i1 = Assets.getBitmapData("assets/images/trex1.png");
        i2 = Assets.getBitmapData("assets/images/trex2.png");
        i3 = Assets.getBitmapData("assets/images/trex3.png");
        i4 = Assets.getBitmapData("assets/images/trex4.png");
        i5 = Assets.getBitmapData("assets/images/trex5.png");
    }

    public function loadChar1() {
        loadGraphic(i1, true, true, 65, 33);
        headSpr.loadGraphic(Assets.getBitmapData("assets/images/head1.png"));
        loadAnimations();
    }

    public function loadChar2() {
        loadGraphic(i2, true, true, 65, 33);
        headSpr.loadGraphic(Assets.getBitmapData("assets/images/head2.png"));
        loadAnimations();
    }

    public function loadChar3() {
        loadGraphic(i3, true, true, 65, 33);
        headSpr.loadGraphic(Assets.getBitmapData("assets/images/head3.png"));
        loadAnimations();
    }

    public function loadChar4() {
        loadGraphic(i4, true, true, 65, 33);
        headSpr.loadGraphic(Assets.getBitmapData("assets/images/head4.png"));
        loadAnimations();
    }

    public function loadChar5() {
        loadGraphic(i5, true, true, 65, 33);
        headSpr.loadGraphic(Assets.getBitmapData("assets/images/head5.png"));
        loadAnimations();
    }

    public function death() {
        bullet.velocity.x = bullet.velocity.y = 0;
        bullet.visible = false;
        isDead = true;
        animation.play("death_side");
        isDeadListen = true;
        FlxG.sound.play("assets/sounds/scream_long.mp3", 1);
    }


    public function loadAnimations() {
        animation.add("death_side", [0, 1, 2, 3, 4, 5, 6], 10, false);

        animation.add("down_stand", [27, 28], 4);
        animation.add("side_stand", [9, 10], 4);
        animation.add("up_stand", [36, 37], 4);

        animation.add("down_walk", [29, 30], 4);
        animation.add("side_walk", [11, 12, 13, 14, 15, 16, 17], 10);
        animation.add("up_walk", [38, 39], 4);

        animation.add("down_stand_load", [31, 32], 4);
        animation.add("side_stand_load", [18, 19], 4);

        animation.add("down_walk_load", [33, 34], 4);
        animation.add("side_walk_load", [20, 21, 22, 23, 24, 25, 26], 10);
    }

    public function goLeft() {
        velocity.x = -SPEED;
        lastDirection = Direction.Left;
        charged ? animation.play("side_walk") : animation.play("side_walk_load");
        facing = FlxObject.LEFT;
        walking = true;
    }

    public function goRight() {
        velocity.x = SPEED;
        lastDirection = Direction.Right;
        charged ? animation.play("side_walk") : animation.play("side_walk_load");
        facing = FlxObject.RIGHT;
        walking = true;
    }

    public function goUp() {
        velocity.y = -SPEED;
        lastDirection = Direction.Up;
        animation.play("up_walk");
//        facing = FlxObject.LEFT;
        walking = true;
    }

    public function goDown() {
        velocity.y = SPEED;
        lastDirection = Direction.Down;
        charged ? animation.play("down_walk") : animation.play("down_walk_load");
//        facing = FlxObject.DOWN;
        walking = true;
    }

    public function fire() {
        fireBullet(lastDirection);
    }

    public function control():Void {

    }

    override public function update():Void {
        super.update();

        walking = false;
        velocity.set(0, 0);

        if (!isDead) {

            control();

            if (!walking) {
                switch(lastDirection){
                    case Direction.Up:
                        animation.play("up_stand");
                    case Direction.Down:
                        charged ? animation.play("down_stand") : animation.play("down_stand_load");
                    case Direction.Left | Direction.Right:
                        charged ? animation.play("side_stand") : animation.play("side_stand_load");
                }
            }
        } else {
            if (animation.finished) {
                if (isDeadListen) {
                    deadListenHandler();
                }
            }
        }
    }

    public function deadListenHandler(){
        isDeadListen = false;
        hurt(1);
        bullet.state = BulletState.NotSpawn;
        bullet.visible = true;
        bullet.play_teleportOut();
        bullet.switchType(BulletType.Teleport);
        bullet.isTeleportOutListen = true;
    }

    public function pickUpBullet() {
        FlxG.log.warn("pick up");
        charged = true;
        FlxG.sound.play("assets/sounds/load.mp3", 1);
        bullet.state = BulletState.Equip;
        bullet.ownedBy = this;
    }

    public function fireBullet(d:Direction) {
        if (!charged) return;
        FlxG.sound.play("assets/sounds/sound_1.mp3", 1);
        FlxG.camera.shake(0.005, 0.1);

        bullet.x = x - offset.x + _halfWidth - bullet.width * .5;
        bullet.y = y - offset.y + _halfHeight - bullet.height * .5;

//        switch(d){
//            case Direction.Up:
//                bullet.y -= _halfHeight + bullet.height * .5;
//            case Direction.Down:
//                bullet.y += _halfHeight + bullet.height * .5;
//            case Direction.Left:
//                bullet.x -= _halfWidth + bullet.width * .5;
//            case Direction.Right:
//                bullet.x += _halfWidth + bullet.width * .5;
//        }

        charged = false;

        bullet.visible = true;
        bullet.state = BulletState.Fired;
        bullet.firedBy = this;
        bullet.fire(d);
    }
}