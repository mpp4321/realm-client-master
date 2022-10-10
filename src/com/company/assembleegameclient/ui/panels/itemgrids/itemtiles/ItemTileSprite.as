package com.company.assembleegameclient.ui.panels.itemgrids.itemtiles
{
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.animation.AnimationsData;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.EquipmentTile;
import com.company.assembleegameclient.ui.tooltip.EquipmentToolTip;
import com.company.assembleegameclient.util.ItemData;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
import com.company.ui.SimpleText;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.text.AntiAliasType;
import flash.text.TextFormat;

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

      public var tierText: SimpleText;
      public var enchantmentText: SimpleText;

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

      public function doEnchantmentText(texture: BitmapData) {
         if(enchantmentText) removeChild(enchantmentText);
         enchantmentText = null;
         if(!Parameters.data_.itemtiers || itemData == null || itemData.Meta == -1) return;
         var rank = ItemData.getRank(itemData);
         var greenpart = 0xFF00FF22 - ((rank-1) * 2 * 0x00001100);
         var redpart = 0xFF000022 + ((rank-1) * 2 * 0x00110000);

         this.enchantmentText = new SimpleText(12,greenpart | redpart,false, 0,0);
         this.enchantmentText.setBold(true);
         this.enchantmentText.y = -22;
         this.enchantmentText.text = "+" + rank;
         this.enchantmentText.updateMetrics();

         GlowRedrawer.GLOW_FILTER_OUTLINE.color = 0xFF000000;
         this.enchantmentText.filters = [ GlowRedrawer.GLOW_FILTER_OUTLINE ];

         //Think it centers by default so gotta subtract half its width
         this.enchantmentText.x = (this.width/2) - (3*enchantmentText.actualWidth_ / 2);
         addChild(this.enchantmentText);
      }

      public function doTierText() {
         if(tierText) removeChild(tierText);
         tierText = null;
         if(!Parameters.data_.itemtiers) return;
         var eqXML = ObjectLibrary.xmlLibrary_[this.itemId];
         if(!eqXML) return;
         this.tierText = new SimpleText(12,16777215,false, 0,0);
         this.tierText.setBold(true);
         this.tierText.y = 4;
         if(eqXML.hasOwnProperty("Consumable") == false)
         {
            EquipmentToolTip.setTierColor(this.tierText, eqXML);
         } else {
            this.tierText.text = "C";
            this.tierText.setColor(0x22ff44);
         }

         GlowRedrawer.GLOW_FILTER_OUTLINE.color = 0xFF000000;
         this.tierText.filters = [ GlowRedrawer.GLOW_FILTER_OUTLINE ];

         this.tierText.updateMetrics();
         //Think it centers by default so gotta subtract half its width
         this.tierText.x = (this.width/2) - (3*tierText.actualWidth_ / 2) + 2;
         addChild(this.tierText);
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
         //Ratio 8 is because we are expecting 8x8 sprites so anything 16x16 needs to be displayed scaled down to 8x8
         texture = ObjectLibrary.getRedrawnTextureFromType(this.itemId,80,true, itemData == null ? -1 : itemData.Meta, true, 5, animation, 8);
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
         this.doTierText();
         this.doEnchantmentText(texture);
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
