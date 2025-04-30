-- Credit: Zerd (https://www.nexusmods.com/baldursgate3/mods/1329)
-- For defining recursive checks that find spells related to root
---Recursively check and add interrupts to a table
---@param interruptsIn table
---@param spellGroup table
---@return boolean
local function AddInterruptsToTable(interruptsIn, interrupt, spellGroup)
    if not interrupt or spellGroup[interrupt.Name] or not interrupt.Name then
        return false
    end

    -- Check if the interrupt is directly in the table or matches the criteria for a relevant interrupt
    spellGroup[interrupt.Name] = true
    if interruptsIn[interrupt.Name] then
        return true
    end

    -- Check recursively if this interrupt uses another interrupt as a base (Using attribute)
    if interrupt.Using and interrupt.Using ~= "" then
        local usingInterrupt = Ext.Stats.Get(interrupt.Using)
        if usingInterrupt and usingInterrupt.Name ~= interrupt.Name then
            if AddInterruptsToTable(interruptsIn, usingInterrupt, spellGroup) then
                return true
            end
        end
    end

    return false
end

---Recursively check related spells and add all that share a root of a spell from our list
---@param spellTableIn table
---@param spellTableIgnore table
---@param spellGroup table -- Pass empty table to group related spells
---@param spellTableOut table
---@return boolean
local function AddSpellsToTable(spellTableIn, spellTableIgnore, spell, spellGroup, spellTableOut)
    if not spell or spellTableIgnore[spell.Name] then
        return false
    end

    if spellTableIn[spell.Name] then
        spellTableOut[spell.Name] = true
        return true
    end

    local hasFlags, spellFlags = pcall(function()
        return spell.SpellFlags
    end)

    if hasFlags and spellFlags then
        for _, v in pairs(spellFlags) do
            if v == "IsTrap" then
                return false
            end
        end
    end

    -- Avoid infinite loops for spells in the same group
    if spellGroup[spell.Name] then
        return false
    end

    spellGroup[spell.Name] = true

    -- Recursively check and add all required interupt spells
    if spell.InterruptPrototype and spell.InterruptPrototype ~= "" then
        local interrupt = Ext.Stats.Get(spell.InterruptPrototype)
        if interrupt and interrupt.Name ~= spell.Name and DarknessInterrupts then
            if AddInterruptsToTable(CheckInterruptDarkness, interrupt, spellGroup) then
                DarknessInterrupts[interrupt.Name] = true
                return true
            end
        end
    end

    if spell.RootSpellID and spell.RootSpellID ~= "" then
        local rootSpell = Ext.Stats.Get(spell.RootSpellID)
        if rootSpell and AddSpellsToTable(spellTableIn, spellTableIgnore, rootSpell, spellGroup, spellTableOut) then
            spellTableOut[spell.Name] = true
            return true
        end
    end

    if spell.SpellContainerID and spell.SpellContainerID ~= "" then
        local spellContainer = Ext.Stats.Get(spell.SpellContainerID)
        if spellContainer and AddSpellsToTable(spellTableIn, spellTableIgnore, spellContainer, spellGroup, spellTableOut) then
            spellTableOut[spell.Name] = true
            return true
        end
    end

    if spell.Using and spell.Using ~= "" then
        local usingSpell = Ext.Stats.Get(spell.Using)
        if usingSpell and AddSpellsToTable(spellTableIn, spellTableIgnore, usingSpell, spellGroup, spellTableOut) then
            spellTableOut[spell.Name] = true
            return true
        end
    end

    return false
end

---Add conditions to spells collected in tables
---@alias ConditionSpellType "spell" | "interrupt"
---@param spellTable table -- Table of spells to patch
---@param spellType ConditionSpellType
---@param conditions string -- Conditions and vars
local function AddSpellConditions(spellTable, spellType, conditions)
    for spellIn, v in pairs(spellTable) do
        local spell = Ext.Stats.Get(spellIn)
        if spell then
            local conditionsType
            if spellType == "interrupt" then
                conditionsType = "Conditions"
            elseif spell.SpellType == "Throw" then
                conditionsType = "ThrowableTargetConditions"
            else
                conditionsType = "TargetConditions"
            end

            if not string.find(spell[conditionsType], conditions) then
                local originalConditions = ""

                if spell[conditionsType] ~= nil and spell[conditionsType] ~= "" then
                    originalConditions = "(" .. spell[conditionsType]:gsub(";", "") .. ") and "
                end

                spell[conditionsType] = originalConditions .. "(" .. conditions .. ")"
            end
        end
    end
end

Ext.Events.StatsLoaded:Subscribe(function()
    Log("STATS LOADED - CLIENT")

    -- Init tables that will be populated with spells we need to patch
    DarknessPlaceSpells = DarknessPlaceSpells or {}
    DarknessTargetSpells = DarknessTargetSpells or {}
    DarknessInterrupts = DarknessInterrupts or {}

    -- Recursively check all spells against our spell tables
    for _, name in pairs(Ext.Stats.GetStats("SpellData")) do
        local spell = Ext.Stats.Get(name)
        AddSpellsToTable(CheckTargetDarkness, CheckTargetDarknessIgnore, spell, {}, DarknessTargetSpells)
        AddSpellsToTable(CheckPlaceDarkness, CheckTargetDarknessIgnore, spell, {}, DarknessPlaceSpells)
    end

    -- Add conditions to collected spells
    AddSpellConditions(DarknessTargetSpells, "spell", "TD_SpellCastingInDarkness(context.Target, context.Source)")
    AddSpellConditions(DarknessInterrupts, "interrupt", "TD_SpellCastingInDarkness(context.Source, context.Observer)")
    AddSpellConditions(DarknessPlaceSpells, "spell", "not Item() and TD_CasterNotBlinded(context.Source)")

    -- Save spells that require seeing a place in space to json
    -- They need to be persisted between sessions after updated during StatsLoaded
    -- DarknessPlaceSpells are checked against when creature tries to use a spell inside Darkness
    SaveDarknessPlaceSpells(DarknessPlaceSpells)
end)
