package com.bilibili.player.core.utils
{
	/**
	 * 通用工厂,用于内存的优化
	 * 逐步建立一个内存缓存机制
	 **/
	public class GeneralFactory
	{
		private var pool:Array = [];
		private var cls:Class = null;
		private var step:int = 0;
		
		public function GeneralFactory(c:Class, initialNumber:int = 0, step:int = 10)
		{
			this.cls = c;
			this.step = step;
			
			if(this.step < 10)
			{
				this.step = 10;
			}
			addNObjects(initialNumber);
		}
		
		public function getObject():Object
		{
			if(pool.length > 0)
			{
				return pool.pop();
			}
			else
			{
				addStep();
				return pool.pop();
			}
		}
		
		public function putObject(obj:Object):void
		{
			pool.push(obj);
		}
		
		private function addStep():void
		{
			addNObjects(step);
		}
		
		private function addNObjects(n:uint):void
		{
			var i:uint = 0;
			var len:uint = pool.length;
			for(; i < n; i ++)
			{
				pool[i + len] = new cls();
			}
		}
	}
}