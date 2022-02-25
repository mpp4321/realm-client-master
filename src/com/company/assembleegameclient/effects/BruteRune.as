package com.company.assembleegameclient.effects {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.Projectile;

public class BruteRune implements ItemEffect {
    public function OnProjectileShoot(player: Player, projectile:Projectile):void {
        projectile.damage_ += projectile.damage_ * player.getBoosts(6) * 0.01;
    }
}
}
