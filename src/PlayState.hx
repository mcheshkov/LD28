package;

import flixel.util.FlxArrayUtil;
import haxe.macro.ExprTools.ExprArrayTools;
import flixel.addons.editors.tiled.TiledObject;
import flash.geom.Point;
import flixel.util.FlxPoint;
import flixel.group.FlxGroup;
import Bullet.BulletState;
import Bullet.BulletState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState {
    public var chars:FlxGroup;
    public var p:Character;
    public var p2:AICharacter;
    public var p3:AICharacter;
    public var p4:AICharacter;
    public var p5:AICharacter;
    public var b:Bullet;
    public var lvl:TiledLevel;
    public var heads:FlxGroup;
    public var spawnPoints:Array<TiledObject>;
/**
	 * Function that is called up when to state is created to set it up. 
	 */

    override public function create():Void {
// Set a background color
        FlxG.cameras.bgColor = 0xff131c1b;
// Show the mouse (in case it hasn't been disabled)
#if !FLX_NO_MOUSE
		FlxG.mouse.hide();
#end

        super.create();

        FlxG.sound.playMusic("assets/music/LD_3.mp3", 1);
        lvl = new TiledLevel("assets/data/map.tmx");
        add(lvl.backgroundTiles);
        add(lvl.foregroundTiles);

        spawnPoints = lvl.getObjectGroup("SPAWN_POINTS").objects;
        FlxArrayUtil.shuffle(spawnPoints, spawnPoints.length * 4);
        heads = new FlxGroup();

        b = new Bullet(lvl);
        b.spawn();

        p = new KeyboardCharacter(1, b);
        p.x = spawnPoints[0].x;
        p.y = spawnPoints[0].y;
        p.id = 1;

        p2 = new AICharacter(2, b, lvl);
        p2.x = spawnPoints[1].x;
        p2.y = spawnPoints[1].y;
        p2.id = 2;

        p3 = new AICharacter(3, b, lvl);
        p3.x = spawnPoints[2].x;
        p3.y = spawnPoints[2].y;
        p3.id = 3;

        p4 = new AICharacter(4, b, lvl);
        p4.x = spawnPoints[3].x;
        p4.y = spawnPoints[3].y;
        p4.id = 4;

        p5 = new AICharacter(5, b, lvl);
        p5.x = spawnPoints[4].x;
        p5.y = spawnPoints[4].y;
        p5.id = 5;


        chars = new FlxGroup();
        chars.add(p);
        chars.add(p2);
        chars.add(p3);
        chars.add(p4);
        chars.add(p5);

        p2.setChars(chars);
        p3.setChars(chars);
        p4.setChars(chars);
        p5.setChars(chars);

        p2.headSpr.x = 5;
        p2.headSpr.y = 5;
        add(p2.headSpr);

        p3.headSpr.x = 25;
        p3.headSpr.y = 5;
        add(p3.headSpr);

        p4.headSpr.x = 45;
        p4.headSpr.y = 5;
        add(p4.headSpr);

        p5.headSpr.x = 65;
        p5.headSpr.y = 5;
        add(p5.headSpr);

        add(chars);
        add(b);

        FlxG.worldBounds.set(-100, -100, 150000, 150000);

        FlxG.camera.follow(p);
        FlxG.camera.setBounds(32, 32, 49 * 32, 49 * 32);
    }

/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */

    override public function destroy():Void {
        super.destroy();
    }

/**
	 * Function that is called once every frame.
	 */

    override public function update():Void {
        super.update();

        if (b.state == BulletState.Pickup) {
            FlxG.overlap(chars, b, function(p:Character, b:Bullet) {
                if (!p.isDead) {
                    b.visible = false;
                    p.pickUpBullet();
                }
            });
        }

        if (b.state == BulletState.Fired) {
            FlxG.overlap(chars, b, function(p:Character, b:Bullet) {
                if (p == b.firedBy) return;
                if(!p.isDead){
                    p.death();
                }
                if (p.headSpr.exists) {
                    remove(p.headSpr);
                }
                //b.drop(true);
            });
        }

        lvl.collideWithLevel(b, function(tile, bullet:Bullet) {
            if (bullet.state != BulletState.NotSpawn) {
                bullet.drop();
           }
        });

        lvl.collideWithLevel(chars);

        if (FlxG.keyboard.pressed("R")) FlxG.switchState(new MenuState());

        if (! p.alive) FlxG.switchState(new LoseState());
        if (! p2.alive && ! p3.alive && !p4.alive && !p5.alive) FlxG.switchState(new WinState());
    }
}