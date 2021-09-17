package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.MixPanel;
import com.company.assembleegameclient.ui.panels.Panel;

public class MixingBowl extends GameObject implements IInteractiveObject {

    public function MixingBowl(objectXML:XML)
    {
        super(objectXML);
        isInteractive_ = true;
    }

    public function getPanel(gs:GameSprite) : Panel
    {
        return new MixPanel(gs);
    }

}
}
