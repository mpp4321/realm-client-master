package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.ui.panels.CharacterChangerPanel;
import com.company.assembleegameclient.ui.panels.CrystalConversion;
import com.company.assembleegameclient.ui.panels.JobAdvancePanel;
import com.company.assembleegameclient.ui.panels.Panel;

public class CrystalConverter extends GameObject implements IInteractiveObject {

    public function CrystalConverter(objectXML:XML)
    {
        super(objectXML);
        isInteractive_ = true;
    }

    public function getPanel(gs:GameSprite) : Panel
    {
        return new CrystalConversion(gs);
    }

}
}
