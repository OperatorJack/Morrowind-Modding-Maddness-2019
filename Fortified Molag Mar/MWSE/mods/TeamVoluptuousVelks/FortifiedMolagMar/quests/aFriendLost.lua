local common = require("TeamVoluptuousVelks.FortifiedMolagMar.common")

local journalId = common.data.journalIds.aFriendLost
local journalIndex = nil
local onJournal = nil

local armigerId = common.data.npcIds.armiger
local armiger = nil

local function updateJournalIndexValue(index)
    journalIndex = index or tes3.getJournalIndex(journalId) 
end

local function onActivate(e)
    if (e.activator == tes3.player and e.target == armiger) then
        event.unregister("activate", onActivate)

        tes3.updateJournal({
            id = journalId,
            index = 30
        })
    end
end

local function onSimulate(e)
    local armiger = armiger or tes3.getReference(armigerId)
    if (tes3.player.position:distance(armiger.position) < 500) then
        event.unregister("simulate", onSimulate)

        tes3.updateJournal({
            id = journalId,
            index = 20
        })
    end
end

local function onCellChanged(e)
    if (e.cell.id == common.data.cellIds.underworks) then
        event.register("simulate", onSimulate)
    elseif (e.previousCell.id == common.data.cellIds.underworks) then
        event.unregister("simulate", onSimulate)
    end
end

local function processJournalIndexValue()
    if (journalIndex == 10) then
        -- Player has been asked to look for the buoyant armiger.
        event.register("cellChanged", onCellChanged)
    elseif (journalIndex == 20) then
        -- Player has found the buoyant armiger's body in the Underworks.
        event.unregister("cellChanged", onCellChanged)
        event.register("activate", onActivate)
    elseif (journalIndex == 30) then
        -- Player found the amulet on the armiger's body.
    elseif (journalIndex == 40) then
        -- Player has completed the quest.
        event.unregister("journal", onJournal)
    end
end

onJournal = function(e)
    if (e.topic.id ~= journalId) then
        return
    end

    updateJournalIndexValue(e.index)
    processJournalIndexValue()
end

local registered = false
local function onLoaded(e)
    if (registered == false) then
        updateJournalIndexValue()
        if (journalIndex == nil or journalIndex < 40) then
            event.register("journal", onJournal)
            processJournalIndexValue()
        end
        registered = true
    end
end

event.register("loaded", onLoaded)