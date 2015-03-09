package com.bilibili.player.components
{
	import flash.utils.*;
	
	/**
	 * 检测其父子类用的方法.
	 * @author Lizeqiangd
	 */
	public class CompareClass
	{
		/**
		 *
		 * @param	* 待检测的类
		 * @param	Class 超类
		 * @return  Boolean 是否相等
		 */
		public static function isSuperClass(value:*, clazz:Class):Boolean
		{
			value = getDefinitionByName(getQualifiedClassName(value));
			while (value != clazz)
			{
				var className:String = getQualifiedSuperclassName(value);
				if (className == "Object")
				{
					return false;
				}
				value = getDefinitionByName(className);
			}
			return true;
		}
	}

}