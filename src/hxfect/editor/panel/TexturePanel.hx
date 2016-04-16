package hxfect.editor.panel;

import haxe.ds.StringMap;
import openfl.Assets;
import openfl.Vector;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;


/**
 * ...
 * @author peperontium
 */
class TexturePanel extends Sprite{
	
	public var tilesheet(get, null) : Tilesheet;
	private inline function get_tilesheet():Tilesheet{
		return _tileSheet;
	}
	public var tileName(get, null):String;
	private inline function get_tileName():String {
		return _tileName;
	}
	
	private var PreviewField_Size:Float;
	
	private var _pathInputPanel : PathInputPanel;
	private var _tileRectPanel : TileRectPanel;
	
	private var _tileName : String;
	private var _tileBMP : BitmapData;
	private var _tileSheet : Tilesheet;
	
	private var _tilesheetCache : StringMap<TileCache>;
	
	private var _tileDrawData : Array<Float>;
	private var _checkBackGround : Tilesheet;
	private var _checkDrawData : Array<Float>;
	private var _tilePreviewField : Sprite;
	
	private var _onTileUpdatedProcedure: String->Tilesheet->Void;
	
	private var _onTileIDChangedProcedure : Int->Void;
	
	
	private function _ReloadTexture():Void {
		//_tilesheetCache.set(_tileName, new TileCache(_tileSheet, _tileRectPanel.tileRects, _tileRectPanel.tileCenters));
		
		if(_tilesheetCache.exists(_pathInputPanel.texturePath)){
			_tileName = _pathInputPanel.texturePath;
			_tileBMP = Assets.getBitmapData(_pathInputPanel.texturePath);
			var data = _tilesheetCache.get(_pathInputPanel.texturePath);
			_tileSheet = data.tilesheet;
			_tileRectPanel.tileRects = data.tileRects;
			_tileRectPanel.tileCenters = data.tileCenters;
			
			_ReDraw();
			return;
			
		}
		
		_tileBMP = Assets.getBitmapData(_pathInputPanel.texturePath);
		if (_tileBMP == null) {
			return;
		}
		
		_tileName = _pathInputPanel.texturePath;
		_tileRectPanel.reset();
		_UpdateAllTileRects();
	}
	
	private function _UpdateAllTileRects():Void{
		
		_tileSheet = new Tilesheet(_tileBMP);
		for(i in 0..._tileRectPanel.tileRects.length){
			_tileSheet.addTileRect(_tileRectPanel.tileRects[i],_tileRectPanel.tileCenters[i]);
		}
		
		if(_onTileUpdatedProcedure != null){
			_onTileUpdatedProcedure(_tileName,_tileSheet);
		}
		_tilesheetCache.set(_tileName, new TileCache(_tileSheet, _tileRectPanel.tileRects, _tileRectPanel.tileCenters));
		
		
		_ReDraw();
	}
	
	private function _ReDraw():Void {
		_tilePreviewField.graphics.clear();
		
		_checkBackGround.drawTiles(_tilePreviewField.graphics,_checkDrawData);
		
		if (_tileBMP == null) {
			return;
		}
		
		if(_onTileIDChangedProcedure != null){
			_onTileIDChangedProcedure(_tileRectPanel.tileID);
		}
		_tileDrawData[2] = _tileRectPanel.tileID;
		_tileSheet.drawTiles(_tilePreviewField.graphics,_tileDrawData);
	}
	
	private function _InitPanels():Void{
		_pathInputPanel = new PathInputPanel();
		_pathInputPanel.setOnPathUpdatedProcedure(_ReloadTexture);
		_pathInputPanel.x = 5;
		_pathInputPanel.y = 5;
		
		_tileRectPanel = new TileRectPanel();
		_tileRectPanel.x = _pathInputPanel.x + _pathInputPanel.width/2 - _tileRectPanel.width/2;
		_tileRectPanel.y = _pathInputPanel.y + _pathInputPanel.height + 10;
		_tileRectPanel.setOnRectUpdatedProcedure(_UpdateAllTileRects);
		_tileRectPanel.setOnIDChangedProcedure(_ReDraw);
	}
	
	private function _InitPreviewField():Void{
		
		_tilePreviewField = new Sprite();
		_tilePreviewField.scaleX = 1;
		_tilePreviewField.scaleY = 1;
		_tilePreviewField.x = 4;
		_tilePreviewField.y = _tileRectPanel.y + _tileRectPanel.height + 15;
		
		var checkBMP = Assets.getBitmapData("resource/check2.png");
		PreviewField_Size = checkBMP.width;
		_checkBackGround = new Tilesheet(checkBMP);
		_checkBackGround.addTileRect(new Rectangle(0,0,checkBMP.width,checkBMP.height));
		_checkDrawData = [0, 0, 0];
		_tileDrawData = [PreviewField_Size/2,PreviewField_Size/2,0];
		
		_checkBackGround.drawTiles(_tilePreviewField.graphics, _checkDrawData);
		
		_tilePreviewField.scrollRect = new Rectangle(0, 0, PreviewField_Size, PreviewField_Size);
	}
	
	public function new() {
		super();
		
		_tilesheetCache = new StringMap<TileCache>();
		
		_InitPanels();
		_InitPreviewField();
		
		
		this.addChild(_pathInputPanel);
		this.addChild(_tileRectPanel);
		this.addChild(_tilePreviewField);
	}
	
	public inline function getTilesheetByName(tileName:String):Tilesheet{
		if (tileName == null || tileName == "") {
			trace("debug");
			return _tileSheet;
		}
		return (if (_tilesheetCache.exists(tileName)) { _tilesheetCache.get(tileName).tilesheet; } else { null; } );
	}
	
	public function setOnTileUpdatedProcedure(proc:String->Tilesheet->Void):Void{
		_onTileUpdatedProcedure = proc;
	}
	
	public function setOnTileIDChangedProcedure(proc:Int->Void):Void{
		_onTileIDChangedProcedure = proc;
	}

	public function getTilesheetTable():StringMap<Tilesheet>{
		var table = new StringMap<Tilesheet>();
		for(key in _tilesheetCache.keys()){
			table.set(key, _tilesheetCache.get(key).tilesheet);
		}
		
		return table;
	}
	
	public function importFile(data:TextFileReader):Void {
		
		if (data.readLine() != "[tiles]") {
			throw "Invalid token";
		}
		
		var buf:String = data.readLine();
		while(buf != "[/tiles]"){
			if(buf == "[tile]"){
				var tileName = data.readLine();
				var tileCache = new TileCache(
						new Tilesheet(Assets.getBitmapData(tileName)), new Vector<Rectangle>(), new Vector<Point>()
					);
					
				buf = data.readLine();
				while (buf != "[/tile]") {
					var tiledata = buf.split(",");
					var rect = new Rectangle(
						Std.parseFloat(tiledata[0]), Std.parseFloat(tiledata[1]),
						Std.parseFloat(tiledata[2]), Std.parseFloat(tiledata[3])
						);
					var point = new Point(Std.parseFloat(tiledata[4]), Std.parseFloat(tiledata[5]));
					
					tileCache.tilesheet.addTileRect(rect, point);
					tileCache.tileRects.push(rect);
					tileCache.tileCenters.push(point);
					
					buf = data.readLine();
				}
				_tilesheetCache.set(tileName,tileCache);
				
			}else{
				buf = data.readLine();
			}
			
		}
	}
	
	public function writeOut():String{
		var buf : String = "[tiles]\r\n";
		for(tilePath in _tilesheetCache.keys()){
			buf += '[tile]\r\n$tilePath\r\n';
			var tileCache = _tilesheetCache.get(tilePath);
			for (i in 0...tileCache.tileRects.length) {
				var rect = tileCache.tileRects[i];
				var point = tileCache.tileCenters[i];
				buf += '${rect.x},${rect.y},${rect.width},${rect.height},${point.x},${point.y}\r\n';
			}
			buf += '[/tile]\r\n';
		}
		
		buf += "[/tiles]\r\n";
		return buf;
	}
}

private class TileCache{
	public var tilesheet : Tilesheet;
	public var tileRects : Vector<Rectangle>;
	public var tileCenters : Vector<Point>;
	
	public inline function new(tilesheet:Tilesheet,tileRects : Vector<Rectangle>,tileCenters : Vector<Point>){
		this.tilesheet = tilesheet;
		this.tileRects = tileRects;
		this.tileCenters = tileCenters;
	}
}

private class PathInputPanel extends Sprite{
	
	public var texturePath(get, set):String;
	private inline function get_texturePath():String { 
		return(_inputField.text);
	}
	private inline function set_texturePath(path:String):String{
		_inputField.text = path;
		_CallUpdatedProcedure();
		return(path);
	}
	
	
	private var _updateButton : TextButton;
	private var _inputField : TextInputField;
	private var _updatedProcedure : Void->Void;
	
	
	public function new(){
		super();
		
		_inputField = new TextInputField(150);
		_inputField.text = "TexturePath";
		
		_updateButton = new TextButton("↓");
		_updateButton.x = _inputField.width+2;
		
		_updatedProcedure = null;
		
		this.addChild(_inputField);
		this.addChild(_updateButton);
		_updateButton.setPushedProcedure(_CallUpdatedProcedure);
	}
	
	private function _CallUpdatedProcedure():Void{
		if(_updatedProcedure != null){
			_updatedProcedure();
		}
	}
	
	public inline function setOnPathUpdatedProcedure(procedure:Void->Void):Void{
		_updatedProcedure = procedure;
	}
	
}

private class TileRectPanel extends Sprite{
	
	public var tileRects(get, set):Vector<Rectangle>;
	private inline function get_tileRects():Vector<Rectangle>{
		return _tileRects;
	}
	private inline function set_tileRects(rects:Vector<Rectangle>):Vector<Rectangle>{
		_tileRects = rects;
		return _tileRects;
	}
	public var tileCenters(get, set):Vector<Point>;
	private inline function get_tileCenters():Vector<Point>{
		return _tileCenters;
	}
	private inline function set_tileCenters(centers:Vector<Point>):Vector<Point>{
		_tileCenters = centers;
		return _tileCenters;
	}
	public var tileID(get, set):Int;
	private inline function get_tileID():Int{
		return _tileID;
	}
	private inline function set_tileID(id:Int):Int {
		_tileID = id;
		if(_onIDChangedProcedure != null){
			_onIDChangedProcedure();
		}
		return _tileID;
	}
	
	private var _tileID : Int;
	private var _tileIDText : TextField;
	private var _idPlusButton : TextButton;
	private var _idMinusButton : TextButton;
	
	private var _tileRects : Vector<Rectangle>;
	private var _tileCenters : Vector<Point>;
	private var _rectPanel : RectPanel;
	private var _pointPanel: PointPanel;
	private var _onRectUpdatedProcedure : Void->Void;
	private var _onIDChangedProcedure : Void->Void;
	
	
	private function _IncrementTileID():Void {
		
		_tileID++;
		_tileIDText.text = Std.string(_tileID);
		
		if(_tileID == _tileRects.length){
			_tileRects.push(new Rectangle());
			_tileCenters.push(new Point());
			
			if (_onRectUpdatedProcedure != null){
				_onRectUpdatedProcedure();
			}
		}
		
		_rectPanel.setRectParam(_tileRects[_tileID]);
		_pointPanel.setPointParam(_tileCenters[_tileID]);
		if (_onIDChangedProcedure != null){
			_onIDChangedProcedure();
		}
	}
	
	private function _DeclimentTileID():Void{
		if (_tileID > 0){
			_tileID--;
			_tileIDText.text = Std.string(_tileID);
			_rectPanel.setRectParam(_tileRects[_tileID]);
			_pointPanel.setPointParam(_tileCenters[_tileID]);
			if (_onIDChangedProcedure != null){
				_onIDChangedProcedure();
			}
		}
	}
		
	private function _UpdateTileRect():Void{
		_tileRects[_tileID] = _rectPanel.rectangle;
		if(_onRectUpdatedProcedure != null){
			_onRectUpdatedProcedure();
		}
	}
	
	private function _UpdateTileCenter():Void{
		_tileCenters[_tileID] = _pointPanel.point;
		if(_onRectUpdatedProcedure != null){
			_onRectUpdatedProcedure();
		}
	}
	
	public function new() {
		super();
		
		_onRectUpdatedProcedure = null;
		_onIDChangedProcedure = null;
		
		_tileID = 0;
		_tileIDText = GlobalSetting.createTextField();
		_tileIDText.width = GlobalSetting.TextSize * 2;
		_tileIDText.text = Std.string(_tileID);
		
		_idPlusButton = new TextButton(" + ",GlobalSetting.TextSize-4);
		_idPlusButton.setPushedProcedure(_IncrementTileID);
		_idMinusButton = new TextButton(" - ",GlobalSetting.TextSize-4);
		_idMinusButton.setPushedProcedure(_DeclimentTileID);
		
		_tileIDText.x = _idMinusButton.width + 10;
		_idPlusButton.x = _tileIDText.x + _tileIDText.width + 10;
		_idPlusButton.y = _idMinusButton.y = (_tileIDText.height-_idPlusButton.height)/2;
		
		_tileRects = new Vector<Rectangle>();
		_tileRects.push(new Rectangle(0,0,0,0));
		_rectPanel = new RectPanel();
		_rectPanel.setOnModifiedProceedure(_UpdateTileRect);
		
		_tileCenters = new Vector<Point>();
		_tileCenters.push(new Point(0,0));
		_pointPanel = new PointPanel();
		_pointPanel.setOnModifiedProceedure(_UpdateTileCenter);
		
		
		this.addChild(_tileIDText);
		this.addChild(_idPlusButton);
		this.addChild(_idMinusButton);
		this.addChild(_rectPanel);
		this.addChild(_pointPanel);
		
		_rectPanel.x = this.width/2 - _rectPanel.width/2;
		_rectPanel.y = 32;
		
		_pointPanel.x = this.width/2 - _pointPanel.width/2;
		_pointPanel.y = _rectPanel.y + _rectPanel.height + 8;
	}

	public inline function setOnRectUpdatedProcedure(procedure:Void->Void):Void{
		_onRectUpdatedProcedure = procedure;
	}
	
	public inline function setOnIDChangedProcedure(procedure:Void->Void):Void{
		_onIDChangedProcedure = procedure;
	}
	
	public function reset():Void{
		_tileID = 0;
		_tileIDText.text = "0";
		_tileRects = new Vector<Rectangle>();
		_tileRects.push(new Rectangle(0,0,0,0));
		_rectPanel.setRectParam(_tileRects[0]);
		_tileCenters = new Vector<Point>();
		_tileCenters.push(new Point(0,0));
		_pointPanel.setPointParam(_tileCenters[0]);
		
	}
}

private class RectPanel extends Sprite{
	
	public var rectangle(get, null):Rectangle;
	private inline function get_rectangle():Rectangle{
		return(new Rectangle(
				Std.parseInt(_xInput.text),
				Std.parseInt(_yInput.text),
				Std.parseInt(_widthInput.text),
				Std.parseInt(_heightInput.text))
			);
	}
	
	private var _xInput : NumberInputField;
	private var _yInput : NumberInputField;
	private var _widthInput : NumberInputField;
	private var _heightInput : NumberInputField;
	
	private var _applyButon : TextButton;
	
	private var _commaText : TextField;
	
	public function setRectParam(rect:Rectangle):Void{
		_xInput.text = Std.string(rect.x);
		_yInput.text = Std.string(rect.y);
		_widthInput.text = Std.string(rect.width);
		_heightInput.text = Std.string(rect.height);
	}
	
	public inline function setOnModifiedProceedure(proceedure:Void->Void):Void{
		_applyButon.setPushedProcedure(proceedure);
	}
	
	public function new() {
		super();
		
		_xInput = new NumberInputField(GlobalSetting.TextSize*2);
		_yInput = new NumberInputField(GlobalSetting.TextSize*2);
		_widthInput = new NumberInputField(GlobalSetting.TextSize*2);
		_heightInput = new NumberInputField(GlobalSetting.TextSize*2);
			
		_commaText = GlobalSetting.createTextField();
		_commaText.autoSize = TextFieldAutoSize.LEFT;
		_commaText.text = "，\n，";
		_commaText.scaleY = 1.1;
		
		_commaText.x = _xInput.width;
		_heightInput.x = _yInput.x = _commaText.x + _commaText.width;
		_widthInput.y = _heightInput.y = _xInput.height;
		
		_applyButon = new TextButton("apply Rect",GlobalSetting.TextSize-2);
		_applyButon.x = (_yInput.x + _yInput.width)/2 - _applyButon.width/2;
		_applyButon.y = _heightInput.y + _heightInput.height + 5;
		
		this.addChild(_commaText);
		this.addChild(_xInput);
		this.addChild(_yInput);
		this.addChild(_widthInput);
		this.addChild(_heightInput);
		this.addChild(_applyButon);
	}
	
}

private class PointPanel extends Sprite{
		
	public var point(get, null):Point;
	private inline function get_point():Point{
		return(new Point(
				Std.parseInt(_xInput.text),
				Std.parseInt(_yInput.text))
			);
	}
	
	private var _xInput : NumberInputField;
	private var _yInput : NumberInputField;
	
	private var _applyButon : TextButton;
	
	private var _commaText : TextField;
	
	public function setPointParam(point:Point):Void{
		_xInput.text = Std.string(point.x);
		_yInput.text = Std.string(point.y);
	}
	
	public inline function setOnModifiedProceedure(proceedure:Void->Void):Void{
		_applyButon.setPushedProcedure(proceedure);
	}
	
	public function new() {
		super();
		
		_xInput = new NumberInputField(GlobalSetting.TextSize*2);
		_yInput = new NumberInputField(GlobalSetting.TextSize*2);
			
		_commaText = GlobalSetting.createTextField();
		_commaText.autoSize = TextFieldAutoSize.LEFT;
		_commaText.text = "，";
		
		_commaText.x = _xInput.width;
		_yInput.x = _commaText.x + _commaText.width;
		
		_applyButon = new TextButton("apply center",GlobalSetting.TextSize-2);
		_applyButon.x = (_yInput.x + _yInput.width)/2 - _applyButon.width/2;
		_applyButon.y = _yInput.y + _yInput.height + 5;
		
		this.addChild(_commaText);
		this.addChild(_xInput);
		this.addChild(_yInput);
		this.addChild(_applyButon);
	}
	
}
