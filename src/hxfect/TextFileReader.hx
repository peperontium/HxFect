package hxfect;


#if (cpp || neko)
import sys.io.File;
import sys.io.FileInput;
#else
import openfl.Assets;
#end

/**
 * ...
 * @author peperontium
 */
 
 #if (cpp||neko)
class TextFileReader{

	private var _fileIn : FileInput;
	
	public function new(filepath:String) {
		_fileIn = File.read(filepath, false);
	}
	
	public inline function readLine():String{
		return _fileIn.readLine();
	}
	
	public inline function eof():Bool{
		return _fileIn.eof();
	}
}

#else

class TextFileReader{

	private var _inData : Array<String>;
	private var _index : Int;
	
	public function new(filepath:String) {
		_inData = Assets.getText(filepath).split("\r\n");
		_index = 0;
	}
	
	public inline function readLine():String{
		return _inData[_index++];
	}
	
	public inline function eof():Bool{
		return (_index >= _inData.length);
	}
}

#end