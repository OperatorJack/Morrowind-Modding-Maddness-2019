local common = require("TeamVoluptuousVelks.DeeperDagothUr.common")

local journalId = "C3_DestroyDagoth"
local coilId = "DU__TEST_Coil"
local cellIds = {
    ["OJ_TEST"] = true,
    ["Dagoth Ur"] = true,
    ["Red Mountain Region"] = true
}

local function isNearCoil(actor)
    local cells = tes3.getActiveCells()
    for _, cell in pairs(cells) do
        for ref in cell:iterateReferences() do
            -- Check that the reference is an activator.
            if (ref.object.objectType == tes3.objectType.activator) then
                -- Check that the object is a ballista
                if (ref.object.id == coilId) then
                    if (ref.position:distance(actor.position)) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function onSpellTick(e)
    if (isNearCoil(e.caster) == true) then
        e.blocked = true
        return false
    end
end

local function onCellChanged(e)
    if (e.previousCell ~= nil) then
        if (cellIds[e.previousCell.id] == true) then
            event.unregister("spellTick", onSpellTick)
        end
    end
    
    if (cellIds[e.cell.id] == true) then
        event.register("spellTick", onSpellTick)
    end
end

local function onJournal(e)
    if (e.topic.id ~= journalId) then
        return
    end

    event.unregister("cellChanged", onCellChanged)
    event.unregister("journal", onJournal)
    event.unregister("spellTick", onSpellTick)
end

local function onLoaded(e)
    local journalIndex = tes3.getJournalIndex(journalId) 
    if (journalIndex == nil or journalIndex < 5) then
        event.register("cellChanged", onCellChanged)
        event.register("journal", onJournal)
    end
end

event.register("loaded", onLoaded)