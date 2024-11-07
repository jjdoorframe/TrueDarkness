Ext.Require("Shared/_DarknessModUtils.lua")
Ext.Require("Server/_DarknessGameplayUtils.lua")
Ext.Require("Server/_DarknessListeners.lua")
Ext.Require("Server/DarknessController.lua")

-- Requires DebuggingEnabled in _DarknessUtils.lua
Ext.Events.ResetCompleted:Subscribe(ReloadStats)

-- ModVars
Ext.Vars.RegisterModVariable(ModuleUUID, "DarknessParents", {
    Server = true
})

Ext.Vars.RegisterModVariable(ModuleUUID, "HadarParents", {
    Server = true
})