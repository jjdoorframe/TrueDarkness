---Template guid of Darkness helper object summoned by the spell
---@type string
DarknessHelperObject = "bdddd432-a5fd-4110-bfc2-90d7792631a0"

---Return user status that's using a mod's status
---@param guid string
---@param statusIn string
---@return string | nil
function GetEntityStatus(guid, statusIn)
    local entity = Ext.Entity.Get(guid)

    if entity and entity.StatusContainer and entity.StatusContainer.Statuses then
        local entityStatuses = entity.StatusContainer.Statuses

        for _, statusId in pairs(entityStatuses) do
            local status = Ext.Stats.Get(statusId)

            if statusId == statusIn or (status and status.Using and status.Using == statusIn) then
                return statusId
            end
        end
    end

    return nil
end

---Check if character has passive
---@param guid string
---@param passiveName string
---@return boolean
function CharacterHasPassive(guid, passiveName)
    local character = Ext.Entity.Get(guid)

    if not character or not character.ServerCharacter then
        Log("Received guid is not a character: %s", guid)
        return false
    end

    if character.PassiveContainer and character.PassiveContainer.Passives then
        local characterPassives = character.PassiveContainer.Passives

        for _, passiveEntity in ipairs(characterPassives) do
            if passiveEntity.Passive.PassiveId == passiveName then
                return true
            end
        end
    end

    return false
end

---Check if character has a status immunity
---@param guid string
---@param immunityName string
---@return boolean
function CharacterHasImmunity(guid, immunityName)
    local character = Ext.Entity.Get(guid)

    if not character or not character.ServerCharacter then
        Log("Received guid is not a character: %s", guid)
        return false
    end

    if character.StatusImmunities and character.StatusImmunities.PersonalStatusImmunities then
        local characterImmunities = character.StatusImmunities.PersonalStatusImmunities

        for immunity, _ in pairs(characterImmunities) do
            if immunity == immunityName then
                return true
            end
        end
    end

    return false
end

---Return world translate of an entity by guid
---@param guid string
---@return number|nil, number|nil, number|nil
function GetWorldTranslate(guid)
    local entity = Ext.Entity.Get(guid)
    local translate

    if entity and entity.Transform and entity.Transform.Transform and entity.Transform.Transform.Translate then
        translate = entity.Transform.Transform.Translate
    else
        translate = {nil, nil, nil}
    end

    return translate[1], translate[2], translate[3]
end

--- Calculate 3D distance between coordinates
---@param x1 number|nil
---@param y1 number|nil
---@param z1 number|nil
---@param x2 number|nil
---@param y2 number|nil
---@param z2 number|nil
---@return number|nil
function CalculateDistance(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--- Return all weapons that character has equipped
---@param characterGuid string
---@return table
function GetAllCharacterWeaponGuids(characterGuid)
    local character = Ext.Entity.Get(characterGuid)
    local weaponGuids = {}

    if character and character.InventoryOwner and character.InventoryOwner.Inventories then
        local inventories = character.InventoryOwner.Inventories

        for _, inventory in ipairs(inventories) do
            local itemEntities = inventory.InventoryContainer.Items

            for _, itemEntity in pairs(itemEntities) do
                local item = itemEntity.Item
                
                if item.Wielding and item.Weapon then
                    local itemGuid = item.Uuid.EntityUuid
                    weaponGuids[itemGuid] = true
                end
            end
        end
    end

    return weaponGuids
end

--- Return guid of a character wielding a weapon
---@param itemGuid string
---@return string|nil
function GetWeaponWielderGuid(itemGuid)
    local item = Ext.Entity.Get(itemGuid)

    if item and item.Wielding and item.Weapon then
        local character = item.Wielding.Owner

        if character and character.Uuid then
            return character.Uuid.EntityUuid
        end
    end

    return nil
end