function OnStatusApplied(objectGuid, status)
    if status == "DARKNESS_TECHNICAL" then
        -- Store items that have active Darkness statuses in a persistent ModVar
        DarknessParents[objectGuid] = true
        Log("Darkness cast on item: %s", objectGuid)
        SavePersistence(DarknessParents)

        -- Apply Darkness to all equipped weapons when it's cast on self to support changing weapon sets
        local characterGuid = GetWeaponWielderGuid(objectGuid)
        if characterGuid then
            local characterWeapons = GetAllCharacterWeaponGuids(characterGuid)
            for weapon, v in pairs(characterWeapons) do
                Osi.ApplyStatus(weapon, "DARKNESS", -1, 1) -- TODO Handle dual wielding better, so it doesn't affect performance
                Log("Applied DARKNESS on secondary weapon: %s", weapon)
            end
        else
            Log("Failed to get weapon wielder for: %s", objectGuid)
        end
    elseif status == "DARKNESS" then
        local entity = Ext.Entity.Get(objectGuid)
        if entity and entity.ServerItem and entity.ServerItem.Template and entity.ServerItem.Template.Id then
            local templateId = entity.ServerItem.Template.Id
            if templateId == DarknessHelperObject then
                -- Store helper objects used for summoning Darkness sphere in persistence
                DarknessParents[objectGuid] = true
                Log("Darkness spawned into world: %s", objectGuid)
                SavePersistence(DarknessParents)
            end
        else
            Log("Failed to get template id of: %s", objectGuid)
        end
    end
end

--- Kill helper object summoned by Darkness spell to clear concentration
local function DestroyDarknessHelper(objectGUID)
    if objectGUID ~= nil then
        if Ext.Entity.Get(objectGUID) then
            Osi.Die(objectGUID)
            DarknessParents[objectGUID] = nil
            Log("Destroyed Darkness helper")
            SavePersistence(DarknessParents)
        else
            Log("Failed to destroy Darkness helper: Already destroyed")
        end
    else
        Log("Failed to destroy Darkness helper: Invalid guid")
    end
end

function OnStatusRemoved(objectGuid, status)
    if status == "DARKNESS_TECHNICAL" then
        -- Remove Darkness items from persistence on status removed
        DarknessParents[objectGuid] = nil
        Log("Object lost Darkness status: %s", objectGuid)
        SavePersistence(DarknessParents)

        -- Remove Darkness from all equipped weapons
        local characterGuid = GetWeaponWielderGuid(objectGuid)
        if characterGuid then
            local characterWeapons = GetAllCharacterWeaponGuids(characterGuid)
            for weapon, v in pairs(characterWeapons) do
                Osi.RemoveStatus(weapon, "DARKNESS")
                Log("Removed DARKNESS from secondary weapon: %s", weapon)
            end
        else
            Log("Failed to get weapon wielder for: %s", objectGuid)
        end
    elseif status == "DARKNESS" then
        local entity = Ext.Entity.Get(objectGuid)
        if entity and entity.ServerItem and entity.ServerItem.Template and entity.ServerItem.Template.Id then
            local templateId = entity.ServerItem.Template.Id
            if templateId == DarknessHelperObject then
                -- Destroy helper object spawned by the spell
                SetTimer(5000, DestroyDarknessHelper, objectGuid)
                Log("Darkness helper started destroy: %s", objectGuid)
            end
        end
    elseif status == "DANCING_LIGHTS" then
        -- Darknss removes statuses from light spells <= lvl 2 using aura
        if Ext.Entity.Get(objectGuid) then
            -- Destroy helper object, which removes concentration
            Osi.Die(objectGuid)
            Log("Destroyed Dancing Lights helper")
        end
    elseif status == "MOONBEAM_AURA" then
        if Ext.Entity.Get(objectGuid) then
            Osi.Die(objectGuid)
            Log("Destroyed Moonbeam helper")
        end
    elseif status == "FLAME_BLADE" then
        if Ext.Entity.Get(objectGuid) then
            Osi.Die(objectGuid)
            Log("Destroyed Flame Blade item")
        end
    end
end

-- Remove Darkness status when item is added to inventory
function OnItemAdded(objectGuid)
    if EntityHasStatus(objectGuid, "DARKNESS") then
        Osi.RemoveStatus(objectGuid, "DARKNESS")
        Log("Item with DARKNESS added to inventory: %s", objectGuid)
    end
end

function OnItemRemoved(objectGuid)
    if EntityHasStatus(objectGuid, "DARKNESS_TECHNICAL") then
        -- Apply Darkness status when Darkness parent is taken out of the inventory
        Osi.ApplyStatus(objectGuid, "DARKNESS", -1, 1)
        Log("Darkness parent removed from inventory: %s", objectGuid)
    elseif EntityHasStatus(objectGuid, "DARKNESS") then
        -- Remove Darkness if the item was a secondary weapon wielded by character
        Osi.RemoveStatus(objectGuid, "DARKNESS")
        Log("Item with DARKNESS removed from inventory: %s", objectGuid)
    end
end

function OnEquipped(objectGuid, characterGuid)
    local item = Ext.Entity.Get(objectGuid)

    if EntityHasStatus(objectGuid, "DARKNESS_TECHNICAL") then
        -- Apply Darkness when item is equipped
        Osi.ApplyStatus(objectGuid, "DARKNESS", -1, 1)
        Log("Darkness parent equipped: %s", objectGuid)

        local characterWeapons = GetAllCharacterWeaponGuids(characterGuid)
        for weapon, v in pairs(characterWeapons) do
            -- Apply Darkness to all equipped weapons when Darkness parent is equipped
            Osi.ApplyStatus(weapon, "DARKNESS", -1, 1)
            Log("Applied DARKNESS on secondary weapon: %s", weapon)
        end
    elseif item and item.InventoryMember and item.InventoryMember.Inventory then
        local itemInventory = item.InventoryMember.Inventory

        -- Apply Darkness on equipped weapons if they share inventory with existing Darkness parent
        for darknessItemGuid, v in pairs(DarknessParents) do
            local darknessItem = Ext.Entity.Get(darknessItemGuid)
            if darknessItem and darknessItem.InventoryMember and darknessItem.InventoryMember.Inventory then
                if itemInventory == darknessItem.InventoryMember.Inventory then
                    Osi.ApplyStatus(objectGuid, "DARKNESS", -1, 1)
                    Log("Applied DARKNESS on secondary weapon: %s", objectGuid)
                end
            end
        end
    end
end

function OnUnequipped(objectGuid, characterGuid)
    local item = Ext.Entity.Get(objectGuid)

    -- Check if item was unequipped into inventory and not dropped while equipped
    if item and item.InventoryMember then
        Osi.RemoveStatus(objectGuid, "DARKNESS")
        Log("Darkness parent unequipped: %s", objectGuid)
    end

    -- Remove Darkness from all equipped weapons if Darkness parent was unequipped
    if EntityHasStatus(objectGuid, "DARKNESS_TECHNICAL") then
        local characterWeapons = GetAllCharacterWeaponGuids(characterGuid)
        for weapon, v in pairs(characterWeapons) do
            Osi.RemoveStatus(weapon, "DARKNESS")
            Log("Removed DARKNESS from secondary weapon: %s", weapon)
        end
    end
end

--- Check if the distance between entity and target position is within a certain range
---@param objectGuid string
---@param targetX number
---@param targetY number
---@param targetZ number
---@param thresholdDistance number
local function IsInDarknessAura(objectGuid, targetX, targetY, targetZ, thresholdDistance)
    local objectX, objectY, objectZ = GetWorldTranslate(objectGuid)
    if objectX and objectY and objectZ then
        local distance = CalculateDistance(objectX, objectY, objectZ, targetX, targetY, targetZ)
        if distance then
            if distance < thresholdDistance then
                return true
            end
        else
            Log("Failed to calculate distance for %s.", objectGuid)
        end
    else
        Log("Failed to get world translate for: %s.", objectGuid)
    end

    return false
end

--- Check if caster can see at a distance of the target
---@param casterGuid string
---@param targetX number
---@param targetY number
---@param targetZ number
---@return boolean
local function CasterCanSee(casterGuid, targetX, targetY, targetZ)
    if casterGuid ~= nil then
        -- Check if caster has an ability to see in magical darkness
        -- Set max sight distance depending on the source
        local sightDistance

        if EntityHasStatus(casterGuid, "TRUESIGHT") then
            sightDistance = 36.5
        elseif CharacterHasPassive(casterGuid, "DevilsSight") then
            sightDistance = 24
        elseif CharacterHasPassive(casterGuid, "FightingStyle_BlindFighting") then
            sightDistance = 3
        else
            return false
        end

        -- Calculate distance between spell target location and the caster
        local casterX, casterY, casterZ = GetWorldTranslate(casterGuid)
        if casterX and casterY and casterZ then
            local castDistance = CalculateDistance(casterX, casterY, casterZ, targetX, targetY, targetZ)
            if castDistance then
                if castDistance <= sightDistance then
                    return true
                end
            else
                Log("Failed to calculate sight distance for %s.", casterGuid)
            end
        else
            Log("Failed to get world translate for: %s.", casterGuid)
        end
    end

    return false
end

--- Restore character control after cancelling spell
---@param casterGuid string
local function UnfreezeCaster(casterGuid)
    if casterGuid ~= nil then
        Osi.Unfreeze(casterGuid)
    end
end

-- Check if a spell that targets a place is being cast inside Darkness
function OnUsingSpellAtPosition(casterGuid, x, y, z, spell)
    if casterGuid ~= nil and next(DarknessParents) and DarknessPlaceSpells[spell] then
        local parents = DarknessParents
        -- Iterate over all active Darkness parent objects stored in persistence
        for objectGuid, _ in pairs(parents) do
            -- Check if spell target is inside Darkness aura of 5m
            if IsInDarknessAura(objectGuid, x, y, z, 5) then
                if not CasterCanSee(casterGuid, x, y, z) then
                    -- Apply overhead status "Spell requires sight!"
                    Osi.ApplyStatus(casterGuid, "CAST_INDARKNESS_FAILED", 0, 1) -- TODO find better UX
                    -- Cancel casting
                    Osi.Freeze(casterGuid)
                    SetTimer(100, UnfreezeCaster, casterGuid)
                    return
                end
            end
        end
    end
end

function OnSessionLoaded()
    Log("SESSION LOADED - SERVER")
    LoadPersistence()
    LoadDarknessPlaceSpells()
end
