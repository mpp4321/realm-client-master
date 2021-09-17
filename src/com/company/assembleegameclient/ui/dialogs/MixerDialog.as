package com.company.assembleegameclient.ui.dialogs {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.InventoryTile;
import com.company.assembleegameclient.ui.panels.itemgrids.itemtiles.ItemTileEvent;
import com.company.util.GraphicsUtil;

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

public class MixerDialog extends Sprite {

    public var slot1: InventoryTile;
    public var slot2: InventoryTile;

    public var slot1Id: int = -1;
    public var slot2Id: int = -1;

    public var player: Player;

    private var outlineFill_ : GraphicsSolidFill = new GraphicsSolidFill(16777215,1);
    private var lineStyle_ : GraphicsStroke = new GraphicsStroke(1, false,LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND,3,outlineFill_);
    private var backgroundFill_:GraphicsSolidFill= new GraphicsSolidFill(3552822,1);
    protected var path_:GraphicsPath= new GraphicsPath(new Vector.<int>(),new Vector.<Number>());
    protected const graphicsData_:Vector.<IGraphicsData> = new <IGraphicsData>[ lineStyle_, backgroundFill_, path_, GraphicsUtil.END_FILL, GraphicsUtil.END_STROKE];

    public function middleIt(slot) {
        slot.x = this.x - this.width / 2;
        slot.y = this.y - this.height / 2;
    }

    public function MixerDialog(player: Player) {
        super();
        this.player = player;




        addEventListener(Dialog.BUTTON1_EVENT, this.mix);
        addEventListener(ItemTileEvent.ITEM_MOVE,this.onTileMove);

        slot1 = new InventoryTile(99, null, true);
        slot2 = new InventoryTile(100, null, true);

        slot1.buildHotKeyBMP();
        slot2.buildHotKeyBMP();

        slot1.setItem(0xc8a, { Meta: -1 });
        slot2.setItem(0xc8a, { Meta: -1 });

        middleIt(slot1); middleIt(slot2);

        addChild(slot1);
        addChild(slot2);
    }

    protected function draw() : void {

//        GraphicsUtil.clearPath(this.path_);
//        GraphicsUtil.drawCutEdgeRect(0,0,WIDTH,this.box_.height + 10,4,[1,1,1,1],this.path_);
//        this.rect_ = new Shape();
//        var g:Graphics = this.rect_.graphics;
//        g.drawGraphicsData(this.graphicsData_);
//        this.box_.addChildAt(this.rect_,0);
//        this.box_.filters = [new DropShadowFilter(0,0,0,1,16,16,1)];
//        addChild(this.box_);

    }

    public function onTileMove(ev: ItemTileEvent) {
        var a = ev.tile.tileId;
    }

    public function mix(ev: Event) {
        player.map_.gs_.gsc_.mix(slot1Id, slot2Id);
    }

}
}
