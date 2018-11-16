package arm;

import zui.*;
import zui.Zui.State;
import zui.Canvas;

class App extends iron.Trait {

	public static var font:kha.Font = null;
	public static var theme:zui.Themes.TTheme;
	public static var color_wheel:kha.Image;
	static var lastW = -1;
	static var lastH = -1;

	public function new() {
		super();

		iron.data.Data.getFont("font_default.ttf", function(f:kha.Font) {
			// iron.data.Data.getImage('color_wheel.png', function(image:kha.Image) {
				font = f;
				// color_wheel = image;
				iron.Scene.active.root.addTrait(new UINodes());
			// });
		});
	}

	public static function w():Int {
		var res = Std.int((kha.System.windowWidth()) / 3);
		return res > 0 ? res : 1; // App was minimized, force render path resize
	}

	public static function h():Int {
		var res = 0;
		res = kha.System.windowHeight();
		return res > 0 ? res : 1; // App was minimized, force render path resize
	}

	public static function x():Int {
		return 0;
	}

	public static function y():Int {
		return 0;
	}

	public static function realw():Int {
		return kha.System.windowWidth();
	}

	public static function realh():Int {
		return kha.System.windowHeight();
	}

	public static function resize() {
		iron.Scene.active.camera.buildProjection();
		if (UINodes.inst.grid != null) {
			UINodes.inst.grid.unload();
			UINodes.inst.grid = null;
		}
	}

	static function render(g:kha.graphics2.Graphics) {
		if (lastW >= 0 && arm.App.realw() > 0 && (lastW != arm.App.realw() || lastH != arm.App.realh())) {
			arm.App.resize();
		}
		lastW = arm.App.realw();
		lastH = arm.App.realh();
	}
}
