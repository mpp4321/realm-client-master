package com.company.assembleegameclient.ui {

import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.RuneRectangle;

import flash.display.GraphicsSolidFill;
import flash.display.Sprite;
import flash.events.MouseEvent;

public class RuneUi extends Sprite {

    private var _scrollbar: Scrollbar;
    private var _runes: Array;
    public var gs: GameSprite;
    private var _closeButton: TextButton;

    private static var typeToRuneId = {
        0xcb4: "Brute",
        0xcaf: "Vampirism",
        0xcb5: "Mage",
        0xcf6: "Juggernaut"
    };

    public function initWithGs(gs: GameSprite) {
        this.gs = gs;
        this.gs.runeMenu = this;

        var oRef = this;

        _closeButton = new TextButton(25, "Close");
        _closeButton.x = 300 - 66;
        _closeButton.y = 400 - 50;
        _closeButton.addEventListener(
                MouseEvent.CLICK,
                function(e: MouseEvent) {
                    var gs = oRef.gs;
                    gs.removeChild(gs.runeMenu);
                    gs.runeMenu = null;
                }
        );
        addChild(_closeButton);
    }

    public function RuneUi() {
        this.graphics.clear()
        this.graphics.beginFill(0x434343);
        this.graphics.drawRect(0, 0, 300, 400);
        this.graphics.endFill();

        _runes = new Array()
        _scrollbar = new Scrollbar(16, 400);
        _scrollbar.x = 300 - 16;

        addChild(_scrollbar)
    }

    public function removeRune(indx: int) {
        for(var i = indx + 1; i < _runes.length; i++) {
            _runes[i]._index--;
        }
        var obj = _runes.splice(indx, 1);
        gs.gsc_.removeRune(typeToRuneId[obj[0].type()]);
        removeChild(obj[0])
        adjustLocations()
    }

    public function adjustLocations() {
        for(var i = 0; i < _runes.length; i++) {
            var runeRectangle = _runes[i];
            runeRectangle.y = i * 100 + 50;
        }
    }

    public function addRune(type: int, cost: int) {
        var nextPos = _runes.length
        var runeRectangle = new RuneRectangle(nextPos, type, cost, removeRune);
        runeRectangle.x = 150 - (runeRectangle.width / 2)
        runeRectangle.y = nextPos * 100 + 50;
        addChild(runeRectangle)
        _runes.push(runeRectangle)
    }

}
}
