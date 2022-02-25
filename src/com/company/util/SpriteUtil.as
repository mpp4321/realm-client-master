package com.company.util
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import mx.effects.Tween;

import starling.core.Starling;

public class SpriteUtil
   {
       
      
      public function SpriteUtil()
      {
         super();
      }

      public static function createFadeoutSprite(parent, bitMap: BitmapData, x_offset: Number, y_offset: Number, scale: Number) : void
      {
         var sprite = new Sprite();
         var g = sprite.graphics;

         sprite.y += x_offset;
         sprite.x += y_offset;
         sprite.scaleX = scale;
         sprite.scaleY = scale;

         g.beginBitmapFill(bitMap, null, false);
         g.drawRect(0, 0, bitMap.width, bitMap.height);
         g.endFill();

         function onEndTweenHelper(value) {
            sprite.parent.removeChild(sprite);
         }

         function onUpdateTweenHelper(value) {
            sprite.alpha = value;
         }

         parent.addChild(sprite);

         var t = new Tween(sprite, 1.0, 0.0, 5000, -1, onUpdateTweenHelper, onEndTweenHelper);
         t.resume();
      }
      
      public static function safeAddChild(sprite:DisplayObjectContainer, displayObject:DisplayObject) : void
      {
         if(sprite != null && displayObject != null && !sprite.contains(displayObject))
         {
            sprite.addChild(displayObject);
         }
      }
      
      public static function safeRemoveChild(sprite:DisplayObjectContainer, displayObject:DisplayObject) : void
      {
         if(sprite != null && displayObject != null && sprite.contains(displayObject))
         {
            sprite.removeChild(displayObject);
         }
      }
   }
}
