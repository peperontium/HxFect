package ;


import haxe.ds.IntMap;

/**
 * ...
 * @author peperontium
 */
class OrderedIntMap<V> implements haxe.Constraints.IMap<Int,V>{

	var _map : IntMap<V>;
	
    var _keys:Array<Int>;
	
	//	positive : Ascending order 	( [0,1,2... )
	//	negative : Descending order ( [9,8,7... )
	var _sortOrder:Int;
	
	public function new(isAscending:Bool = true) {
		_map = new IntMap<V>();
		_keys = [];
		_sortOrder = if (isAscending) { 1; } else { -1; };
	}
	
	
	private inline function _Compair(k1:Int,k2:Int):Int{
		return (k1-k2)*_sortOrder;
	}
	
	private inline function _SortKeys():Void{
		_keys.sort(_Compair);
		
	}
	
	
	public inline function exists(key:Int):Bool{
		return _map.exists(key);
	}
	
	public inline function get(key:Int):V{
		return _map.get(key);
	}
	
	public inline function set(key:Int, value:V):Void {
		if (_keys.indexOf(key) == -1){
			_keys.push(key);
			_SortKeys();
		}
		_map.set(key, value);
		
	}
	
	public function remove(key:Int):Bool {
		if(_keys.remove(key))
			_SortKeys();
		
		return _map.remove(key);
	}
	
	public function keys():Iterator<Int> {
		return _keys.iterator();
	}
	
	public function iterator():Iterator<V> {
		return new OrderedIntMapIterator(_map);
	}
	
	public function toString():String {
		var str : String = "[ ";
		for(k in _keys){
			str = str + k + " => " + _map.get(k) + ", ";
		}
		
		return (str + " ]");
	}
}

private class OrderedIntMapIterator<V>{

    var _intMap : IntMap<V>;
	var _keysItr : Iterator<Int>;
	
    public function new(intMap:IntMap<V>){
        _intMap = intMap;
		_keysItr = intMap.keys();
	}
	
    public function hasNext():Bool{
		return _keysItr.hasNext();
	}
	
    public function next():V{
        return _intMap.get(_keysItr.next());
	}
}