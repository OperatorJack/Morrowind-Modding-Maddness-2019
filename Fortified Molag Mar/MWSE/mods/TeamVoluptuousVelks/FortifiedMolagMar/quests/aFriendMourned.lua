local common = require("TeamVoluptuousVelks.FortifiedMolagMar.common")

local journalId = common.data.journalIds.aFriendMourned
local journalIndex = nil
local onJournal = nil

local enchantedBarrierId = common.data.objectIds.enchantedBarrier

local function updateJournalIndexValue(index)
    journalIndex = index or tes3.getJournalIndex({id = journalId}) 
end

local function onActivate(e)
    local enchantedBarrier = tes3.getReference(enchantedBarrierId)
    if (e.activator == tes3.player and e.target == enchantedBarrier) then
        event.unregister("activate", onActivate)
        common.debug("A Friend Mourned: Unregistering Activate Event.")

        tes3.messageBox(common.data.messageBoxes.enchantedBarrierActivate)

        tes3.updateJournal({
            id = journalId,
            index = 40
        })
    end
end

local function processJournalIndexValue()
    if (journalIndex == 20) then
        -- Player has been asked to retrieve the buoyant armiger's body 
        -- and investigate the area.
        event.unregister("activate", onActivate)
        event.register("activate", onActivate)
        common.debug("A Friend Mourned: Registered Activate Event.")
    elseif (journalIndex == 30) then
        -- Player has found evidence of a daedric cult.
        event.unregister("activate", onActivate)
        event.register("activate", onActivate)
        common.debug("A Friend Mourned: Registered Activate Event.")
    elseif (journalIndex == 40) then
        -- Player has found the enchanted barrier.
        event.unregister("activate", onActivate)
        common.debug("A Friend Mourned: Registered Activate Event.")
    elseif (journalIndex == 60) then
        -- Player has reported back to Indaram.
        event.unregister("journal", onJournal)
        common.debug("A Friend Mourned: Unregistered Journal Event.")
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
        if (journalIndex == nil or journalIndex < 60) then
            event.register("journal", onJournal)
            common.debug("A Friend Mourned: Registered Journal Event")
            processJournalIndexValue()
        end
        registered = true
    end
end

event.register("loaded", onLoaded)