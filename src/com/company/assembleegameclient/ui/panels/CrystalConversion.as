package com.company.assembleegameclient.ui.panels
{
   import com.company.assembleegameclient.game.GameSprite;
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.ui.board.GuildBoardWindow;
import com.company.assembleegameclient.ui.dialogs.ClassAdvancementDialog;
import com.company.assembleegameclient.util.GuildUtil;
   import flash.events.MouseEvent;

import kabam.rotmg.messaging.impl.GameServerConnection;

public class CrystalConversion extends ButtonPanel
   {
       
      
      public function CrystalConversion(gs:GameSprite)
      {
         super(gs,"Exchange Realm Crystals?","Exchange");
      }
      
      override protected function onButtonClick(event:MouseEvent) : void
      {
         var p:Player = gs_.map.player_;
         if(p == null)
         {
            return;
         }
         p.map_.gs_.gsc_.attemptCrystalConversion();
      }
   }
}
