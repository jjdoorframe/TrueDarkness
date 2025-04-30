Ext.Events.SessionLoaded:Subscribe(function()
    OnSessionLoaded()
end)

-- Listener for Darkness status applied
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(objectGuid, status, causee, storyActionID)
    OnStatusApplied(GetShortGuid(objectGuid), status)
end)

-- Listener for Darkness statuses removed
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(objectGuid, status, cause, storyActionID)
    OnStatusRemoved(GetShortGuid(objectGuid), status)
end)

-- Listener for item with Darkness added to inventory
Ext.Osiris.RegisterListener("AddedTo", 3, "after", function(objectGuid, inventoryHolder, addType)
    OnItemAdded(GetShortGuid(objectGuid))
end)

-- Listener for item removed from inventory
Ext.Osiris.RegisterListener("RemovedFrom", 2, "after", function(objectGuid, inventoryHolder)
    OnItemRemoved(GetShortGuid(objectGuid))
end)

-- Listener for item equipped for character
Ext.Osiris.RegisterListener("Equipped", 2, "after", function(objectGuid, character)
    OnEquipped(GetShortGuid(objectGuid), character)
end)

-- Listener for item unequipped from character
Ext.Osiris.RegisterListener("Unequipped", 2, "after", function(objectGuid, character)
    OnUnequipped(GetShortGuid(objectGuid), character)
end)

-- Listener for caster using a spell targeting ground
Ext.Osiris.RegisterListener("UsingSpellAtPosition", 8, "before",
    function(casterGuid, x, y, z, spell, spellType, spellElement, story)
        OnUsingSpellAtPosition(casterGuid, x, y, z, spell)
    end)

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function()
    ClearOutdatedDarkness()
end)