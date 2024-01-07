package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class RemoveRune extends OutgoingMessage
   {
      public var rune:String;

      public function RemoveRune(id:uint, callback:Function)
      {
         super(id,callback);
      }
      
      override public function writeToOutput(data:IDataOutput) : void
      {
         data.writeUTF(this.rune);
      }
      
      override public function toString() : String
      {
         return formatToString("REMOVERUNE","rune");
      }
   }
}
