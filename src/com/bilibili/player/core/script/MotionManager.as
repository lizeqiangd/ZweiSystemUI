package com.bilibili.player.core.script
{
	import com.bilibili.player.core.script.interfaces.IMotionManager;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.libspark.betweenas3.*;
	import org.libspark.betweenas3.core.easing.IEasing;
	import org.libspark.betweenas3.easing.*;
	import org.libspark.betweenas3.events.TweenEvent;
	import org.libspark.betweenas3.tweens.ITween;
	import org.libspark.betweenas3.tweens.ITweenGroup;
	
	//import tv.bilibili.script.interfaces.IMotionManager;
	
	public class MotionManager implements IMotionManager
	{
		private const acceptValue:Array = ["x","y","alpha","rotationZ","rotationY","rotationX","fontsize"];
		private var _$tmv:ITweenGroup;
		private var _$tmr:Timer = null;
		private var _$MotionConfig:Object = new Object;
		private var _$CompleteCallBack:Function=null;
		private var _$target:DisplayObject;
		private var optimizedGroup:Array = [];
		
		private var isRelative:Boolean = false;
		private var motionComplete: Boolean = false;
		
		private var motionPlayTime:uint = 0;
		
		private var _$internalTimer:uint = 0;
		private var _$internalRun:uint = 0;
		private var _$running:Boolean = false;
		
		private var uniqid:uint = getTimer()*10+Math.floor(Math.random()*10);
		
		public function MotionManager(target:DisplayObject)
		{
			_$target = target;
		}

		public function get running():Boolean
		{
			return _$running;
		}
		
		private function onEnterFrame(...rest):void
		{
			if (_$internalRun + getTimer() - _$internalTimer > _$MotionConfig.lifeTime*1000)
			{
				//EventBus.getInstance().log("onent "+uniqid+"@: "+(_$internalRun + getTimer() - _$internalTimer));
				_$target.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				stop();
				if (_$CompleteCallBack!=null) 
					_$CompleteCallBack(null);
			}
		}
		
		public function reset():void
		{
			stop();
			_$tmv.gotoAndStop(0);
			motionComplete = false;
		}
		
		public function play():void
		{
			if (_$running) return;
			if (isRelative)
			{
				updateTween();
			}
//			ExternalInterface.call("_debugPlayer","MotionManager["+uniqid+"]::play()");
			//if (_$tmr!=null) _$tmr.start();
			if (!_$running && _$MotionConfig.lifeTime > 0)
			{
				_$internalTimer = getTimer();
				_$target.addEventListener(Event.ENTER_FRAME,onEnterFrame);
				//EventBus.getInstance().log("add listner "+uniqid+"@: "+(_$internalRun + getTimer() - _$internalTimer));
			}
			_$running = true;
			if (!motionComplete && _$tmv) _$tmv.play();
		}
		
		public function stop():void 
		{
			if (!_$running) return;
//			ExternalInterface.call("_debugPlayer","MotionManager["+uniqid+"]::stop()");
			//if (_$tmr!=null) _$tmr.stop();
			if(_$tmv) _$tmv.stop();
			if (_$running)
			{
				if (_$MotionConfig.lifeTime > 0){
					_$internalRun+=getTimer()-_$internalTimer;
					_$target.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
				}
				//EventBus.getInstance().log("remove "+uniqid+"@"+(_$internalRun + getTimer() - _$internalTimer));
				_$running = false;
			}
		}
				
		/**
		 * time: ms
		 * 
		 */
		public function forcasting(time:Number):Boolean
		{
			if (_$MotionConfig.lifeTime == 0 && time > motionPlayTime){
				return true;				
			}else if (_$MotionConfig.lifeTime == 0)
			{
				return false;
			}
			if (time > motionPlayTime && time < motionPlayTime+_$MotionConfig.lifeTime*1000)
			{
				return true;
			}else
			{
				return false;
			}
		}
		
		/**
		 * time: ms
		 * 
		 */
		public function setPlayTime(time:Number):void
		{
			motionPlayTime = time;
		}
		
		private function updateTween():void
		{
			var tmvList:Array = [];
			var serials:Array = [];
			for each (var optimizedGroupItem:Array in optimizedGroup)
			{
				for each (var cfg_grp:Object in optimizedGroupItem)
				{
					var tmv:ITween;
					var fromValue:Object = [];
					var toValue:Object = [];
					var lifeTime:Number = 0;
					var startDelay:Number;
					var repeat:Number = 1;
					var s_easing:String = "Sine";
					var t_easing:IEasing;
					for each (var cfg:Object in cfg_grp)
					{
						if (!lifeTime)
						{
							lifeTime = cfg.lifeTime;
							startDelay = cfg.startDelay;
							s_easing = cfg.easing;
							repeat = cfg.repeat;
						}
						if (isRelative)
						{
							if (cfg.key == "x")
							{
								if (cfg.fromValue > 0 && cfg.fromValue < 1) cfg.fromValue = _$target.parent.width * cfg.fromValue;
								if (cfg.toValue > 0 && cfg.toValue < 1) cfg.toValue = _$target.parent.width * cfg.toValue;
							}else if (cfg.key == "y")
							{
								if (cfg.fromValue > 0 && cfg.fromValue < 1) cfg.fromValue = _$target.parent.width * cfg.fromValue;
								if (cfg.toValue > 0 && cfg.toValue < 1) cfg.toValue = _$target.parent.width * cfg.toValue;
							}
						}
						fromValue[cfg.key] = cfg.fromValue;
						toValue[cfg.key] = cfg.toValue;
					}
					//EventBus.getInstance().log(startDelay.toString());				
					switch(s_easing)
					{
						case "None": t_easing=null; break;
						case "Back": t_easing = org.libspark.betweenas3.easing.Back.easeInOut; break;
						case "Bounce": t_easing = org.libspark.betweenas3.easing.Bounce.easeInOut; break;
						case "Circular": t_easing = org.libspark.betweenas3.easing.Circular.easeInOut; break;
						case "Cubic": t_easing = org.libspark.betweenas3.easing.Cubic.easeInOut; break;
						case "Elastic": t_easing = org.libspark.betweenas3.easing.Elastic.easeInOut; break;
						case "Exponential": t_easing = org.libspark.betweenas3.easing.Exponential.easeInOut; break;
						case "Sine": t_easing = org.libspark.betweenas3.easing.Sine.easeInOut; break;
						case "Quintic": t_easing = org.libspark.betweenas3.easing.Quintic.easeInOut; break;
						case "Linear": t_easing = org.libspark.betweenas3.easing.Linear.easeInOut; break;
						default: t_easing = org.libspark.betweenas3.easing.Sine.easeInOut; 
					}
					tmv = BetweenAS3.tween(_$target,toValue,fromValue,lifeTime,t_easing);
					if (startDelay)
					{
						
						tmv = BetweenAS3.delay(tmv, startDelay/1000);
					}
					if (repeat > 1)
					{
						tmv = BetweenAS3.repeat(tmv, repeat);
					}
					
					var tmv_f:Function = function():void{
						motionComplete=true;
						tmv.removeEventListener(TweenEvent.COMPLETE,tmv_f); 
					}
					tmv.addEventListener(TweenEvent.COMPLETE,tmv_f);
					tmvList.push(tmv);
				}
				serials.push(BetweenAS3.parallelTweens(tmvList));
			}
			if (serials.length == 1)
			{
				this._$tmv = serials.pop();
			}else
			{
				this._$tmv = BetweenAS3.serialTweens(tmvList);
			}
		}
		public function initTween(MotionConfig:Object,motionGroup:Boolean=false):String
		{
			if (!motionGroup)
			{
				optimizedGroup.length = 0;
			}
			var mKey:int = optimizedGroup.length;
			optimizedGroup[mKey] = [];
			isRelative = false;
			if (MotionConfig.lifeTime == undefined) MotionConfig.lifeTime = 3;
			for each (var key:String in acceptValue)
			{
				if (MotionConfig[key]!=undefined)
				{
					if (!MotionConfig[key].lifeTime) MotionConfig[key].lifeTime = MotionConfig.lifeTime;
					if (MotionConfig[key].startDelay == undefined || MotionConfig[key].startDelay <= 0) MotionConfig[key].startDelay = 0;
					//if (MotionConfig[key].startDelay > MotionConfig.lifeTime) return "Motion "+key+" error: startDelay > lifeTime";
					if (MotionConfig[key].toValue == undefined){
						if (MotionConfig[key].fromValue==undefined)
						{
							return "Motion "+key+" error: no transform";
						}else
						{
							MotionConfig[key].toValue = MotionConfig[key].fromValue;
						}
					}
					if (MotionConfig[key].easing == undefined) MotionConfig[key].easing = "Linear";
					if (MotionConfig[key].repeat == undefined) MotionConfig[key].repeat = 1 ;
					var subKey:String = MotionConfig[key].lifeTime.toString()+","+MotionConfig[key].startDelay.toString()+","+MotionConfig[key].easing+","+MotionConfig[key].repeat;
					/*MotionConfig[key].lifeTime = Number(MotionConfig[key].lifeTime);
					if (isNaN(MotionConfig[key].lifeTime)) return "Motion "+key+" error:lifeTime Number error";
					MotionConfig[key].startDelay = Number(MotionConfig[key].startDelay);
					if (isNaN(MotionConfig[key].startDelay)) return "Motion "+key+" error: startDelay Number error";
					MotionConfig[key].fromValue = Number(MotionConfig[key].fromValue);
					if (isNaN(MotionConfig[key].fromValue)) return "Motion "+key+" error: fromValue Number error";
					MotionConfig[key].toValue = Number(MotionConfig[key].toValue);
					if (isNaN(MotionConfig[key].toValue)) return "Motion "+key+" error: toValue Number error "+MotionConfig[key].toValue;
					*/
					if (key == "x")
					{
						if (MotionConfig[key].fromValue > 0 && MotionConfig[key].fromValue < 1) isRelative = true;
						else if (MotionConfig[key].toValue > 0 && MotionConfig[key].toValue < 1) isRelative = true;
					}else if (key == "y")
					{
						if (MotionConfig[key].fromValue > 0 && MotionConfig[key].fromValue < 1) isRelative = true;
						else if (MotionConfig[key].toValue > 0 && MotionConfig[key].toValue < 1) isRelative = true;
					}
					MotionConfig[key].key = key;
					if (optimizedGroup[mKey][subKey] == undefined) optimizedGroup[mKey][subKey]=[];
					optimizedGroup[mKey][subKey].push(MotionConfig[key]);
				}
			}
			if (MotionConfig.lifeTime > 0 && !motionGroup)
			{
			 	_$tmr = new Timer(MotionConfig.lifeTime*1000,1);
			 	_$tmr.stop();
			 	var tmr_f:Function=function(eve:TimerEvent):void{
			 		_$tmr.removeEventListener(TimerEvent.TIMER_COMPLETE,tmr_f);
			 		_$tmr.stop();
			 		_$tmv.stop();
			 		if (_$CompleteCallBack!=null) 
						_$CompleteCallBack(eve);
			 	}
			 	_$tmr.addEventListener(TimerEvent.TIMER_COMPLETE,tmr_f);
				
			 }else if (!motionGroup)
			 {
			 	_$tmr = null;
			 }
			this._$MotionConfig = MotionConfig;
			if (!isRelative) updateTween();
			return "";
		}
		public function initTweenGroup(MotionConfigs:Array,lifeTime:Number=NaN):void
		{
			optimizedGroup.length = 0;
			for each(var MotionConfig:Object in MotionConfigs)
			{
				if (!isNaN(lifeTime)) MotionConfig.lifeTime = lifeTime;
				var res:String = this.initTween(MotionConfig,true);
				if (res)
				{
					throw new Error(res);
					return;
				}
			}
		}
		
		public function setCompleteListener(tmr_f:Function):void
		{
			_$CompleteCallBack = tmr_f;			
		}
	}
}