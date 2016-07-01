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
	
	public var scalingX(get, set):Float;
	private inline function get_scalingX():Float{
		return _scalingX;
	}
	private inline function set_scalingX(s:Float):Float {
		_scalingX = s;
		_transformDirty = true;
		return (s);
	}
	public var scalingY(get, set):Float;
	private inline function get_scalingY():Float{
		return _scalingY;
	}
	private inline function set_scalingY(s:Float):Float {
		_scalingY = s;
		_transformDirty = true;
		return (s);
	}
	
	///	rotation parameter(radian)
	public var rotation(get, set):Float;
	private inline function get_rotation():Float{
		return _rotation;
	}
	private inline function set_rotation(r:Float ):Float {
		_rotation = r;
		_transformDirty = true;
		return r;
	}
	
	public var name(get, null):String;
	private inline function get_name():String{
		return _name;
	}
	
	public var zDepth(get, null):Int;
	private inline function get_zDepth():Int{
		return(_zDepth);
	}
	
	private var _name : String;
	private var _isLoop:Bool;
	
	private var _rootNode : HxFectNode;
	private var _effectManager : HxFectManager;
	
	///	描画用z順ノード
	private var _zSortedRenderNodes : OrderedIntMap<List<HxFectNode>>;
	
	private var _scalingX : Float;
	private var _scalingY : Float;
	private var _rotation : Float;
	
	private var _transformMtx : Matrix;
	private var _transformDirty : Bool;
	
	private var _zDepth : Int;
	
	private var _autoUpdate : Bool;
	private var _isPlaying : Bool;
	
	private var _timer : Int;
	
	
	
	private function new(manager:HxFectManager) {
		_zSortedRenderNodes = new OrderedIntMap<List<HxFectNode>>(false);
		_effectManager = manager;
		
		_name = "";
		_isLoop = false;
		
		_scalingX = 1.0;
		_scalingY = 1.0;
		_rotation = 0.0;
		
		_transformMtx = new Matrix();
		_transformDirty = false;
		
		_zDepth = 0;
		
		_isPlaying = false;
		_autoUpdate = true;
		
		_timer = 0;
	}
	
	public inline function registerRenderNode(node:HxFectNode):Void{
		if(_zSortedRenderNodes.exists(node.zDepth) == false){
			_zSortedRenderNodes.set(node.zDepth,new List<HxFectNode>());
		}
		_zSortedRenderNodes.get(node.zDepth).add(node);
	}
	
	public inline function setTime(time:Int):Void{
		_timer = time;
	}
	
	public function play(zDepth:Int):Void {
		//	二重再生防ぐ
		if (_isPlaying) {
			_timer = 0;
			if(zDepth != _zDepth){
				//	描画深度の変更
				_effectManager.unregisterEffect(this);
				_effectManager.registerEffect(this);
			}
			return;
		}
		
		_isPlaying = true;
		_zDepth = zDepth;
		_effectManager.registerEffect(this);
	}
	
	public inline function setAutoUpdate(state:Bool):Void{
		_autoUpdate = state;
	}
	
	public inline function stop():Void {
		if(_isPlaying){
			_isPlaying = false;
			_effectManager.unregisterEffect(this);
		}
	}
	
	public function update():Bool {
		if (_timer > REMAINING_FRAME) {
			if(_isLoop){
				_timer = 0;
			}else{
				return false;
			}
		}
		
		if(_transformDirty){
			var x = _transformMtx.tx;
			var y = _transformMtx.ty;
			_transformMtx.identity();
			_transformMtx.scale(_scalingX, _scalingY);
			_transformMtx.rotate(_rotation);
			_transformMtx.translate(x, y);
			_transformDirty = false;
		}
		
		_rootNode.update(_transformMtx,_timer);
		
		if(_autoUpdate){
			_timer++;
		}
		
		return true;
	}
	
	public function render(graphics : Graphics):Void{
		
		for(zEffectNodes in _zSortedRenderNodes){
			for(effectnode in zEffectNodes){
				effectnode.render(graphics);
			}
		}
		
	}
	
	public function clone():HxFect{
		var clone = new HxFect(_effectManager);
		
		clone._name 	= this._name;
		clone._scalingX = this._scalingX;
		clone._scalingY = this._scalingY;
		clone._rotation = this._rotation;
		clone._transformMtx 	= this._transformMtx.clone();
		clone._transformDirty	= this._transformDirty;
		clone._isLoop 	= this._isLoop;
		clone._isPlaying = this._isPlaying;
		
		clone._zSortedRenderNodes = new OrderedIntMap<List<HxFectNode>>(false);
		clone._rootNode = this._rootNode.cloneTree(clone);
		
		return clone;
	}
	
	public static function CreateFromFile(path:String, manager:HxFectManager):HxFect{
		
		var dataReader = new TextFileReader(path);
		
		var hxFect = new HxFect(manager);
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
				//var tilesheet = new Tilesheet(openfl.display.BitmapData.fromFile(tileName));
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
