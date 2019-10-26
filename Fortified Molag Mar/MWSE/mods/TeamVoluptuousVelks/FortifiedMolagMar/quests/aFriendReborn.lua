local common = require("TeamVoluptuousVelks.FortifiedMolagMar.common")

local journalId = common.data.journalIds.aFriendReborn
local journalIndex = nil
local onJournal = nil

local armigerId = common.data.npcIds.genericArmiger
local weakCultistId = common.data.npcIds.weakCultist

local indaramId = common.data.npcIds.indaram
local indaram = nil

local cultistId = common.data.npcIds.cultist
local cultist = nil

local function updateJournalIndexValue(index)
    journalIndex = index or tes3.getJournalIndex({id = journalId}) 
end

local function spawnArmiger(position)
    return tes3.createReference({
        object = armigerId,
        position = position,
        orientation = tes3.player.orientation,
        cell = tes3.player.cell
    })
end

local function spawnCultist(position)
    return tes3.createReference({
        object = weakCultistId,
        position = position,
        orientation = tes3.player.orientation,
        cell = tes3.player.cell
    })
end

local function onBattleStageTwoSimulate(e)
    event.unregister("simulate", onBattleStageTwoSimulate)

end

local function onBattleStageOneSimulate(e)
    event.unregister("simulate", onBattleStageOneSimulate)

    indaram = tes3.getReference(indaramId)

    local armigers = {}
    local cultists = {}

    table.insert(armigers, spawnArmiger({0,0,0}))
    table.insert(armigers, spawnArmiger({0,0,0}))
    table.insert(armigers, spawnArmiger({0,0,0}))
    table.insert(armigers, spawnArmiger({0,0,0}))

    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))
    table.insert(cultists, spawnCultist({0,0,0}))

    cultist = tes3.createReference({
        object = cultistId,
        position = {0,0,0},
        orientation = tes3.player.orientation,
        cell = tes3.player.cell
    })

    local deadArmiger = tes3.createReference({
        object = common.data.npcIds.armiger,
        position = {0,0,0},
        orientation = tes3.player.orientation,
        cell = tes3.player.cell
    })

    common.debug("A Friend Reborn: Stage One: Creating References.")

    for _, armiger in pairs(armigers) do
        for _, cultistRef in pairs(cultists) do
            mwscript.startCombat({
                reference = armiger,
                target = cultistRef
            })
            mwscript.startCombat({
                reference = cultistRef,
                target = armiger
            })
        end
    end

    common.debug("A Friend Reborn: Stage One: Starting Combat.")

    timer.start({
        iterations = 1,
        duration = 10,
        callback = function()
            common.debug("A Friend Reborn: Stage One: Casting Summon.")

            tes3.cast({
                reference = cultist,
                target = deadArmiger,
                spell = "fireball"
            })

            timer.start({
                iterations = 1,
                duration = 3,
                callback = function()
                    common.debug("A Friend Reborn: Stage One: Creating Dremora Lord.")

                    local dremoraLord = tes3.createReference({
                        object = common.data.npcIds.dremoraLord,
                        position = {0,0,0},
                        orientation = tes3.player.orientation,
                        cell = tes3.player.cell
                    })

                    local actors = common.getActorsNearTargetPosition(tes3.player.cell, dremoraLord.position, 200)

                    common.debug("A Friend Reborn: Stage One: Killing nearby actors.")

                    for _, actor in pairs(actors) do
                        actor.mobile:applyHealthDamage(9999999)
                    end

                    deadArmiger:disable()

                    timer.delayOneFrame({
                        callback = function()
                            deadArmiger.deleted = true
                        end
                    })
     
                    tes3.updateJournal({
                        id = journalId,
                        index = 60
                    })
                end
            })
        end
    })
end

local function onCellChanged(e)
    if (e.cell.id == common.data.cellIds.battlements) then
        tes3.positionCell({
            reference = indaramId,
            position = {0,0,0},
            orientation = {0,0,0},
            cell = tes3.player.cell
        })
        
        event.unregister("cellChanged", onCellChanged)
        common.debug("A Friend Reborn: Unregistering CellChanged Event.")
    end
end

local function processJournalIndexValue()
    if (journalIndex == 20) then
        -- Player has been told to meet Indaram on the battlements.
        event.register("cellChanged", onCellChanged)
        common.debug("A Friend Reborn: Registering CellChanged Event.")
    elseif (journalIndex == 40) then
        -- Player conversation with Indaram interrupted by battle.
        event.register("simulate", onBattleStageOneSimulate)
        common.debug("A Friend Reborn: Registering Stage One Simulate Event.")
    elseif (journalIndex == 60) then
        -- The Dreamora lord was summoned.
        event.register("simulate", onBattleStageTwoSimulate)
        common.debug("A Friend Reborn: Registering Stage Two Simulate Event.")
    elseif (journalIndex == 80) then
        -- Molar Mar was breached.
    elseif (journalIndex == 100) then
        -- Player has been saved by Vivec.
    elseif (journalIndex == 120) then
        -- Player has received reward from Vivec.
    end
end

onJournal = function(e)
    if (e.topic.id ~= journalId) then
        return
    end

    common.debug("A Friend Reborn: Updating Journal Index to: " .. e.index)

    updateJournalIndexValue(e.index)
    processJournalIndexValue()
end

local registered = false
local function onLoaded(e)
    if (registered == false) then
        updateJournalIndexValue()
        if (journalIndex == nil or journalIndex < 80) then
            common.debug("A Friend Reborn: Registering Journal Event.")

            event.register("journal", onJournal)
            processJournalIndexValue()
        end
        registered = true
    end
end

event.register("loaded", onLoaded)