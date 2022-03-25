package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.WorldPosData;
   
   public class PlayerExplode extends OutgoingMessage
   {
       
      
      public var time_:int;
      
      public var bulletId_:int;
      
      public function PlayerExplode(id:uint, callback:Function)
      {
         super(id,callback);
      }
      
      override public function writeToOutput(data:IDataOutput) : void
      {
         data.writeInt(this.time_);
         data.writeInt(this.bulletId_)
      }
      
      override public function toString() : String
      {
         return formatToString("PLAYEREXPLODE","time_","bulletId_");
      }
   }
}
