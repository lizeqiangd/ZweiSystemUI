package com.bilibili.player.core.script.interfaces
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/** 
	 * 幕布相关的操作
	 * 别名:$
	 **/
	public interface IScriptDisplay
	{
		/**
		 * 屏幕宽度 
		 **/
		function get fullScreenWidth():uint;
		/**
		 * 屏幕高度
		 **/
		function get fullScreenHeight():uint;
		/**
		 * 幕布宽度
		 **/
		function get width():uint;
		/**
		 * 幕布高度
		 **/
		function get height():uint;
		/**
		 * 播放器的帧率
		 */
		function get frameRate():Number;
		/**
		 * 播放器的帧率
		 */
		function set frameRate(value:Number):void;
		/**
		 * 创建2d转换矩阵
		 **/
		function createMatrix(a:Number=1, b:Number=0, c:Number=0, d:Number=1, tx:Number=0, ty:Number=0):Matrix;
		/**
		 * 创建渐变矩阵
		 **/
		function createGradientBox(width:Number, height:Number, rotation:Number, tx:Number, ty:Number):Matrix;
		/**
		 * 创建Point点
		 * @param x x坐标的值
		 * @param y y坐标的值
		 **/
		function createPoint(x:Number=0, y:Number=0):Point;
		/**
		 * 创建字幕(不同于用户弹幕系统中的字幕)
		 * @param text 字幕内容
		 * @param param 其他参数
		 **/
		function createComment(text:String, param:Object):ICommentField;
		/**
		 * 创建Shape对象
		 * @param param 相关参数
		 **/
		function createShape(param:Object):Shape;
		/**
		 * 创建绘图对象
		 * @param param 相关参数
		 **/
		function createCanvas(param:Object):ICommentCanvas;
		/**
		 * 创建按钮
		 * @param param 相关参数
		 **/
		function createButton(param:Object):ICommentButton;
		/**
		 * 创建发光滤镜(即new GlowFilter)
		 * @copy flash.filters.GlowFilter#GlowFilter
		 **/
		function createGlowFilter(color:uint=0xFF0000, alpha:Number=1.0, blurX:Number=6.0, blurY:Number=6.0, strength:Number=2, quality:int=1, inner:Boolean=false, knockout:Boolean=false):GlowFilter;
		/**
		 * 创建模糊滤镜
		 * @copy flash.filters.BlurFilter#BlurFilter
		 **/
		function createBlurFilter(x:Number=0, y:Number=0, num:uint=1):BlurFilter;
		function createBevelFilter(distance:Number = 4.0, angle:Number = 45, highlightColor:uint = 0xFFFFFF, highlightAlpha:Number = 1.0, shadowColor:uint = 0x000000, shadowAlpha:Number = 1.0, blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1, quality:int = 1, type:String = "inner", knockout:Boolean = false):*;
		function createColorMatrixFilter(matrix:Array = null):*;
		function createConvolutionFilter(matrixX:Number = 0, matrixY:Number = 0, matrix:Array = null, divisor:Number = 1.0, bias:Number = 0.0, preserveAlpha:Boolean = true, clamp:Boolean = true, color:uint = 0, alpha:Number = 0.0):*;
		function createDisplacementMapFilter(mapBitmap:BitmapData = null, mapPoint:Point = null, componentX:uint = 0, componentY:uint = 0, scaleX:Number = 0.0, scaleY:Number = 0.0, mode:String = "wrap", color:uint = 0, alpha:Number = 0.0):*;
		function createDropShadowFilter(distance:Number = 4.0, angle:Number = 45, color:uint = 0, alpha:Number = 1.0, blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1.0, quality:int = 1, inner:Boolean = false, knockout:Boolean = false, hideObject:Boolean = false):*;
		function createGradientBevelFilter(distance:Number = 4.0, angle:Number = 45, colors:Array = null, alphas:Array = null, ratios:Array = null, blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1, quality:int = 1, type:String = "inner", knockout:Boolean = false):*;
		function createGradientGlowFilter(distance:Number = 4.0, angle:Number = 45, colors:Array = null, alphas:Array = null, ratios:Array = null, blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1, quality:int = 1, type:String = "inner", knockout:Boolean = false):*;
		/**
		 * 转换为vector.<int>
		 **/
		function toIntVector(a:Array):Vector.<int>;
		/**
		 * 转换为vector.<Number>
		 **/
		function toNumberVector(a:Array):Vector.<Number>;
		/**
		 * 将数组转换为Vector.<uint>
		 **/
		function toUIntVector(a:Array):Vector.<uint>;
		/**
		 * 创建Matrix3D
		 * @param a 用于初始化的Array或者Vector.<Number>
		 **/
		function createMatrix3D(a:*):Matrix3D;
		/**
		 * 创建Vector3D
		 **/
		function createVector3D(x:Number=0.0, y:Number=0.0, z:Number=0.0, w:Number=0.0):Vector3D;
		/**
		 * 创建flash.text.TextFormat
		 **/
		function createTextFormat(font:String = null, size:Object = null, color:Object = null, bold:Object = null, italic:Object = null, underline:Object = null, url:String = null, target:String = null, align:String = null, leftMargin:Object = null, rightMargin:Object = null, indent:Object = null, leading:Object = null):TextFormat;
		/**
		 * 创建TextField
		 **/
		function createTextField():TextField;
		/**
		 * 创建ColorTransform
		 **/
		function createColorTransform(redMultiplier:Number = 1.0, greenMultiplier:Number = 1.0, blueMultiplier:Number = 1.0, alphaMultiplier:Number = 1.0, redOffset:Number = 0, greenOffset:Number = 0, blueOffset:Number = 0, alphaOffset:Number = 0):ColorTransform;
		
		/**
		 * functions from @see flash.geom.Utils3D
		 */
		function pointTowards(percent:Number, mat:Matrix3D, pos:Vector3D, at:Vector3D=null, up:Vector3D=null):Matrix3D;
		function projectVector(m:Matrix3D, v:Vector3D):Vector3D;
		function projectVectors(m:Matrix3D, verts:Vector.<Number>, projectedVerts:Vector.<Number>, uvts:Vector.<Number>):void;
	}
}