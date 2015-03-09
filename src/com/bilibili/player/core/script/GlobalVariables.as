package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.IGlobal;
	//import tv.bilibili.script.interfaces.IGlobal;
	
	public class GlobalVariables implements IGlobal
	{
		protected var _dict:Object = {};
		public function GlobalVariables()
		{
			//TODO: implement function
		}
		
		public function _set(key:String, val:*):void
		{
			_dict[key] = val;
		}
		
		public function _get(key:String):*
		{
			return _dict[key];
		}
		
		public function _(key:String):*
		{
			return _dict[key];
		}
	}
}