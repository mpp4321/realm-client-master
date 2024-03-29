package com.company.assembleegameclient.ui.tooltip
{
import com.company.assembleegameclient.constants.InventoryOwnerTypes;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.animation.AnimationsData;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.ui.LineBreakDesign;
import com.company.assembleegameclient.util.ItemData;
import com.company.ui.SimpleText;
import com.company.util.BitmapUtil;
import com.company.util.KeyCodes;
import com.company.util.MichaelUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.DropShadowFilter;
import flash.text.StyleSheet;
import flash.utils.Dictionary;
import kabam.rotmg.assets.model.AnimationHelper;
import kabam.rotmg.constants.ActivationType;
import kabam.rotmg.messaging.impl.data.StatData;
   
   public class EquipmentToolTip extends ToolTip
   {
      private static const MAX_WIDTH:int = 230;
      private static const CSS_TEXT:String = ".in { margin-left:10px; text-indent: -10px; }";
      
      private var icon_:Bitmap;
      private var anim: AnimationHelper;

      private var titleText_:SimpleText;
      private var tierText_:SimpleText;
      private var descText_:SimpleText;
      private var line1_:LineBreakDesign;
      private var effectsText_:SimpleText;
      private var line2_:LineBreakDesign;
      private var restrictionsText_:SimpleText;
      private var player_:Player;
      private var itemData_;
      private var isEquippable_:Boolean = false;
      private var objectType_:int;
      private var objectXML_:XML = null;
      private var playerCanUse:Boolean;
      private var restrictions:Vector.<Restriction>;
      private var effects:Vector.<Effect>;
      private var itemSlotTypeId:int;
      private var invType:int;
      private var inventoryOwnerType:String;
      private var inventorySlotID:uint;
      private var isInventoryFull:Boolean;
      private var yOffset:int;
      private var enchantmentStrength: Number;
      
      public function EquipmentToolTip(objectType:int, itemData, player:Player, invType:int, inventoryOwnerType:String, inventorySlotID:uint = 1.0)
      {
         this.player_ = player;
         this.itemData_ = itemData;
         this.inventoryOwnerType = inventoryOwnerType;
         this.inventorySlotID = inventorySlotID;
         this.isInventoryFull = Boolean(player)?Boolean(player.isInventoryFull()):Boolean(false);
         this.playerCanUse = player != null?Boolean(ObjectLibrary.isUsableByPlayer(objectType,player)):Boolean(false);
         var backgroundColor:uint = this.playerCanUse || this.player_ == null ? 0x363636 : 6036765;
         var outlineColor:uint = this.playerCanUse || player == null ? 0x9B9B9B : 10965039;
         super(backgroundColor,1,outlineColor,1,true);
         this.objectType_ = objectType;
         this.objectXML_ = ObjectLibrary.xmlLibrary_[objectType];
         var equipSlotIndex:int = Boolean(this.player_)?int(ObjectLibrary.getMatchingSlotIndex(this.objectType_,this.player_)):int(-1);
         this.isEquippable_ = equipSlotIndex != -1;
         this.effects = new Vector.<Effect>();
         this.invType = invType;
         this.itemSlotTypeId = int(this.objectXML_.SlotType);
         this.enchantmentStrength = MichaelUtil.determineEnchantmentStrength(objectXML_);
         this.addIcon();
         this.addTitle();
         this.addTierText();
         this.addDescriptionText();
         this.addNumProjectilesTagsToEffectsList();
         this.addProjectileTagsToEffectsList();
         this.addActivateTagsToEffectsList();
         this.addActivateOnEquipTagsToEffectsList();
         this.addCooldownTagToEffectsList();
         this.addDoseTagsToEffectsList();
         this.addMpCostTagToEffectsList();
         this.addAdornTag()
         this.addFameBonusTagToEffectsList();
         this.makeEffectsList();
         this.makeRestrictionList();
         this.makeRestrictionText();
      }

      public function addAdornTag() : void {
         if(this.itemData_ != null && this.itemData_.hasOwnProperty("ItemComponent")) {
            const color = "#AA6633";
            this.effects.push(new Effect("", TooltipHelper.wrapInFontTag("Adorned with "  + this.itemData_.ItemComponent, color)));
         }
      }

      public override function detachFromTarget() : void {
         if(anim != null) {
            this.anim.destroy();
            this.anim = null;
         }
         super.detachFromTarget();
      }

      private static function BuildRestrictionsHTML(restrictions:Vector.<Restriction>) : String
      {
         var restriction:Restriction = null;
         var line:String = null;
         var html:String = "";
         var first:Boolean = true;
         for each(restriction in restrictions)
         {
            if(!first)
            {
               html = html + "\n";
            }
            else
            {
               first = false;
            }
            line = "<font color=\"#" + restriction.color_.toString(16) + "\">" + restriction.text_ + "</font>";
            if(restriction.bold_)
            {
               line = "<b>" + line + "</b>";
            }
            html = html + line;
         }
         return html;
      }

      private function changeTexture() {
         var texture:BitmapData = ObjectLibrary.getRedrawnTextureFromType(this.objectType_,60,true,itemData_ == null ? -1 : itemData_.Meta, true, 5, anim);
         texture = BitmapUtil.cropToBitmapData(texture,4,4,texture.width - 8,texture.height - 8);
         this.icon_.bitmapData = texture;
      }
      
      private function addIcon() : void
      {
         var eqXML:XML = ObjectLibrary.xmlLibrary_[this.objectType_];
         var scaleValue:int = 5;
         if(eqXML.hasOwnProperty("ScaleValue"))
         {
            scaleValue = eqXML.ScaleValue;
         }
         var animationData: AnimationsData = ObjectLibrary.typeToAnimationsData_[objectType_];
         if(animationData != null) {
            anim = new AnimationHelper();
            anim.setFrames(animationData.animations[0].frames);
            anim.setSpeed(animationData.animations[0].period_ / animationData.animations[0].frames.length);
            anim.signal.add(changeTexture);
         }
         var texture:BitmapData = ObjectLibrary.getRedrawnTextureFromType(this.objectType_,60,true,itemData_ == null ? -1 : itemData_.Meta, true, scaleValue, anim);
         texture = BitmapUtil.cropToBitmapData(texture,4,4,texture.width - 8,texture.height - 8);
         this.icon_ = new Bitmap(texture);
         addChild(this.icon_);
      }

      public static function setTierColor(tierText_: SimpleText, objectXML_: XML) {
         if(objectXML_.hasOwnProperty("Tier"))
         {
            tierText_.text = "T" + objectXML_.Tier;
         }
         else
         {
            var bagType = objectXML_.hasOwnProperty("BagType") ? int(objectXML_.BagType) : 4;
            switch(bagType) {
               case 4:
                  tierText_.setColor(0x46b989);
                  tierText_.text = "UT";
                  break;
               case 5:
                  tierText_.setColor(0x6464f4);
                  tierText_.text = "RT";
                  break;
               case 6:
                  tierText_.setColor(0xd8bd27);
                  tierText_.text = "LT";
                  break;
               case 7:
                  tierText_.setColor(0xc13e54);
                  tierText_.text = "GT";
                  break;
               case 8:
                  tierText_.setColor(0xc13e95);
                  tierText_.text = "MT";
                  break;
               default:
                  tierText_.setColor(9055202);
                  tierText_.text = "UT";
                  break;
            }

         }
      }

      private function addTierText() : void
      {
         this.tierText_ = new SimpleText(16,16777215,false,30,0);
         this.tierText_.setBold(true);
         this.tierText_.y = this.icon_.height / 2 - this.titleText_.actualHeight_ / 2;
         this.tierText_.x = MAX_WIDTH - 30;
         if(this.objectXML_.hasOwnProperty("Consumable") == false && this.isPet() == false)
         {
            setTierColor(this.tierText_, objectXML_);
            this.tierText_.updateMetrics();
            addChild(this.tierText_);
         }
      }
      
      private function isPet() : Boolean
      {
         var activateTags:XMLList = null;
         activateTags = this.objectXML_.Activate.(text() == "PermaPet");
         return activateTags.length() >= 1;
      }
      
      private function addTitle() : void
      {
         //var prefix:String = ItemData.getPrefix(this.itemData_);
         var color:int = ItemData.getColor(this.itemData_.Meta);
         if (color == -1)
         {
            color = this.playerCanUse || this.player_ == null?int(16777215):int(16549442);
         }

         this.titleText_ = new SimpleText(16,color,false,MAX_WIDTH - this.icon_.width - 4 - 30,0);
         this.titleText_.setBold(true);
         this.titleText_.wordWrap = true;
         var item_rank: int = ItemData.getRank(this.itemData_);
         var item_rank_text: String = item_rank > 0 ? "+" + item_rank : "";
         var item_name = this.itemData_.hasOwnProperty("Rename") ? this.itemData_.Rename : ObjectLibrary.typeToDisplayId_[this.objectType_];
         this.titleText_.text = item_name + item_rank_text;
         this.titleText_.updateMetrics();
         this.titleText_.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
         this.titleText_.x = this.icon_.width + 4;
         this.titleText_.y = this.icon_.height / 2 - this.titleText_.actualHeight_ / 2;

         addChild(this.titleText_);
      }
      
      private function buildUniqueTooltipData() : String
      {
         var effectDataList:XMLList = null;
         var uniqueEffectList:Vector.<Effect> = null;
         var effectDataXML:XML = null;
         if(this.objectXML_.hasOwnProperty("ExtraTooltipData"))
         {
            effectDataList = this.objectXML_.ExtraTooltipData.EffectInfo;
            uniqueEffectList = new Vector.<Effect>();
            for each(effectDataXML in effectDataList)
            {
               var name: String = effectDataXML["@name"];
               var desc: String = effectDataXML["@description"];
               if(itemData_ != null) {
                  for(var prop in itemData_) {
                     name = name.replace("{" + prop + "}", itemData_[prop].toString());
                     desc = desc.replace("{" + prop + "}", itemData_[prop].toString());
                  }
               }
               uniqueEffectList.push(new Effect(name, desc));
            }
            return this.BuildEffectsHTML(uniqueEffectList) + "\n";
         }
         return "";
      }
      
      private function makeEffectsList() : void
      {
         this.yOffset = this.descText_.y + this.descText_.height + 8;
         if(this.effects.length != 0 || this.objectXML_.hasOwnProperty("ExtraTooltipData"))
         {
            this.line1_ = new LineBreakDesign(MAX_WIDTH - 12,0);
            this.line1_.x = 8;
            this.line1_.y = this.yOffset;
            addChild(this.line1_);
            this.effectsText_ = new SimpleText(14,11776947,false,MAX_WIDTH - this.icon_.width - 4,0);
            this.effectsText_.wordWrap = true;
            this.effectsText_.htmlText = this.buildUniqueTooltipData() + this.BuildEffectsHTML(this.effects);
            this.effectsText_.useTextDimensions();
            this.effectsText_.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            this.effectsText_.x = 4;
            this.effectsText_.y = this.line1_.y + 8;
            addChild(this.effectsText_);
            this.yOffset = this.effectsText_.y + this.effectsText_.height + 8;
         }
      }

      private function addNumProjectilesTagsToEffectsList() : void
      {
         if(this.objectXML_.hasOwnProperty("NumProjectiles"))
         {
            this.effects.push(new Effect("Shots",this.objectXML_.NumProjectiles));
         }
      }
      
      private function addFameBonusTagToEffectsList() : void
      {
         var fameBonusMod:Number = ItemData.getStat(this.itemData_, ItemData.FAME_BONUS_BIT, 1, enchantmentStrength);

         if(this.objectXML_.hasOwnProperty("FameBonus") || fameBonusMod != 0)
         {
            var fameBonus:int = this.objectXML_.hasOwnProperty("FameBonus") ? int(this.objectXML_.FameBonus) : 0;
            var fameBonusString:String = (fameBonus + fameBonusMod).toString() + "%";
            if (fameBonusMod != 0)
            {
               fameBonusString += " (+" + fameBonusMod + "%)";
               fameBonusString = TooltipHelper.wrapInFontTag(fameBonusString, ItemData.getColorString(this.itemData_));
            }
            this.effects.push(new Effect("Fame Bonus",fameBonusString));
         }
      }
      
      private function addMpCostTagToEffectsList() : void
      {
         if(this.objectXML_.hasOwnProperty("MpCost"))
         {
            this.effects.push(new Effect("MP Cost",this.objectXML_.MpCost));
         }
      }

      private function addCooldownTagToEffectsList() : void
      {
         var cooldownMod:Number = ItemData.getStat(this.itemData_, ItemData.COOLDOWN_BIT, ItemData.COOLDOWN_MULTIPLIER, enchantmentStrength);
         if(this.objectXML_.hasOwnProperty("Cooldown") || cooldownMod != 0)
         {
            var cooldown:Number = this.objectXML_.hasOwnProperty("Cooldown") ? Number(this.objectXML_.Cooldown) : 0.2;
            var cooldownString:String = TooltipHelper.getFormattedString((cooldown - (cooldown * cooldownMod))) + "s";
            if (cooldownMod != 0)
            {
               cooldownString += " (-" + int(cooldownMod * 100) + "%)";
               cooldownString = TooltipHelper.wrapInFontTag(cooldownString, ItemData.getColorString(this.itemData_.Meta));
            }
            this.effects.push(new Effect("Cooldown",cooldownString));
         }
      }

      private function addDoseTagsToEffectsList() : void
      {
         if(this.objectXML_.hasOwnProperty("Doses"))
         {
            this.effects.push(new Effect("Doses",this.objectXML_.Doses));
         }
      }

      static var movingTooltipDate = new Date();

      private function addProjectileTagsToEffectsList() : void
      {
         var projXML:XML = null;
         var range:Number = NaN;
         var condEffectXML:XML = null;
         var color:String = ItemData.getColorString(this.itemData_);
         if(this.objectXML_.hasOwnProperty("Projectile"))
         {
             var projs = this.objectXML_.elements("Projectile")
             var len = projs.length();
             var projXML = projs[movingTooltipDate.seconds % len];
//            for each(var projXML in this.objectXML_.Projectile) {
//               projXML = XML(this.objectXML_.Projectile);
               var minDmg:int = int(projXML.MinDamage);
               var maxDmg:int = int(projXML.MaxDamage);
               var dmgMod:Number = ItemData.getStat(this.itemData_, ItemData.DAMAGE_BIT, ItemData.DAMAGE_MULTIPLIER, enchantmentStrength);
               minDmg += int(minDmg * dmgMod);
               maxDmg += int(maxDmg * dmgMod);
               var dmgString:String = (minDmg == maxDmg ? minDmg : minDmg + " - " + maxDmg).toString();
               if (dmgMod != 0)
               {
                  dmgString += " (+" + int(dmgMod * 100) + "%)";
                  dmgString = TooltipHelper.wrapInFontTag(dmgString, color);
               }
               this.effects.push(new Effect("Damage", dmgString));

               range = Number(projXML.Speed) * Number(projXML.LifetimeMS) / 10000;
               this.effects.push(new Effect("Range",TooltipHelper.getFormattedString(range)));
               if(this.objectXML_.Projectile.hasOwnProperty("MultiHit"))
               {
                  this.effects.push(new Effect("","Shots hit multiple targets"));
               }
               if(this.objectXML_.Projectile.hasOwnProperty("PassesCover"))
               {
                  this.effects.push(new Effect("","Shots pass through obstacles"));
               }
               if(this.objectXML_.Projectile.hasOwnProperty("ArmorPiercing"))
               {
                  this.effects.push(new Effect("","Shots ignore defence of target"));
               }

               var rateOfFire:Number = this.objectXML_.hasOwnProperty("RateOfFire") ? Number(this.objectXML_.RateOfFire) : 1.0;
               var rateOfFireDataValue:Number = ItemData.RATE_OF_FIRE_MULTIPLIER * rateOfFire;
               var rateOfFireData:Number = ItemData.getStat(this.itemData_, ItemData.RATE_OF_FIRE_BIT, rateOfFireDataValue, enchantmentStrength);
               var rateOfFireString:String = (int(rateOfFire * 100) + int(rateOfFireData * 100)) + "%";
               if (rateOfFireData != 0)
               {
                  rateOfFireString += " (+" + int(rateOfFireData * 100) + "%)";
                  rateOfFireString = TooltipHelper.wrapInFontTag(rateOfFireString, color);
               }
               this.effects.push(new Effect("Rate of Fire", rateOfFireString));

               if(projXML.ConditionEffect.length() > 0) {

                  this.effects.push(new Effect("Shot Effects", ""));
                  for each(condEffectXML in projXML.ConditionEffect)
                  {
                     this.effects.push(new Effect("",condEffectXML.text() + " for " + condEffectXML.@duration + " secs"));
                  }

               }
//            }
         }
      }
      
      private function addActivateTagsToEffectsList() : void
      {
         var activateXML:XML = null;
         var val:String = null;
         var stat:int = 0;
         var amt:int = 0;
         var activationType:String = null;
         for each(activateXML in this.objectXML_.Activate)
         {
            activationType = activateXML.toString();
            switch(activationType)
            {
               case ActivationType.BAG_REMOVE:
                  var string = "";
                  for(var item in itemData_.StoredItems)
                  {
                     var itemXML = ObjectLibrary.getXMLfromId(
                             ObjectLibrary.getIdFromType(int(itemData_.StoredItems[item]))
                     );
                     string = "[" + itemXML.@id + "]";
                     this.effects.push(new Effect("", string));
                  }
                  continue;
               case ActivationType.FAME_CONSUME:
                  this.effects.push(new Effect("", "Gives " + itemData_.MiscIntOne + " fame on use."));
                  continue;
               case ActivationType.EGG_ITEM:
                 var workingString = "";
                 var type = parseInt(this.objectXML_.EggType[0].text());
                 switch(type)
                 {
                    case 1:
                         workingString = "Gives a random item when this item collects: " + itemData_.Meta + " / 200000 xp";
                         break;
                    case 2:
                         workingString = "Gives a random item when this item collects: " + itemData_.Meta + " / 500000 xp"
                         break;
                    default:
                         break;
                 }
                  this.effects.push(new Effect("", workingString));
                  continue;
               case ActivationType.DYE:
                  this.effects.push(new Effect("", "Changes texture of your character"));
                  continue;
               case ActivationType.STAT_BOOST_AURA:
                  stat = int(activateXML.@stat);
                  this.effects.push(new StatScaleEffect("Party Effect","Within {range} sqrs", activateXML, player_));
                  this.effects.push(new StatScaleEffect("","+{amount} " + StatData.statToName(stat) + " for {duration} secs", activateXML, player_));
                  continue;
               case ActivationType.STAT_BOOST_SELF:
                  stat = int(activateXML.@stat);
                  this.effects.push(new Effect("Effect on Self",""));
                  this.effects.push(new StatScaleEffect("","+{amount} " + StatData.statToName(stat) + " for {duration} secs", activateXML, player_));
                  continue;
               case ActivationType.COND_EFFECT_AURA:
//                  this.effects.push(new Effect("Party Effect","Within " + activateXML.@range + " sqrs"));
//                  this.effects.push(new Effect("",activateXML.@effect + " for " + activateXML.@duration + " secs"));
                  this.effects.push(new StatScaleEffect("Party Effect","Within {range} sqrs", activateXML, player_));
                  this.effects.push(new StatScaleEffect("",activateXML.@effect + " for {duration} secs", activateXML, player_));
                  continue;
               case ActivationType.COND_EFFECT_SELF:
//                  this.effects.push(new Effect("Effect on Self",""));
//                  this.effects.push(new Effect("",activateXML.@effect + " for " + activateXML.@duration + " secs"));
                  this.effects.push(new Effect("Effect on Self",""));
                  this.effects.push(new StatScaleEffect("",activateXML.@effect + " for {duration} secs", activateXML, player_));
                  continue;
               case ActivationType.COND_EFFECT_BLAST:
//                  this.effects.push(new Effect("Effect on Self",""));
//                  this.effects.push(new Effect("",activateXML.@effect + " for " + activateXML.@duration + " secs"));
                  this.effects.push(new StatScaleEffect("Effect on Enemies","Within {range} sqrs", activateXML, player_));
                  this.effects.push(new StatScaleEffect("",activateXML.@effect + " for {duration} secs", activateXML, player_));
                  continue;
               case ActivationType.HEAL:
                  //this.effects.push(new Effect("","+" + activateXML.@amount + " HP"));
                  this.effects.push(new StatScaleEffect("","+{amount} HP", activateXML, player_));
                  continue;
               case ActivationType.HEAL_NOVA:
//                  this.effects.push(new Effect("Party Heal",activateXML.@amount + " HP at " + activateXML.@range + " sqrs"));
                  this.effects.push(new StatScaleEffect("Party Heal","{amount} HP at {range} sqrs", activateXML, player_));
                  continue;
               case ActivationType.MAGIC:
                  //this.effects.push(new Effect("","+" + activateXML.@amount + " MP"));
                  this.effects.push(new StatScaleEffect("","+{amount} MP", activateXML, player_));
                  continue;
               case ActivationType.MAGIC_NOVA:
                  this.effects.push(new StatScaleEffect("Fill Party Magic","{amount} MP at {range} sqrs", activateXML, player_));
                  continue;
               case ActivationType.TELEPORT:
                  this.effects.push(new Effect("","Teleport to Target"));
                  continue;
               case ActivationType.VAMPIRE_BLAST:
                  this.effects.push(new StatScaleEffect("Steal","{totalDamage} HP within {range} sqrs", activateXML, player_));
                  continue;
               case ActivationType.TRAP:
                  this.effects.push(new StatScaleEffect("Trap","{totalDamage} HP within {range} sqrs", activateXML, player_));
                  this.effects.push(new StatScaleEffect("",activateXML.@effect + " for {duration} secs", activateXML, player_));
                  continue;
               case ActivationType.STASIS_BLAST:
                  this.effects.push(new StatScaleEffect("Stasis on Group","{duration} secs", activateXML, player_));
                  continue;
               case ActivationType.DECOY:
                  this.effects.push(new StatScaleEffect("Decoy","{duration} secs", activateXML, player_));
                  continue;
               case ActivationType.LIGHTNING:
                  this.effects.push(new Effect("Lightning",""));
                  this.effects.push(new StatScaleEffect("","{totalDamage} to " + activateXML.@maxTargets + " targets", activateXML, player_));
                  continue;
               case ActivationType.STRONG_LIGHTNING:
                  this.effects.push(new Effect("Strong Lightning",""));
                  this.effects.push(new StatScaleEffect("","{totalDamage} to " + activateXML.@maxTargets + " targets", activateXML, player_));
                  continue;
               case ActivationType.POISON_GRENADE:
                  this.effects.push(new Effect("Poison Grenade",""));
                  this.effects.push(new StatScaleEffect("","{totalDamage} HP over {duration} secs within {range} sqrs", activateXML, player_));
                  continue;
               case ActivationType.REMOVE_NEG_COND:
                  this.effects.push(new Effect("","Removes negative conditions"));
                  continue;
               case ActivationType.REMOVE_NEG_COND_SELF:
                  this.effects.push(new Effect("","Removes negative conditions"));
                  continue;
               case ActivationType.BULLET_NOVA:
                  this.effects.push(new Effect("Shots", "20"));
                  continue;
               case ActivationType.SHURIKEN:
                  this.effects.push(new StatScaleEffect("Shots", "{amount}", activateXML, player_));
                  this.effects.push(new Effect("", "Stars seek nearby enemies"));
                  this.effects.push(new Effect("", "Dazes nearby enemies"));
                  continue;
               case ActivationType.INCREMENT_STAT:
                  stat = int(activateXML.@stat);
                  amt = int(activateXML.@amount);
                  if(stat != 0 && stat != 1)
                  {
                     val = "Permanently increases " + StatData.statToName(stat);
                  }
                  else
                  {
                     val = "+" + amt + " " + StatData.statToName(stat);
                  }
                  this.effects.push(new Effect("",val));
                  continue;
               default:
                  break;
            }
         }
      }
      
      private function formatStringForPluralValue(amount:uint, string:String) : String
      {
         if(amount > 1)
         {
            string = string + "s";
         }
         return string;
      }
      
      private function addActivateOnEquipTagsToEffectsList() : void
      {
         var activateXML:XML = null;
         var stats:Dictionary = new Dictionary();
         var datas:Dictionary = new Dictionary();
         for each(activateXML in this.objectXML_.ActivateOnEquip)
         {
            var stat:int = int(activateXML.@stat);
            var amount:int = int(activateXML.@amount);

            if (stats[stat] == null) {
               stats[stat] = 0;
            }
            stats[stat] = stats[stat] + amount;
         }

         if (this.itemData_.Meta != -1 || this.itemData_.hasOwnProperty("ExtraStatBonuses"))
         {
            var k:int = -1;
            if ((k = ItemData.getStat(this.itemData_, ItemData.MAX_HP_BIT, 5, enchantmentStrength)) != 0) {
               stats[0] = (stats[0] || 0) + k;
               datas[0] = (datas[0] || 0) + k;
            }
            if ((k = ItemData.getStat(this.itemData_, ItemData.MAX_MP_BIT, 5, enchantmentStrength)) != 0) {
               stats[1] = (stats[1] || 0) + k;
               datas[1] = (datas[1] || 0) + k;
            }
            if ((k = ItemData.getStat(this.itemData_, ItemData.ATTACK_BIT, 1, enchantmentStrength)) != 0) {
               stats[2] = (stats[2] || 0) + k;
               datas[2] = (datas[2] || 0) + k;
            }
            if ((k = ItemData.getStat(this.itemData_, ItemData.DEFENSE_BIT, 1, enchantmentStrength)) != 0) {
               stats[3] = (stats[3] || 0) + k;
               datas[3] = (datas[3] || 0) + k;
            }
            if ((k = ItemData.getStat(this.itemData_, ItemData.SPEED_BIT, 1, enchantmentStrength)) != 0) {
               stats[4] = (stats[4] || 0) + k;
               datas[4] = (datas[4] || 0) + k;
            }
            if ((k = ItemData.getStat(this.itemData_, ItemData.DEXTERITY_BIT, 1, enchantmentStrength)) != 0) {
               stats[5] = (stats[5] || 0) + k;
               datas[5] = (datas[5] || 0) + k;
            }
            if ((k = ItemData.getStat(this.itemData_, ItemData.VITALITY_BIT, 1, enchantmentStrength)) != 0) {
               stats[6] = (stats[6] || 0) + k;
               datas[6] = (datas[6] || 0) + k;
            }
            if ((k = ItemData.getStat(this.itemData_, ItemData.WISDOM_BIT, 1, enchantmentStrength)) != 0) {
               stats[7] = (stats[7] || 0) + k;
               datas[7] = (datas[7] || 0) + k;
            }
         }

         var isEmpty:Boolean = true;
         var s:Object;
         for each (s in stats)
         {
            if (s != null){
               isEmpty = false;
               break;
            }
         }

         if (!isEmpty)
         {
            this.effects.push(new Effect("On Equip", ""));

            for (s in stats)
            {
               var key:int = int(s);
               var value:int = stats[s];
               var data:int = datas[key] == null ? 0 : datas[key];

               this.effects.push(new Effect("", this.addIncrementStatTag(key, value, data)));
            }
         }
      }

      private function addIncrementStatTag(stat:int, amount:int, data:int) : String
      {
         var amountString:String = null;
         var dataString:String = null;
         var textColor:String = TooltipHelper.DEFAULT_COLOR;
         if(amount > -1)
         {
            amountString = String("+" + amount);
         }
         else
         {
            amountString = String(amount);
            textColor = "#ff0000";
         }

         if (data > 0)
         {
            dataString = " (+" + data + ")";
            textColor = ItemData.getColorString(this.itemData_);
         }
         else {
            dataString = "";
         }

         return amountString + TooltipHelper.wrapInFontTag(dataString, textColor) + " " + StatData.statToName(stat);
      }
      
      private function addEquipmentItemRestrictions() : void
      {
         this.restrictions.push(new Restriction("Must be equipped to use",11776947,false));
         if(this.isInventoryFull || this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)
         {
            this.restrictions.push(new Restriction("Double-Click to equip",11776947,false));
         }
         else
         {
            this.restrictions.push(new Restriction("Double-Click to take",11776947,false));
         }
      }
      
      private function addAbilityItemRestrictions() : void
      {
         this.restrictions.push(new Restriction("Press [" + KeyCodes.CharCodeStrings[Parameters.data_.useSpecial] + "] in world to use",16777215,false));
      }
      
      private function addConsumableItemRestrictions() : void
      {
         this.restrictions.push(new Restriction("Consumed with use",11776947,false));
         if(this.isInventoryFull || this.inventoryOwnerType == InventoryOwnerTypes.CURRENT_PLAYER)
         {
            this.restrictions.push(new Restriction("Double-Click or Shift-Click on item to use",16777215,false));
         }
         else
         {
            this.restrictions.push(new Restriction("Double-Click to take & Shift-Click to use",16777215,false));
         }
      }
      
      private function addReusableItemRestrictions() : void
      {
         this.restrictions.push(new Restriction("Can be used multiple times",11776947,false));
         this.restrictions.push(new Restriction("Double-Click or Shift-Click on item to use",16777215,false));
      }
      
      private function makeRestrictionList() : void
      {
         var reqXML:XML = null;
         var reqMet:Boolean = false;
         var stat:int = 0;
         var value:int = 0;
         this.restrictions = new Vector.<Restriction>();
         if(this.objectXML_.hasOwnProperty("Soulbound"))
         {
            this.restrictions.push(new Restriction("Soulbound",9055202,false));
         }
         if(this.playerCanUse)
         {
            if(this.objectXML_.hasOwnProperty("Usable"))
            {
               this.addAbilityItemRestrictions();
               this.addEquipmentItemRestrictions();
            }
            else if(this.objectXML_.hasOwnProperty("Consumable"))
            {
               this.addConsumableItemRestrictions();
            }
            else if(this.objectXML_.hasOwnProperty("InvUse"))
            {
               this.addReusableItemRestrictions();
            }
            else
            {
               this.addEquipmentItemRestrictions();
            }
         }
         else if(this.player_ != null)
         {
            this.restrictions.push(new Restriction("Not usable by " + ObjectLibrary.typeToDisplayId_[this.player_.objectType_],16549442,true));
         }
         var usable:Vector.<String> = ObjectLibrary.usableBy(this.objectType_);
         if(usable != null)
         {
            this.restrictions.push(new Restriction("Usable by: " + usable.join(", "),11776947,false));
         }
         for each(reqXML in this.objectXML_.EquipRequirement)
         {
            reqMet = ObjectLibrary.playerMeetsRequirement(reqXML,this.player_);
            if(reqXML.toString() == "Stat")
            {
               stat = int(reqXML.@stat);
               value = int(reqXML.@value);
               this.restrictions.push(new Restriction("Requires " + StatData.statToName(stat) + " of " + value,reqMet?11776947:16549442,reqMet?Boolean(false):Boolean(true)));
            }
         }
      }
      
      private function makeRestrictionText() : void
      {
         var sheet:StyleSheet = null;
         if(this.restrictions.length != 0)
         {
            this.line2_ = new LineBreakDesign(MAX_WIDTH - 12,0);
            this.line2_.x = 8;
            this.line2_.y = this.yOffset;
            addChild(this.line2_);
            sheet = new StyleSheet();
            sheet.parseCSS(CSS_TEXT);
            this.restrictionsText_ = new SimpleText(14,11776947,false,MAX_WIDTH - 4,0);
            this.restrictionsText_.styleSheet = sheet;
            this.restrictionsText_.wordWrap = true;
            this.restrictionsText_.htmlText = "<span class=\'in\'>" + BuildRestrictionsHTML(this.restrictions) + "</span>";
            this.restrictionsText_.useTextDimensions();
            this.restrictionsText_.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
            this.restrictionsText_.x = 4;
            this.restrictionsText_.y = this.line2_.y + 8;
            addChild(this.restrictionsText_);
         }
      }
      
      private function addDescriptionText() : void
      {
         this.descText_ = new SimpleText(14,11776947,false,MAX_WIDTH,0);
         this.descText_.wordWrap = true;
         this.descText_.text = String(this.objectXML_.Description);
         this.descText_.updateMetrics();
         this.descText_.filters = [new DropShadowFilter(0,0,0,0.5,12,12)];
         this.descText_.x = 4;
         this.descText_.y = this.icon_.height + 2;
         addChild(this.descText_);
      }
      
      private function BuildEffectsHTML(effects:Vector.<Effect>) : String
      {
         var effect:Effect = null;
         var textColor:String = null;
         var html:String = "";
         var first:Boolean = true;
         for each(effect in effects)
         {
            textColor = "#FFFF8F";
            if(!first)
            {
               html = html + "\n";
            }
            else
            {
               first = false;
            }
            if(effect.name_ != "")
            {
               html = html + (effect.name_ + ": ");
            }
            html = html + ("<font color=\"" + textColor + "\">" + effect.value_ + "</font>");
         }
         return html;
      }
   }
}

class Effect
{

   public var name_:String;
   
   public var value_:String;
   
   function Effect(name:String, value:String)
   {
      super();
      this.name_ = name;
      this.value_ = value;
   }
}

import com.company.assembleegameclient.objects.Player;

class StatScaleEffect extends Effect {
   public var statScale: Number;
   public var statDurationScale: Number;
   public var statRangeScale: Number;

   public var statMin: Number;

   static function scaleFunction(stat, amount, min, scale) {
      return amount + (Math.max(0, (stat - min)) * scale);
   }

   static function getStatByString(p: Player, s): int {
      switch(s) {
         case "Health": return p.maxHP_;
         case "Mana": return p.maxMP_;
         case "Attack": return p.attack_;
         case "Defense": return p.defense_;
         case "Speed": return p.speed_;
         case "Dexterity": return p.dexterity_;
         case "Vitality": return p.vitality_;
         default: return p.wisdom_;
      }
   }

   function StatScaleEffect(name: String, value: String, oXML, player_: Player) {
      var useWisMod = oXML.hasOwnProperty('@useWisMod');
      var totalDamage = oXML.hasOwnProperty("@totalDamage") ? oXML.@totalDamage : -1;
      var amount = oXML.hasOwnProperty("@amount") ? oXML.@amount : -1;
      var duration = oXML.hasOwnProperty("@duration") ? oXML.@duration : -1;
      var range = oXML.hasOwnProperty("@range") ? oXML.@range : oXML.hasOwnProperty("@radius") ? oXML.@radius : -1;

      totalDamage = Number(totalDamage);
      amount = Number(amount);
      duration = Number(duration);
      range = Number(range);

      statScale = Number(oXML.hasOwnProperty("@statScale") ? oXML.@statScale : 0);
      statDurationScale = Number(oXML.hasOwnProperty("@statDurationScale") ? oXML.@statDurationScale : 0);
      statRangeScale = Number(oXML.hasOwnProperty("@statRangeScale") ? oXML.@statDurationScale : 0);
      statMin = Number(oXML.hasOwnProperty("@statMin") ? oXML.@statMin : 0);

      var stat = getStatByString(player_, String(oXML.hasOwnProperty('@statForScale') ? oXML.@statForScale : "Wisdom"));

      if(totalDamage != -1)
         value = value.replace("{totalDamage}", useWisMod ? scaleFunction(stat, totalDamage, statMin, statScale) : totalDamage);
      if(amount != -1)
         value = value.replace("{amount}", useWisMod ? scaleFunction(stat, amount, statMin, statScale) : amount);
      if(duration != -1)
         value = value.replace("{duration}", useWisMod ? scaleFunction(stat, duration, statMin, statDurationScale) : duration);
      if(range != -1)
         value = value.replace("{range}", useWisMod ? scaleFunction(stat, range, statMin, statRangeScale) : range);

      super(name, value);
   }
}

class Restriction
{


   public var text_:String;
   
   public var color_:uint;
   
   public var bold_:Boolean;
   
   function Restriction(text:String, color:uint, bold:Boolean)
   {
      super();
      this.text_ = text;
      this.color_ = color;
      this.bold_ = bold;
   }
}
