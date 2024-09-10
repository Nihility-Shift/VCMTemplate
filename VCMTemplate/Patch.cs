using HarmonyLib;

namespace VCMTemplate
{
    [HarmonyPatch(typeof(MainMenu), "Start")]
    class Patch
    {
        static void Postfix()
        {
            Plugins.Log.LogInfo("Example Patch Executed");
        }
    }
}
