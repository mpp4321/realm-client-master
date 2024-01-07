package kabam.rotmg.messaging.impl.incoming
{
import com.company.assembleegameclient.ui.RuneUi;

import flash.utils.IDataInput;
   
   public class OpenRunesMenu extends IncomingMessage
   {
      public var runeUi: RuneUi;

      public function OpenRunesMenu(id:uint, callback:Function)
      {
         super(id,callback);
      }
      
      override public function parseFromInput(data:IDataInput) : void
      {
         runeUi = new RuneUi();
         var amount = data.readByte();
         for(var i = 0; i < amount; i++) {
            var itemId = data.readInt();
            var cost = data.readInt();
            runeUi.addRune(itemId, cost);
            trace("adding rune");
         }
      }
      
      override public function toString() : String
      {
         return formatToString("OPENRUNEUI","runeUi");
      }
   }
}
