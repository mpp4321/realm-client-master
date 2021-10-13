package com.company.assembleegameclient.effects {
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.objects.Projectile;

public interface ItemEffect {

    function OnProjectileShoot(player: Player, projectile: Projectile): void;

}
}
