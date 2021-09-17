package com.company.assembleegameclient.ui.panels {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.dialogs.MixerDialog;

import flash.events.MouseEvent;

public class MixPanel extends ButtonPanel {
    public function MixPanel(gs: GameSprite) {
        super(gs, "Mixing Device", "View");
    }

    override protected function onButtonClick(event:MouseEvent) : void
    {
        var p : Player = gs_.map.player_;
        if(p == null)
        {
            return;
        }
        gs_.addChild(new MixerDialog(p));
    }

}
}
