package com.company.util
{
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.messaging.impl.GameServerConnection;

public class Random
   {
       
      
      public var seed:uint;
      
      public function Random(seed:uint)
      {
         this.seed = seed;
      }

      public function drop(count:int) : void {
         for (var i:int = 0; i < count; i++)
            gen();
      }

      public function nextIntRange(min:uint, max:uint) : uint
      {
         return min == max? min :min + this.gen() % (max - min);
      }

      public function nextNumber() : Number
      {
         var t_24: Number = gen() >> 8; // discard 8 bytes to make it 24
         var secondary = Number(1 << 24);
         return t_24 / secondary;
      }

      private function gen() : uint
      {
         var lb:uint = 16807 * (this.seed & 0xFFFF);
         var hb:uint = 16807 * (this.seed >> 16);
         lb = lb + ((hb & 32767) << 16);
         lb = lb + (hb >> 15);
         if(lb > 2147483647)
         {
            lb = lb - 2147483647;
         }
         return this.seed = lb;
      }
   }
}
