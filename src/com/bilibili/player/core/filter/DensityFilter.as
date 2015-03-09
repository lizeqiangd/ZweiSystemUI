package com.bilibili.player.core.filter {
	
	import com.bilibili.player.core.comments.Comment;
	import com.bilibili.player.core.comments.CommentData;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.valueobjects.config.PlayerConfig;
	
	import flash.utils.getTimer;
	
	//import org.lala.comments.Comment;
	//import org.lala.comments.CommentData;
	//import org.lala.utils.CommentConfig;

	/**
	 * 密度处理，使弹幕更均匀
	 */
	public final class DensityFilter
	{
		private static var _instance:DensityFilter = null;
		
		public static function getInstance():DensityFilter
		{
			if(_instance == null)
			{
				_instance = new DensityFilter;
			}
			return _instance;
		}
		
		/**
		 * 处理的单位区:ms
		 */
		private var field:uint = 1000;
		/**
		 * 用于计算的时间,与
		 * org.lala.comments.ScrollCommentSpaceManager/duration
		 * 一致
		 */
		private var duration:Number = 3;
		
		public function DensityFilter()
		{
		}
		
		/**
		 *  cmts应该是根据time从小到大排序
		 */
		[Deprecated(message="考虑到非实时弹幕也可以使用实时的区间算法，预先计算的方法由于涉及过多的变更而被弃用")]
		public function validateAll(cmts:Array):void
		{
			var config:PlayerConfig = ValueObjectManager.getPlayerConfig;
			if(config.density <= 0)
			{
				cmts.forEach(function(cmt:CommentData, ...args):void
				{
					if(cmt.blocked && cmt.blockType === BlockType.OVERFLOW_BLOCK)
					{
						cmt.blocked = false;
					}
				});
				return;
			}
			/** 一个区间内最大的弹幕数目 **/
			var max_field:uint = Math.floor(config.density * (0.5 * config.speede) / duration * field / 1000);
			if(max_field < 1)
			{
				max_field = 1;
			}
			
			var field_cache:Vector.<CommentData> = new Vector.<CommentData>;
			var i:uint = 0;
			var comment:CommentData;
			var field_start:uint = 0;
			while(i < cmts.length)
			{
				comment = cmts[i];
				var time:uint = Math.floor(comment.stime * 1000);
				if(time > field_start + field)
				{
					/**
					 * 到达下一个区间，上一个区间处理完成
					 */
					while(field_cache.length)
					{
						field_cache.pop();
					}
					while(field_start + field < time)
					{
						field_start += field;
					}
				}
				if(comment.pool != 0)
				{
					continue;
				}
				if(field_cache.length < max_field)
				{
					/**
					 * 溢出屏蔽的标志只对没有过滤的弹幕设置
					 */
					if(comment.blocked === false || (comment.blockType === BlockType.OVERFLOW_BLOCK))
					{
						if(comment.blocked === true)
						{
							/**
							 * 移除溢出标志
							 */
							comment.blocked = false;
						}
						field_cache.push(comment);
					}
				}
				else
				{
					/**
					 * 溢出屏蔽的标志只对没有过滤的弹幕设置
					 */
					if(comment.blocked === false)
					{
						comment.blocked = true;
						comment.blockType = BlockType.OVERFLOW_BLOCK;
					}
				}
				i++;
			}
		}
		
		/**
		 * 新弹幕
		 */
		public function validate(cmts:Array, cmt:Comment):void
		{
			
		}
		
		/**
		 * 实时区间开始
		 */
		private var live_start:Number = 0;
		/**
		 * 实时区间累积弹幕数
		 */
		private var live_current:Number = 0;
		/**
		 * 实时弹幕的密度控制:维持一个实时弹幕计数区间,不需要弹幕数据,只需要适时调用
		 */
		public function validateLive(cmt:CommentData):Boolean
		{
			var config:PlayerConfig =  ValueObjectManager.getPlayerConfig
			if(config.density <= 0 || cmt.pool !== 0)
			{
				return true;
			}
			
			/** 一个区间内最大的弹幕数目:每次使用都再次计算，不需要考虑与配置同步问题 **/
			var max_field:uint = Math.floor(config.density * (0.5 * config.speede) / duration * field / 1000);
			if(max_field < 1)
			{
				max_field = 1;
			}
			
			if(live_start == 0)
			{
				live_start = getTimer();
			}
			var time:Number = getTimer();
			
			/**
			 * 上一个区间完成：不一定与这个区间相邻（弹幕比较少的情况）
			 */
			if(time > live_start + field)
			{
				live_current = 0;
				while(time > live_start + field)
				{
					live_start += field;
				}
			}
			
			if(live_current < max_field)
			{
				live_current ++;
				return true;
			}
			return false;
		}
	}
}