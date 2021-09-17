package kabam.rotmg.messaging.impl.outgoing {
import flash.utils.IDataOutput;

public class MixMessage extends OutgoingMessage {

    public var slotId1:int;
    public var slotId2:int;

    public function MixMessage(id:uint, callback:Function)
    {
        super(id,callback);
    }

    override public function writeToOutput(data:IDataOutput) : void
    {
        data.writeInt(this.slotId1);
        data.writeInt(this.slotId2);
    }

    override public function toString() : String
    {
        return formatToString("MIX","slotId1", "slotId2");
    }
}
}
