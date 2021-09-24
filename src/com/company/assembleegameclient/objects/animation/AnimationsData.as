package com.company.assembleegameclient.objects.animation
{
import com.company.assembleegameclient.objects.TextureData;

import flash.display3D.textures.Texture;

public class AnimationsData
   {
       
      
      public var animations:Vector.<AnimationData>;

      public function AnimationsData(xml:XML)
      {
         var animationXML:XML = null;
         this.animations = new Vector.<AnimationData>();
         super();
         for each(animationXML in xml.Animation)
         {
            this.animations.push(new AnimationData(animationXML));
         }
      }

      //Assumes period is split evenly by every frame and takes by time
      //Assumes also that there is only one animation in this set
      //Used for items currently
      public function getBySimpleDistrubution(simpleTime: int) : TextureData {
          var seconds: Number = simpleTime / 1000.0;
          var period = (animations[0].period_ / animations[0].frames.length) / 1000.0;
          var key = int(Math.floor(seconds / period)) % animations[0].frames.length;
          return animations[0].frames[key].textureData_;
      }
   }
}
