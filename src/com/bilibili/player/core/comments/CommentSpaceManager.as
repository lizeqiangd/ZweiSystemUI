package com.bilibili.player.core.comments
{
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.valueobjects.config.PlayerConfig;
    //import org.lala.utils.CommentConfig;

    /**
    * 弹幕占用视觉空间管理分配类,本身实现线性空间管理
    * @author aristotle9
    **/
    public class CommentSpaceManager
    {
        /** 层数列 **/
        protected var Pools:Array = [];
        /** 宽度 **/
        protected var Width:int;
        /** 高度 **/
        protected var Height:int;
        /** 配置 **/
        protected var config:PlayerConfig =ValueObjectManager.getPlayerConfig
        
        public function CommentSpaceManager()
        {
        }
        /**
        * 设置宽度高度参数
        * @param w 宽度
        * @param h 高度
        **/
        public function setRectangle(w:int,h:int):void
        {
            this.Width = w;
            this.Height = h;
        }
        /** 添加弹幕到空间,重点在于设置x,y值 **/
        public function add(cmt:Comment):void
        {
            cmt.x = (this.Width - cmt.width) / 2;
            if(cmt.height >= this.Height)
            {
                cmt.setY(0,-1,transformY);
            }
            else
            {
                /** 进入高级y坐标确定 **/
                this.setY(cmt);   
            }
        }
        /** 复杂一点的y坐标确定 **/
        protected function setY(cmt:Comment,index:int = 0):void
        {
            /** 临时y坐标 **/
            var y:int = 0;
            if(this.Pools.length <= index)
            {
                this.Pools.push(new Array());
            }
            var pool:Array = this.Pools[index];
            if(pool.length == 0)
            {
                cmt.setY(yOffsetByScreenIndex(0, index),index,transformY);
                pool.push(cmt);
                return;
            }
            if(this.vCheck(0,cmt,index))
            {
                cmt.setY(yOffsetByScreenIndex(0, index),index,transformY);
                CommentManager.binsert(pool,cmt,bottom_cmp);
                return;
            }
            for each(var c:Comment in pool)
            {
                y = c.bottom + 1;
                if(y + cmt.height > this.Height)
                {
                    break;
                }
                if(this.vCheck(y,cmt,index))
                {
                    cmt.setY(yOffsetByScreenIndex(y, index),index,transformY);
                    CommentManager.binsert(pool,cmt,bottom_cmp);
                    return;
                }
            }
            this.setY(cmt,index + 1);
            
        }
        /** y坐标转换函数(id) **/
        protected function transformY(y:int,cmt:Comment):int
        {
            return y;
        }
        /** 底部排序比较函数 **/
        protected function bottom_cmp(a:Comment,b:Comment):int
        {
            if(a.bottom < b.bottom)
            {
                return -1;
            }
            else if(a.bottom == b.bottom)
            {
                return 0;
            } 
            else 
            {
                return 1;
            }
        }
        /** 碰撞检测 **/
        protected function vCheck(y:int,cmt:Comment,index:int):Boolean
        {
            var bottom:int = y + cmt.height;
            for each(var c:Comment in this.Pools[index])
            {
                if(c.y > bottom || c.bottom < y)
                {
                    continue;
                }
                else 
                {
                    return false;
                }
            }
            return true;
        }
        /**
        * 移除函数
        */
        public function remove(cmt:Comment):void
        {
            if(cmt.index != -1)
            {
                var pool:Array = this.Pools[cmt.index];
                var n:int = pool.indexOf(cmt);
                pool.splice(n,1);
            }
        }
		/**
		 * 虚拟屏中的y值偏移
		 * <p>
		 * 在bilibili中非第一屏的弹幕y值是随机的,这样增加了致密感,</br>
		 * 在原mukioplayer算法中,各虚拟屏是重叠的,这样有多屏并且都同一高度时会产生完全的重叠,</br>
		 * 看上去屏幕还是一行行分离的,达不到字幕多欢乐的效果</br>
		 * 第一屏因为index是0,所以没有偏移</br>
		 * 显然,要实现<b>随机</b>的值也是在这里改</br>
		 * </p>
		 * @param y0 未偏移的y值
		 * @param index 虚拟屏的编号,也是偏移的根据之一
		 * @return 经过偏移并且模式除后的y坐标
		 **/
		protected function yOffsetByScreenIndex(y0:int, index:uint):int
		{
			/** 虚拟屏间的偏移量:不能是字号的整数倍,不然达不到效果 **/
			/** 默认字体是25 **/
			return y0;
			var step:uint = Math.random() * Height;
			return (y0 + step * index) % Height;
		}
    }
}