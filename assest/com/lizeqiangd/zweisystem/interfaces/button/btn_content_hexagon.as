package com.lizeqiangd.zweisystem.interfaces.button
{
	//import com.lizeqiangd.zweisystem.abstract.unit.BaseTextButton
	import com.lizeqiangd.zweisystem.interfaces.baseunit.BaseAssestButton;
	import flash.geom.ColorTransform;
	//import com.lizeqiangd.zweisystem.manager.AnimationManager;
	import flash.display.MovieClip;
	
	public class btn_content_hexagon extends BaseAssestButton
	{
		/**
		 * 设置标题文字
		 */
		public var mc_button:MovieClip
		public var mc_anime:MovieClip
		public var mc_frame:MovieClip
		
		public function btn_content_hexagon()
		{
			super(true)
		}
		
		public function set setColor(e:uint)
		{
			var ct:ColorTransform = new ColorTransform
			ct.color = e
			mc_anime.transform.colorTransform = ct
			mc_button.transform.colorTransform = ct
			mc_frame.transform.colorTransform = ct
		}
	}
}