package com.lizeqiangd.zweisystem.interfaces.scrollbar
{
	
	import flash.display.MovieClip;
	//import com.zweisystem.managers.AnimationManager
	//import com.zweisystem.events
	//import com.zweisystem.interfaces.scrollbar.sb_hexagon_core;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	
	public class sb_hexagon extends MovieClip
	{
		public var mc_down:MovieClip = new MovieClip;
		public var mc_up:MovieClip = new MovieClip;
		public var mc_pointer:MovieClip = new MovieClip;
		public var mc_bg:MovieClip = new MovieClip;
		
		private var tempMask:Sprite = new Sprite;
		private var _core:sb_hexagon_core;
		
		public function init($target:DisplayObjectContainer, $maskTarget:*, $height:Number = 200, $direction:String = "L")
		{
			totelHeight = $height;
			_core = new sb_hexagon_core($target, $maskTarget, mc_pointer, mc_bg, 0, true, true, true, $direction);
			$maskTarget.addEventListener(MouseEvent.MOUSE_OUT, onOutAlpha);
			$maskTarget.addEventListener(MouseEvent.MOUSE_OVER, onOverAlpha);
			_core.DOWN = mc_down;
			_core.UP = mc_up;
			addUiAnimation();
		}
		
		public function initText($target:TextField, $height:Number)
		{
			totelHeight = $height;
			_core = new sb_hexagon_core($target, tempMask, mc_pointer, mc_bg, 30, true, true, true, "L", true);
			
			$target.addEventListener(MouseEvent.MOUSE_OVER, onOverAlpha);
			
			$target.addEventListener(MouseEvent.MOUSE_OUT, onOutAlpha);
			$target.mouseWheelEnabled = false;
			_core.DOWN = mc_down;
			_core.UP = mc_up;
			addUiAnimation();
		}
		
		public function refresh()
		{
			_core.refresh();
		
		}
		
		private function onOverAlpha(e:MouseEvent)
		{
			this.alpha=1
			//AnimationManager.fade(this, 1);
		}
		
		private function onOutAlpha(e:MouseEvent)
		{
			this.alpha=0.2
			//AnimationManager.fade(this, 0.2);
		}
		
		private function addUiAnimation()
		{
			mc_down.alpha = 0.5;
			mc_up.alpha = 0.5;
			mc_pointer.alpha = 0.5;
			mc_down.addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);
			mc_up.addEventListener(MouseEvent.MOUSE_OVER, onDown, false, 0, true);
			mc_pointer.addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);
			
			mc_down.addEventListener(MouseEvent.MOUSE_OVER, onOver, false, 0, true);
			mc_up.addEventListener(MouseEvent.MOUSE_OVER, onOver, false, 0, true);
			mc_pointer.addEventListener(MouseEvent.MOUSE_OVER, onOver, false, 0, true);
			
			mc_down.addEventListener(MouseEvent.MOUSE_OUT, onOut, false, 0, true);
			mc_up.addEventListener(MouseEvent.MOUSE_OUT, onOut, false, 0, true);
			mc_pointer.addEventListener(MouseEvent.MOUSE_OUT, onOut, false, 0, true);
		}
		
		private function removeUiAnimation()
		{
			mc_down.alpha = 0.5;
			mc_up.alpha = 0.5;
			mc_pointer.alpha = 0.5;
			mc_down.removeEventListener(MouseEvent.MOUSE_DOWN, onDown)
			mc_up.removeEventListener(MouseEvent.MOUSE_OVER, onDown)
			mc_pointer.removeEventListener(MouseEvent.MOUSE_DOWN, onDown)
			
			mc_down.removeEventListener(MouseEvent.MOUSE_OVER, onOver)
			mc_up.removeEventListener(MouseEvent.MOUSE_OVER, onOver)
			mc_pointer.removeEventListener(MouseEvent.MOUSE_OVER, onOver)
			
			mc_down.removeEventListener(MouseEvent.MOUSE_OUT, onOut)
			mc_up.removeEventListener(MouseEvent.MOUSE_OUT, onOut)
			mc_pointer.removeEventListener(MouseEvent.MOUSE_OUT, onOut)
		}
		
		private function onDown(e:MouseEvent)
		{
			//AnimationManager.fade(e.target , 1);
			e.target.alpha = 1
		}
		
		private function onOver(e:MouseEvent)
		{
			e.target.alpha = 0.9
			//AnimationManager.fade(e.target ,0.9);
		}
		
		private function onOut(e:MouseEvent)
		{
			e.target.alpha = 0.5
			//AnimationManager.fade(e.target ,0.5);
		}
		
		private function set enable(value:Boolean)
		{
			if (value)
			{
				//AnimationManager.fade_in(this);
				this.visible = true
				addUiAnimation()
			}
			else
			{
				this.visible = false
				//AnimationManager.fade_out(this);
				removeUiAnimation()
			}
		}
		
		private function set totelHeight(t:Number)
		{
			this.mc_bg.height = t - 15;
			mc_bg.y = 7.5;
			mc_down.y = t;
		}
	}
}