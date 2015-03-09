package
{
	import com.lizeqiangd.zweisystem.events.UIEvent;
	import com.lizeqiangd.zweisystem.interfaces.button.btn_general;
	import com.lizeqiangd.zweisystem.interfaces.button.btn_general_s;
	import com.lizeqiangd.zweisystem.interfaces.button.btn_hexagon;
	import com.lizeqiangd.zweisystem.interfaces.button.btn_label;
	import com.lizeqiangd.zweisystem.interfaces.button.btn_content_hexagon;
	import com.lizeqiangd.zweisystem.interfaces.button.btn_rect;
	import com.lizeqiangd.zweisystem.interfaces.button.special.btn_psychopass;
	import com.lizeqiangd.zweisystem.interfaces.checkbox.cb_content
	import com.lizeqiangd.zweisystem.interfaces.checkbox.cb_emission
	import com.lizeqiangd.zweisystem.interfaces.checkbox.cb_general;
	import com.lizeqiangd.zweisystem.interfaces.checkbox.cb_hexagon
	import com.lizeqiangd.zweisystem.interfaces.label.la_general;
	import com.lizeqiangd.zweisystem.interfaces.label.la_rect;
	import com.lizeqiangd.zweisystem.interfaces.numericstepper.ns_general;
	import com.lizeqiangd.zweisystem.interfaces.numericstepper.ns_number;
	import com.lizeqiangd.zweisystem.manager.SkinManager;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Lizeqiangd
	 */
	public class EinStationUserInterface extends Sprite
	{
		
		public function EinStationUserInterface()
		{
			this.stage.align = StageAlign.TOP_LEFT
			this.stage.scaleMode = StageScaleMode.NO_SCALE
			var sm:SkinManager = new SkinManager()
			sm.addEventListener(Event.COMPLETE, onSkinLoadComplete)
			//onSkinLoadComplete()
		}
		
		private function onSkinLoadComplete(e:Event = null):void
		{
			var button_class_arr:Array = []
			button_class_arr = [btn_general, btn_general_s, btn_label, btn_rect, btn_hexagon, cb_content, cb_emission, btn_content_hexagon, cb_hexagon, btn_psychopass, cb_general, la_general, la_rect]
			for (var i:int = 0; i < button_class_arr.length; i++)
			{
				var temp:* = new (button_class_arr[i] as Class)
				temp.title = '按钮测试'
				//temp.enable = Math.random() > 0.5
				addChild(temp)
				temp.x = 10 + Math.floor(i / 8) * 200
				temp.y = 10 + (i % 8) * 50
				temp.addEventListener(UIEvent.CLICK, function(e:*):void
					{
						trace(e.target)
					})
			}
			var ns_numbers:ns_number = new ns_number
			ns_numbers.setMax = 100
			addChild(ns_numbers)
			ns_numbers.x = 200
			ns_numbers.y = 250
			
			var ns_generals:ns_general = new ns_general
			ns_generals.setMax = 100
			addChild(ns_generals)
			ns_generals.x = 200
			ns_generals.y = 280
		
		}
	
	}

}