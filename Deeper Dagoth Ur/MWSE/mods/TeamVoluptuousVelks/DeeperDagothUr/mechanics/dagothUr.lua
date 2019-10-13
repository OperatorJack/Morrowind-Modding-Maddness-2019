
local common = require("TeamVoluptuousVelks.DeeperDagothUr.common")

-- Dagoth Ur Mechanics --
local journalId = "C3_DestroyDagoth"
local cellId = "Dagoth Ur, Facility Cavern"
local barrierId = "stageOneBarrier"
local heartId = ""

local dagothUrSpellCasted = false
local stagesDagothUr = {}
local barrier = nil
local heart = nil

local function onHeartSimulate(e)
    if (tes3.player.position:distance(heart.position) <= 500) then
        stagesDagothUr.thirdStage.initialize()
        event.unregister("simulate", onHeartSimulate)
    end
end

local function onBarrierSpellCasted(e)
    barrier:enable()
    dagothUrSpellCasted = true
    event.unregister("spellCasted", onBarrierSpellCasted)
end

stagesDagothUr = {
    ["firstStage"] = {
        initialize = function()
            common.debug("Dagoth Ur Fight: Beginning First Stage")

            -- Disable barrier.
            barrier = tes3.getReference(barrierId)
            barrier:disable()

            -- Opening barrier mechanic.
            local spell = tes3.getObject("shockball")
            event.register("spellCasted", onBarrierSpellCasted, { filter = spell })
            tes3.cast({
                caster = common.data.mechanics.dagothUr.ids.dagothUrs.dagoth_ur_1,
                target = barrier,
                spell = spell
            })

            -- Teleport Dagoth Ur to the second stage area.
            tes3.positionCell({
                reference = common.data.mechanics.dagothUr.ids.dagothUrs.dagoth_ur_1,
                position = {},
                orientation = {},
                cell = tes3.player.cell
            })

            -- Set timer to spawn enemies
            timer.start({
                duration = 5,
                callback = function ()
                    tes3.createReference({
                        object = common.data.mechanics.dagothUr.ids.creatures.ashSlave,
                        position = tes3.player.position,
                        orientation = tes3.player.orientation,
                        cell = tes3.player.cell
                    })
                end,
                iterations = 12
            })

            -- Set timer to continue to next stage.
            timer.start({
                duration = 60,
                callback = function ()   
                    if (dagothUrSpellCasted == true) then         
                        barrier:disable()
                        tes3.messageBox("The barrier to the next platform dissipates, opening the way to continue.")
                    end

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
                tes3.createReference({
                    object = heartwight.id,
                    position = heartwight.position,
                    orientation = heartwight.orientation,
                    cell = tes3.player.cell
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
                        reference = common.data.mechanics.dagothUr.ids.dagothUrs.dagoth_ur_1,
                        position = {},
                        orientation = {},
                        cell = tes3.player.cell
                    })
                end,
                iterations = 1
            })
        end
    }
}


local function onCellChanged(e)
    if (cellId == e.cell.id) then
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
