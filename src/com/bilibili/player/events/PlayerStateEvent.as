package com.bilibili.player.events
{
	import flash.events.Event;
	
	/**
	 * The PlayerEvent.JWPLAYER_PLAYER_STATE constant defines the value of the
	 * <code>type</code> property of the event object
	 * for a <code>jwplayerPlayerState</code> event.
	 *
	 * <table class="innertable">
	 *		<tr><th>Property</th><th>Value</th></tr>
	 *		<tr><td><code>id</code></td><td>ID of the player in the HTML DOM. Used by javascript to reference the player.</td></tr>
	 *		<tr><td><code>client</code></td><td>A string representing the client the player runs in (e.g. FLASH WIN 9,0,115,0).</td></tr>
	 * 		<tr><td><code>version</code></td><td>A string representing the major version, minor version and revision number of the player (e.g. 5.0.395).</td></tr>
	 * 		<tr><td><code>newstate</code></td><td>The new state of the player</td></tr>
	 * 		<tr><td><code>oldstate</code></td><td>The previous state of the player</td></tr>
	 * </table>
	 * editor:Lizeqiangd
	 * 20141031 脱离JWPlayer 准备进一步脱离化
	 * 20141105 加入PlayerState静态变量
	 */
	public class PlayerStateEvent extends PlayerEvent
	{
		public static const IDLE:String = "IDLE";
		/** Buffering; will start to play when the buffer is full. **/
		public static const BUFFERING:String = "BUFFERING";
		/** The file is being played back. **/
		public static const PLAYING:String = "PLAYING";
		/** Playback is paused. **/
		public static const PAUSED:String = "PAUSED";
		/*
		 *
		 * @see com.longtailvideo.jwplayer.player.PlayerState
		 * @eventType PlayerState
		 */
		public static var PLAYER_STATE:String = "PlayerState";
		
		public var newstate:String = "";
		public var oldstate:String = "";
		
		public function PlayerStateEvent(type:String, newState:String, oldState:String)
		{
			super(type);
			this.newstate = newState;
			this.oldstate = oldState;
		}
		
		public override function clone():Event
		{
			return new PlayerStateEvent(this.type, this.newstate, this.oldstate);
		}
		
		public override function toString():String
		{
			return '[PlayerStateEvent type="' + type + '"' + ' oldstate="' + oldstate + '"' + ' newstate="' + newstate + '"' + ' id="' + id + '"' + ' client="' + client + '"' + ' version="' + version + '"' + ' message="' + message + '"' + "]";
		}
	}
}