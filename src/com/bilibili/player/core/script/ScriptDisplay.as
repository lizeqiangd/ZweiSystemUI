package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.ICommentButton;
	import com.bilibili.player.core.script.interfaces.ICommentCanvas;
	import com.bilibili.player.core.script.interfaces.ICommentField;
	import com.bilibili.player.core.script.interfaces.IMotionElement;
	import com.bilibili.player.core.script.interfaces.IScriptDisplay;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.system.namespaces.bilibili;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ScriptDisplay implements IScriptDisplay
	{
		/** 弹幕脚本元件所在的层 **/
		protected var _layer:DisplayObjectContainer;
		/** 播放器,用于获取宽度和高度 **/
		//protected var _player:IPlayer;
		/** 配置的默认值 **/
		bilibili var _defaultConfig:Object;
		/** 脚本管理 **/
		protected var _scriptManager:ScriptManager;
		
		/** 依赖差不多都接口化了 **/
		public function ScriptDisplay(/*player:IPlayer,*/ layer:DisplayObjectContainer, manager:ScriptManager)
		{
			//_player = player;
			_layer = layer;
			_scriptManager = manager;
			bilibili::_defaultConfig = {
				x: 0
				,y: 0
				,z: null
				,scale: 1
				,alpha: 1
				,parent: _layer
				,lifeTime: 3
				,motion: null
			};
		}
		
		public function get fullScreenWidth():uint
		{
			return _layer.stage.fullScreenWidth;
		}
		
		public function get fullScreenHeight():uint
		{
			return _layer.stage.fullScreenHeight;
		}
		
		public function get screenWidth():uint
		{
			return _layer.stage.fullScreenWidth;
		}
		
		public function get screenHeight():uint
		{
			return _layer.stage.fullScreenHeight;
		}
		
		public function get stageWidth():uint
		{
			return _layer.stage.stageWidth;
		}
		
		public function get stageHeight():uint
		{
			return _layer.stage.stageHeight;
		}
		
		public function get width():uint
		{return ValueObjectManager.getCommentDisplayer.width
//			return _player.controls.display.width;
		}
		
		public function get height():uint
		{return ValueObjectManager.getCommentDisplayer.height
//			return _player.controls.display.height;
		}
		
		/** 非公开api:调试时使用 **/
		public function get root():DisplayObjectContainer
		{
			return _layer;	
		}
		
		public function createMatrix(a:Number=1, b:Number=0, c:Number=0, d:Number=1, tx:Number=0, ty:Number=0):Matrix
		{
			return new Matrix(a, b, c, d, tx, ty);
		}
		
		public function createGradientBox(width:Number,height:Number,rotation:Number,tx:Number,ty:Number):Matrix
		{
			var matr: Matrix = new Matrix();
			matr.createGradientBox(width,height,rotation, tx, ty);
			return matr;
		}
		
		public function createPoint(x:Number=0, y:Number=0):Point
		{
			return new Point(x, y);
		}
		/**
		 * 创建一个文本
		 * 使用param初始化文本属性
		 * 并且添加到幕布上
		 **/
		public function createComment(text:String, param:Object):ICommentField
		{
			/** 缺省参数 **/
			bilibili::extend(param, bilibili::_defaultConfig);
			bilibili::extend(param, {
				color: 0xffffff
				,font: '黑体'
				,fontsize: 25
			});
			
			var cf:CommentField = new CommentField();
			cf.text = text;
			cf.initStyle(param);
			
			/** 设置移动配置 **/
			bilibili::setupMotionElement(param, cf);
			return cf;
		}
		
		public function createShape(param:Object):Shape
		{
			bilibili::extend(param, bilibili::_defaultConfig);
			
			var cs:CommentShape = new CommentShape;
			cs.initStyle(param);
			
			bilibili::setupMotionElement(param, cs);
			return cs;
		}
		
		public function createCanvas(param:Object):ICommentCanvas
		{
			bilibili::extend(param, bilibili::_defaultConfig);
			
			var cc:CommentCanvas = new CommentCanvas();
			cc.initStyle(param);
			
			bilibili::setupMotionElement(param, cc);
			return cc;
		}
		public function createButton(param:Object):ICommentButton
		{
			bilibili::extend(param, bilibili::_defaultConfig);
			bilibili::extend(param, {
				text: 'Button'
				,width: 60
				,height: 30
			});
			
			var cb:CommentButton = new CommentButton;
			cb.initStyle(param);
			cb.text = param.text;
			if(param.onclick)
				cb.addEventListener(MouseEvent.CLICK,
					function(event:MouseEvent):void
					{
						param.onclick();
					});
			
			bilibili::setupMotionElement(param, cb);
			return cb;
		}
		
		//bilibili function extend(param:Object, param1:Object):void
		//{
			//// TODO Auto Generated method stub			
		//}
		
		public function createGlowFilter(color:uint=0xFF0000, alpha:Number=1.0, blurX:Number=6.0, blurY:Number=6.0, strength:Number=2, quality:int=1, inner:Boolean=false, knockout:Boolean=false):GlowFilter
		{
			return new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}
		
		public function createBlurFilter(x:Number=0, y:Number=0, num:uint=1):BlurFilter
		{
			return new BlurFilter(x, y, num);
		}
		
		/**
		 * 通用的设置可配置的移动图形
		 * @param config 总配置
		 * @param elm 可配置的移动图形
		 **/
		bilibili function setupMotionElement(config:Object, elm:IMotionElement):void
		{
			/**
			 * 专门为外部脚本库编写的代码
			 * 当脚本库要成为可以移动的元素,但是不想在脚本库中编译进整个betweenas3时,
			 * 则将其motionManager属性的setter放到bilibili命名空间下,然后在bilibili命名空间下调用
			 * setupMotionElement来设置运动属性.其他的移除工作都将与脚本内置的移动元素相同.
			 * 还有初始配置化工作也必须要内部元素相同
			 **/
			if(elm.motionManager == null)
			{
				elm.bilibili::['motionManager'] = new MotionManager(elm as DisplayObject);
			}
			/** 设置开始的播放时间:用于检测回收判定 **/
			elm.motionManager.setPlayTime(ValueObjectManager.getMediaProvider.position * 1000);
			
			/** 默认的移动策略 **/
			if(config.motionGroup)
			{
				elm.motionManager.initTweenGroup(config.motionGroup, config.lifeTime);
			}
			else if(config.motion)
			{
				var motionConfig:Object = config.motion;
				
				if(isNaN(motionConfig.lifeTime))
					motionConfig.lifeTime = config.lifeTime;
				if(motionConfig.lifeTime < 0)
					motionConfig.lifeTime = 0.001;
				
				elm.motionManager.initTween(motionConfig);
			}
			/** 移动完成后的工作 **/
			function complete():void
			{
				if(elm['parent'])
					elm['parent'].removeChild(elm);
				/** 从特殊弹幕管理器上删除产生的cmtField **/
				_scriptManager.popEl(elm);
			};
			elm.motionManager.setCompleteListener(complete);
			/** 从特殊弹幕管理器上记录产生的cmtField **/
			_scriptManager.pushEl(elm);
		
			if(config.parent && config.parent.hasOwnProperty('addChild'))
				config.parent.addChild(elm);
			else
				_layer.addChild(elm as DisplayObject);
			
			/** 元件暂停与播放受到播放器状态的影响 **/
			if(ValueObjectManager.getMediaProvider.state == 'PLAYING')
				elm.motionManager.play();
			
		}
		
		/**
		 * 如果obj中没有定义相关属性,则从dft中拷贝默认的值
		 * @param obj 需要填装默认值的对象,就地改变
		 * @param dft 默认值
		 **/
		bilibili static function extend(obj:Object, dft:Object):void
		{
			for(var a:String in dft)
			{
				if(obj.hasOwnProperty(a))
					continue;
				
				obj[a] = dft[a];
			}
			
			if(dft.hasOwnProperty('motion') && obj['motion'] === null)
				obj.motion = {};
		}
		
		public function toIntVector(a:Array):Vector.<int>
		{
			return Vector.<int>(a);
		}
		
		public function toUIntVector(a:Array):Vector.<uint>
		{
			return Vector.<uint>(a);
		}
		
		public function toNumberVector(a:Array):Vector.<Number>
		{
			return Vector.<Number>(a);
		}
		
		public function createMatrix3D(a:*):Matrix3D
		{
			if(a is Vector.<Number>)
			{
				return new Matrix3D(a);
			}
			else
			{
				return new Matrix3D(Vector.<Number>(a));
			}
		}
		
		public function createColorTransform(redMultiplier:Number=1.0, greenMultiplier:Number=1.0, blueMultiplier:Number=1.0, alphaMultiplier:Number=1.0, redOffset:Number=0, greenOffset:Number=0, blueOffset:Number=0, alphaOffset:Number=0):ColorTransform
		{
			return new ColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
		}
		
		public function createTextFormat(font:String=null, size:Object=null, color:Object=null, bold:Object=null, italic:Object=null, underline:Object=null, url:String=null, target:String=null, align:String=null, leftMargin:Object=null, rightMargin:Object=null, indent:Object=null, leading:Object=null):TextFormat
		{
			return new TextFormat(font, size, color, bold, italic, underline, url, target, align, leftMargin, rightMargin, indent, leading);
		}
		
		public function createVector3D(x:Number=0.0, y:Number=0.0, z:Number=0.0, w:Number=0.0):Vector3D
		{
			return new Vector3D(x, y, z, w);
		}
		
		public function createTextField():TextField
		{
			return new CommentField();
		}
		
		public function createBevelFilter(distance:Number=4.0, angle:Number=45, highlightColor:uint=0xFFFFFF, highlightAlpha:Number=1.0, shadowColor:uint=0x000000, shadowAlpha:Number=1.0, blurX:Number=4.0, blurY:Number=4.0, strength:Number=1, quality:int=1, type:String="inner", knockout:Boolean=false):*
		{
			return new BevelFilter(distance, angle, highlightColor, highlightAlpha, shadowColor, shadowAlpha, blurX, blurY, strength, quality, type, knockout);
		}
		
		public function createColorMatrixFilter(matrix:Array=null):*
		{
			return new ColorMatrixFilter(matrix);
		}
		
		public function createConvolutionFilter(matrixX:Number=0, matrixY:Number=0, matrix:Array=null, divisor:Number=1.0, bias:Number=0.0, preserveAlpha:Boolean=true, clamp:Boolean=true, color:uint=0, alpha:Number=0.0):*
		{
			return new ConvolutionFilter(matrixX, matrixY, matrix, divisor, bias, preserveAlpha, clamp, color, alpha);
		}
		
		public function createDisplacementMapFilter(mapBitmap:BitmapData=null, mapPoint:Point=null, componentX:uint=0, componentY:uint=0, scaleX:Number=0.0, scaleY:Number=0.0, mode:String="wrap", color:uint=0, alpha:Number=0.0):*
		{
			return new DisplacementMapFilter(mapBitmap, mapPoint, componentX, componentY, scaleX, scaleY, mode, color, alpha);
		}
		
		public function createDropShadowFilter(distance:Number=4.0, angle:Number=45, color:uint=0, alpha:Number=1.0, blurX:Number=4.0, blurY:Number=4.0, strength:Number=1.0, quality:int=1, inner:Boolean=false, knockout:Boolean=false, hideObject:Boolean=false):*
		{
			return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
		}
		
		public function createGradientBevelFilter(distance:Number=4.0, angle:Number=45, colors:Array=null, alphas:Array=null, ratios:Array=null, blurX:Number=4.0, blurY:Number=4.0, strength:Number=1, quality:int=1, type:String="inner", knockout:Boolean=false):*
		{
			return new GradientBevelFilter(distance, angle, colors, alphas, ratios, blurX, blurY, strength, quality, type, knockout);
		}
		
		public function createGradientGlowFilter(distance:Number=4.0, angle:Number=45, colors:Array=null, alphas:Array=null, ratios:Array=null, blurX:Number=4.0, blurY:Number=4.0, strength:Number=1, quality:int=1, type:String="inner", knockout:Boolean=false):*
		{
			return new GradientGlowFilter(distance, angle, colors, alphas, ratios, blurX, blurY, strength, quality, type, knockout);
		}
		
		public function get frameRate():Number
		{
			return _layer.stage.frameRate;
		}
		
		public function set frameRate(value:Number):void
		{
			if(value > 0 && value < 120)
			{
				_layer.stage.frameRate = value;
			}
		}
		
		public function pointTowards(percent:Number, mat:Matrix3D, pos:Vector3D, at:Vector3D=null, up:Vector3D=null):Matrix3D
		{
			return Utils3D.pointTowards(percent, mat, pos, at, up);
		}
		
		public function projectVector(m:Matrix3D, v:Vector3D):Vector3D
		{
			return Utils3D.projectVector(m, v);
		}
		
		public function projectVectors(m:Matrix3D, verts:Vector.<Number>, projectedVerts:Vector.<Number>, uvts:Vector.<Number>):void
		{
			return Utils3D.projectVectors(m, verts, projectedVerts, uvts);
		}
	}
}