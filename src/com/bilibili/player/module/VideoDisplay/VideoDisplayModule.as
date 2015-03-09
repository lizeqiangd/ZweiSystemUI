package com.bilibili.player.module.VideoDisplay
{
	import com.bilibili.player.abstract.module.BaseModule;
	import com.bilibili.player.abstract.module.iModule;
	import com.bilibili.player.applications.VideoControlBar.Standard.StandardVideoControlBar;
	import com.bilibili.player.components.encode.ResizeObject;
	import com.bilibili.player.core.comments.CommentDisplayer;
	import com.bilibili.player.core.script.NoParentSprite;
	import flash.display.Sprite;
	import flash.events.StageVideoEvent;
	import flash.geom.Rectangle;
	//import com.bilibili.player.core.comments.CommentDisplayer;
	import com.bilibili.player.events.MediaEvent;
	import com.bilibili.player.events.PlayerControlEvent;
	import com.bilibili.player.events.PlayerStateEvent;
	import com.bilibili.player.manager.ModuleManager;
	import com.bilibili.player.manager.ValueObjectManager;
	import com.bilibili.player.net.media.MediaProvider;
	import com.bilibili.player.system.proxy.StageProxy;
	import com.bilibili.player.valueobjects.media.PlaylistItem;
	
	import flash.media.StageVideo;
	import flash.media.Video;
	
	/**
	 * 视频显示和弹幕显示层.播放器核心模块
	 * 同时可能会打开Flash的硬件加速功能.
	 *
	 * 显示包含逻辑:
	 * [理论上的黑底层]
	 * stageVideo(video)[Video]
	 * CommentLayer
	 * ScripeCommentLayer
	 * VideoControlBar
	 * 全屏事件在这里接收并重新显示大小和显示逻辑
	 * @author Lizeqiangd
	 * update
	 * 20150106 再次审核代码的逻辑性.
	 */
	public class VideoDisplayModule extends BaseModule implements /*iVideoDisplay,*/iModule
	{
		/**
		 * 视频实例
		 */
		private var video:Video
		
		/**
		 * 硬件加速视频实例
		 */
		private var stageVideo:StageVideo
		
		/**
		 * 应用:视频控制条
		 */
		private var vcb:StandardVideoControlBar
		
		/**
		 * 媒体提供者.用于实际操作视频的播放等功能.
		 */
		private var mp:MediaProvider
		
		/**
		 * 弹幕层
		 */
		private var cl:Sprite
		private var scl:NoParentSprite
		/**
		 * 应用:弹幕显示
		 */
		private var cd:CommentDisplayer
		
		/**
		 * 其他flag
		 */
		private var isStageVideoAvailable:Boolean = false
		private var isStageVideoEnabled:Boolean = true
		private var isStageVideoUsing:Boolean = false
		
		//debug
		private var logTimeEvent_Playing:Boolean = false
		
		public function VideoDisplayModule()
		{
			setModuleName = "VideoDisplay"
			vcb = new StandardVideoControlBar
			video = new Video()
			video.smoothing = true
			if (StageProxy.stage.stageVideos.length)
			{
				isStageVideoAvailable = true
				stageVideo = StageProxy.stage.stageVideos[0]
			}
			mp = ValueObjectManager.getMediaProvider
		}
		
		public function init():void
		{
			mp.initializeMediaProvider()
			//显示视频地方应该在这里处理stagevideo模式			
			if (isStageVideoEnabled && isStageVideoAvailable)
			{
				//ValueObjectManager.getTimeLogCollector.setTimeLogEnd("stagevideo on")
				mp.setVideoRender = stageVideo
				stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, onStageVideoRender)
				isStageVideoUsing = true
			}
			else
			{
				isStageVideoUsing = false
				mp.setVideoRender = video
				ModuleManager.addToLayer(video, "background")
			}
			initCommentDisplay()
			ModuleManager.addToLayer(cl, "background")
			ModuleManager.addToLayer(scl, "background")
			ModuleManager.addToLayer(vcb, "application")
			
			addUiListener()
			vcb.setPlayButtonState(false) //默认是显示播放按钮
			//vcb.setVolume(100,true)			
			onStageResize()
		}
		
		/**
		 *添加本类所有侦听
		 */
		public function addUiListener():void
		{
			StageProxy.addResizeFunction(onStageResize)
			mp.addEventListener(MediaEvent.MEDIA_BUFFER, onMediaProviderMediaEventHandle)
			mp.addEventListener(MediaEvent.MEDIA_BUFFER_FULL, onMediaProviderMediaEventHandle)
			mp.addEventListener(MediaEvent.MEDIA_COMPLETE, onMediaProviderMediaEventHandle)
			mp.addEventListener(MediaEvent.MEDIA_ERROR, onMediaProviderMediaEventHandle)
			mp.addEventListener(MediaEvent.MEDIA_LOADED, onMediaProviderMediaEventHandle)
			mp.addEventListener(MediaEvent.MEDIA_META, onMediaProviderMediaEventHandle)
			mp.addEventListener(MediaEvent.MEDIA_SEEK, onMediaProviderMediaEventHandle)
			mp.addEventListener(MediaEvent.MEDIA_RESIZE, onMediaProviderMediaEventHandle)
			mp.addEventListener(MediaEvent.MEDIA_TIME, onMediaProviderMediaEventHandle)
			mp.addEventListener(MediaEvent.MEDIA_VOLUME, onMediaProviderMediaEventHandle)
			mp.addEventListener(PlayerStateEvent.PLAYER_STATE, onMediaProviderPlayerStateEvent)
			vcb.addUiListener()
		}
		
		/**
		 * 移除本类所有侦听
		 */
		public function removeUiListener():void
		{
			StageProxy.removeResizeFunction(onStageResize)
			mp.removeEventListener(MediaEvent.MEDIA_BUFFER, onMediaProviderMediaEventHandle)
			mp.removeEventListener(MediaEvent.MEDIA_BUFFER_FULL, onMediaProviderMediaEventHandle)
			mp.removeEventListener(MediaEvent.MEDIA_COMPLETE, onMediaProviderMediaEventHandle)
			mp.removeEventListener(MediaEvent.MEDIA_ERROR, onMediaProviderMediaEventHandle)
			mp.removeEventListener(MediaEvent.MEDIA_LOADED, onMediaProviderMediaEventHandle)
			mp.removeEventListener(MediaEvent.MEDIA_META, onMediaProviderMediaEventHandle)
			mp.removeEventListener(MediaEvent.MEDIA_SEEK, onMediaProviderMediaEventHandle)
			mp.removeEventListener(MediaEvent.MEDIA_RESIZE, onMediaProviderMediaEventHandle)
			mp.removeEventListener(MediaEvent.MEDIA_TIME, onMediaProviderMediaEventHandle)
			mp.removeEventListener(MediaEvent.MEDIA_VOLUME, onMediaProviderMediaEventHandle)
			mp.removeEventListener(PlayerStateEvent.PLAYER_STATE, onMediaProviderPlayerStateEvent)
			vcb.removeUiListener()
		}
		
		/**
		 * 添加对控制条的侦听
		 */
		private function addVCBEventListener():void
		{
			vcb.addEventListener(PlayerControlEvent.SEEK, onPlayerControlEventHandle)
			vcb.addEventListener(PlayerControlEvent.PLAY, onPlayerControlEventHandle)
			vcb.addEventListener(PlayerControlEvent.PAUSE, onPlayerControlEventHandle)
			//vcb.addEventListener(PlayerControlEvent.MUTE, onPlayerControlEventHandle)
			vcb.addEventListener(PlayerControlEvent.VOLUME, onPlayerControlEventHandle)
			vcb.addEventListener(PlayerControlEvent.REPEAT, onPlayerControlEventHandle)
			vcb.addEventListener(PlayerControlEvent.HIDE_COMMENT, onPlayerControlEventHandle)
		}
		
		/**
		 * 移除对控制条的侦听
		 */
		private function removeVCBEventListener():void
		{
			vcb.removeEventListener(PlayerControlEvent.SEEK, onPlayerControlEventHandle)
			vcb.removeEventListener(PlayerControlEvent.PLAY, onPlayerControlEventHandle)
			vcb.removeEventListener(PlayerControlEvent.PAUSE, onPlayerControlEventHandle)
			//vcb.addEventListener(PlayerControlEvent.MUTE, onPlayerControlEventHandle)
			vcb.removeEventListener(PlayerControlEvent.VOLUME, onPlayerControlEventHandle)
			vcb.removeEventListener(PlayerControlEvent.REPEAT, onPlayerControlEventHandle)
			vcb.removeEventListener(PlayerControlEvent.HIDE_COMMENT, onPlayerControlEventHandle)
		}
		
		/**
		 * StageVideo显示大小获取会异步,因此在这里设置.
		 */
		private function onStageVideoRender(e:StageVideoEvent):void
		{
			//trace("VideoDisplaModule.onStageVideoRender.status:", e.status)
			stageVideo.viewPort = new Rectangle(0, 0, stageVideo.videoWidth, stageVideo.videoHeight)
		}
		
		/**
		 * 在这里放置弹幕播放器
		 */
		private function initCommentDisplay():void
		{
			scl = new NoParentSprite
			cl = new Sprite
			cd = ValueObjectManager.getCommentDisplayer
			cd.init(cl, scl)
			scl.x = 0
			cl.x = 0
		}
		
		/**
		 * 视频控制条 功能逻辑控制转发
		 */
		private function onPlayerControlEventHandle(e:PlayerControlEvent):void
		{
			switch (e.type)
			{
				case PlayerControlEvent.SEEK: 
					//直接通知mediaprovider进行跳转.
					mp.seek(e.data)
					break;
				case PlayerControlEvent.PLAY: 
					//播放冲突交给mp处理
					mp.play()
					break;
				case PlayerControlEvent.PAUSE: 
					//暂停冲突交给mp处理
					mp.pause();
					break;
				case PlayerControlEvent.VOLUME: 
					//静音处理也在这里进行.
					mp.setVolume(e.data)
					break;
				case PlayerControlEvent.HIDE_COMMENT: 
					//隐藏弹幕按钮.
					cd.clearComments()
					scl.visible=e.data
					cl.visible = e.data
					break
				case PlayerControlEvent.REPEAT: 
					mp.repeat = e.data;
					break
				default: 
			}
		}
		
		private function onMediaProviderMediaEventHandle(e:MediaEvent):void
		{
			switch (e.type)
			{
				case MediaEvent.MEDIA_TIME: 
					vcb.setVideoPlayTime(e.position, 0, e.duration)
					if (e.position > 0 && !logTimeEvent_Playing)
					{
						logTimeEvent_Playing = true
						ValueObjectManager.getTimeLogCollector.setTimeLogEnd("loadvideo")
					}
					break;
				case MediaEvent.MEDIA_COMPLETE: 
					vcb.setVideoPlayTime(0.001, 0, 0)
					//trace(0.1,0,0)
					break;
				case MediaEvent.MEDIA_BUFFER: 
					vcb.setVideoPlayTime(0, e.buffer, e.duration)
					break;
				case MediaEvent.MEDIA_LOADED: 
					addVCBEventListener()
					ValueObjectManager.getTimeLogCollector.createTimeLog("loadvideo", "缓存视频中")
					break;
				case MediaEvent.MEDIA_VOLUME: 
					//被动控制
					break;
				case MediaEvent.MEDIA_RESIZE: 
					onStageResize()
					break;
				case MediaEvent.MEDIA_ERROR: 
					trace("MediaProviderError:", e.message)
					break
				case MediaEvent.MEDIA_META: 
					ValueObjectManager.getTimeLogCollector.setTimeLogEnd("loadvideo")
					break
				case MediaEvent.MEDIA_SEEK: 
					//ValueObjectManager.getTimeLogCollector.setTimeLogEnd("loadvideo")
					break
				default: 
				trace("VideoDisplayModule.onMediaProviderMediaEventHandle:uncatch event:", e.type)
			}
		}
		
		private function onMediaProviderPlayerStateEvent(e:PlayerStateEvent):void
		{
			switch (e.newstate)
			{
				case PlayerStateEvent.PAUSED: 
					vcb.setPlayButtonState(false)
					break;
				case PlayerStateEvent.PLAYING: 
					vcb.setPlayButtonState(true)
					break;
				case PlayerStateEvent.BUFFERING: 
					vcb.setPlayButtonState(false)
					break;
				case PlayerStateEvent.IDLE: 
					vcb.setPlayButtonState(false)
					break;
				default: 
			}
		}
		
		/**
		 * 自适应功能
		 */
		private function onStageResize():void
		{
			if (isStageVideoUsing)
			{
				if (stageVideo.videoWidth)
				{
					var newRect:Rectangle = new Rectangle()
					ResizeObject.resizeInside(newRect, stageVideo.videoWidth, stageVideo.videoHeight, StageProxy.stageWidth, StageProxy.stageHeight - 50)
					newRect.x = StageProxy.stageWidth / 2 - newRect.width / 2
					newRect.y = StageProxy.stageHeight / 2 - 25 - newRect.height / 2
					stageVideo.viewPort = newRect
				}
			}
			else
			{
				ResizeObject.resizeInside(video, video.videoWidth, video.videoHeight, StageProxy.stageWidth, StageProxy.stageHeight - 50)
				video.x = StageProxy.stageWidth / 2 - video.width / 2
				video.y = StageProxy.stageHeight / 2 - 25 - video.height / 2
			}
			
			vcb.y = StageProxy.stageHeight - 50
			ValueObjectManager.getCommentDisplayer.resize(StageProxy.stageWidth, StageProxy.stageHeight - 50)
			//vcb.configWidth(StageProxy.stageWidth)
			vcb.configWidth(StageProxy.stageWidth)
		}
		
		/**
		 * 设置音量大小
		 */
		public function setVolume(value:Number):void
		{
			vcb.setVolume(value)
		}
	}
}