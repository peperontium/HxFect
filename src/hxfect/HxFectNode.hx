package hxfect;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import openfl.display.Graphics;
import openfl.display.Tilesheet;
import openfl.geom.Matrix;
import openfl.geom.Point;

/**
 * ...
 * @author peperontium
 */
class HxFectNode {
	
	public var zDepth(get, null) : Int;
	private inline function get_zDepth():Int{
		return _zDepth;
	}
	
	private var _name : String;
	
	private var _tileSheet : Tilesheet;
	private var _tileID : Int;
	private var _tileDrawData : Array<Float>;
	///	HxFectごとの内部での描画順
	private var _zDepth : Int;
	
	private var _keyframe : KeyFrame;
	
	private var _childrenNode : List<HxFectNode>;
	
	
	private function new() {
		
		_tileID = 0;
		_tileDrawData = [0,0,0,0,0,0,0];
		_zDepth = 0;
		
		_childrenNode = new List<HxFectNode>();
	}
	
	/**
	 * 再帰的に行列更新
	 */
	public function update(parentTransform:Matrix,frame:Int):Void{
		
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
		
		
		if(_childrenNode.isEmpty() == false){
			for(node in _childrenNode){
				node.update(mtx,frame);
			}
		}
	}
	
	/**
	 * このノードのみを描画、描画順はノードツリーを保持するHxFect側で管理
	 */
	public function render(graphics : Graphics):Void {
		if(_tileSheet != null)
			_tileSheet.drawTiles(graphics,_tileDrawData,true,Tilesheet.TILE_TRANS_2x2);
	}
	
	
	private static function _GetKeyFrameFromData(data:TextFileReader):KeyFrame{
		var vals:Array<String> = [];
		
		var scalingKF = new OrderedIntMap<Point>();
		var buf = data.readLine();
		if (buf == "[kfScaling]") {
			buf = data.readLine();
			while (buf != "[/kfScaling]") {
				vals = buf.split(",");
				scalingKF.set(Std.parseInt(vals[0]), new Point(Std.parseFloat(vals[1]), Std.parseFloat(vals[2])));
				buf = data.readLine();
			}
		}
		
		var rotationKF = new OrderedIntMap<Float>();
		buf = data.readLine();
		if (buf == "[kfRotation]"){
			buf = data.readLine();
			while(buf != "[/kfRotation]"){
				vals = buf.split(",");
				rotationKF.set(Std.parseInt(vals[0]), Std.parseFloat(vals[1]));
				buf = data.readLine();
			}
		}
		
		var translationKF = new OrderedIntMap<Point>();
		buf = data.readLine();
		if (buf == "[kfTranslation]") {
			buf = data.readLine();
			while(buf != "[/kfTranslation]"){
				vals = buf.split(",");
				translationKF.set(Std.parseInt(vals[0]), new Point(Std.parseFloat(vals[1]), Std.parseFloat(vals[2])));
				buf = data.readLine();
			}
		}
		
		return new KeyFrame(scalingKF, rotationKF, translationKF);
	}
	
	public static function CreateHxFectNodeTreeFromData(data:TextFileReader,tileTable:StringMap<Tilesheet>,managerEffect:HxFect):HxFectNode{
		
		var node = new HxFectNode();
		
		node._name = data.readLine();
		
		//	tilesheet名、ID,Z深度
		var vals:Array<String> = data.readLine().split(",");
		node._tileSheet = tileTable.get(vals[0]);
		node._tileID = Std.parseInt(vals[1]);
		node._tileDrawData[2] = node._tileID;
		node._zDepth = Std.parseInt(vals[2]);
		
		
		node._keyframe = _GetKeyFrameFromData(data);
		
		while(data.readLine() != "[/node]"){
			node._childrenNode.add(CreateHxFectNodeTreeFromData(data,tileTable,managerEffect));
		}
		
		managerEffect.registerRenderNode(node);
		
		return node;
	}
	
}
