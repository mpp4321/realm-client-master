package com.company.util {
public class MichaelUtil {
    public static function getIfFieldExistsOr(obj: Object, field: String, defaul) {
        if(obj.hasOwnProperty(field)) {
            return obj[field].text()[0];
        }
        return defaul;
    }

    public static function determineEnchantmentStrength(xml) : Number
    {
        var enchantmentStrength = Number(MichaelUtil.getIfFieldExistsOr(xml, "EnchantmentStrength", -1.0));
        var tier = MichaelUtil.getIfFieldExistsOr(xml, "Tier", 0);
        if(enchantmentStrength < 0) {
            if(tier != 0)
                enchantmentStrength = Math.ceil(MichaelUtil.getIfFieldExistsOr(xml, "Tier", 1) / 2);
            else
                enchantmentStrength = 6.0;
        } else {
        }
        return enchantmentStrength;
    }
}
}
