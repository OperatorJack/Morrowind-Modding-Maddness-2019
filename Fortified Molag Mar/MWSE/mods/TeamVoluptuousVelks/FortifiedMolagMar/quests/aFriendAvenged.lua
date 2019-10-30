local common = require("TeamVoluptuousVelks.FortifiedMolagMar.common")

local journalId = common.data.journalIds.aFriendAvenged
local journalIndex = nil
local onJournal = nil

local mageId = common.data.npcIds.mage
local mage = nil

local armigerId = common.data.npcIds.genericArmiger
local armiger1 = nil
local armiger2 = nil
local armiger3 = nil
local armiger4 = nil

local weakCultistId = common.data.npcIds.weakCultist
local cultistId = common.data.npcIds.cultist
local cultist = nil

local cultActivatorId = common.data.objectIds.cultActivator

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
    common.debug("A Friend Avenged: Triggering Tunnel Fight.")

    tes3.worldController.flagTeleportingDisabled = true

    local cultists = {}
    table.insert(cultists, spawnCultist({-2429, -2814, 32}))
    table.insert(cultists, spawnCultist({-2543, -2774, 32}))
    table.insert(cultists, spawnCultist({-2370, -2617, 32}))
    table.insert(cultists, spawnCultist({-2380, -2434, 32}))
    table.insert(cultists, spawnCultist({-1744, -2843, 32}))
    table.insert(cultists, spawnCultist({-1592, -2801, 32}))
    table.insert(cultists, spawnCultist({-1680, -2638, 32}))
    table.insert(cultists, spawnCultist({-1725, -2454, 32}))

    for _, cultistRef in pairs(cultists) do
        mwscript.startCombat({
            reference = mage,
            target = cultistRef
        })
        mwscript.startCombat({
            reference = armiger1,
            target = cultistRef
        })
        mwscript.startCombat({
            reference = armiger2,
            target = cultistRef
        })
        mwscript.startCombat({
            reference = armiger3,
            target = cultistRef
        })
        mwscript.startCombat({
            reference = armiger4,
            target = cultistRef
        })
    end

    common.debug("A Friend Avenged: Triggering Timer.")
    
    timer.start({
        duration = 5,
        iterations = 1,
        callback = function()
            common.debug("A Friend Avenged: Killing Armiger 3 & 4.")
            
            armiger3.mobile:applyHealthDamage(9999)
            armiger4.mobile:applyHealthDamage(9999)
    
            timer.start({
                duration = 5,
                iterations = 1,
                callback = function()
                    common.debug("A Friend Avenged: Spawning Powerful Cultist.")

                    local orientationRad = tes3vector3.new(
                        math.rad(0),
                        math.rad(0),
                        math.rad(7)
                    )
                       
                    cultist = tes3.createReference({
                        object = cultistId,
                        position = {-1587, -2775, 32},
                        orientation = orientationRad,
                        cell = tes3.player.cell
                    })
    
                    timer.start({
                        duration = 5,
                        iterations = 1,
                        callback = function()
                            common.debug("A Friend Avenged: Killing Armiger 1 & 2.")
                            
                            armiger1.mobile:applyHealthDamage(9999)
                            armiger2.mobile:applyHealthDamage(9999)
    
                            timer.start({
                                duration = 7,
                                iterations = 1,
                                callback = function()
                                    common.debug("A Friend Avenged: Killing Mage & equipping artifact.")
                                    
                                    tes3.messageBox(common.data.messageBoxes.mageDeathDialogue)
                        
                                    mwscript.addItem({
                                        reference = tes3.player,
                                        item = common.data.objectIds.artifactChargedRing
                                    })
                                    mwscript.equip({
                                        reference = tes3.player,
                                        item = common.data.objectIds.artifactChargedRing
                                    })
                        
                                    mage.mobile:applyHealthDamage(9999999)
    
                                    timer.start({
                                        duration = 10,
                                        iterations = 1,
                                        callback = function()
                                            common.debug("A Friend Avenged: Removing cultists... Retreating.")
                                            
                                            tes3.fadeOut({
                                                duration = 2
                                            })

                                            timer.start({
                                                duration = 2,
                                                iterations = 1,
                                                callback = function()
                                                    cultist:disable()
                                                    for _,cultistRef in pairs(cultists) do
                                                        cultistRef:disable()
                                                    end
                                        
                                                    timer.delayOneFrame({
                                                        callback = function()
                                                            cultist.deleted = true
                                                            for _,cultistRef in pairs(cultists) do
                                                                cultistRef.deleted = true
                                                            end
                                                        end
                                                    })
                                        
                                                    tes3.messageBox(common.data.messageBoxes.cultistRetreatDialogue)
                                        
                                                    timer.start({
                                                        duration = 3,
                                                        iterations = 1,
                                                        callback = function ()
                                                            common.debug("A Friend Avenged: Processing retreat.")
        
                                                            tes3.worldController.flagTeleportingDisabled = false
                                                            
                                                            tes3.fadeIn({
                                                                duration = 2
                                                            })
        
                                                            tes3.updateJournal({
                                                                id = journalId,
                                                                index = 100
                                                            })
                                                        end
                                                    })
                                                end
                                            })
                                        end
                                    })
                                end
                            })
                        end
                    })
                end
            })
        end
    })
end

local function onSimulate(e)
    if (tes3.player.data.fortifiedMolarMar.variables.hasSpawnedActorsForSecondTunnelFight ~= true) then
        local orientationRad = tes3vector3.new(
            math.rad(0),
            math.rad(0),
            math.rad(183)
        )

        mage = tes3.createReference({
            object = mageId,
            position = {-1969, -3862, 32},
            orientation = orientationRad,
            cell = tes3.player.cell
        })

        armiger1 = tes3.createReference({
            object = armigerId,
            position = {-1840, -3936, 32},
            orientation = orientationRad,
            cell = tes3.player.cell
        })
        armiger2 = tes3.createReference({
            object = armigerId,
            position = {-2270, -3933, 32},
            orientation = orientationRad,
            cell = tes3.player.cell
        })
        armiger3 = tes3.createReference({
            object = armigerId,
            position = {-2262, -3763, 32},
            orientation = orientationRad,
            cell = tes3.player.cell
        })
        armiger4 = tes3.createReference({
            object = armigerId,
            position = {-2368, -3606, 32},
            orientation = orientationRad,
            cell = tes3.player.cell
        })
        common.debug("A Friend Avenged: Simulate Event DoOnce complete.")

        tes3.player.data.fortifiedMolarMar.variables.hasSpawnedActorsForSecondTunnelFight = true
    end

    local cultActivator = tes3.getReference(cultActivatorId)
    if (tes3.player.position:distance(cultActivator.position) < 2500) then
        event.unregister("simulate", onSimulate)
        common.debug("A Friend Avenged: Unregistering Tunnel Simulate Event.")

        triggerTunnelFight()
    end
end


local function onCellChanged(e)
    if (e.cell.id == common.data.cellIds.underworks) then
        event.register("simulate", onSimulate)
        common.debug("A Friend Avenged: Registering Simulate Event.")
    elseif (e.previousCell and e.previousCell.id == common.data.cellIds.underworks) then
        event.unregister("simulate", onSimulate)
        common.debug("A Friend Avenged: Unregistering Tunnel Simulate Event.")
    end
end

local function onShrineActivate(e)
    local targetId = e.target.object.id
    if (common.data.playerData.shrines[targetId] ~= nil) then
        common.debug("A Friend Avenged: Target ID: " .. targetId)
        common.debug("A Friend Avenged: Shrine Activated.")
        
        if (tes3.player.data.fortifiedMolarMar.shrines[targetId] == true) then
            return
        end

        local isAmuletEquipped = mwscript.hasItemEquipped({
            reference = tes3.player,
            item = common.data.objectIds.amulet
        })

        if (isAmuletEquipped == true) then
            common.debug("A Friend Avenged: Amulet is equipped.")
            
            tes3.player.data.fortifiedMolarMar.shrines[targetId] = true

            local done = true
            for shrineId, state in pairs(common.data.playerData.shrines) do
                if (tes3.player.data.fortifiedMolarMar.shrines[shrineId] == nil or tes3.player.data.fortifiedMolarMar.shrines[shrineId] == false) then
                    done = false
                end
            end

            if (done == true) then
                event.unregister("activate", onShrineActivate)
                common.debug("A Friend Avenged: Unregistering Shrine Activate Event.")

                tes3.messageBox(common.data.messageBoxes.shrinesCompletedDialogue)
                tes3.updateJournal({
                    id = journalId,
                    index = 60
                })
            else
                tes3.messageBox(common.data.messageBoxes.shrinesInProgressDialogue)   
            end
        else
            tes3.messageBox(common.data.messageBoxes.shrinesNoAmuletDialogue)
        end
    end
end

local function processJournalIndexValue()
    if (journalIndex == 20) then
        -- Player has been told to speak to the Mage about the amulet.
    elseif (journalIndex == 40) then
        -- Player has been told to purify the amulet by walking the Pilgrim's Path.
        event.register("activate", onShrineActivate)
        common.debug("A Friend Avenged: Registering Shrine Activate Event.")
    elseif (journalIndex == 60) then
        -- Player has been told to return to the Mage.
    elseif (journalIndex == 80) then
        -- Player has been instructed to meet the Mage at the previous cultist location.
        event.register("cellChanged", onCellChanged)        
    elseif (journalIndex == 100) then
        -- Player has been given the artifact.  
        event.unregister("cellChanged", onCellChanged)         
    elseif (journalIndex == 120) then
        -- Player has reported the situation to Indaram.
        event.unregister("journal", onJournal)
        common.debug("A Friend Avenged: Unregistered Journal Event.")
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
        if (journalIndex == nil or journalIndex < 120) then
            event.register("journal", onJournal)
            common.debug("A Friend Avenged: Registered Journal Event.")
            processJournalIndexValue()
        end
        registered = true
    end
end

event.register("loaded", onLoaded)