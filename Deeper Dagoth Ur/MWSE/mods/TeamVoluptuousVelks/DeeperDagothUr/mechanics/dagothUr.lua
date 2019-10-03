
local common = require("TeamVoluptuousVelks.DeeperDagothUr.common")

-- Dagoth Ur Mechanics --
local dagothUrIds = {
    ["dagoth_ur_1"] = true,
    ["dagoth_ur_2"] = true
}

local function isDagothUr(id)
    return dagothUrIds[id] == true
end

local combatStartedWithDagothUr = false
local stagesDagothUr = {}
stagesDagothUr = {
    ["firstStage"] = {
        initialize = function()
            common.debug("Dagoth Ur Fight: Beginning First Stage")

            stagesDagothUr.secondStage.initialize()
        end
    },
    ["secondStage"] = {
        initialize = function()
            common.debug("Dagoth Ur Fight: Beginning Second Stage")

        end
    }
}

local function onCombatStartedWithDagothUr(e)
    local targetId = e.target.object.baseObject.id
    if (isDagothUr(targetId) == false) then
        return
    end

    if (combatStartedWithDagothUr == true) then
        return
    end

    combatStartedWithDagothUr = true

    tes3.messageBox("Starting combat with Dagoth Ur.")

    stagesDagothUr.firstStage.initialize()
end

event.register("combatStarted", onCombatStartedWithDagothUr)
------------------------------------------
