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
class MenuState extends FlxState
{
    public function _mixV(i:Int,j:Int):Float{
        return i/31;
    }

    public function _mixH(i:Int,j:Int):Float{
        return j/31;
    }

    public function _mixDR(i:Int,j:Int):Float{
        return Math.pow((Math.pow(i/31,4)+Math.pow(j/31,4)),1/4);
//        return Math.max(i,j)/31;
    }

    public function _mixDL(i:Int,j:Int):Float{
        return Math.pow((Math.pow((31-i)/31,4)+Math.pow(j/31,4)),1/4);
//        return Math.max((31-i),j)/31;
    }

    public function _mixUR(i:Int,j:Int):Float{
        return Math.pow((Math.pow(i/31,4)+Math.pow((31-j)/31,4)),1/4);
//        return Math.max(i,(31-j))/31;
    }

    public function _mixUL(i:Int,j:Int):Float{
        return Math.pow((Math.pow((31-i)/31,4)+Math.pow((31-j)/31,4)),1/4);
//        return Math.max((31-i),(31-j))/31;
    }

    public function mix(bd1:BitmapData,bd2:BitmapData,mf:Int->Int->Float):BitmapData{
        var bdmix:BitmapData = new BitmapData(32,32);

        for (i in 0...32){
            for (j in 0...32){
                var p1 = bd1.getPixel(i,j);
                var p2 = bd2.getPixel(i,j);

                var r1:Float = (p1 >> 16 & 0xFF) / 255;
                var g1:Float = (p1 >> 8  & 0xFF) / 255;
                var b1:Float = (p1       & 0xFF) / 255;

                var r2:Float = (p2 >> 16 & 0xFF) / 255;
                var g2:Float = (p2 >> 8  & 0xFF) / 255;
                var b2:Float = (p2       & 0xFF) / 255;

//                var a1:Float = Math.sqrt(r1*r1 + g1 * g1 + b1*b1);
//                var a2:Float = Math.sqrt(r2*r2 + g2 * g2 + b2*b2);

                var a1:Float = Math.max(r1, Math.max(g1 , b1));
                var a2:Float = Math.max(r2, Math.max(g2 , b2));

//                a1 /= Math.max(a1,a2);
//                a2 /= Math.max(a1,a2);

//                var a1:Float = b1;
//                var a2:Float = b2;

                var mix:Float = mf(i,j);

//                if (i < 8) mix = 0
//                else if (i<24) mix = (i-8) / 15;
//                else mix = 1;

                var depth:Float = 0.2;
                var ma:Float = Math.max(a1 + mix, a2 + (1-mix)) - depth;

                var bb1:Float = Math.max(a1 + mix - ma, 0);
                var bb2:Float = Math.max(a2 + (1-mix) - ma, 0);

                var r = (Math.floor((r1 * bb1 + r2 * bb2) / (bb1 + bb2) * 255)) & 0xFF;
                var g = (Math.floor((g1 * bb1 + g2 * bb2) / (bb1 + bb2) * 255)) & 0xFF;
                var b = (Math.floor((b1 * bb1 + b2 * bb2) / (bb1 + bb2) * 255)) & 0xFF;

                var pp = (r << 16) | (g << 8) | (b);

                bdmix.setPixel(i,j,pp);
            }
        }

        return bdmix;
    }

    public function makeSq(bdres:BitmapData,bd1:BitmapData,bd2:BitmapData){
        var ul = mix(bd1,bd2,_mixUL);
        var u  = mix(bd2,bd1,_mixH);
        var ur = mix(bd1,bd2,_mixUR);
        var l  = mix(bd2,bd1,_mixV);
        //////////////
        var r  = mix(bd1,bd2,_mixV);
        var dl = mix(bd1,bd2,_mixDL);
        var d  = mix(bd1,bd2,_mixH);
        var dr = mix(bd1,bd2,_mixDR);

        bdres.copyPixels(ul,ul.rect,new Point(0, h));
        bdres.copyPixels(u, u.rect,new Point(32,h));
        bdres.copyPixels(ur,ur.rect,new Point(64,h));
        bdres.copyPixels(l, l.rect,new Point(0, h+32));
        ///
        bdres.copyPixels(r, r.rect,new Point(64,h+32));
        bdres.copyPixels(dl,dl.rect,new Point(0, h+64));
        bdres.copyPixels(d, d.rect,new Point(32,h+64));
        bdres.copyPixels(dr,dr.rect,new Point(64,h+64));

        h += 32 * 3;
    }

    public var h:Int;

    public function mixing(){
        var bd:BitmapData = Assets.getBitmapData("assets/tiled/tileset.png");

        var arr:Array<{i:Int,j:Int}> = [];
        arr.push({i:1,j:0});
        arr.push({i:1,j:1});
        arr.push({i:2,j:1});
        arr.push({i:2,j:2});

        var addRowCount = arr.length * (arr.length - 1) * 3; // because of 3x3 square

        var bdres:BitmapData = new BitmapData(bd.width,bd.height + addRowCount * 32);
        bdres.copyPixels(bd,bd.rect,new Point(0,0));
        h=bd.height;

        for (t1 in 0...arr.length){
            for (t2 in t1+1...arr.length){
                var bd1:BitmapData = new BitmapData(32,32);
                var bd2:BitmapData = new BitmapData(32,32);

                var i1 = arr[t1].i;
                var j1 = arr[t1].j;
                var i2 = arr[t2].i;
                var j2 = arr[t2].j;

                bd1.copyPixels(bd,new Rectangle(i1*32,j1*32,32,32),new Point(0,0));
                bd2.copyPixels(bd,new Rectangle(i2*32,j2*32,32,32),new Point(0,0));

                makeSq(bdres,bd1,bd2);
                makeSq(bdres,bd2,bd1);
            }
        }

        var ss:FlxSprite = new FlxSprite();
        ss.loadGraphic(bdres);
        ss.x = 10;
        ss.y = -110;
        add(ss);

        var ss2:FlxSprite = new FlxSprite();
        ss2.loadGraphic(bdres);
        ss2.x = 200;
        ss2.y = -450;
        add(ss2);

        var ss3:FlxSprite = new FlxSprite();
        ss3.loadGraphic(bdres);
        ss3.x = 400;
        ss3.y = -800;
        add(ss3);
    }

    public var a:FlxSprite;
    public var b:FlxSprite;

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
        FlxG.sound.playMusic("assets/music/LD.mp3", 1);

        a = new FlxSprite();
        a.loadGraphic(Assets.getBitmapData("assets/images/menu.png"));
        add(a);

        b = new FlxSprite();
        b.loadGraphic(Assets.getBitmapData("assets/images/bulletdare.png"));
        add(b);


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

        if(FlxG.keyboard.pressed("ENTER")){
            b.visible = false;
        }

        if(FlxG.keyboard.pressed("SHIFT")){
            FlxG.switchState(new PlayState());
        }
	}	
}