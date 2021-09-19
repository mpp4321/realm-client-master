package com.company.assembleegameclient.ui.dialogs {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.InventoryTile;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileEvent;
import com.company.util.GraphicsUtil;
import com.company.util.MoreColorUtil;

import flash.display.CapsStyle;
import flash.display.Graphics;

import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Shape;

import flash.display.Sprite;

import flash.events.Event;

import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.ui.view.HUDView;

public class MixerDialog extends Sprite {

    public function MixerDialog(p: Player) {
        super();

        var pt = p.map_.gs_.hudView.EQUIPMENT_INVENTORY_POSITION;
        this.x = pt.x;
        this.y = pt.y;
        //p.map_.gs_.hudView.background.addChild(this);
        //p.map_.gs_.hudView.equippedGridBG.transform = MoreColorUtil.veryDarkCT;

        for(var i = 0; i < 4; i++) {
            var sprite = new Sprite();

            sprite.x = i * 40;

            sprite.graphics.beginFill(0x555555, 0.9);
            sprite.graphics.drawRect(0, 0, 40, 40);
            sprite.graphics.endFill();

            addChild(sprite);
        }
    }

    public function middleIt(slot) {
        slot.x = this.x - this.width / 2;
        slot.y = this.y - this.height / 2;
    }

    //8 slots to select on ui
    public var selectedSlots: Vector.<Boolean>;

    public function draw() {
    }

    public function mix(ev: Event) {
        //player.map_.gs_.gsc_.mix(slot1Id, slot2Id);
    }

}
}
