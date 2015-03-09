package com.bilibili.player.core.comments
{
    import com.bilibili.player.manager.ValueObjectManager;
    import com.bilibili.player.valueobjects.config.PlayerConfig;
    import com.greensock.TweenMax;
    import com.greensock.motionPaths.LinePath2D;
    import com.greensock.motionPaths.PathFollower;
    
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Linear;
    import org.libspark.betweenas3.easing.Quadratic;
    import org.libspark.betweenas3.events.TweenEvent;
    import org.libspark.betweenas3.tweens.ITween;

    /** bili新弹幕的表现类 **/
    public class FixedPosComment extends TextField implements IComment
    {
        /** 完成地调用的函数,无参数 **/
        protected var _complete:Function;
        /** 配置数据 **/
        protected var item:CommentDataMode7;
        /** 动作补间 **/
        private var _tw:ITween;
		/** 弹幕配置 **/
		protected static var config:PlayerConfig=ValueObjectManager.getPlayerConfig
		/**
		 * 舞台宽度
		 **/
		private var Width:Number;
		/**
		 * 舞台高度
		 **/
		private var Height:Number;
		
        /** 构造函数 **/
        public function FixedPosComment()
        {
        }
		[Deprecated(replacement="initialize2")]
		public function initialize(data:CommentData):void
		{
		}
		public function initialize2(data:CommentDataMode7, w:Number=0, h:Number=0):void
		{
            /** 复制配置 **/
            item = data as CommentDataMode7;
			/** 如果生存时间为0,则为无限(计算机意义上的无限) **/
			if(item["duration"] == 0)
			{
				item["duration"] = Number.MAX_VALUE;
			}
			Width = w;
			Height = h;
            init();
		}
		
		/** 开始播放 **/
        public function start():void
        {
            this.visible = true;
            this._tw.play();
        }
        /** 暂停 **/
        public function pause():void
        {
            this._tw.stop();
        }
        /** 恢复播放 **/
        public function resume():void
        {
            this._tw.play();
        }
        /**
         * 设置完成播放时调用的函数,调用一次仅一次
         * @param	foo 完成时调用的函数,无参数
         */
        public function set complete(foo:Function):void
        {
            this._complete = foo;
        }
        /**
         * 初始化,由构造函数最后调用
		 * 所有属性必须重新赋值:重置缓存的数据!!
         */
        protected function init():void
        {
			this.mouseEnabled = false;
            this.visible = false;
            this.x = absolutePos(item.x, Width);
            this.y = absolutePos(item.y, Height);
            if (item.rY != 0 || item.rZ != 0)
            {
                this.rotationY = item.rY;
                this.rotationZ = item.rZ;
            }
			else
			{
				this.rotationY = this.rotationZ = 0;
			}
            this.alpha = item.inAlpha;
            this.autoSize = 'left';
			if(item.borderStyle)
			{
            	this.filters = config.getFilterByColor(item.color);
			}
			else
			{
				this.filters = [];
			}
			if(item.fontFamily)
			{
            	this.defaultTextFormat = new TextFormat(item.fontFamily, config.sizee * item.size, item.color, config.bold, null, null, null, null, null, null, null, null, 2);
			}
			else
			{
            	this.defaultTextFormat = new TextFormat(config.font, config.sizee * item.size, item.color, config.bold, null, null, null, null, null, null, null, null, 2);
			}
            this.text = item.text;
			
            var tw1:ITween = BetweenAS3.tween(this, { alpha:item.outAlpha }, { alpha:item.inAlpha }, item.duration, Quadratic.easeOut);
            if (!item.adv)
            {
                this._tw = tw1;
            } 
            else 
            {
				if(item.motionPath == null)
				{
                var tw2:ITween = BetweenAS3.tween(this, { x:absolutePos(item.toX, Width), y:absolutePos(item.toY, Height) }, { x:this.x, y:this.y }, item.mDuration, item.isAccelerated ? Quadratic.easeOut : Linear.easeIn);
                this._tw = BetweenAS3.parallel(tw1, BetweenAS3.delay(tw2, item.delay));
				}
				else
				{
					var pStr:Array = (item.motionPath.substring(1)).split("L");
					var pArr:Array = pStr.map(function(s:String, index:uint, a:Array):Point
					{
						var arr:Array = s.split(",");
						return new Point(new Number(arr[0]), new Number(arr[1]));
					});
					var path:LinePath2D = new LinePath2D(pArr);
					var follower:PathFollower = path.addFollower(this, 0, false);
					TweenMax.to(follower, item.mDuration, {progress: 1});
					
					this._tw = tw1;
				}
            }
            this._tw.addEventListener(TweenEvent.COMPLETE, completeHandler);
        }
		
		/**
         * 结束事件监听
         */
        private function completeHandler(event:TweenEvent):void
        {
			this._tw.removeEventListener(TweenEvent.COMPLETE, completeHandler);
            this._complete();
        }
		/**
		 * 对原始数据的引用(副本)
		 **/
		public function get data():CommentData
		{
			return item;
		}
		/**
		 * 提前结束,清理现场
		 **/
		public function stop():void
		{
			this._tw.stop();
			completeHandler(null);
		}
		
		/**
		 * 计算实际坐标:
		 * 如果在0-1范围内,按百分比计算
		 **/
		protected function absolutePos(n:Number, t:Number):Number
		{
			if(n <= 0 || n >= 1)
			{
				return n;
			}
			else
			{
				return t * n;
			}
		}
    }
}