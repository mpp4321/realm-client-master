package com.company.assembleegameclient.ui {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.ButtonPanel;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileSprite;

import flash.display.GraphicsSolidFill;
import flash.display.Sprite;
import flash.events.MouseEvent;

import kabam.rotmg.util.components.LegacyBuyButton;

import starling.events.Event;

internal class RuneRectangle extends Sprite {
    private var _type: int;
    private var _runeCost: int;

    private var _background: Sprite;
    private var _itemSprite: ItemTileSprite;
    private var _removeButton: TextButton;

    private var _index: int;
    private var _removeMe;

    public function type(): int {
        return _type;
    }

    public function RuneRectangle(index: int, type: int, runeCost: int, removeMe) {
        _index = index
        _type = type;
        _runeCost = runeCost;

        _removeMe = removeMe

        _background = new Sprite();
        _background.width = 300 - 16;
        _background.height = 100;

        _removeButton = new TextButton(100, "Remove");
        _removeButton.width = 100;
        _removeButton.height = 32;
        _removeButton.x = 105
        // Centered for some reason
        _removeButton.y = -16
        _removeButton.addEventListener(MouseEvent.CLICK, function (_e) {
            _removeMe(_index)
        })
        addChild(_removeButton)

        var g = _background.graphics;
        g.clear();
        g.beginFill(0x545454,1);
        g.drawRect(0, 0, _background.width, _background.height);
        g.endFill();

        _itemSprite = new ItemTileSprite();
        _itemSprite.setType(type, null);
        _itemSprite.x = 50;
        _itemSprite.width = 100;
        _itemSprite.height = 100;

        addChild(_background)
        addChild(_itemSprite)
    }
}
}
