package com.adobe.images
{
   import flash.utils.ByteArray;
   import flash.display.BitmapData;
   import flash.geom.*;
   
   public class PNGEncoder extends Object
   {
      
      public function PNGEncoder() {
         super();
      }
      
      public static function encode(img:BitmapData) : ByteArray {
         var p:uint = 0;
         var j:* = 0;
         var png:ByteArray = new ByteArray();
         png.writeUnsignedInt(2.303741511E9);
         png.writeUnsignedInt(218765834);
         var IHDR:ByteArray = new ByteArray();
         IHDR.writeInt(img.width);
         IHDR.writeInt(img.height);
         IHDR.writeUnsignedInt(134610944);
         IHDR.writeByte(0);
         writeChunk(png,1229472850,IHDR);
         var IDAT:ByteArray = new ByteArray();
         var i:int = 0;
         while(i < img.height)
         {
            IDAT.writeByte(0);
            if(!img.transparent)
            {
               j = 0;
               while(j < img.width)
               {
                  p = img.getPixel(j,i);
                  IDAT.writeUnsignedInt(uint((p & 16777215) << 8 | 255));
                  j++;
               }
            }
            else
            {
               j = 0;
               while(j < img.width)
               {
                  p = img.getPixel32(j,i);
                  IDAT.writeUnsignedInt(uint((p & 16777215) << 8 | p >>> 24));
                  j++;
               }
            }
            i++;
         }
         IDAT.compress();
         writeChunk(png,1229209940,IDAT);
         writeChunk(png,1229278788,null);
         return png;
      }
      
      private static var crcTable:Array;
      
      private static var crcTableComputed:Boolean = false;
      
      private static function writeChunk(png:ByteArray, type:uint, data:ByteArray) : void {
         var c:uint = 0;
         var n:uint = 0;
         var k:uint = 0;
         if(!crcTableComputed)
         {
            crcTableComputed = true;
            crcTable = [];
            n = 0;
            while(n < 256)
            {
               c = n;
               k = 0;
               while(k < 8)
               {
                  if(c & 1)
                  {
                     c = uint(uint(3.988292384E9) ^ uint(c >>> 1));
                  }
                  else
                  {
                     c = uint(c >>> 1);
                  }
                  k++;
               }
               crcTable[n] = c;
               n++;
            }
         }
         var len:uint = 0;
         if(data != null)
         {
            len = data.length;
         }
         png.writeUnsignedInt(len);
         var p:uint = png.position;
         png.writeUnsignedInt(type);
         if(data != null)
         {
            png.writeBytes(data);
         }
         var e:uint = png.position;
         png.position = p;
         c = 4.294967295E9;
         var i:int = 0;
         while(i < e - p)
         {
            c = uint(crcTable[(c ^ png.readUnsignedByte()) & uint(255)] ^ uint(c >>> 8));
            i++;
         }
         c = uint(c ^ uint(4.294967295E9));
         png.position = e;
         png.writeUnsignedInt(c);
      }
   }
}
