local common = require("TeamVoluptuousVelks.DeeperDagothUr.common")

-- Ash Vampire Mechanics --
local ashVampireIds = {
    ["ash_vampire"] = true,
    ["dagoth araynys"] = true,
    ["dagoth endus"] = true,
    ["dagoth gilvoth"] = true,
    ["dagoth odros"] = true,
    ["dagoth tureynul"] = true,
    ["dagoth uthol"] = true,
    ["dagoth vemyn"] = true
}

local function isAshVampire(id)
    return ashVampireIds[id] == true or (id:lower():startswith("dagoth") == true and isDagothUr(id) == false)
end

local function onDeathOfAshVampire(e)
    local referenceId = e.mobile.object.baseObject.id
    if (isAshVampire(referenceId) == false) then
        return
    end

    local ashVampire = e.mobile

    common.debug("Ash Vampire is dying.")

    local actors = common.getActorsNearTargetPosition(ashVampire.cell, ashVampire.position, 850)
    local countOfActors = 0
    for _, actor in pairs(actors) do
        if (actor.mobile.health.current > 1) then
            countOfActors = countOfActors + 1
        end
    end
    local ratio = -17 * countOfActors + 90
    
    if (ratio <= 0) then
        common.debug("Ash Vampire Death: Ratio is 0.")
        return
    else
        common.debug("Ash Vampire Death: Ratio is " .. ratio)
    end

    -- ratio% chance of this occuring on death.
    if (common.shouldPerformRandomEvent(ratio) == true) then
        if (referenceId == "dagoth araynys") then
            tes3.messageBox("araynys")
        elseif (referenceId == "dagoth endus") then
            tes3.messageBox("endus")
        elseif (referenceId == "dagoth gilvoth") then
            tes3.messageBox("gilvoth")
        elseif (referenceId == "dagoth odros") then
            tes3.messageBox("odros")
        elseif (referenceId == "dagoth tureynul") then
            tes3.messageBox("tureynul")
        elseif (referenceId == "dagoth uthol") then
            tes3.messageBox("uthol")
        elseif (referenceId == "dagoth vemyn") then
            tes3.messageBox("vemyn")
        end

        return
    end

    common.debug("Ash Vampire Death: Check failed.")
end

local onCombatStartedWithAshVampireInitialized = {}
local function onCombatStartedWithAshVampire(e)
    local targetId = e.target.object.baseObject.id
    local targetReferenceId = e.target.object.id

    if (isAshVampire(targetId) == false) then
        return
    end

    if (e.actor ~= tes3.mobilePlayer) then
        return
    end

    if (onCombatStartedWithAshVampireInitialized[targetReferenceId] == true) then  
        return
    end

    common.debug("Starting Combat with Ash Vampires")

    -- Mark the reference as processed.
    onCombatStartedWithAshVampireInitialized[targetReferenceId] = true

    local ashVampire = e.target
    local hasCastSummonAscendedSleepers = false

    local combatTimer
    combatTimer = timer.start({
        duration = 5,
        callback = function ()
            if (ashVampire.health.current < 1) then                
                common.debug("Ash Vampire Combat: Ash Vampire has died. Timer Cancelled.")
                combatTimer:cancel()
                return
            end

            if (hasCastSummonAscendedSleepers) then             
                common.debug("Ash Vampire Combat: Ash Vampire has used all new mechanics. Timer Cancelled.")
                combatTimer:cancel()
                return
            end

            if (common.shouldPerformRandomEvent(95) == false) then
                common.debug("Ash Vampire Combat: Random Check failed. Continuing on next iteration.")
                return
            end

            if (hasCastSummonAscendedSleepers == false) then
                common.debug("Ash Vampire: Summoning Ascended Sleepers.")

                -- Explodes spell, for visual effect.
                common.forceCast({
                    reference = ashVampire,
                    target = ashVampire,
                    spell = common.data.spellIds.ashVampireSummonAscendedSleepers
                })

                hasCastSummonAscendedSleepers = false
            end
        end,
        iterations = 24
    })
end

event.register("death", onDeathOfAshVampire)
event.register("combatStarted", onCombatStartedWithAshVampire)
------------------------------------------