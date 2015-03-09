package com.bilibili.player.core.script
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	/**
	 * 无法访问parent的Sprite:应对脚本访问任意显示对象的情况 
	 * @author aristotle9
	 * @editor Lizeqiangd
	 * 20141117 更改路径
	 **/
	public class NoParentSprite extends Sprite
	{
		public function NoParentSprite()
		{
			super();
		}
		
		override public function get parent():DisplayObjectContainer
		{
			return null
		}
	}
}