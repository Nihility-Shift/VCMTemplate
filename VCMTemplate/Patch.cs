using CG.Client.UI;
using HarmonyLib;

namespace VCMTemplate
{
    [HarmonyPatch(typeof(FadeController), "Start")]
    class Patch
    {
        static void Postfix()
        {
            BepinPlugin.Log.LogInfo("Example Patch Executed");
        }
    }
}
