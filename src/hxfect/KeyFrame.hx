package hxfect;

import haxe.ds.IntMap;
import openfl.geom.Point;
import openfl.geom.Matrix;
/**
 * ...
 * @author peperontium
 */
class KeyFrame{
	
	#if APP_EDITOR
	public var _translation: OrderedIntMap<Point>;
	public var _scaling 	: OrderedIntMap<Point>;
	///	ラジアン回転角
	public var _rotation	: OrderedIntMap<Float>;
	
	#else
	private var _translation: OrderedIntMap<Point>;
	private var _scaling 	: OrderedIntMap<Point>;
	///	degree回転角
	private var _rotation	: OrderedIntMap<Float>;
	#end
	
	private var _transformMatrix : Matrix;
	
	private function _InterPolateKeyFrame<T>(frame:Int,kfMap:OrderedIntMap<T>,interPolatefunc:(T->T->Float->T)):T{
		
		if (kfMap.exists(frame)) {
			return(kfMap.get(frame));
		}
		
		var lower :Int = 0;
		var upper :Int = 0;
		var it = kfMap.keys();
		while(it.hasNext()){
			upper = it.next();
			if(upper > frame){
				break;
			}
			lower = upper;
		}
		
		if(lower == upper){
			return(kfMap.get(lower));
		}else{
			return (interPolatefunc(kfMap.get(upper), kfMap.get(lower),(frame-lower)/(upper-lower)));
		}
	}
	

	public function new(scalingKeyFrames:OrderedIntMap<Point>,rotationKeyFrames:OrderedIntMap<Float>,translationKeyFrames:OrderedIntMap<Point>){
		_translation = translationKeyFrames;
		_scaling = scalingKeyFrames;
		_rotation = rotationKeyFrames;
		
		_transformMatrix = new Matrix();
	}
	
	public function evalTransform(frame:Int):Matrix{
		
		var scaling:Point = _InterPolateKeyFrame(frame, _scaling, Point.interpolate);
		
		var rotation:Float = _InterPolateKeyFrame(frame, _rotation,
							function(n1:Float,n2:Float,ratio:Float):Float{
								return (n2*(1-ratio)+n1*ratio);
							}
						);
		
		var translate:Point =  _InterPolateKeyFrame(frame, _translation, Point.interpolate);
		
		_transformMatrix.identity();
		_transformMatrix.scale(scaling.x,scaling.y);
		_transformMatrix.rotate(MathUtil.toRadian(rotation));
		_transformMatrix.translate(translate.x, translate.y);
		
		return _transformMatrix;
	}
	
}
