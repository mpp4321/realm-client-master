package com.company.assembleegameclient.util {
import avmplus.metadataXml;

import starling.utils.Color;

public class ItemData
{
    public static const MAX_HP_BIT:uint = 1 << 8;
    public static const MAX_MP_BIT:uint = 1 << 9;
    public static const ATTACK_BIT:uint = 1 << 10;
    public static const DEFENSE_BIT:uint = 1 << 11;
    public static const SPEED_BIT:uint = 1 << 12;
    public static const DEXTERITY_BIT:uint = 1 << 13;
    public static const VITALITY_BIT:uint = 1 << 14;
    public static const WISDOM_BIT:uint = 1 << 15;
    public static const RATE_OF_FIRE_BIT:uint = 1 << 16;
    public static const DAMAGE_BIT:uint = 1 << 17;
    public static const COOLDOWN_BIT:uint = 1 << 18;
    public static const FAME_BONUS_BIT:uint = 1 << 19;

    public static const COOLDOWN_MULTIPLIER:Number = 0.05;
    public static const DAMAGE_MULTIPLIER:Number = 0.05;
    public static const RATE_OF_FIRE_MULTIPLIER:Number = 0.05;

    public static function hasStat(data:int, bit:uint) : Boolean
    {
        if (data == -1) {
            return false;
        }
        return (uint(data) & bit) != 0
    }

    public static function getExtraStats(obj: Object, bit: uint): int {
        if('ExtraStatBonuses' in obj) {
            if(("" +bit) in obj.ExtraStatBonuses) {
                return int(obj.ExtraStatBonuses["" + bit]);
            }
        }
        return 0;
    }

    public static function getStat(obj:Object, bit:uint, multiplier:Number, enchantmentStrength:Number) : Number
    {
        if(obj == null) return 0;
        var data = obj.Meta;
        var rank:int = getRank(obj);
        var value:int = 0;
        if (hasStat(data, bit))
        {
            value += rank;
        }
        var finish = (value + getExtraStats(obj, bit));
        return finish * multiplier;
    }

    public static function getRank(data: Object) : int
    {
        if(data == null) return -1;
        return data.hasOwnProperty("ItemLevel") ? data.ItemLevel : -1;
    }

    public static function getColor(data: Object) : int
    {
        var rank = getRank(data);
        if (rank == -1) {
            return -1;
        }
        if (rank % 8 == 0)
        {
            return 0x00a6ff;
        }
        else if (rank % 8 == 1)
        {
            return 0x7300ff;
        }
        else if (rank % 8 == 2)
        {
            return 0xffc800;
        }
        else if (rank % 8 == 3)
        {
            return 0x84ff00;
        }
        else if (rank % 8 == 4)
        {
            return 0xf542e6;
        }
        else if (rank % 8 == 5)
        {
            return 0x00ffdd;
        }
        else if (rank % 8 == 6)
        {
            return 0xffffff;
        }
        else if (rank % 8 == 7)
        {
            return 0xff5500;
        }
        return -1;
    }

    public static function getColorString(data:Object) : String
    {
        var rank = getRank(data);
        if (rank == -1) return "";
        if (rank % 8 == 0)
        {
            return "#00a6ff";
        }
        else if (rank % 8 == 1)
        {
            return "#7300ff";
        }
        else if (rank % 8 == 2)
        {
            return "#ffc800";
        }
        else if (rank % 8 == 3)
        {
            return "#84ff00";
        }
        else if (rank % 8 == 4)
        {
            return "#f542e6";
        }
        else if (rank % 8 == 5)
        {
            return "#00ffdd";
        }
        else if (rank % 8 == 6)
        {
            return "#ffffff";
        }
        else if (rank % 8 == 7)
        {
            return "#ff5500";
        }
        return "";
    }
}
}
