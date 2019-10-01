
local function onCombatStartWithDagothUr(e)
    local dagothUrId = "dagoth ur"
    if (e.target.object.id ~= dagothUrId) then
        return
    end

    tes3.messageBox("Starting combat with Dagoth Ur.")
end

event.register("combatStart", onCombatStartWithDagothUr)


local function onCombatStartWithAscendedSleeper(e)
    local ascendedSleeperId = "ascended sleeper"
    if (e.target.object.id ~= ascendedSleeperId) then
        return
    end

    tes3.messageBox("Starting combat with Ascended Sleeper.")
end

event.register("combatStart", onCombatStartWithAscendedSleeper)