package com.bilibili.player.core.comments
{
	import flash.net.Socket;
	import flash.utils.ByteArray;

	/**
	 * 实时消息解析
	 * bilibili socket 二进制数据解析
	 * @author Aristotle9
	 * 20141208 转移路径
	 **/
	public class IMDataParser
	{
		/**
		 * 当前状态
		 **/
		private var _parser_Index:int = 0;
		private var _parser_Length:int = 0;
		private var _parser_BufferLength:int = 0;
		/**
		 * 当前数据
		 **/
		private var _data:ByteArray;
		/**
		 * 解析出的命令执行接口宿主
		 **/
		private var _client:Object;
		
		public function IMDataParser(client:Object)
		{
			_data = new ByteArray();
			_client = client;
		}
		
		public function readSocketData(s:Socket):void
		{
			_parser_BufferLength += s.bytesAvailable;
			s.readBytes(_data, _data.length);
			packetParser();
		}
		
		protected function packetParser():void
		{
			if (_parser_BufferLength > 2)
			{
				if (_parser_BufferLength > 4096) //too many data, may be packet error! reset
				{
					//clear All buffer
					_data.readUTFBytes(_parser_BufferLength);
					_parser_Index = _parser_Length = _parser_BufferLength = 0;
					return;
				}
				if (_parser_Index == 0)
				{
					_parser_Index = _data.readShort();
					_parser_BufferLength-=2;
				}
				if (_parser_Length == 0)
				{
					_parser_Length = getPacketLength(_parser_Index);
					if (_parser_Length == -1)
					{
						//clear All buffer
						_data.readUTFBytes(_parser_BufferLength);
						_parser_Index = _parser_Length = _parser_BufferLength = 0;
						return;
					}
					if (_parser_Length==0)
					{
						if (_parser_BufferLength < 2) return;
						_parser_Length = _data.readShort()-2;
						_parser_BufferLength-=2;
					}
					
					_parser_Length-=2;
				}
				
				
				if (_parser_Length <= _parser_BufferLength)
				{
					switch (_parser_Index)
					{
						case 0x01:
							var _readInt:*=_data.readInt();
							_client.numGuanzhong = _readInt;
							_client.setStateInfo("弹幕服务器连接成功.");
							_client.externalCall("PlayerSetOnline", _readInt);
							break;
						case 0x02:
							//这是个弹幕
							_client.newCommentString(_data.readUTFBytes(_parser_Length));
							break;
						case 0x04:
							//PACKET_CHAT
							//PLAYER_COMMAND
							_client.playerCommand(_data.readUTFBytes(_parser_Length));
							break;
						case 0x05:
							//PACKET_BROADCAST
							_client.externalCall('playerBroadcast', _data.readUTFBytes(_parser_Length));
							break;
						case 0x06:
							//这是一条滚动消息
							_client.newScrollMessage(_data.readUTFBytes(_parser_Length));
							break;
						case 0x08:
							//更新评论
							var _i:int = _data.readShort();
							_client.externalCall("CallPlayerAction",_i);
							break;
						case 0x11:
							_client.externalCall("_playerDebug","Server Updated");
							return;
						default:	//skip another packet
							_data.readUTFBytes(_parser_Length);
					}
					_parser_BufferLength -= _parser_Length;
					_parser_Index = 0;
					_parser_Length = 0;
					if (_parser_BufferLength>0)
					{
						return packetParser();
					}
				}
			}
			//trace("IMDataParser")
		}
		
		/**
		 * 解码长度
		 **/
		protected function getPacketLength(index:*):int
		{
			switch (index)
			{
				case 0x00: return 0;
				case 0x01: return 6;
				case 0x02: 
				case 0x03: 
				case 0x04:
				case 0x05: 
				case 0x06: return 0;
				case 0x07: return 0;
				case 0x08: return 4;
				case 0x10: return 3;
				case 0x11: return 2;//PACKET_UPGRADE
				default: return -1;
			}
		}
	}
}