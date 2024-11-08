function OnStatusApplied(objectGuid, statusId)
    local status = Ext.Stats.Get(statusId)
    local isDarknessSummon = false
    local isDarknessItem = false

    if status and status.AuraRadius ~= "" then
        if statusId == "DARKNESS" or (status.Using and status.Using == "DARKNESS") then
            isDarknessSummon = true
        elseif statusId == "DARKNESS_TECHNICAL" or (status.Using and status.Using == "DARKNESS_TECHNICAL") then
            isDarknessItem = true
        end
    end

    if isDarknessItem then
        -- Store items that have active Darkness statuses in a persistent ModVar
        local statusDarkness = GetEntityStatus(objectGuid, "DARKNESS")

        DarknessParents[objectGuid] = {
            Radius = status.AuraRadius,
            Darkness = statusDarkness,
            Active = true
        }

        SavePersistence()

        Log("Darkness cast on item: %s", objectGuid)

        -- Apply Darkness to all equipped weapons when it's cast on self to support changing weapon sets
        local characterGuid = GetWeaponWielderGuid(objectGuid)

        if characterGuid then
            local characterWeapons = GetAllCharacterWeaponGuids(characterGuid)

            for weapon, _ in pairs(characterWeapons) do
                Osi.ApplyStatus(weapon, statusDarkness, -1, 1) -- TODO Handle dual wielding better, so it doesn't affect performance

                Log("Applied DARKNESS on secondary weapon: %s", weapon)
            end
        else
            Log("Failed to get weapon wielder for: %s", objectGuid)
        end
    elseif isDarknessSummon then
        -- Store Darkness helper objects summoned by the spell in a persistent ModVar
        local entity = Ext.Entity.Get(objectGuid)

        if entity and entity.ServerItem and entity.ServerItem.Template and entity.ServerItem.Template.Id then
            local templateId = entity.ServerItem.Template.Id

            if templateId == DarknessHelperObject then
                DarknessParents[objectGuid] = {
                    Radius = status.AuraRadius,
                    Darkness = statusId,
                    Active = true
                }

                SavePersistence()

                Log("Darkness spawned into world: %s", objectGuid)
            end
        else
            Log("Failed to get template id of: %s", objectGuid)
        end

    elseif statusId == "VOID_AURA" then
        -- Store Hunger of Harad in persistence
        -- Doesn't need any checks because status is only ever applied to helper object
        HadarParents[objectGuid] = true
        SavePersistence()

        Log("Hunger of Hadar spawned into world: %s", objectGuid)
    elseif statusId == "DARKNESS_REMOVE" then
        local statusDarkness = GetEntityStatus(objectGuid, "DARKNESS")
        local statusTechnical = GetEntityStatus(objectGuid, "DARKNESS_TECHNICAL")

        if statusTechnical then
            Osi.RemoveStatus(objectGuid, statusTechnical)

            Log("Daylight dispelled Darkness from item: %s", objectGuid)
        elseif statusDarkness then
            Osi.RemoveStatus(objectGuid, statusDarkness)

            Log("Daylight dispelled Darkness from: %s", objectGuid)
        end
    end
end

--- Kill helper object summoned by Darkness spell to clear concentration
local function DestroyDarknessHelper(objectGuid)
    if objectGuid ~= nil then
        if Ext.Entity.Get(objectGuid) then
            Osi.Die(objectGuid)
            SavePersistence()

            Log("Destroyed Darkness helper")
        else
            Log("Failed to destroy Darkness helper: Already destroyed")
        end
    else
        Log("Failed to destroy Darkness helper: Invalid guid")
    end
end

function OnStatusRemoved(objectGuid, statusId)
    local status = Ext.Stats.Get(statusId)
    local isDarknessSummon = false
    local isDarknessItem = false

    if status and status.AuraRadius then
        if statusId == "DARKNESS" or (status.Using and status.Using == "DARKNESS") then
            isDarknessSummon = true
        elseif statusId == "DARKNESS_TECHNICAL" or (status.Using and status.Using == "DARKNESS_TECHNICAL") then
            isDarknessItem = true
        end
    end

    if isDarknessItem then
        -- Remove Darkness items from persistence on status removed
        local statusDarkness = DarknessParents[objectGuid].Darkness

        DarknessParents[objectGuid] = nil
        SavePersistence()

        Log("Object lost Darkness status: %s", objectGuid)

        -- Remove Darkness from all equipped weapons
        local characterGuid = GetWeaponWielderGuid(objectGuid)
        
        if characterGuid then
            local characterWeapons = GetAllCharacterWeaponGuids(characterGuid)

            for weapon, v in pairs(characterWeapons) do
                Osi.RemoveStatus(weapon, statusDarkness)

                Log("Removed DARKNESS from secondary weapon: %s", weapon)
            end
        else
            Log("Failed to get weapon wielder for: %s", objectGuid)
        end
    elseif isDarknessSummon then
        local entity = Ext.Entity.Get(objectGuid)

        if entity and entity.ServerItem and entity.ServerItem.Template and entity.ServerItem.Template.Id then
            local templateId = entity.ServerItem.Template.Id

            if templateId == DarknessHelperObject then
                -- Destroy helper object spawned by the spell
                DarknessParents[objectGuid] = nil
                SetTimer(5000, DestroyDarknessHelper, objectGuid)

                Log("Darkness helper started destroy: %s", objectGuid)
            end
        end
    elseif statusId == "VOID_AURA" then
        HadarParents[objectGuid] = nil

        Log("Hunger of Hadar was destroyed: %s", objectGuid)
        SavePersistence()
    elseif statusId == "DANCING_LIGHTS" then
        -- Darknss removes statuses from light spells <= lvl 2 using aura
        if Ext.Entity.Get(objectGuid) then
            -- Destroy helper object, which removes concentration
            Osi.Die(objectGuid)

            Log("Destroyed Dancing Lights helper")
        end
    elseif statusId == "MOONBEAM_AURA" then
        if Ext.Entity.Get(objectGuid) then
            Osi.Die(objectGuid)

            Log("Destroyed Moonbeam helper")
        end
    elseif statusId == "FLAME_BLADE" then
        if Ext.Entity.Get(objectGuid) then
            Osi.Die(objectGuid)
            
            Log("Destroyed Flame Blade item")
        end
    end
end

-- Remove Darkness status when item is added to inventory
function OnItemAdded(objectGuid)
    local status = GetEntityStatus(objectGuid, "DARKNESS")

    if status then
        if DarknessParents[objectGuid] then
            DarknessParents[objectGuid].Active = true
        end

        Osi.RemoveStatus(objectGuid, status)

        Log("Item with DARKNESS added to inventory: %s", objectGuid)
    end
end

function OnItemRemoved(objectGuid)
    local statusDarkness = GetEntityStatus(objectGuid, "DARKNESS")

    if statusDarkness then
        -- Remove Darkness if the item was a secondary weapon wielded by character
        Osi.RemoveStatus(objectGuid, statusDarkness)

        Log("Item with DARKNESS removed from inventory: %s", objectGuid)
    elseif GetEntityStatus(objectGuid, "DARKNESS_TECHNICAL") then
        -- Apply Darkness status when Darkness parent is taken out of the inventory
        statusDarkness = DarknessParents[objectGuid].Darkness

        Osi.ApplyStatus(objectGuid, statusDarkness, -1, 1)
        DarknessParents[objectGuid].Active = true

        Log("Darkness parent removed from inventory: %s", objectGuid)
    end
end

function OnEquipped(objectGuid, characterGuid)
    local item = Ext.Entity.Get(objectGuid)
    local statusDarkness

    if GetEntityStatus(objectGuid, "DARKNESS_TECHNICAL") then
        -- Apply Darkness when item is equipped
        statusDarkness = DarknessParents[objectGuid].Darkness

        Osi.ApplyStatus(objectGuid, statusDarkness, -1, 1)
        DarknessParents[objectGuid].Active = true

        Log("Darkness parent equipped: %s", objectGuid)

        local characterWeapons = GetAllCharacterWeaponGuids(characterGuid)

        for weapon, v in pairs(characterWeapons) do
            -- Apply Darkness to all equipped weapons when Darkness parent is equipped
            Osi.ApplyStatus(weapon, statusDarkness, -1, 1)

            Log("Applied DARKNESS on secondary weapon: %s", weapon)
        end
    elseif item and item.InventoryMember and item.InventoryMember.Inventory then
        local itemInventory = item.InventoryMember.Inventory

        -- Apply Darkness on equipped weapons if they share inventory with existing Darkness parent
        for darknessItemGuid, _ in pairs(DarknessParents) do
            local darknessItem = Ext.Entity.Get(darknessItemGuid)

            if darknessItem and darknessItem.InventoryMember and darknessItem.InventoryMember.Inventory then
                if itemInventory == darknessItem.InventoryMember.Inventory then
                    statusDarkness = DarknessParents[darknessItemGuid].Darkness
                    Osi.ApplyStatus(objectGuid, statusDarkness, -1, 1)
                    
                    Log("Applied DARKNESS on secondary weapon: %s", objectGuid)
                end
            end
        end
    end
end

function OnUnequipped(objectGuid, characterGuid)
    local item = Ext.Entity.Get(objectGuid)
    local statusDarkness = GetEntityStatus(objectGuid, "DARKNESS")

    -- Check if item was unequipped into inventory and not dropped while equipped
    if item and item.InventoryMember and statusDarkness then
        if DarknessParents[objectGuid] then
            DarknessParents[objectGuid].Active = false
        end

        Osi.RemoveStatus(objectGuid, statusDarkness)

        Log("Darkness parent unequipped: %s", objectGuid)
    end

    -- Remove Darkness from all equipped weapons if Darkness parent was unequipped
    if GetEntityStatus(objectGuid, "DARKNESS_TECHNICAL") then
        local characterWeapons = GetAllCharacterWeaponGuids(characterGuid)

        for weapon, v in pairs(characterWeapons) do
            Osi.RemoveStatus(weapon, statusDarkness)
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
---@alias SightCheckType "darkness" | "hadar"
---@param casterGuid string
---@param checkType SightCheckType
---@param targetX number
---@param targetY number
---@param targetZ number
---@return boolean
local function CasterCanSee(casterGuid, checkType, targetX, targetY, targetZ)
    if casterGuid ~= nil then
        -- Check if caster has an ability to see in magical darkness
        -- Set max sight distance depending on the source
        local sightDistance

        -- Always allow casting spells with blind immunity
        -- Changed from "Blindsight" for item support
        if CharacterHasImmunity(casterGuid, "SG_Blinded") then
            return true
        end

        -- Check each ability in reverse order of sight distance
        -- Truesight and Devil's Sight only allow seeing in magical darkness, not HoH
        if checkType == "darkness" then
            if GetEntityStatus(casterGuid, "TRUESIGHT") then
                sightDistance = 36.5
            elseif CharacterHasPassive(casterGuid, "DevilsSight") then
                sightDistance = 24
            end
        end

        -- Blind Fighting gives Blindsight up to 10ft/3m
        -- Only check if creature doesn't have a better ability
        if not sightDistance and CharacterHasPassive(casterGuid, "FightingStyle_BlindFighting") then
            sightDistance = 3
        elseif not sightDistance then
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
function OnUsingSpellAtPosition(casterGuid, x, y, z, spell) -- TODO Switch to dynamic distance based on parent status
    if casterGuid ~= nil and DarknessPlaceSpells[spell] then
        local darknessRefs = DarknessParents
        local hadarRefs = HadarParents

        -- Iterate over all active Darkness parent objects stored in persistence
        for objectGuid, data in pairs(darknessRefs) do
            -- Check if spell target is inside Darkness aura of 5m
            if data.Active and IsInDarknessAura(objectGuid, x, y, z, data.Radius) then
                if not CasterCanSee(casterGuid, "darkness", x, y, z) then
                    -- Apply overhead status "Spell requires sight!"
                    Osi.ApplyStatus(casterGuid, "CAST_INDARKNESS_FAILED", 0, 1) -- TODO find better UX
                    -- Cancel casting
                    Osi.Freeze(casterGuid)
                    SetTimer(100, UnfreezeCaster, casterGuid)
                    return
                end
            end
        end

        -- Cancel cast if target is inside HoH
        for objectGuid, _ in pairs(hadarRefs) do
            if IsInDarknessAura(objectGuid, x, y, z, 6) then
                if not CasterCanSee(casterGuid, "hadar", x, y, z) then
                    Osi.ApplyStatus(casterGuid, "CAST_INDARKNESS_FAILED", 0, 1)
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
