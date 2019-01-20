package arm;

import zui.*;
import zui.Nodes;
import iron.data.SceneFormat;

@:access(zui.Zui)
class UINodes extends iron.Trait {

	public static var inst:UINodes;

	public var wx:Int;
	public var wy:Int;
	public var ww:Int;

	public var ui:Zui;
	var drawMenu = false;
	var showMenu = false;
	var hideMenu = false;
	var menuCategory = 0;
	var addNodeButton = false;
	var popupX = 0.0;
	var popupY = 0.0;
	var urlParsed = false;

	public var nodes = new Nodes();
	public var canvasLogic:TNodeCanvas = null;
	public var changed = false;
	public var grid:kha.Image = null;
	public var hwnd = Id.handle();

	public function new() {
		super();
		inst = this;

		// iron.data.Data.getBlob('default_logic.json', function(blob:kha.Blob) {
			iron.data.Data.getBlob('logic_nodes.json', function(bnodes:kha.Blob) {

				var s = '{"nodes":[],"links":[]}';

				#if kha_html5
				// var s = blob.toString();
				var url = StringTools.urlDecode(js.Browser.window.location.href);
				if (url.indexOf("?") > 0) {
					s = url.split("?")[1];
					s = decode(s);
					urlParsed = true;
				}
				#end

				canvasLogic = haxe.Json.parse(s);
				NodeCreatorLogic.list = haxe.Json.parse(bnodes.toString());

				NodeCreatorLogic.list.categories.sort(function(a, b):Int {
					if (a.name < b.name) return -1;
					else if (a.name > b.name) return 1;
					return 0;
				});

				var t = zui.Themes.dark;
				t.ELEMENT_H = 18;
				t.BUTTON_H = 16;

				var scale = armory.data.Config.raw.window_scale;
				ui = new Zui({font: arm.App.font, color_wheel: arm.App.color_wheel, scaleFactor: scale});
				ui.scrollEnabled = false;
				
				notifyOnRender2D(render2D);
				notifyOnUpdate(update);

				notifyOnInit(parseLogic);

				kha.System.notifyOnCutCopyPaste(onCut, onCopy, onPaste);
			});
		// });
	}

	function encode(str:String):String {
		str = StringTools.replace(str, '{"nodes":[{',          '~0');
		str = StringTools.replace(str, '"id":',                '~1');
		str = StringTools.replace(str, ',"name":"',            '~2');
		str = StringTools.replace(str, '","type":"ACTION","color":-3388340',  '~3');
		str = StringTools.replace(str, '","type":"OBJECT","color":-14250817', '~4');
		str = StringTools.replace(str, '","type":"SHADER","color":-11959648', '~5');
		str = StringTools.replace(str, '","type":"INTEGER","color":-3388340', '~6');
		str = StringTools.replace(str, '","type":"VALUE","color":-10238109',  '~7');
		str = StringTools.replace(str, '","type":"VECTOR","color":-10238109', '~8');
		str = StringTools.replace(str, '","type":"RGBA","color":-3388340',    '~9');
		str = StringTools.replace(str, '","type":"STRING","color":-3388340',  '~a');
		str = StringTools.replace(str, '","type":"BOOL","color":-3388340',    '~b');
		str = StringTools.replace(str, '","type":"',           '~c');
		str = StringTools.replace(str, '","x":',               '~d');
		str = StringTools.replace(str, ',"y":',                '~e');
		str = StringTools.replace(str, ',"color":-5025958',    '~f');
		str = StringTools.replace(str, ',"inputs":[',          '~g');
		str = StringTools.replace(str, ',"outputs":[',         '~h');
		str = StringTools.replace(str, ',"node_id":',          '~i');
		str = StringTools.replace(str, ',"default_value":',    '~j');
		str = StringTools.replace(str, ',"buttons":[',         '~k');
		str = StringTools.replace(str, ',"links":[{',          '~l');
		str = StringTools.replace(str, ',"from_id":',          '~m');
		str = StringTools.replace(str, ',"from_socket":',      '~n');
		str = StringTools.replace(str, ',"to_id":',            '~o');
		str = StringTools.replace(str, ',"to_socket":',        '~p');
		str = StringTools.replace(str, '[0,0,0]',              '~q');
		str = StringTools.replace(str, '[0,0,0,0]',            '~r');
		str = StringTools.replace(str, '},{',                  '~s');
		str = StringTools.replace(str, ',"color":',            '~t');
		str = StringTools.replace(str, ',"data":',             '~u');
		str = StringTools.replace(str, ',"output":',           '~v');
		str = StringTools.replace(str, '"name":"property',     '~w');
		return StringTools.urlEncode(str);
	}

	function decode(str:String):String {
		str = StringTools.replace(str, '~w', '"name":"property'    );
		str = StringTools.replace(str, '~v', ',"output":'          );
		str = StringTools.replace(str, '~u', ',"data":'            );
		str = StringTools.replace(str, '~t', ',"color":'           );
		str = StringTools.replace(str, '~s', '},{'                 );
		str = StringTools.replace(str, '~r', '[0,0,0,0]');
		str = StringTools.replace(str, '~q', '[0,0,0]'     );
		str = StringTools.replace(str, '~p', ',"to_socket":'       );
		str = StringTools.replace(str, '~o', ',"to_id":'           );
		str = StringTools.replace(str, '~n', ',"from_socket":'     );
		str = StringTools.replace(str, '~m', ',"from_id":'         );
		str = StringTools.replace(str, '~l', ',"links":[{'         );
		str = StringTools.replace(str, '~k', ',"buttons":['        );
		str = StringTools.replace(str, '~j', ',"default_value":'   );
		str = StringTools.replace(str, '~i', ',"node_id":'         );
		str = StringTools.replace(str, '~h', ',"outputs":['        );
		str = StringTools.replace(str, '~g', ',"inputs":['         );
		str = StringTools.replace(str, '~f', ',"color":-5025958'   );
		str = StringTools.replace(str, '~e', ',"y":'               );
		str = StringTools.replace(str, '~d', '","x":'              );
		str = StringTools.replace(str, '~c', '","type":"'          );
		str = StringTools.replace(str, '~b', '","type":"BOOL","color":-3388340'   );
		str = StringTools.replace(str, '~a', '","type":"STRING","color":-3388340' );
		str = StringTools.replace(str, '~9', '","type":"RGBA","color":-3388340'   );
		str = StringTools.replace(str, '~8', '","type":"VECTOR","color":-10238109');
		str = StringTools.replace(str, '~7', '","type":"VALUE","color":-10238109' );
		str = StringTools.replace(str, '~6', '","type":"INTEGER","color":-3388340');
		str = StringTools.replace(str, '~5', '","type":"SHADER","color":-11959648');
		str = StringTools.replace(str, '~4', '","type":"OBJECT","color":-14250817');
		str = StringTools.replace(str, '~3', '","type":"ACTION","color":-3388340' );
		str = StringTools.replace(str, '~2', ',"name":"'           );
		str = StringTools.replace(str, '~1', '"id":'               );
		str = StringTools.replace(str, '~0', '{"nodes":[{'         );
		return str;
	}

	function onCut(): String { return onCopy(); }
	function onCopy(): String { return 'https://armory3d.org/logic/?' + encode(haxe.Json.stringify(canvasLogic)); }
	function onPaste(s: String) { }

	function update() {
		var mouse = iron.system.Input.getMouse();
		var keyboard = iron.system.Input.getKeyboard();

		if (ui.changed || changed) {
			parseLogic();
			changed = false;
		}

		wx = Std.int(iron.App.w());
		wy = 0;
		var mx = mouse.x + App.x();
		var my = mouse.y + App.y();
		if (mx < wx || my < wy) return;
		if (ui.isTyping) return;

		if (addNodeButton) {
			showMenu = true;
			addNodeButton = false;
		}
		else if (mouse.released()) {
			hideMenu = true;
		}

		if (keyboard.started("x") || keyboard.started("backspace")) {
			if (nodes.nodeSelected != null) {
				var c = canvasLogic;
				nodes.removeNode(nodes.nodeSelected, c);
				changed = true;
			}
		}

		if (keyboard.started("p")) {
			var c = canvasLogic;
			var str = haxe.Json.stringify(c);
			trace(str);
		}
	}

	public function getNodeX():Int {
		var mouse = iron.system.Input.getMouse();
		return Std.int((mouse.x + App.x() - wx - nodes.PAN_X()) / nodes.SCALE);
	}

	public function getNodeY():Int {
		var mouse = iron.system.Input.getMouse();
		return Std.int((mouse.y + App.y() - wy - nodes.PAN_Y()) / nodes.SCALE);
	}

	public function drawGrid() {
		var ww = arm.App.realw() - iron.App.w();
		var wh = iron.App.h();
		var w = ww + 40 * 2;
		var h = wh + 40 * 2;
		grid = kha.Image.createRenderTarget(w, h);
		grid.g2.begin(true, 0xff242424);
		for (i in 0...Std.int(h / 40) + 1) {
			grid.g2.color = 0xff282828;
			grid.g2.drawLine(0, i * 40, w, i * 40);
			grid.g2.color = 0xff323232;
			grid.g2.drawLine(0, i * 40 + 20, w, i * 40 + 20);
		}
		for (i in 0...Std.int(w / 40) + 1) {
			grid.g2.color = 0xff282828;
			grid.g2.drawLine(i * 40, 0, i * 40, h);
			grid.g2.color = 0xff323232;
			grid.g2.drawLine(i * 40 + 20, 0, i * 40 + 20, h);
		}
		grid.g2.end();
	}

	function render2D(g:kha.graphics2.Graphics) {
		
		g.end();

		if (grid == null) drawGrid();

		// Start with UI
		ui.begin(g);
		// ui.begin(rt.g2); ////
		
		// Make window
		ww = Std.int(arm.App.realw() - iron.App.w());
		var lay = 0;
		wx = Std.int(iron.App.w());
		wy = 0;
		var ew = Std.int(ui.ELEMENT_W());
		if (ui.window(hwnd, wx, wy, ww, iron.App.h())) {
			
			ui.g.color = 0xffffffff;
			ui.g.drawImage(grid, (nodes.panX * nodes.SCALE) % 40 - 40, (nodes.panY * nodes.SCALE) % 40 - 40);

			ui.g.font = arm.App.font;
			ui.g.fontSize = 22;
			if (!urlParsed) {
				var title = "Ctrl + C to copy URL";
				var titlew = ui.g.font.width(22, title);
				var titleh = ui.g.font.height(22);
				ui.g.drawString(title, ww - titlew - 20, iron.App.h() - titleh - 10);
			}
			
			var c = canvasLogic;
			nodes.nodeCanvas(ui, c);

			ui.g.color = ui.t.WINDOW_BG_COL;
			//ui.g.fillRect(0, 0, ww, 24);
			ui.g.color = 0xffffffff;

			ui._x = 3;
			ui._y = 3;
			ui._w = ew;

			if (!urlParsed) {
				if (ui.button("Action")) { addNodeButton = true; menuCategory = 0; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x += ew + 3;
				ui._y = 3;
				if (ui.button("Animation")) { addNodeButton = true; menuCategory = 1; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x += ew + 3;
				ui._y = 3;
				if (ui.button("Array")) { addNodeButton = true; menuCategory = 2; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x += ew + 3;
				ui._y = 3;
				if (ui.button("Canvas")) { addNodeButton = true; menuCategory = 3; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x += ew + 3;
				ui._y = 3;
				if (ui.button("Event")) { addNodeButton = true; menuCategory = 4; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x += ew + 3;
				ui._y = 3;
				if (ui.button("Input")) { addNodeButton = true; menuCategory = 5; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x = 3;
				ui._y = 30;
				if (ui.button("Logic")) { addNodeButton = true; menuCategory = 6; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x = ew + 3;
				ui._y = 30;
				// if (ui.button("Native")) { addNodeButton = true; menuCategory = 7; popupX = wx + ui._x; popupY = wy + ui._y; }
				// ui._x += ew + 3;
				// ui._y = 30;
				if (ui.button("Navmesh")) { addNodeButton = true; menuCategory = 8; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x += ew + 3;
				ui._y = 30;
				if (ui.button("Physics")) { addNodeButton = true; menuCategory = 9; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x += ew + 3;
				ui._y = 30;
				if (ui.button("Sound")) { addNodeButton = true; menuCategory = 10; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x += ew + 3;
				ui._y = 30;
				if (ui.button("Value")) { addNodeButton = true; menuCategory = 11; popupX = wx + ui._x; popupY = wy + ui._y; }
				ui._x += ew + 3;
				ui._y = 30;
				if (ui.button("Variable")) { addNodeButton = true; menuCategory = 12; popupX = wx + ui._x; popupY = wy + ui._y; }
			}
		}

		ui.endWindow();

		if (drawMenu) {
			
			var numNodes = 0;
			numNodes = NodeCreatorLogic.list.categories[menuCategory].nodes.length;
			var ph = numNodes * 20;
			var py = popupY;
			g.color = 0xff222222;
			g.fillRect(popupX, py, ew, ph);

			ui.beginLayout(g, Std.int(popupX), Std.int(py), ew);
			
			NodeCreatorLogic.draw(menuCategory);

			ui.endLayout();
		}

		ui.end();

		g.begin(false);

		if (showMenu) {
			showMenu = false;
			drawMenu = true;
			
		}
		if (hideMenu) {
			hideMenu = false;
			drawMenu = false;
		}
	}

	var lastT:iron.Trait = null;
	public function parseLogic() {
		if (lastT != null) iron.Scene.active.getChild("Cube").removeTrait(lastT);
		armory.system.Logic.packageName = "armory.logicnode";
		var t = armory.system.Logic.parse(canvasLogic);
		lastT = t;
		iron.Scene.active.getChild("Cube").addTrait(t);
	}
}
