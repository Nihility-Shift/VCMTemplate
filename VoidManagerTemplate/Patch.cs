using HarmonyLib;

namespace VCMTemplate
{
    [HarmonyPatch(typeof(MainMenu), "Start")]
    class Patch
    {
        static void Postfix()
        {
            BepinPlugin.Log.LogInfo("Example Patch Executed");
        }
    }
}
