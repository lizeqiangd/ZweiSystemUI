package com.lizeqiangd.zweisystem.manager
{
	//import com.greensock.loading.core.DisplayObjectLoader;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * 加载外部swf文件作为整体播放器的素材库.
	 * 2014.09.29
	 * 2014.10.14 改用重新建立实例的方式创建皮肤,否则一个皮肤只能用一次还有可能报错....惨惨惨
	 * @author Lizeqiangd
	 */
	public class SkinManager extends EventDispatcher
	{
		
		[Embed(source="../../../../../assest/EinStationUI.swf")]
		private var EmbeddedSkin:Class;
		private var onCompleteFunction:Function
		
		private var skinObj:DisplayObjectContainer
		private static var skinClip:MovieClip
		private static var isInited:Boolean = false
		
		public function SkinManager()
		{
			var skinObj:DisplayObjectContainer = new EmbeddedSkin() as DisplayObjectContainer;
			try
			{
				//trace("SkinManager")
				var embeddedLoader:Loader = Loader(skinObj.getChildAt(0));
				embeddedLoader.contentLoaderInfo.addEventListener(Event.INIT, loadComplete);
				embeddedLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
					//trace("SkinManager2")
			}
			catch (e:Error)
			{
				trace("SkinManager:failed to load assest swf")
			}
		}
		
		protected function loadComplete(evt:Event):void
		{
			try
			{
				var loader:LoaderInfo = LoaderInfo(evt.target);
				skinClip = MovieClip(loader.content);
				loader.removeEventListener(Event.INIT, loadComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
				isInited = true
				dispatchEvent(new Event(Event.COMPLETE));
			}
			catch (e:Error)
			{
				//com.lizeqiangd.zweisystem.interfaces.skins.select_arrow_up
				trace("SkinManager:loadError2")
			}
		
		}
		
		protected function loadError(evt:ErrorEvent):void
		{
			trace("SkinManager:loadError")
		}
		
		public static function getSkinContent():MovieClip
		{
			return skinClip
		}
		
		public static function getObject(e:String):*
		{
			if (!isInited)
			{
				trace("SkinManager.getObject:not init")
				return
			}
			try
			{
				//var cls:Class = skinClip['com.lizeqiangd.zweisystem.interfaces.skins.'+e].constructor
				var cls:Class = skinClip[e].constructor
			}
			catch (s:*)
			{
				trace("SkinManager:没有这个东西",e)
				return null
			}
			
			//getDefinitionByName(getQualifiedClassName(skinClip[e])) as Class
			var d:* = new cls()
			//skinClip.getChildByName(e)
			
			d.x = 0
			d.y = 0
			d.scaleX = 1
			d.scaleY = 1
			d.alpha = 1
			return d
		}
	
	}

}