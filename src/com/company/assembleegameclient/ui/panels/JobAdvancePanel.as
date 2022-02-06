package com.company.assembleegameclient.ui.panels
{
   import com.company.assembleegameclient.game.GameSprite;
   import com.company.assembleegameclient.objects.Player;
   import com.company.assembleegameclient.ui.board.GuildBoardWindow;
import com.company.assembleegameclient.ui.dialogs.ClassAdvancementDialog;
import com.company.assembleegameclient.util.GuildUtil;
   import flash.events.MouseEvent;
   
   public class JobAdvancePanel extends ButtonPanel
   {
       
      
      public function JobAdvancePanel(gs:GameSprite)
      {
         super(gs,"Advance Job?","View");
      }
      
      override protected function onButtonClick(event:MouseEvent) : void
      {
         var p:Player = gs_.map.player_;
         if(p == null)
         {
            return;
         }
         gs_.addChild(new ClassAdvancementDialog(p));
      }
   }
}
