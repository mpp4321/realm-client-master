package com.company.assembleegameclient.effects {
import flash.utils.Dictionary;

public class EffectsLibrary {

    private static var itemEffects: Dictionary = null;

    public function getEffects(): Dictionary {
        return itemEffects;
    }

    public function EffectsLibrary() {
        if(itemEffects == null) {
            itemEffects = new Dictionary();
            itemEffects["Brute"] = new BruteRune();
        }
    }
}
}
