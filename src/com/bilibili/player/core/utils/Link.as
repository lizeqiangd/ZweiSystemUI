package com.bilibili.player.core.utils
{
	/**
	 * 双向键表
	 * 用于维护tween表,方便删除其中的节点(效率应该比vector要高)
	 **/
	public class Link {
		
		public var first:Node;
		public var last:Node;
		private var nodeFac:GeneralFactory;
		
		public function Link() {
			first = null;
			last = null;
			nodeFac = new GeneralFactory(Node, 40, 20);
		}
		/**
		 * 链表是否为空
		 **/
		public function empty():Boolean
		{
			return first === null;
		}
		/**
		 * 末尾添加一个数据
		 **/
		public function append(obj:Object):Node
		{
			var node:Node = nodeFac.getObject() as Node;
			node.data = obj;
			node.next = null;
			
			if(first === null)
			{
				node.prev = null;
				first = node;
			}
			else
			{
				node.prev = last;
				last.next = node;
			}
			last = node;
			return node;
		}
		/**
		 * 删除一个节点:需要提供前一个节点!!
		 **/
		public function removeNode(node:Node):void
		{
			var prev:Node = node.prev;
			var next:Node = node.next;
			
			if(prev)
			{
				if(next)
				{
					prev.next = next;
					next.prev = prev;
				}
				else
				{
					prev.next = null;
					last = prev;
				}
			}
			else
			{
				if(next)
				{
					next.prev = null;
					first = next;
				}
				else
				{
					first = null;
					last = null;
				}
			}
			node.data = node.prev = node.next = null;
			nodeFac.putObject(node);
		}
	}
}