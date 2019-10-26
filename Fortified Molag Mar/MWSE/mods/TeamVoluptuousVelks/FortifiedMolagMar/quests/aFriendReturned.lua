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

local enchantedBarrierId = common.data.objectIds.enchantedBarrier

local function updateJournalIndexValue(index)
    journalIndex = index or tes3.getJournalIndex({id = journalId}) 
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
    common.debug("A Friend Returned: Triggering Tunnel Fight.")

    tes3.worldController.flagTeleportingDisabled = true

    local cultists = {}
    table.insert(cultists, spawnCultist({-2442, -3242, 22}))
    table.insert(cultists, spawnCultist({-2373, -3592, 22}))
    table.insert(cultists, spawnCultist({-2045, -3861, 22}))
    table.insert(cultists, spawnCultist({-1845, -3893, 22}))
    table.insert(cultists, spawnCultist({-1684, -3496, 22}))
    table.insert(cultists, spawnCultist({-1832, -3649, 22}))
       
    local orientationRad = tes3vector3.new(
        math.rad(0),
        math.rad(0),
        math.rad(0)
    )

    tes3.positionCell({
        reference = mage,
        position = {-1686, -645, 32},
        orientation = orientationRad,
        cell = tes3.player.cell
    })

    tes3.positionCell({
        reference = armiger1,
        position = {-1727, -1211, 32},
        orientation = orientationRad,
        cell = tes3.player.cell
    })
    tes3.positionCell({
        reference = armiger2,
        position = {-2359, -1463, 32},
        orientation = orientationRad,
        cell = tes3.player.cell
    })

    for _, cultistRef in pairs(cultists) do
        mwscript.startCombat({
            reference = armiger1,
            target = cultistRef
        })
        mwscript.startCombat({
            reference = armiger2,
            target = cultistRef
        })
    end

    common.debug("A Friend Returned: Triggering Timer.")

    local combatTimer = nil
    combatTimer = timer.start({
        duration = 5,
        iterations = -1,
        callback = function()
            common.debug("A Friend Returned: Checking for deadcount.")
        
            local deadCount = 0
            for _, cultistRef in pairs(cultists) do
                if (cultistRef.mobile.isDead == true) then
                    deadCount = deadCount + 1
                end
            end
            if (deadCount > 4) then
                common.debug("A Friend Returned: Met deadcount.")
            
                combatTimer:cancel()

                cultist = tes3.createReference({
                    object = cultistId,
                    position = {-1787, -1973, 32},
                    orientation = tes3.player.orientation,
                    cell = tes3.player.cell
                })

                mwscript.startCombat({
                    reference = armiger1,
                    target = cultist
                })
                mwscript.startCombat({
                    reference = armiger2,
                    target = cultist
                })

                timer.start({
                    duration = 3,
                    iterations = 1,
                    callback = function()
                        tes3.messageBox(common.data.messageBoxes.mageSkirmishDialogue)
                    end
                })

                combatTimer = timer.start({
                    duration = 30,
                    iterations = 1,
                    callback = function()
                        common.debug("A Friend Returned: Teleporting out.")

                        tes3.fadeOut({
                            duration = 2
                        })

                        mage:disable()
                        armiger1:disable()
                        armiger2:disable()
                        cultist:disable()

                        timer.delayOneFrame({
                            callback = function()
                                mage.deleted = true
                                armiger1.deleted = true
                                armiger2.deleted = true
                                cultist.deleted = true
                            end
                        })

                        timer.start({
                            duration = 3,
                            iterations = 1,
                            callback = function ()
                                tes3.fadeIn({
                                    duration = 2
                                })
                    
                                tes3.worldController.flagTeleportingDisabled = false

                                local orientationRad = tes3vector3.new(
                                    math.rad(0),
                                    math.rad(0),
                                    math.rad(245)
                                )
        
                                tes3.positionCell({
                                    cell =common.data.cellIds.armigersStronghold,
                                    position = {4743, 4645, 15875},
                                    orientation = orientationRad,
                                    reference = tes3.player
                                })
        
                                tes3.updateJournal({
                                    id = journalId,
                                    index = 80
                                })
                            end
                        })
                    end
                })
            end
        end
    })
end

local function onFightSimulate(e)
    local cultActivator = tes3.getReference(cultActivatorId)
    if (tes3.player.position:distance(cultActivator.position) < 5000) then
        event.unregister("simulate", onFightSimulate)

        triggerTunnelFight()
    end
end

local underworksSimulateDoOnce = false
local function onUnderworksSimulate(e)
    if (underworksSimulateDoOnce == false) then
        local orientationRad = tes3vector3.new(
            math.rad(0),
            math.rad(0),
            math.rad(86)
        )
        
        mage = tes3.createReference({
            object = mageId,
            position = {2276, -6058, 496},
            orientation = orientationRad,
            cell = tes3.player.cell
        })

        armiger1 = tes3.createReference({
            object = armigerId,
            position = {2156, -6007, 496},
            orientation = orientationRad,
            cell = tes3.player.cell
        })
        armiger2 = tes3.createReference({
            object = armigerId,
            position = {2172, -6187, 496},
            orientation = orientationRad,
            cell = tes3.player.cell
        })

        underworksSimulateDoOnce = true
    end
    
    if (tes3.player.position:distance(mage.position) < 500) then
        common.debug("A Friend Returned: Casting spell on barrier.")

        underworksSimulateCastDoOnce = true
        event.unregister("simulate", onUnderworksSimulate)

        local enchantedBarrier = tes3.getReference(enchantedBarrierId)
        local spell = tes3.getObject(common.data.spellIds.dispelEnchantedBarrier)

        tes3.cast({
            reference = mage,
            target = mage,
            spell = spell
        })

        common.debug("A Friend Returned: Casted spell on barrier.")

        timer.start({
            iterations = 1,
            duration = 4,
            callback = function()
                enchantedBarrier:disable()
                common.debug("A Friend Returned: Barrier Disabled.")
        
                timer.delayOneFrame({
                    callback = function()
                        common.debug("A Friend Returned: Barrier Deleted.")
                        enchantedBarrier.deleted = true
                    end
                })
        
                tes3.updateJournal({
                    id = journalId,
                    index = 60
                })
                common.debug("A Friend Returned: Journal Updated.")
        
                event.unregister("simulate", onFightSimulate)
                event.register("simulate", onFightSimulate)
                common.debug("A Friend Returned: Registering Simulate Event in Callback.")
        
            end
        })
    end
end

local function onCellChangedStageTwo(e)
    if (e.cell.id == common.data.cellIds.underworks) then
        event.register("simulate", onFightSimulate)
        common.debug("A Friend Returned: Registering Simulate Event.")
    elseif (e.previousCell and e.previousCell.id == common.data.cellIds.underworks) then
        event.unregister("simulate", onFightSimulate)
        common.debug("A Friend Returned: Unregistering Simulate Event.")
    end
end
local function onCellChangedStageOne(e)
    if (e.cell.id == common.data.cellIds.underworks) then
        event.register("simulate", onUnderworksSimulate)
        common.debug("A Friend Returned: Registering Simulate Event.")
    elseif (e.previousCell and e.previousCell.id == common.data.cellIds.underworks) then
        event.unregister("simulate", onUnderworksSimulate)
        common.debug("A Friend Returned: Unregistering Simulate Event.")
    end
end

local function processJournalIndexValue()
    if (journalIndex == 20) then
        -- Player has been asked to speak with the Mage.
    elseif (journalIndex == 40) then
        -- Player has been told to meet the Mage at the enchanted barrier.
        event.register("cellChanged", onCellChangedStageOne)
    elseif (journalIndex == 60) then
        event.unregister("cellChanged", onCellChangedStageOne)
        event.register("cellChanged", onCellChangedStageTwo)
        -- Player has been told to continue through the tunnel.
    elseif (journalIndex == 80) then
        -- Player has been teleported out by the group Amvisi Intervention spell.
        event.unregister("cellChanged", onCellChangedStageTwo)
    elseif (journalIndex == 100) then
        -- Player has completed the quest.
        event.unregister("journal", onJournal)
    elseif (journalIndex == 110) then
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
        if (journalIndex == nil or journalIndex < 100) then
            event.register("journal", onJournal)
            processJournalIndexValue()
        end
        registered = true
    end
end

event.register("loaded", onLoaded)