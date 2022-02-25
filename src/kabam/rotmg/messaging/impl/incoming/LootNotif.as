package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class LootNotif extends IncomingMessage
{
    public var type:int;

    public function LootNotif(id:uint, callback:Function)
    {
        super(id,callback);
    }

    override public function parseFromInput(data:IDataInput) : void
    {
        this.type = data.readInt();
    }

    override public function toString() : String
    {
        return formatToString("LOOTNOTIF","type");
    }
}
}
