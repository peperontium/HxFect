package;

/**
 * ...
 * @author peperontium
 */
class MathUtil{
	
	public static inline function square(n:Float):Float{
		return n * n;
	}
	
	public static inline function sgn(x:Float):Int{
		return (x < 0 ? -1 :
				(x > 0 ? 1 : 
					0));
	}
	
	public static inline function isRangeIn(n:Float,min:Float,max:Float):Bool{
		return(n > min && n < max);
	}
	
	public static inline function fclamp(n:Float,min:Float,max:Float):Float{
		return Math.min(max,Math.max(n,min));
	}
	
	public static inline function clamp(n:Int,min:Int,max:Int):Int{
		return (n < min ? min : 
				(n > max ? max : 
					n));
	}
	
	public static inline function toRadian(degree:Float):Float{
		return degree * Math.PI / 180;
	}
	
	public static inline function toDegree(radian:Float):Float{
		return radian * 180/ Math.PI;
	}
}