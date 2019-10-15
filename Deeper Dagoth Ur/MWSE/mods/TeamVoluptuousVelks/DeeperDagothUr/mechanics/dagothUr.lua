
local common = require("TeamVoluptuousVelks.DeeperDagothUr.common")

-- Dagoth Ur Mechanics --
local journalId = "C3_DestroyDagoth"
local cellId = "Akulakhan's Chamber"
local barrierId = "DU_stageOneBarrier"
local heartId = "heart_akulakhan"

local stagesDagothUr = {}
local barrier = nil
local heart = nil
local dagothUr = nil

local function onHeartSimulate(e)
    if (tes3.player.position:distance(heart.position) <= 500) then
        stagesDagothUr.thirdStage.initialize()
        event.unregister("simulate", onHeartSimulate)
    end
end

stagesDagothUr = {
    ["firstStage"] = {
        initialize = function()
            common.debug("Dagoth Ur Fight: Beginning First Stage")

            -- Get Dagoth Ur reference
            dagothUr = tes3.getReference(common.data.mechanics.dagothUr.ids.dagothUrs.dagoth_ur_2)

            -- Disable barrier.
            barrier = tes3.getReference(barrierId)

            -- Set timer to continue to teleport dagoth ur.
            timer.start({
                duration = 8,
                callback = function ()          
                    -- Teleport Dagoth Ur to the second stage area.
                    tes3.positionCell({
                        reference = dagothUr,
                        position = tes3.player.position,
                        orientation = tes3.player.orientation,
                        cell = tes3.player.cell
                    })
                end,
                iterations = 1
            })

            local spawnCreatures = function()
                tes3.createReference({
                    object = common.data.mechanics.dagothUr.ids.creatures.ashSlave,
                    position = tes3.player.position,
                    orientation = tes3.player.orientation,
                    cell = tes3.player.cell
                })
                tes3.createReference({
                    object = common.data.mechanics.dagothUr.ids.creatures.ashSlave,
                    position = tes3.player.position,
                    orientation = tes3.player.orientation,
                    cell = tes3.player.cell
                })
                tes3.createReference({
                    object = common.data.mechanics.dagothUr.ids.creatures.ascendedSleeper,
                    position = tes3.player.position,
                    orientation = tes3.player.orientation,
                    cell = tes3.player.cell
                })
            end

            spawnCreatures()
            -- Set timer to spawn enemies
            timer.start({
                duration = 10,
                callback = function ()
                    spawnCreatures()
                end,
                iterations = 5
            })

            -- Set timer to continue to next stage.
            timer.start({
                duration = 60,
                callback = function ()          
                    barrier:disable()
                    tes3.messageBox("The barrier to the next platform dissipates, opening the way to continue.")
                    stagesDagothUr.secondStage.initialize()
                end,
                iterations = 1
            })
        end
    },
    ["secondStage"] = {
        initialize = function()
            common.debug("Dagoth Ur Fight: Beginning Second Stage")

            -- Resurrect the heartwights & add them to table.
            for _, heartwight in pairs(common.data.mechanics.dagothUr.heartwights) do

                local heartwightRef = tes3.createReference({
                    object = heartwight.id,
                    position = tes3.player.position, -- heartwight.position,
                    orientation = tes3.player.orientation, -- heartwight.orientation,
                    cell = tes3.player.cell
                })

                local heartwightRefBaseHealth = heartwightRef.mobile.health.current
                tes3.modStatistic({
                    reference = heartwightRef,
                    name = "health",
                    current = heartwightRefBaseHealth * .5 * -1
                })

                local heartwightRefBaseMagicka = heartwightRef.mobile.magicka.current
                tes3.modStatistic({
                    reference = heartwightRef,
                    name = "magicka",
                    current = heartwightRefBaseMagicka * .5 * -1
                })

            end

            -- Get the Heart reference
            heart = tes3.getReference(heartId)

            -- Register simulate event
            event.register("simulate", onHeartSimulate)
        end
    },
    ["thirdStage"] = {
        initialize = function()
            common.debug("Dagoth Ur Fight: Beginning Third Stage")

            timer.start({
                duration = 4,
                callback = function()                
                    -- Teleport Dagoth Ur to the third stage area, near the heart.
                    tes3.positionCell({
                        reference = dagothUr,
                        position = tes3.player.position,
                        orientation = tes3.player.orientation,
                        cell = tes3.player.cell
                    })
                end,
                iterations = 1
            })
        end
    }
}


local function onCellChanged(e)
    common.debug( cellId .. " - " .. e.cell.id)
    if (cellId == e.cell.id) then
        common.debug("Dagoth Ur Fight: Initializing fight.")
        stagesDagothUr.firstStage.initialize()
    end
end

local function onJournal(e)
    if (e.topic.id ~= journalId) then
        return
    end

    event.unregister("cellChanged", onCellChanged)
    event.unregister("journal", onJournal)
end

local function onLoaded(e)
    local journalIndex = tes3.getJournalIndex(journalId) 
    if (journalIndex == nil or journalIndex < 5) then
        event.register("cellChanged", onCellChanged)
        event.register("journal", onJournal)
    end
end

event.register("loaded", onLoaded)
------------------------------------------
