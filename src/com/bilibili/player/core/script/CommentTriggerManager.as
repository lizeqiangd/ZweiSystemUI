package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.ICommentTriggerManager;
	
	import com.bilibili.player.manager.ValueObjectManager;
	//import org.lala.event.EventBus;
	
	//import tv.bilibili.script.interfaces.ICommentTriggerManager;
	
	public class CommentTriggerManager implements ICommentTriggerManager
	{
		private var hooks:Vector.<Function>;
		
		public function CommentTriggerManager()
		{
			hooks = new Vector.<Function>();
		}
		
		public function addTrigger(f:Function):void
		{
			hooks.push(f);
		}
		
		public function removeTrigger(f:Function):void
		{
			var index:int = hooks.indexOf(f);
			if (index !== -1)
			{
				hooks.splice(index, 1);
			}
		}
		
		public function trigger(item:Object):Boolean
		{
			if (hooks.length == 0)
			{
				return false;
			}
			var len:int = hooks.length;
			try
			{
				for (var i:int = 0; i < len; i++)
				{
					hooks[i].call(null, item);
				}
			}
			catch (err:Error)
			{
				ValueObjectManager.getEventBus.log(err.toString());
			}
			return true;
		}
	}
}