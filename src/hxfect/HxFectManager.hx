package hxfect;


import haxe.ds.IntMap;
import haxe.ds.StringMap;
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
	///	エフェクト名 => 描画深度 のテーブル
	private var _zDepthTable : StringMap<Int>;
	
	
	public function new() {
		_effects = new List<HxFect>();
		_zSortedRenderEffects = new OrderedIntMap<List<HxFect>>();
		_zDepthTable = new StringMap<Int>();
	}
	
	public function registerEffect(effect:HxFect,zDepth:Int):Void {
		_effects.add(effect);
		
		if(_zSortedRenderEffects.exists(zDepth) == false){
			_zSortedRenderEffects.set(zDepth,new List<HxFect>());
		}
		
		_zDepthTable.set(effect.name,zDepth);
		_zSortedRenderEffects.get(zDepth).add(effect);
	}
	
	public function unregisterEffect(effect:HxFect):Void{
		_effects.remove(effect);
		_zSortedRenderEffects.get(_zDepthTable.get(effect.name)).remove(effect);
		_zDepthTable.remove(effect.name);
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