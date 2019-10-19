local common = require("TeamVoluptuousVelks.FortifiedMolagMar.common")

local journalId = common.data.journalIds.aFriendReturned
local journalIndex = nil
local onJournal = nil

local mageId = common.data.npcIds.mage
local mage = nil

local armigerId = common.data.npcIds.genericArmiger
local armiger1 = nil
local armiger2 = nil

local weakCultistId = common.data.npcIds.weakCultist
local cultistId = common.data.npcIds.cultist
local cultist = nil

local cultActivatorId = common.data.objectIds.cultActivator
local cultActivator = nil

local enchantedBarrierId = common.data.objectIds.enchantedBarrier
local enchantedBarrier = nil

local function updateJournalIndexValue(index)
    journalIndex = index or tes3.getJournalIndex(journalId) 
end

local function spawnCultist(position)
    return tes3.createReference({
        object = weakCultistId,
        position = position,
        orientation = tes3.player.orientation,
        cell = tes3.player.cell
    })
end

local function triggerTunnelFight()
    tes3.worldController.flagTeleportingDisabled = true

    local cultists = {}
    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))
    
    tes3.positionCell({
        object = mage,
        position = {0,0,0},
        orientation = {0,0,0},
        cell = tes3.player.cell
    })

    tes3.positionCell({
        reference = armiger1,
        position = {0,0,0},
        orientation = {0,0,0},
        cell = tes3.player.cell
    })
    tes3.positionCell({
        reference = armiger2,
        position = {0,0,0},
        orientation = {0,0,0},
        cell = tes3.player.cell
    })


    local combatTimer = nil
    combatTimer = timer.start({
        duration = 5,
        iterations = -1,
        callback = function()
            local deadCount = 0
            for _, cultistRef in pairs(cultists) do
                if (cultistRef.mobile.isDead == true) then
                    deadCount = deadCount + 1
                end
            end
            if (deadCount > 4) then
                combatTimer:cancel()

                cultist = tes3.createReference({
                    object = cultistId,
                    position = {0,0,0},
                    orientation = tes3.player.orientation,
                    cell = tes3.player.cell
                })

                timer.start({
                    duration = 3,
                    iterations = 1,
                    callback = function()
                        tes3.messageBox(common.data.messageBox.mageSkirmishDialogue)
                    end
                })

                combatTimer = timer.start({
                    duration = 60,
                    iterations = 1,
                    callback = function()
                        tes3.worldController.flagTeleportingDisabled = false

                        mage:disable()
                        armiger1:disable()
                        armiger2:disable()

                        timer.delayOneFrame({
                            callback = function()
                                mage.deleted = true
                                armiger1.deleted = true
                                armiger2.deleted = true
                            end
                        })

                        tes3.positionCell({
                            cell =common.data.cellIds.armigersStronghold,
                            position = {0,0,0},
                            orientation = {0,0,0},
                            reference = tes3.player
                        })

                        tes3.updateJournal({
                            id = journalId,
                            index = 40
                        })
                    end
                })
            end
        end
    })
end

local underworksSimulateDoOnce = false
local function onUnderworksSimulate(e)
    if (underworksSimulateDoOnce == false) then
        mage = tes3.createReference({
            object = mageId,
            position = {0,0,0},
            orientation = {0,0,0},
            cell = tes3.player.cell
        })

        armiger1 = tes3.createReference({
            object = armigerId,
            position = {0,0,0},
            orientation = {0,0,0},
            cell = tes3.player.cell
        })
        armiger2 = tes3.createReference({
            object = armigerId,
            position = {0,0,0},
            orientation = {0,0,0},
            cell = tes3.player.cell
        })

        underworksSimulateDoOnce = true
    end
    
    if (tes3.player.position:distance(mage.position) < 500) then
        event.unregister("simulate", onUnderworksSimulate)

        local enchantedBarrier = enchantedBarrier or tes3.getReference(enchantedBarrierId)

        tes3.cast({
            reference = mage,
            target = enchantedBarrier,
            spell = common.data.spellIds.dispelEnchantedBarrier
        })

        tes3.unlock({
            reference = enchantedBarrier
        })

        tes3.updateJournal({
            id = journalId,
            index = 30
        })
    end
end

local function onTunnelSimulate(e)
    local cultActivator = cultActivator or tes3.getReference(cultActivatorId)
    if (tes3.player.position:distance(cultActivator.position) < 1000) then
        event.unregister("simulate", onTunnelSimulate)

        triggerTunnelFight()
    end
end

local function onCellChanged(e)
    if (e.cell.id == common.data.cellIds.underworks) then
        event.register("simulate", onUnderworksSimulate)
    elseif (e.previousCell.id == common.data.cellIds.underworks) then
        event.unregister("simulate", onUnderworksSimulate)
    end
    
    if (e.cell.id == common.data.cellIds.tunnel) then
        event.register("simulate", onTunnelSimulate)
    elseif (e.previousCell.id == common.data.cellIds.tunnel) then
        event.unregister("simulate", onTunnelSimulate)
    end
end

local function processJournalIndexValue()
    if (journalIndex == 10) then
        -- Player has been asked to speak with the Mage.
    elseif (journalIndex == 20) then
        -- Player has been told to meet the Mage at the enchanted barrier.
        event.register("cellChanged", onCellChanged)
    elseif (journalIndex == 30) then
        -- Player has been told to continue through the tunnel.
    elseif (journalIndex == 40) then
        -- Player has been teleported out by the group Amvisi Intervention spell.
        event.unregister("cellChanged", onCellChanged)
    elseif (journalIndex == 50) then
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