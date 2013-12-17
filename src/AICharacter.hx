package;

import flixel.group.FlxGroup;
import flixel.util.FlxAngle;
import flixel.util.FlxPath;
import flixel.effects.particles.FlxParticle;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import Bullet.BulletState;
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
class AICharacter extends Character
{
    public var lvl:TiledLevel;
    public var chars:Array<Character>;

    public static var PI_1_8:Float;
    public static var PI_3_8:Float;
    public static var PI_5_8:Float;
    public static var PI_7_8:Float;
    public static var PI_init:Bool = false;

    public function new(skin:Int,b:Bullet,lvl:TiledLevel){
        super(skin,b);
        lastBulletState = BulletState.Fired;
        this.lvl = lvl;
        lastPoss = [];

        if (! PI_init){
            PI_init = true;
            PI_1_8 = 1./8.*Math.PI;
            PI_3_8 = 3./8.*Math.PI;
            PI_5_8 = 5./8.*Math.PI;
            PI_7_8 = 7./8.*Math.PI;
        }
    }

    public function setChars(chars:FlxGroup){
        this.chars = [];

        for (c in chars.members){
            this.chars.push(cast(c,Character));
        }
    }

    public static var VIEWFIELD:Float = 300;

    public function getTargetRadius(distToBullet:Float):Float{
        if (distToBullet < VIEWFIELD) return 0;
        else return FlxRandom.float() * distToBullet / 3;
    }

    public var target:FlxPoint = null;

    public var lastBulletState:BulletState;

    public var path:Array<FlxPoint>;
    public var pathIdx:Int = 0;

    var consecPos:Int = 0;
    var lastPoss:Array<FlxPoint>;

    public function setPath(p:Array<FlxPoint>){
        path = p;
        pathIdx = 0;
    }

    public function followPath(){

//            FlxG.log.notice("GOTO",p);
//            FlxG.log.notice("POS",myp);
//            FlxG.log.notice("DIST",FlxMath.getDistance(myp,p));
        if (pathIdx >= path.length){
            FlxG.log.add("Path End");
            path = null;
            pathIdx = 0;
            return;
        }

        var p:FlxPoint = path[pathIdx];

//        FlxG.log.add("MID",getMidpoint());
        var mm:FlxPoint = new FlxPoint();
        mm.x = x + origin.x;
        mm.y = y + origin.y;
//        FlxG.log.add("ORIG",mm);
//        FlxG.log.add("DIST",FlxMath.getDistance(mm,p),Character.SPEED / FlxG.framerate);

        if (FlxMath.getDistance(mm,p) < Character.SPEED / FlxG.framerate){
            x = p.x - origin.x;
            y = p.y - origin.y;
            pathIdx++;
            return;
        }

//        var dx:Float = (p.x) - (this.x + this.origin.x);
//        var dy:Float = (p.y) - (this.y + this.origin.y);

//        FlxG.log.add("DX DY ",dx,dy);


        var angle = FlxAngle.angleBetweenPoint(this,p);
        angle += FlxRandom.floatRanged(-PI_1_8,PI_1_8);
//        FlxG.log.add("ANGLE",angle);
//            FlxG.log.notice("ANGLE",angle);
        if      (angle < -PI_7_8) {goLeft();}
        else if (angle < -PI_5_8) {goUp();goLeft();}
        else if (angle < -PI_3_8) {goUp();}
        else if (angle < -PI_1_8) {goUp();goRight();}
        else if (angle <  PI_1_8) {goRight();}
        else if (angle <  PI_3_8) {goDown();goRight();}
        else if (angle <  PI_5_8) {goDown();}
        else if (angle <  PI_7_8) {goDown();goLeft();}
        else                      {goLeft();}
    }

    public function findPath(p:FlxPoint):Array<FlxPoint>{
        var arr = cast(lvl.foregroundTiles.members[0],FlxTilemap).findPath(getMidpoint(),p,false);
        if (arr == null) FlxG.log.add("findPath NULL");
        return arr;
    }

    public var folowing:Bool = false;

    override public function control():Void {
//        FlxG.log.add("CONTROL",id);

        var found:Bool = false;
        for (p in lastPoss){
            if (Math.round(p.x) == Math.round(x) && Math.round(p.y) == Math.round(y)){
                consecPos++;
                found = true;
                break;
            }
        }
        if (! found){
            consecPos = 0;
//            FlxG.log.notice("NOT FOUND");
            var pp = new FlxPoint();
            pp.x = x;
            pp.y = y;
            lastPoss.push(pp);
            if (lastPoss.length > 4) {
                lastPoss.shift();
            }
        }

        if (consecPos == 30 || Math.random() < 0.001){
//            FlxG.log.add(id,"RANDOM", consecPos);

            var ppp:FlxPoint = getMidpoint();
            ppp.x += FlxRandom.intRanged(-200,200);
            ppp.y += FlxRandom.intRanged(-200,200);

            setPath(findPath(ppp));

            cTarget = null;
        }

        if(bullet.state == BulletState.Pickup){
            folowing = false;

            if (lastBulletState != bullet.state || path == null){
//                FlxG.log.add(this.id,"SEARCHING",bullet.state,path);
                var pb: FlxPoint = bullet.getMidpoint();

                var r = getTargetRadius(FlxMath.getDistance(getMidpoint(),pb));
                var a = FlxRandom.float() * 2 * Math.PI;

                var x = r * Math.cos(a);
                var y = r * Math.sin(a);

                target = new FlxPoint();
                target.x = x + pb.x;
                target.y = y + pb.y;

//                FlxG.log.add("rad",r);
//                FlxG.log.notice("target",target);
//                FlxG.log.notice("bullet",pb);

                setPath(findPath(target));
                if (path != null) for (i in path){
                    FlxG.log.add("path",i);
                }
            }
        }
        else if (bullet.state == BulletState.Fired){
            folowing = false;

//            FlxG.log.add(id,"EVADING");
            var ppp:FlxPoint = getMidpoint();
            switch(bullet.lastDirection){
                case Up:
                    if (bullet.y > y && bullet.overlapsAt(bullet.x,y + origin.y - bullet.origin.y,this)){
                        if (FlxRandom.chanceRoll(50)){
                            ppp.x -= Character.size;
                        }
                        else {
                            ppp.x += Character.size;
                        }
//                        setPath(findPath(ppp));
                        setPath([ppp]);
                    }
                case Down:
                    if (bullet.y < y && bullet.overlapsAt(bullet.x,y + origin.y - bullet.origin.y,this)){
                        if (FlxRandom.chanceRoll(50)){
                            ppp.x -= Character.size;
                        }
                        else {
                            ppp.x += Character.size;
                        }
//                        setPath(findPath(ppp));
                        setPath([ppp]);
                    }
                case Left:
                    if (bullet.x > x && bullet.overlapsAt(x + origin.x - bullet.origin.x,bullet.y,this)){
                        if (FlxRandom.chanceRoll(50)){
                            ppp.y += Character.size;
                        }
                        else {
                            ppp.y -= Character.size;
                        }
//                        setPath(findPath(ppp));
                        setPath([ppp]);
                    }
                case Right:
                    if (bullet.x > x && bullet.overlapsAt(x + origin.x - bullet.origin.x,bullet.y,this)){
                        if (FlxRandom.chanceRoll(50)){
                            ppp.y += Character.size;
                        }
                        else {
                            ppp.y -= Character.size;
                        }
//                        setPath(findPath(ppp));
                        setPath([ppp]);
                    }
            }
        }
        else if (bullet.state == BulletState.Equip && bullet.ownedBy == this){
            while(cTarget == null || cTarget == this){
                var i = FlxRandom.intRanged(0,chars.length-1);
                cTarget = chars[i];
                if (cTarget.isDead) cTarget = this;
            }

            if (! folowing || path == null){
//                FlxG.log.add(id,"FOLLOWING");
                folowing = true;
                var p:FlxPoint = new FlxPoint();
                p.x = cTarget.x;
                p.y = cTarget.y;

                setPath(findPath(p));
            }
        }

        if (cTarget != null){
            try{
                FlxG.log.add("BOT TARGET ", cast(cTarget,Character).id);
            }
            catch(e:Dynamic){

            }

            if (Math.abs(cTarget.y - y) < Character.size){
                if (cTarget.x < x) goLeft();
                else if (cTarget.x > x) goRight();
                fire();
                cTarget = null;
            }
            else if (Math.abs(cTarget.x - x)  < Character.size){
                if (cTarget.y < y) goUp();
                else if (cTarget.y > y) goDown();
                fire();
                cTarget = null;
            }
        }

        if (path != null){
            followPath();
        }

        lastBulletState = bullet.state;

//        lvl.collideWithLevel(this,function(l,c){
//            FlxG.log.notice("COLLIDEDEDE");
//        });
    }

    public var cTarget:Character = null;
}