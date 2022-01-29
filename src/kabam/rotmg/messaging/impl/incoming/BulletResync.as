package kabam.rotmg.messaging.impl.incoming {
import flash.utils.IDataInput;

public class BulletResync extends IncomingMessage
{
    public function BulletResync(id:uint, callback:Function)
    {
        super(id,callback);
    }

    override public function parseFromInput(data:IDataInput) : void
    {
    }

    override public function toString() : String
    {
        return formatToString("BULLETRESYNC","");
    }
}
}
