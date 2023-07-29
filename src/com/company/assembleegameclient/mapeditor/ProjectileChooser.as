package com.company.assembleegameclient.mapeditor
{
   import com.company.assembleegameclient.map.GroundLibrary;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.util.MoreStringUtil;
   
   public class ProjectileChooser extends Chooser
   {
       
      function ProjectileChooser()
      {
         var id:* = null;
         var type:int = 0;
         var tileElement:ObjectElement = null;
         super(Layer.OBJECT);
         var ids:Vector.<String> = new Vector.<String>();
         for(id in ObjectLibrary.xmlLibrary_)
         {
            var v = ObjectLibrary.xmlLibrary_[id];
            if(String(v.Class) == "Projectile") {
               ids.push(id);
            }
         }
         ids.sort(MoreStringUtil.cmp);
         for each(id in ids)
         {
            tileElement = new ObjectElement(ObjectLibrary.xmlLibrary_[id]);
            addElement(tileElement);
         }
      }
   }
}
