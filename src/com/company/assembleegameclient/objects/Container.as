package com.company.assembleegameclient.objects
{
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Map;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.sound.SoundEffectLibrary;
import com.company.assembleegameclient.ui.panels.Panel;
import com.company.assembleegameclient.ui.panels.itemgrids.ContainerGrid;
import com.company.assembleegameclient.util.ItemData;
import com.company.util.PointUtil;

import flash.display.BitmapData;

public class Container extends GameObject implements IInteractiveObject
   {
      public var isLoot_:Boolean;
      public var ownerId_:int;

      public function Container(objectXML:XML)
      {
         super(objectXML);
         isInteractive_ = true;
         this.isLoot_ = objectXML.hasOwnProperty("Loot");
         this.ownerId_ = -1;
      }

      override protected function getTexture(camera:Camera, time:int, forceGlow: int = 0): BitmapData {

          var bestRank = -1;
          var bestRankData = 0;
          for each(var idata in this.itemDatas_) {
              if(!('Meta' in idata)) continue;
              var rank = ItemData.getRank(idata.Meta);
              if(rank > bestRank) {bestRank = rank; bestRankData = idata.Meta};
          }

          if(bestRank > Parameters.data_.rankFilter) {
              forceGlow = ItemData.getColor(bestRankData);
              this.size_ = 160;
          }

          return super.getTexture(camera, time, forceGlow);
      }

      public function setOwnerId(ownerId:int) : void
      {
         this.ownerId_ = ownerId;
         isInteractive_ = this.ownerId_ < 0 || this.isBoundToCurrentAccount();
      }

      public function isBoundToCurrentAccount() : Boolean
      {
         return map_.player_.accountId_ == this.ownerId_;
      }
      
      override public function addTo(map:Map, x:Number, y:Number) : Boolean
      {
         if(!super.addTo(map,x,y))
         {
            return false;
         }
         if(map_.player_ == null)
         {
            return true;
         }
         var dist:Number = PointUtil.distanceXY(map_.player_.x_,map_.player_.y_,x,y);
         if(this.isLoot_ && dist < 10)
         {
            SoundEffectLibrary.play("loot_appears");
         }
         return true;
      }
      
      public function getPanel(gs:GameSprite) : Panel
      {
         var player:Player = gs && gs.map?gs.map.player_:null;
         var invPanel:ContainerGrid = new ContainerGrid(this,player);
         return invPanel;
      }
   }
}
