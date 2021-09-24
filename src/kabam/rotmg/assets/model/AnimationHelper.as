package kabam.rotmg.assets.model
{
import com.company.assembleegameclient.objects.TextureData;
import com.company.assembleegameclient.objects.animation.AnimationsData;
import com.company.assembleegameclient.objects.animation.FrameData;

import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.utils.Timer;

import kabam.lib.loopedprocs.LoopedCallback;

import kabam.lib.loopedprocs.LoopedProcess;

import org.osflash.signals.Signal;

public class AnimationHelper
   {
       
      
      private const DEFAULT_SPEED:int = 200;
      
      public var bitmap:BitmapData;
      
      private var frames:Vector.<BitmapData> = new Vector.<BitmapData>(0);
      
      public var timer : LoopedProcess;
      
      private var isStarted:Boolean;
      
      private var index:int;
      
      private var count:uint;

      public var signal: Signal = new Signal();
      
      public function AnimationHelper()
      {
         super();
         timer = new LoopedCallback(DEFAULT_SPEED, iterate);
         LoopedProcess.addProcess(timer);
      }

      public function destroy() {
          timer.destroy();
          LoopedProcess.destroyProcess(timer);
      }

      public function setSpeed(speed:int) : void
      {
          timer.interval = speed;
      }
      
      public function setFrames(newFrames: Vector.<FrameData>) : void
      {
         var frame : FrameData = null;
         this.frames.length = 0;
         this.index = 0;
         for each(frame in newFrames)
         {
            this.count = this.frames.push(frame.textureData_.texture_);
         }
         if(this.isStarted)
         {
            this.start();
         }
         else
         {
            this.iterate();
         }
      }
      
      public function addFrame(frame:BitmapData) : void
      {
         this.count = this.frames.push(frame);
         this.isStarted && this.start();
      }
      
      public function start() : void
      {
         if(!this.isStarted && this.count > 0)
         {
            this.iterate();
         }
         this.isStarted = true;
      }
      
      public function stop() : void
      {
         this.isStarted = false;
      }
      
      private function iterate(event:TimerEvent = null) : void
      {
         this.index = ++this.index % this.count;
         this.bitmap = this.frames[this.index];
         signal.dispatch();
      }
      
      public function dispose() : void
      {
         var frame:BitmapData = null;
         this.stop();
         this.index = 0;
         this.count = 0;
         this.frames.length = 0;
         for each(frame in this.frames)
         {
            frame.dispose();
         }
      }
   }
}
