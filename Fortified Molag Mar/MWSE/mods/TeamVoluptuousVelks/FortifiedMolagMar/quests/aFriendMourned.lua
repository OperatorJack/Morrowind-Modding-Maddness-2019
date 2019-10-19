local common = require("TeamVoluptuousVelks.FortifiedMolagMar.common")

local journalId = common.data.journalIds.aFriendLost
local journalIndex = nil
local onJournal = nil

local enchantedBarrierId = common.data.objectIds.enchantedBarrier
local enchantedBarrier = nil

local function updateJournalIndexValue(index)
    journalIndex = index or tes3.getJournalIndex(journalId) 
end

local function onActivate(e)
    local enchantedBarrier = enchantedBarrier or tes3.getReference(enchantedBarrierId)
    if (e.activator == tes3.player and e.target == enchantedBarrier) then
        event.unregister("activate", onActivate)

        tes3.messageBox(common.data.messageBoxes.enchantedBarrierActivate)

        tes3.updateJournal({
            id = journalId,
            index = 30
        })
    end
end

local function onCellChanged(e)
    if (e.cell.id == common.data.cellIds.underworks) then
        event.register("activate", onActivate)
    elseif (e.previousCell.id == common.data.cellIds.underworks) then
        event.unregister("activate", onActivate)
    end
end

local function processJournalIndexValue()
    if (journalIndex == 10) then
        -- Player has been asked to retrieve the buoyant armiger's body 
        -- and investigate the area.
        event.register("cellChanged", onCellChanged)
    elseif (journalIndex == 20) then
        -- Player has found the enchanted barrier.
        event.unregister("cellChanged", onCellChanged)
    elseif (journalIndex == 30) then
        -- Player has reported back to Indaram.
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
        if (journalIndex == nil or journalIndex < 30) then
            event.register("journal", onJournal)
            processJournalIndexValue()
        end
        registered = true
    end
end

event.register("loaded", onLoaded)