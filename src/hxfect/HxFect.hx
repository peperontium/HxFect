package hxfect;

import haxe.ds.StringMap;

import openfl.Assets;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.geom.Matrix;
import openfl.display.Graphics;
import openfl.display.Tilesheet;

import hxfect.HxFectNode;

/**
 * ...
 * @author peperontium
 */
class HxFect{
	
	public static inline var REMAINING_FRAME = 59;
	
	public var x(get, set):Float;
	private inline function get_x():Float{
		return _transformMtx.tx;
	}
	private inline function set_x(x:Float):Float {
		_transformMtx.tx = x;
		return _transformMtx.tx;
	}
	public var y(get, set):Float;
	private inline function get_y():Float{
		return _transformMtx.ty;
	}
	private inline function set_y(y:Float):Float {
		_transformMtx.ty = y;
		return _transformMtx.ty;
	}
	
	public var scaling(get, set):Float;
	private inline function get_scaling():Float{
		return _transformMtx.a;
	}
	private inline function set_scaling(s:Float):Float {
		_transformMtx.a = s;
		_transformMtx.b = s;
		_transformMtx.c = s;
		_transformMtx.d = s;
		return _transformMtx.a;
	}
	
	
	public var name(get, null):String;
	private inline function get_name():String{
		return _name;
	}
	
	public var visible(get, set):Bool;
	private inline function get_visible():Bool{
		return (_isVisible);
	}
	private inline function set_visible(val : Bool):Bool {
		_isVisible = val;
		return (_isVisible);
	}
	
	
	private var _name : String;
	
	private var _rootNode : HxFectNode;
	
	///	描画用z順ノード
	private var _zSortedRenderNodes : OrderedIntMap<List<HxFectNode>>;
	
	private var _transformMtx : Matrix;
	
	private var _isLoop:Bool;
	private var _isPlaying : Bool;
	private var _isVisible : Bool;
	
	private var _timer : Int;
	
	
	
	private function new() {
		_zSortedRenderNodes = new OrderedIntMap<List<HxFectNode>>();
		
		_name = "";
		
		_transformMtx = new Matrix();
		
		_isLoop = false;
		_isPlaying = true;
		_isVisible = true;
		
		_timer = 0;
	}
	
	public inline function registerRenderNode(node:HxFectNode):Void{
		if(_zSortedRenderNodes.exists(-node.zDepth) == false){
			_zSortedRenderNodes.set(-node.zDepth,new List<HxFectNode>());
		}
		_zSortedRenderNodes.get(-node.zDepth).add(node);
	}
	
	public inline function setTime(time:Int):Void{
		_timer = time;
	}
	
	public inline function play():Void{
		_isPlaying = true;
	}
	
	public inline function pause():Void{
		_isPlaying = false;
	}
	
	public function update():Bool {
		if (_timer > REMAINING_FRAME) {
			if(_isLoop){
				_timer = 0;
			}else{
				return false;
			}
		}
		
		if(!_isPlaying){
			return true;
		}
		
		_rootNode.update(_transformMtx,_timer);
		_timer++;
		
		return true;
	}
	
	public function render(graphics : Graphics):Void{
		
		if(!_isVisible){
			return;
		}
		
		for(zEffectNodes in _zSortedRenderNodes){
			for(effectnode in zEffectNodes){
				effectnode.render(graphics);
			}
		}
		
	}
	
	public static function CreateFromFile(path:String):HxFect{
		
		var dataReader = new TextFileReader(path);
		
		var hxFect = new HxFect();
		hxFect._name = path;
		
		//	このエフェクトで使う tilesheet名->tilesheet テーブルの作成
		var tileTable = _ImportTilesheetTable(dataReader);
		
		if (dataReader.readLine() != "[effect]") {
			throw "Invalid token";
		}
		
		//	ループ再生?
		hxFect._isLoop = (dataReader.readLine() == "1");
		
		if(dataReader.readLine() == "[node]"){
			hxFect._rootNode = HxFectNode.CreateHxFectNodeTreeFromData(dataReader,tileTable,hxFect);
		}
		
		//	if(dataReader.readLine(); == "[/effect]")
		dataReader.readLine();
		return hxFect;
	}
	
	private static function _ImportTilesheetTable(reader:TextFileReader):StringMap<Tilesheet>{
		if (reader.readLine() != "[tiles]") {
			throw "Invalid token";
		}
		
		var tileTable = new StringMap<Tilesheet>();
		var buf:String = reader.readLine();
		while(buf != "[/tiles]"){
			if(buf == "[tile]"){
				var tileName = reader.readLine();
				var tilesheet = new Tilesheet(Assets.getBitmapData(tileName));
					
				buf = reader.readLine();
				while (buf != "[/tile]") {
					var tiledata = buf.split(",");
					var rect = new Rectangle(
						Std.parseFloat(tiledata[0]), Std.parseFloat(tiledata[1]),
						Std.parseFloat(tiledata[2]), Std.parseFloat(tiledata[3])
						);
					var point = new Point(Std.parseFloat(tiledata[4]), Std.parseFloat(tiledata[5]));
					
					tilesheet.addTileRect(rect, point);
					
					buf = reader.readLine();
				}
				tileTable.set(tileName,tilesheet);
				
			}else{
				buf = reader.readLine();
			}
			
		}
		
		return tileTable;
	}
	
}
