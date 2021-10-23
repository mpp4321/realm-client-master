package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class ShootDesync extends IncomingMessage
{
    public var diff:int;

    public function ShootDesync(id:uint, callback:Function)
    {
        super(id,callback);
    }

    override public function parseFromInput(data:IDataInput) : void
    {
        this.diff = data.readInt();
    }

    override public function toString() : String
    {
        return formatToString("SHOOTDESYNC","diff");
    }
}
}
