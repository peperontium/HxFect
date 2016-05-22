package hxfect;


import haxe.ds.ObjectMap;
import openfl.display.Graphics;
import openfl.display.Tilesheet;

/**
 * ...
 * @author peperontium
 */
class HxFectManager{
	
	private var _effects : List<HxFect>;
	///	描画用z順エフェクト
	private var _zSortedRenderEffects : OrderedIntMap<List<HxFect>>;
	
	
	public function new() {
		_effects = new List<HxFect>();
		_zSortedRenderEffects = new OrderedIntMap<List<HxFect>>(false);
	}
	
	public function registerEffect(effect:HxFect):Void {
		_effects.add(effect);
		
		if(_zSortedRenderEffects.exists(effect.zDepth) == false){
			_zSortedRenderEffects.set(effect.zDepth,new List<HxFect>());
		}
		
		_zSortedRenderEffects.get(effect.zDepth).add(effect);
	}
	
	public function unregisterEffect(effect:HxFect):Void{
		_effects.remove(effect);
		_zSortedRenderEffects.get(effect.zDepth).remove(effect);
	}
	
	public function updateAll():Void{
		for(effect in _effects){
			if(effect.update() == false){
				unregisterEffect(effect);
			}
		}
	}
	
	public function renderAll(graphics:Graphics):Void{
		for(zEffects in _zSortedRenderEffects){
			for(effect in zEffects){
				effect.render(graphics);
			}
		}
	}
	
}