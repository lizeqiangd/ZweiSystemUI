package com.bilibili.player.system.config
{
	
	/**
	 * 全系统具体数值设定全部在这里
	 * @author lizeqiangd
	 */
	public class BPSetting
	{
		
		///***********时间类
		
		public static const AnimationTime_ButtonCommentSubmitTint:Number = 0 //.2
		
		public static const AnimationTime_ButtonCommentStyleSelectionTint:Number = 0 //.3
		
		public static const AnimationTime_ButtonCommentStylePanelTint:Number = 0 //.5
		
		public static const AnimationTime_ColorPickerDisplayTint:Number = 0 //.5
		
		public static const AnimationTime_ColorPickerCoreMovement:Number = 0 //.4
		
		public static const AnimationTime_StylePanelMovement:Number = 0.2
		
		public static const AnimationTime_DataGridRowBackGroundTint:Number = 0.2
		
		public static const AnimationTime_BlockListRowFunctionButtonFade:Number = 0.2 //0.5
		
		public static const DefaultAnimationTime_ButtonMouse:Number = 0 //0.1
		
		public static const DefaultTimer_onMouseDownToContinue:uint = 700
		
		public static const AnimationTme_VideoControlBarButtonTint:Number =0.5//播放器控制按钮变色时间
		///***********颜色类
		//public static const Color_CommentListTitleRowMouseDown:uint = 0xaacfff
		public static const Color_CommentListTitleRowMouseUp:uint = 0xe8e8e8
		
		public static const AnimationTint_DataGirdRowBackGroundOver:uint = 0xcce1ff
		public static const AnimationTint_DataGirdRowBackGroundDown:uint = 0xaacfff
		public static const AnimationTint_DataGirdRowBackGroundOut:uint = 0xffffff
		
		public static const AnimationTint_CommentSubmitButtonMouseDown:uint = 0x00A1D6
		public static const AnimationTint_CommentSubmitButtonMouseOver:uint = 0x32B4DE
		public static const AnimationTint_CommentSubmitButtonMouseUp:uint = 0x32B4DE
		public static const AnimationTint_CommentSubmitButtonMouseOut:uint = 0x00c2fb
		
		public static const BilibiliLightBlueUnit:uint = 0x00c2fb
		
		public static const BilibiliGray:uint = 0xa2a2a2
		
		public static const CommentSenderTextDisableColor:uint = 0x000000
		//默认鼠标按钮颜色
		public static const DefaultColor_ButtonMouseDown:uint = 0x333333
		public static const DefaultColor_ButtonMouseUp:uint = 0xffffff
		public static const DefaultColor_ButtonMouseOut:uint = 0xffffff
		public static const DefaultColor_ButtonMouseOver:uint = 0xcccccc
		
		///***********默认参数类
		public static const ScrollbarScrollSpeedDenominator:Number = 20
		public static const ScrollbarPointerMinimumHeight:Number = 20
		
		public static const StandardCommentStylePanelBackGroundAlpha:Number = 0.95
		
		public static const StandardDataGirdRowHeight:Number = 25
		
		///*************默认变量设置
		
		public static const ValueObject_DataGirdSelected:String = "dgr_comment_selected"
		
		public static const ValueObject_BlockListDelete:String = "dgr_block_delete"
		public static const ValueObject_BlockListActive:String = "dgr_block_active"
		
		///********全局类
		public static const PositionUtilityOffsetX:Number = 0
		public static const PositionUtilityOffsetY:Number = 0
		public static const AnimationManagerDefaultTime:Number = 0.5
		
		public static const AnimeWindowsDefaultOpeningAnimation:String = "scale_fade_in"
		public static const AnimeWindowsDefaultClosingAnimation:String = "fade_out"
		
		/** 播放器版本**/
		public static const PlayerVersion:String = "0.1"
		/** sharedObjectName **/
		public static const SharedObjectName:String = 'com.bilibili.player';
		/** 主站网站 **/
		public static const HOST:String = 'http://www.bilibili.com';
		
		/** 老的Acfun弹幕格式 **/
		public static const CommentFormat_OLDACFUN:String = "OldAcfun"
		/** Amf弹幕格式 **/
		public static const CommentFormat_AMFCMT:String = 'AMFCmt';
	}

}