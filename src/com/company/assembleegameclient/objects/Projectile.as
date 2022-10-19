package com.company.assembleegameclient.objects
{
import com.adobe.utils.DictionaryUtil;
import com.company.assembleegameclient.engine3d.Point3D;
   import com.company.assembleegameclient.map.Camera;
   import com.company.assembleegameclient.map.Map;
   import com.company.assembleegameclient.map.Square;
import com.company.assembleegameclient.objects.animation.AnimationsData;
import com.company.assembleegameclient.objects.particles.HitEffect;
   import com.company.assembleegameclient.objects.particles.SparkParticle;
   import com.company.assembleegameclient.parameters.Parameters;
   import com.company.assembleegameclient.util.BloodComposition;
   import com.company.assembleegameclient.util.FreeList;
   import com.company.assembleegameclient.util.RandomUtil;
   import com.company.assembleegameclient.util.TextureRedrawer;
   import com.company.util.GraphicsUtil;
   import com.company.util.Trig;
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.display.GraphicsGradientFill;
   import flash.display.GraphicsPath;
   import flash.display.IGraphicsData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;

import kabam.rotmg.assets.model.AnimationHelper;

public class Projectile extends BasicObject
   {
      public static var nextFakeBulletId_:int = 0;

      public var animation: AnimationHelper;
      public var props_:ObjectProperties;
      public var containerProps_:ObjectProperties;
      public var projProps_:ProjectileProperties;
      public var texture_:BitmapData;
      public var bulletId_:int;
      public var ownerId_:int;
      public var containerType_:int;
      public var bulletType_:uint;
      public var damagesEnemies_:Boolean;
      public var damagesPlayers_:Boolean;
      public var damage_:int;
      public var didCrit_:Boolean;
      public var sound_:String;
      public var startX_:Number;
      public var startY_:Number;
      public var startTime_:int;
      public var lastUpdate_:int = 0;
      public var angle_:Number = 0;
      public var multiHitDict_:Dictionary;
      public var p_:Point3D;
      private var staticPoint_:Point;
      private var staticVector3D_:Vector3D;
      protected var shadowGradientFill_:GraphicsGradientFill;
      protected var shadowPath_:GraphicsPath;

      public var speedOverride: Number = -1.0;
      
      public function Projectile()
      {
         this.p_ = new Point3D(100);
         this.staticPoint_ = new Point();
         this.staticVector3D_ = new Vector3D();
         this.shadowGradientFill_ = new GraphicsGradientFill(GradientType.RADIAL,[0,0],[0.5,0],null,new Matrix());
         this.shadowPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS,new Vector.<Number>());
         this.speedOverride = -1.0;
         super();
      }

      public function mod(x, m) {
          var r = x % m;
          return x < 0 ? r + m : r;
      }

      //Make sure same as server
      private function findNextBulletId(id: int, m : int) {
         var r = id % m;
         var slot = r < 0 ? r + m : r;
         return slot;
      }

      public function doTextureThings() {
         if(animation != null) {
            texture_ = animation.bitmap;
         }
      }

      public function reset_with_props(proj_props: ProjectileProperties, props: ObjectProperties, bulletType: int, ownerId:int, bulletId:int, angle:Number, startTime:int, notItem: Boolean = false) {
         var size:Number = NaN;
         clear();
         this.bulletType_ = bulletType;
         this.bulletId_ = bulletId;
         this.ownerId_ = ownerId;
         this.angle_ = Trig.boundToPI(angle);
         this.startTime_ = startTime;
         objectId_ = getNextFakeObjectId();
         z_ = 0.5;

         this.containerProps_ = props;
         this.containerType_ = props.type_;
         this.projProps_ = proj_props;
         this.props_ = ObjectLibrary.getPropsFromId(this.projProps_.objectId_);

         hasShadow_ = this.props_.shadowSize_ > 0;

         var textureData:TextureData = ObjectLibrary.typeToTextureData_[this.props_.type_];
         var animationData: AnimationsData = ObjectLibrary.typeToAnimationsData_[this.props_.type_];
         if(animationData != null) {
            animation = new AnimationHelper();
            animation.setFrames(animationData.animations[0].frames);
            animation.setSpeed(animationData.animations[0].period_ / animationData.animations[0].frames.length);
            animation.signal.add(doTextureThings);
            doTextureThings();
         } else {
            this.texture_ = textureData.getTexture(objectId_);
         }

         this.damagesPlayers_ = this.containerProps_.isEnemy_;
         this.damagesEnemies_ = !this.damagesPlayers_;
         this.sound_ = this.containerProps_.oldSound_;
         this.multiHitDict_ = this.projProps_.multiHit_ ? new Dictionary() : null;
         if(this.projProps_.size_ >= 0)
         {
            size = this.projProps_.size_;
         }
         else
         {
            size = ObjectLibrary.getSizeFromType(this.containerType_);
         }
         this.p_.setSize(8 * (size / 100));
         this.damage_ = 0;

      }

      public function reset(containerType:int, bulletType:int, ownerId:int, bulletId:int, angle:Number, startTime:int, notItem: Boolean = false) : void
      {
         var size:Number = NaN;
         clear();
         this.speedOverride = -1.0;
         this.containerType_ = containerType;
         this.bulletType_ = bulletType;
         this.bulletId_ = bulletId;
         this.ownerId_ = ownerId;
         this.didCrit_ = false;
         this.angle_ = Trig.boundToPI(angle);
         this.startTime_ = startTime;
         objectId_ = getNextFakeObjectId();
         z_ = 0.5;
         this.containerProps_ = ObjectLibrary.propsLibrary_[this.containerType_];

         var keys = DictionaryUtil.getKeys(this.containerProps_.projectiles_);
         var projLength = keys.length;
         if(notItem) {
            this.projProps_ = this.containerProps_.projectiles_[bulletType];
         }
         else {
            var modIndex = findNextBulletId(bulletType, projLength) + keys[0];
            this.projProps_ = this.containerProps_.projectiles_[modIndex];
         }

         this.props_ = ObjectLibrary.getPropsFromId(this.projProps_.objectId_);
         hasShadow_ = this.props_.shadowSize_ > 0;

         var textureData:TextureData = ObjectLibrary.typeToTextureData_[this.props_.type_];
         var animationData: AnimationsData = ObjectLibrary.typeToAnimationsData_[this.props_.type_];
         if(animationData != null) {
            animation = new AnimationHelper();
            animation.setFrames(animationData.animations[0].frames);
            animation.setSpeed(animationData.animations[0].period_ / animationData.animations[0].frames.length);
            animation.signal.add(doTextureThings);
            doTextureThings();
         } else {
            this.texture_ = textureData.getTexture(objectId_);
         }

         this.damagesPlayers_ = this.containerProps_.isEnemy_;
         this.damagesEnemies_ = !this.damagesPlayers_;
         this.sound_ = this.containerProps_.oldSound_;
         this.multiHitDict_ = this.projProps_.multiHit_ ? new Dictionary() : null;
         if(this.projProps_.size_ >= 0)
         {
            size = this.projProps_.size_;
         }
         else
         {
            size = ObjectLibrary.getSizeFromType(this.containerType_);
         }
         this.p_.setSize(8 * (size / 100));
         this.damage_ = 0;
      }
      
      public function setDamage(damage:int) : void
      {
         this.damage_ = damage;
      }
      
      override public function addTo(map:Map, x:Number, y:Number) : Boolean
      {
         var player:Player = null;
         this.startX_ = x;
         this.startY_ = y;
         if(!super.addTo(map,x,y))
         {
            return false;
         }
         if(!this.containerProps_.flying_ && square_.sink_)
         {
            if (square_.obj_ && square_.obj_.props_.protectFromSink_)
            {
               z_ = 0.5;
            }
            else
            {
               z_ = 0.1;
            }
         }
         else
         {
            player = map.goDict_[this.ownerId_] as Player;
            if(player != null && player.sinkLevel_ > 0)
            {
               z_ = (0.5 - (0.4 * (player.sinkLevel_ / Parameters.MAX_SINK_LEVEL)));
            }
         }
         return true;
      }
      
      public function moveTo(x:Number, y:Number) : Boolean
      {
         var square:Square = map_.getSquare(x,y);
         if(square == null)
         {
            return false;
         }
         x_ = x;
         y_ = y;
         square_ = square;
         return true;
      }
      
      override public function removeFromMap() : void
      {
         super.removeFromMap();
         this.multiHitDict_ = null;
         if(animation != null)  {
            animation.destroy();
            animation = null;
         }
         FreeList.deleteObject(this);
      }

      private function speedAt(elapsed: int): Number {
         var speed:Number = this.speedOverride != -1.0 ? this.speedOverride : this.projProps_.speed_;
         var accel = this.projProps_.accelerate_;

         if (accel && elapsed > this.projProps_.accelerateDelay_)
         {
            //var elapsedWithDelay = Math.max(0, elapsed - projProps_.accelerateDelay_);
            var elapsedWithDelay = elapsed;
            var speedIncrease = elapsedWithDelay * (accel / 1000);
            speed += speedIncrease;
            //speed *= ( projProps_.accelerate_ * Math.min(0, Number(elapsed) - projProps_.accelerateDelay_) / this.projProps_.lifetime_);
         }

         if(projProps_.speedClamp_ > 0) {
            if(projProps_.speed_ > projProps_.speedClamp_) {
               if(speed < projProps_.speedClamp_) {
                  speed = projProps_.speedClamp_;
               }
            } else {
               if(speed > projProps_.speedClamp_) {
                  speed = projProps_.speedClamp_;
               }
            }
         }
         return speed;
      }

      private function angleAt(elapsed: int) {

         var speed = speedAt(elapsed);

         var distBeforeAccel = Math.min(elapsed, projProps_.accelerateDelay_) * (projProps_.speed_ / 10000);
         var distAfterAccel = Math.max(0, elapsed - projProps_.accelerateDelay_) * (speed / 10000);
         var dist:Number = distBeforeAccel + distAfterAccel;
         var phase:Number = this.bulletId_ % 2 == 0?Number(0):Number(Math.PI);

         if(this.projProps_.wavy_)
         {
            const periodFactor = 6 * Math.PI;
            const amplitudeFactor = Math.PI / 64;
            var theta = this.angle_ + amplitudeFactor * Math.sin(phase + periodFactor * elapsed / 1000);
            return theta;
         }
         else
         {
            if(this.projProps_.boomerang_)
            {
               const halfway = this.projProps_.lifetime_ * (this.projProps_.speed_ / 10000) / 2;
               if(dist > halfway)
               {
                  return Math.PI + this.angle_;
               }
            }
            if(this.projProps_.amplitude_ != 0)
            {
              const direction = this.projProps_.amplitude_ * Math.cos(phase + elapsed / this.projProps_.lifetime_ * this.projProps_.frequency_ * 2 * Math.PI);
              return this.angle_ + Math.atan(direction);
            }
         }
         return this.angle_;
      }
      
      private function positionAt(elapsed:int, p:Point) : void
      {
         lastUpdate_ = elapsed;
         var periodFactor:Number = NaN;
         var amplitudeFactor:Number = NaN;
         var theta:Number = NaN;
         var t:Number = NaN;
         var x:Number = NaN;
         var y:Number = NaN;
         var sin:Number = NaN;
         var cos:Number = NaN;
         var halfway:Number = NaN;
         var deflection:Number = NaN;
         p.x = this.startX_;
         p.y = this.startY_;

         var elapsedT = elapsed / 1000.0;
         var dist;

         //TODO projectile accel delay

         var accel = this.projProps_.accelerate_;
         var speed = speedOverride != -1.0 ? speedOverride : this.projProps_.speed_;

         var delayT = this.projProps_.accelerateDelay_ / 1000.0;
         var distDelayT = speed * delayT;

         trace("S: " + speed);
         trace("A: " + accel);
         trace("PP: " + speedOverride);

         if(Math.abs(accel) > 0 && elapsedT >= delayT) {
            var delta = -speed / accel;
            if((elapsedT - delayT) > delta && delta > 0.0) {
               dist = (accel * Math.pow(delta, 2) / 2.0) + (speed * delta);
            } else {
               dist = (accel * Math.pow(elapsedT - delayT, 2) / 2.0) + (speed * (elapsedT - delayT));
            }
            dist += distDelayT;
            dist /= 10.0;
         } else {
            dist = elapsed * speed / 10000.0;
         }

         /*var distBeforeAccel = Math.min(elapsed, projProps_.accelerateDelay_) * (projProps_.speed_ / 10000);
         var distAfterAccel = Math.max(0, elapsed - projProps_.accelerateDelay_) * (speed / 10000);*/
         //var dist:Number = distBeforeAccel + distAfterAccel;

         var phase: Number = projProps_.phaseLock_ == 1 ? 0 : Math.PI;
         if(projProps_.phaseLock_ == -1)
            phase = this.bulletId_ % 2 == 0?Number(0):Number(Math.PI);

         if(this.projProps_.wavy_ && this.projProps_.amplitude_ == 0)
         {
            periodFactor = 6 * Math.PI;
            amplitudeFactor = Math.PI / 64;
            theta = this.angle_ + amplitudeFactor * Math.sin(phase + periodFactor * elapsed / 1000);
            p.x = p.x + dist * Math.cos(theta);
            p.y = p.y + dist * Math.sin(theta);
            return;
         }

         if(this.projProps_.parametric_)
         {
            t = elapsed / this.projProps_.lifetime_ * 2 * Math.PI;
            x = Math.sin(t) * (Boolean(this.bulletId_ % 2)?1:-1);
            y = Math.sin(2 * t) * (this.bulletId_ % 4 < 2?1:-1);
            sin = Math.sin(this.angle_);
            cos = Math.cos(this.angle_);
            p.x = p.x + (x * cos - y * sin) * this.projProps_.magnitude_;
            p.y = p.y + (x * sin + y * cos) * this.projProps_.magnitude_;
            return;
         }
         if(this.projProps_.boomerang_)
         {
            halfway = this.projProps_.lifetime_ * (speed / 10000) / 2;
            if(dist > halfway)
            {
               dist = halfway - (dist - halfway);
            }
         }
         p.x = p.x + dist * Math.cos(this.angle_);
         p.y = p.y + dist * Math.sin(this.angle_);
         if(this.projProps_.amplitude_ != 0)
         {

            var ampFactor = this.projProps_.amplitude_;
            if(this.projProps_.wavy_) {
               ampFactor *= Math.pow(elapsed / this.projProps_.lifetime_, 1.4);
            }
            deflection = ampFactor * Math.sin(phase + elapsed / this.projProps_.lifetime_ * this.projProps_.frequency_ * 2 * Math.PI);
            p.x = p.x + deflection * Math.cos(this.angle_ + Math.PI / 2);
            p.y = p.y + deflection * Math.sin(this.angle_ + Math.PI / 2);
         }
      }

      public function bulletIdByIsPlayer(isPlayer, startId, k) {
         if(isPlayer) return startId - k;
         return startId + k;
      }

      public function dieAndExplode(time: int) {
         if(this.projProps_.explodeCount == 0)
              return;

         if(map_.player_ != null) {
            var count = this.projProps_.explodeCount;
            var props = this.projProps_.explodeProjectile;

            var object: GameObject = map_.goDict_[ownerId_];
            if(object == null) return;

            var isPlayer = !object.props_.isEnemy_;

            var startId = map_.player_.map_.nextProjectileId_;
            if(ownerId_ == map_.player_.objectId_) {
               map_.player_.map_.nextProjectileId_ -= count;
            } else {
               Projectile.nextFakeBulletId_ += count;
            }

            for(var i = 0; i < count; i++) {
               var angle = 360.0 / count * i * (Math.PI / 180.0);
               var proj = FreeList.newObject(Projectile) as Projectile;

               proj.reset_with_props(props, object.props_, Math.abs(startId - i), ownerId_, startId - i,angle,time);

               var minDamage = int(props.minDamage_) + int(props.minDamage_);
               var maxDamage = int(props.maxDamage_) + int(props.maxDamage_);
               var damage;

               if(isPlayer) {
                  damage = map_.gs_.gsc_.getNextDamage(minDamage, maxDamage);
               } else {
                  // min max are same here
                  damage = props.minDamage_;
               }

               proj.setDamage(damage);

               map_.addObj(proj,x_,y_);
            }
            map_.gs_.gsc_.playerExplosion(time, this.bulletId_);
         }
      }
      
      override public function update(time:int, dt:int) : Boolean
      {
         var colors:Vector.<uint> = null;
         var player:Player = null;
         var isPlayer:Boolean = false;
         var isTargetAnEnemy:Boolean = false;
         var sendMessage:Boolean = false;
         var d:int = 0;
         var elapsed:int = time - this.startTime_;
         if(elapsed > this.projProps_.lifetime_)
         {
            dieAndExplode(time);
            return false;
         }
         var p:Point = this.staticPoint_;
         this.positionAt(elapsed,p);
         if(!this.moveTo(p.x,p.y) || square_.tileType_ == 255)
         {
            if(this.damagesPlayers_)
            {
               map_.gs_.gsc_.squareHit(time,this.bulletId_);
            }
            else if(square_.obj_ != null)
            {
               if (Parameters.data_.particles) {
                  colors = BloodComposition.getColors(this.texture_);
                  map_.addObj(new HitEffect(colors, 100, 3, this.angle_, this.projProps_.speed_), p.x, p.y);
               }
            }
            return false;
         }
         if (square_.obj_ != null && (!square_.obj_.props_.isEnemy_ || !this.damagesEnemies_) && (square_.obj_.props_.enemyOccupySquare_ || !this.projProps_.passesCover_ && square_.obj_.props_.occupySquare_)) {
            if (this.damagesPlayers_) {
               map_.gs_.gsc_.squareHit(time, this.bulletId_);
            } else {
               if (Parameters.data_.particles) {
                  colors = BloodComposition.getColors(this.texture_);
                  map_.addObj(new HitEffect(colors, 100, 3, this.angle_, this.projProps_.speed_), p.x, p.y);
               }
            }
            return false;
         }

         var targets:Vector.<GameObject> = this.getHit(p.x,p.y);
         if(targets.length > 0)
         {
            var target:GameObject;
            for each (target in targets) {
               player = map_.player_;
               isPlayer = player != null;
               isTargetAnEnemy = target.props_.isEnemy_;
               var isAlly = map_.goDict_[this.ownerId_] != null && map_.goDict_[this.ownerId_].props_.ally;
               sendMessage = isPlayer && (this.damagesPlayers_ || (isTargetAnEnemy && (this.ownerId_ == player.objectId_ || isAlly)));
               if (sendMessage) {
                  d = GameObject.damageWithDefense(this.damage_, target.defense_, this.projProps_.armorPiercing_, target.condition_, isPlayer ? player.protection_ : 0);
                  if (target == player) {
                     map_.gs_.gsc_.playerHit(this.bulletId_);
                     target.damage(d, this.projProps_.effects_, this);
                  } else if (target.props_.isEnemy_) {
                     map_.gs_.gsc_.enemyHit(time, this.bulletId_, target.objectId_);
                     target.damage(d, this.projProps_.effects_, this);
                  }
               }
               if (this.projProps_.multiHit_) {
                  this.multiHitDict_[target] = true;
               } else {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function getHit(pX:Number, pY:Number) : Vector.<GameObject>
      {
         var go:GameObject = null;
         var xDiff:Number = NaN;
         var yDiff:Number = NaN;
         var dist:Number = NaN;
         var minDist:Number = Number.MAX_VALUE;
         var minGO:GameObject = null;
         var gos:Vector.<GameObject> = new Vector.<GameObject>();

         if (damagesEnemies_)
         {
            for each(go in map_.hittable_)
            {
               xDiff = go.x_ > pX?Number(go.x_ - pX):Number(pX - go.x_);
               yDiff = go.y_ > pY?Number(go.y_ - pY):Number(pY - go.y_);
               if(xDiff <= GameObject.HITBOX_RADIUS && yDiff <= GameObject.HITBOX_RADIUS)
               {
                  if(!(this.projProps_.multiHit_ && this.multiHitDict_[go] != null))
                  {
                     if (this.projProps_.multiHit_)
                        gos.push(go);
                     else
                     {
                        dist = Math.sqrt(xDiff * xDiff + yDiff * yDiff);
                        if(dist < minDist)
                        {
                           minDist = dist;
                           gos.length = 0;
                           gos.push(go);
                        }
                     }
                  }
               }
            }
         }
         else if (damagesPlayers_)
         {
            go = map_.player_;
            if (go.isTargetable())
            {
               xDiff = go.x_ > pX ? Number(go.x_ - pX) : Number(pX - go.x_);
               yDiff = go.y_ > pY ? Number(go.y_ - pY) : Number(pY - go.y_);
               if (!(xDiff > GameObject.HITBOX_RADIUS || yDiff >  GameObject.HITBOX_RADIUS)) {
                  if (!(this.projProps_.multiHit_ && this.multiHitDict_[go] != null)) {
                     gos.push(go);
                  }
               }
            }
         }
         return gos;
      }
      
      override public function draw(graphicsData:Vector.<IGraphicsData>, camera:Camera, time:int) : void
      {
         var texture:BitmapData = this.texture_;

         var r:Number = this.props_.rotation_ == 0?Number(0):Number(time / this.props_.rotation_);
         this.staticVector3D_.x = x_;
         this.staticVector3D_.y = y_;
         this.staticVector3D_.z = z_;
          if(projProps_.smartAngle) {
             this.p_.draw(graphicsData,this.staticVector3D_,angleAt(this.lastUpdate_) - camera.angleRad_ + this.props_.angleCorrection_ + r,camera.wToS_,camera,texture);
          } else {
             this.p_.draw(graphicsData,this.staticVector3D_,this.angle_ - camera.angleRad_ + this.props_.angleCorrection_ + r,camera.wToS_,camera,texture);
          }
         if(this.projProps_.particleTrail_ && Parameters.data_.particles)
         {
            map_.addObj(new SparkParticle(100, 16711935, 600, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
            map_.addObj(new SparkParticle(100, 16711935, 600, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
            map_.addObj(new SparkParticle(100, 16711935, 600, 0.5, RandomUtil.plusMinus(3), RandomUtil.plusMinus(3)), x_, y_);
         }
      }
      
      override public function drawShadow(graphicsData:Vector.<IGraphicsData>, camera:Camera, time:int) : void
      {
         var s:Number = this.props_.shadowSize_ / 400;
         var w:Number = 30 * s;
         var h:Number = 15 * s;
         this.shadowGradientFill_.matrix.createGradientBox(w * 2,h * 2,0,posS_[0] - w,posS_[1] - h);
         graphicsData.push(this.shadowGradientFill_);
         this.shadowPath_.data.length = 0;
         this.shadowPath_.data.push(posS_[0] - w,posS_[1] - h,posS_[0] + w,posS_[1] - h,posS_[0] + w,posS_[1] + h,posS_[0] - w,posS_[1] + h);
         graphicsData.push(this.shadowPath_);
         graphicsData.push(GraphicsUtil.END_FILL);
      }
   }
}
