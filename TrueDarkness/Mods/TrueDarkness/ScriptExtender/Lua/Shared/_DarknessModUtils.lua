---Toggle debug across the mod
DebuggingEnabled = false

---@param message string
function Log(message, ...)
    if DebuggingEnabled then
        local formattedMessage = string.format(message, ...)
        Ext.Utils.Print("[True Darkness] " .. formattedMessage)
    end
end

-- Reloads stats files at runtime
-- Only enabled with debugging
function ReloadStats()
    if DebuggingEnabled then
        local path = 'Public/TrueDarkness/Stats/Generated/Data/'
        local stats = {'Spell_Target.txt', 'Status_BOOST.txt', 'Spell_Projectile.txt', 'Object.txt'}
        for _, filename in pairs(stats) do
            local filePath = string.format('%s%s', path, filename)
            if string.len(filename) > 0 then
                Log('RELOADING %s', filePath)
                Ext.Stats.LoadStatsFile(filePath, false)
            else
                Log('Invalid file: %s', filePath)
            end
        end
    end
end

---@param time integer
function SetTimer(time, call, ...)
    local startTime = Ext.Utils.MonotonicTime()
    local event
    local args = {...}
    event = Ext.Events.Tick:Subscribe(function()
        if Ext.Utils.MonotonicTime() - startTime >= time then
            call(table.unpack(args))
            Ext.Events.Tick:Unsubscribe(event)
        end
    end)
    return event
end

-- Loads persisted ModVar table of items with active Darkness applied
function LoadPersistence()
    local modVars = Ext.Vars.GetModVariables(ModuleUUID)    -- TODO Switch to single ModVar with dynamic distance calculation to support class mods
    if modVars then
        if modVars.DarknessParents then
            DarknessParents = modVars.DarknessParents
            Log("PERSISTENCE: DARKNESS PARENTS LOADED")
        else
            DarknessParents = {}
            Log("PERSISTENCE: DARKNESS PARENTS EMPTY - INITIALIZING")
        end 

        if modVars.HadarParents then
            HadarParents = modVars.HadarParents
            Log("PERSISTENCE: HADAR PARENTS LOADED")
        else
            HadarParents = {}
            Log("PERSISTENCE: HADAR PARENTS EMPTY - INITIALIZING")
        end 
    else
        DarknessParents = {}
        HadarParents = {}
        SharDarknessParents = {}
        Log("PERSISTENCE: FAILED MODVAR LOAD - INITIALIZING")
    end
end

function SavePersistence()
    if DarknessParents then
        Ext.Vars.GetModVariables(ModuleUUID).DarknessParents = DarknessParents
        Log("PERSISTENCE: DARKNESS PARENTS SAVED")
    else
        Log("PERSISTENCE: NO DARKNESS PARENTS TO SAVE")
    end

    _D(DarknessParents)

    if HadarParents then
        Ext.Vars.GetModVariables(ModuleUUID).HadarParents = HadarParents
        Log("PERSISTENCE: HADAR PARENTS SAVED")
    else
        Log("PERSISTENCE: NO HADAR PARENTS TO SAVE")
    end
end

-- Load spells that need to be persisted between sessions
function LoadDarknessPlaceSpells()
    DarknessPlaceSpells = {}
    local file, fileData = pcall(Ext.IO.LoadFile, "TrueDarkness/TD_DarknessPlaceSpells.json")
    if not file or not fileData then
        Log("SPELLS: Failed to load TD_DarknessPlaceSpells.json - Initializing")
    else
        local jsonStatus, data = pcall(Ext.Json.Parse, fileData)
        if not jsonStatus then
            Log("SPELLS: Failed to parse " .. data)
        else
            Log("SPELLS: LOADED")
            DarknessPlaceSpells = data or {}
        end
    end
end

---@param spellTable table
function SaveDarknessPlaceSpells(spellTable)
    LoadDarknessPlaceSpells()
    local dirty = false

    for spellID, spellData in pairs(spellTable) do
        if not DarknessPlaceSpells[spellID] then
            DarknessPlaceSpells[spellID] = spellData
            dirty = true
        end
    end

    if dirty then
        local spellsJson = Ext.Json.Stringify(DarknessPlaceSpells)
        local saveStatus, saveErr = pcall(Ext.IO.SaveFile, "TrueDarkness/TD_DarknessPlaceSpells.json", spellsJson)
        if not saveStatus then
            Log("SPELLS: Failed to save " .. saveErr)
        else
            Log("SPELLS: SAVED")
        end
    else
        Log("SPELLS: No changes to save.")
    end
end