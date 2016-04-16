package hxfect.editor;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import hxfect.KeyFrame;
import openfl.display.Graphics;
import openfl.display.Tilesheet;
import openfl.geom.Matrix;
import openfl.geom.Point;

import hxfect.HxFectNode;


/**
 * ...
 * @author peperontium
 */
class HxFectNodeEditable extends HxFectNode{
	
	public var name(get, set):String;
	private inline function get_name():String{
		return _name;
	}
	private inline function set_name(name:String):String{
		_name = name;
		return _name;
	}
		
	public function set_zDepth(z:Int):Int {
		if(_zDepth != z){
			this._managerEffect.unregisterRenderNode(this);
			_zDepth = z;
			_managerEffect.registerRenderNode(this);
		}else{
			_zDepth = z;
		}
		return _zDepth;
	}
	
	
	public var tileID(get, null):Int;
	private inline function get_tileID():Int{
		return _tileID;
	}
	public var tileName(get, null):String;
	private inline function get_tileName():String{
		return _tileName;
	}
	
	public var keyFrame(get, set):KeyFrame;
	private inline function get_keyFrame():KeyFrame{
		return _keyframe;
	}
	private inline function set_keyFrame(kf:KeyFrame):KeyFrame{
		_keyframe = kf;
		return _keyframe;
	}
	
	private var _childrenNodeEditable : List<HxFectNodeEditable>;
	private var _tileName : String;
	
	private var _managerEffect : HxFectEditable;
	
	private var _parentNode : HxFectNodeEditable;
	
	
	private function new(parent:HxFectNodeEditable) {
		super();
		
		_parentNode = parent;
		if(_parentNode != null)
			_parentNode.addChildNode(this);
		
		_tileName = "null";
		
		_childrenNodeEditable = new List<HxFectNodeEditable>();
	}
	
	public function setTileSheet(tile:Tilesheet, tilename:String, id:Int):Void {
		_tileSheet = tile;
		_tileName = tilename;
		_tileID = id;
	}
	
	public function updateTile(tileName:String,tile:Tilesheet):Void{
		if(_tileName != tileName){
			return;
		}
		
		_tileSheet = tile;
		
	}
	
	public function addChildNode(node:HxFectNodeEditable):Void{
		_childrenNodeEditable.add(node);
	}
	
	public function removeThisNode():Void{
		
		if(_parentNode == null){
			//削除不可、ルート
			return;
		}
		
		_managerEffect.unregisterRenderNode(this);
		_parentNode._childrenNodeEditable.remove(this);
		
		for(node in _childrenNodeEditable){
			node.removeThisNode();
		}
	}
	
	override public function update(parentTransform:Matrix,frame:Int):Void {
		
		var mtx = _keyframe.evalTransform(frame);
		//	apply parent transform
		mtx.concat(parentTransform);
		
		_tileDrawData[0] = mtx.tx;
		_tileDrawData[1] = mtx.ty;
		//_tileDrawData[2] = tileID;
		_tileDrawData[3] = mtx.a;
		_tileDrawData[4] = mtx.b;
		_tileDrawData[5] = mtx.c;
		_tileDrawData[6] = mtx.d;
		
		
		if(_childrenNodeEditable.isEmpty() == false){
			for(node in _childrenNodeEditable){
				node.update(mtx,frame);
			}
		}
	}
	
	override public function render(graphics:Graphics):Void {
		if(_tileSheet != null){
			_tileDrawData[2] = _tileID;
			super.render(graphics);
		}
	}
	
	public function writeNode():String{
		
		var buf = "[node]\r\n";
		
		buf += '$_name\r\n';
		buf += '$_tileName,$tileID,$_zDepth\r\n';
		
		buf += '[kfScaling]\r\n';
		for(frame in _keyframe._scaling.keys()){
			buf += '$frame,${_keyframe._scaling.get(frame).x},${_keyframe._scaling.get(frame).y}\r\n';
		}
		buf += '[/kfScaling]\r\n';
		
		buf += '[kfRotation]\r\n';
		for(frame in _keyframe._rotation.keys()){
			buf += '$frame,${_keyframe._rotation.get(frame)}\r\n';
		}
		buf += '[/kfRotation]\r\n';
		
		buf += '[kfTranslation]\r\n';
		for(frame in _keyframe._translation.keys()){
			buf += '$frame,${_keyframe._translation.get(frame).x},${_keyframe._translation.get(frame).y}\r\n';
		}
		buf += '[/kfTranslation]\r\n';
		
		if(_childrenNodeEditable.isEmpty() == false){
			for(childNode in _childrenNodeEditable){
				buf += childNode.writeNode();
			}
		}
		buf += "[/node]\r\n";
		return buf;
	}
	
	public static function CreateEmptyNode(managerEffect:HxFectEditable,parentNode:HxFectNodeEditable):HxFectNodeEditable{
		var node = new HxFectNodeEditable(parentNode);
		
		node._name = "";
		
		node._tileSheet = null;
		node._tileName = "";
		
		var scalingKF = new OrderedIntMap<Point>();
		scalingKF.set(0, new Point(1, 1));
		var rotateKF = new OrderedIntMap<Float>();
		rotateKF.set(0, 0);
		var translateKF = new OrderedIntMap<Point>();
		translateKF.set(0, new Point(0, 0));
		
		node._keyframe = new KeyFrame(scalingKF, rotateKF,translateKF);
		
		node._managerEffect = managerEffect;
		node._managerEffect.registerRenderNode(node);
		
		return node;
	}
		
}