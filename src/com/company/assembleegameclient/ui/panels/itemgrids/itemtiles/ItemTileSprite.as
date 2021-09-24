package com.company.assembleegameclient.ui.panels.itemgrids.itemtiles
{
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.animation.AnimationsData;
import com.company.ui.SimpleText;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;

import kabam.rotmg.assets.model.AnimationHelper;
import kabam.rotmg.constants.ItemConstants;

public class ItemTileSprite extends Sprite
   {
      
      protected static const DIM_FILTER:Array = [new ColorMatrixFilter([0.4,0,0,0,0,0,0.4,0,0,0,0,0,0.4,0,0,0,0,0,1,0])];
      
      private static const DOSE_MATRIX:Matrix = function():Matrix
      {
         var m:* = new Matrix();
         m.translate(10,5);
         return m;
      }();
       
      
      public var itemId:int;
      public var itemData:Object;
      public var itemBitmap:Bitmap;

      public var animation: AnimationHelper;

      public function ItemTileSprite()
      {
         super();
         this.itemBitmap = new Bitmap();
         addChild(this.itemBitmap);
         this.itemId = -1;
      }
      
      public function setDim(dim:Boolean) : void
      {
         filters = dim?DIM_FILTER:null;
      }

      public function doTextureThings() {
         if(itemId == ItemConstants.NO_ITEM) {
            if(animation != null)  {
               animation.destroy();
               animation = null;
            }
            visible = false;
            return;
         }
         var texture:BitmapData = null;
         var eqXML:XML = null;
         var tempText:SimpleText = null;
         texture = ObjectLibrary.getRedrawnTextureFromType(this.itemId,80,true, itemData == null ? -1 : itemData.Meta, true, 5, animation);
         eqXML = ObjectLibrary.xmlLibrary_[this.itemId];
         if(eqXML && eqXML.hasOwnProperty("Doses"))
         {
            texture = texture.clone();
            tempText = new SimpleText(12,16777215,false,0,0);
            tempText.text = String(eqXML.Doses);
            tempText.updateMetrics();
            texture.draw(tempText,DOSE_MATRIX);
         }
         this.itemBitmap.bitmapData = texture;
         this.itemBitmap.x = -texture.width / 2;
         this.itemBitmap.y = -texture.height / 2;
         visible = true;
      }

      public function setType(displayedItemType:int, displayedItemData : Object) : void
      {
         if(displayedItemData == itemId && displayedItemData == itemData) {
            doTextureThings();
            return;
         }
         this.itemId = displayedItemType;
         var animationData: AnimationsData = ObjectLibrary.typeToAnimationsData_[itemId];
          if(animationData != null) {
             animation = new AnimationHelper();
             animation.setFrames(animationData.animations[0].frames);
             animation.setSpeed(animationData.animations[0].period_ / animationData.animations[0].frames.length);
             animation.signal.add(doTextureThings);
          }
          else {
             if(animation != null)  {
                animation.destroy();
                animation = null;
             }
          }
         this.itemData = displayedItemData;
         if(this.itemId != ItemConstants.NO_ITEM)
         {
             doTextureThings();
         }
         else
         {
            visible = false;
         }
      }
   }
}
