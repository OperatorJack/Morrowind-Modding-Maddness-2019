local common = require("TeamVoluptuousVelks.DeeperDagothUr.common")

-- Dagoth Ur Mechanics --
local dagothUrId = "dagoth ur"

local function onCombatStartWithDagothUr(e)
    if (e.target.object.id ~= dagothUrId) then
        return
    end

    tes3.messageBox("Starting combat with Dagoth Ur.")
end

event.register("combatStart", onCombatStartWithDagothUr)
------------------------------------------

-- Ascended Sleeper Mechanics --
local ascendedSleeperId = "ascended_sleeper"

local function isAscendedSleeper(id)
    return id == ascendedSleeperId
end

local function onDeathOfAscendedSleeper(e)
    local referenceId = e.mobile.object.baseObject.id
    if (isAscendedSleeper(referenceId) == false) then
        return
    end

    common.debug("Ascended Sleeper is dying.")

    -- 5% chance of this occuring on death.
    if (common.shouldPerformRandomEvent(10)) then
        local result = math.random(1, 3)

        if (result == 1) then
            common.debug("Ascended Sleeper Death: Result 1.")
            tes3.messageBox("As the Ascended Sleeper dies, you hear a whisper: 'What are you doing? You have no idea." .. 
            " Poor animal. You struggle and fight, and understand nothing.'")
        elseif (result == 2) then
            common.debug("Ascended Sleeper Death: Result 2.")
            tes3.messageBox("With it's last breath, the Ascended Sleeper gasps: 'A bug. A weed. A piece of dust. Busy, " ..
             "busy, busy.'")
        else 
            common.debug("Ascended Sleeper Death: Result 3.")
            tes3.messageBox("A calmness radiates from the Ascended Sleeper, and it says 'You think what you do has meaning? " .. 
            " You think you slay me, and I am dead? It is just dream and waking over and over, one appearance after another, nothing real. What you do here means nothing. Why do we waste our breath on you?'")
        end

        return
    end

    common.debug("Ascended Sleeper Death: Check failed.")
end

local function onCombatStartedWithAscendedSleeper(e)
    local targetId = e.target.object.baseObject.id
    if (isAscendedSleeper(targetId) == false) then
        return
    end

    if (e.actor ~= tes3.mobilePlayer) then
        return
    end

    common.debug("Starting Combat with Ascended Sleeper.")
    
    local ascendedSleeper = e.target
    local player = e.actor

    local hasCastHealSpell = false
    local ascendedSleeperHealSpell = tes3.getObject("hearth heal")

    local hasCastSummonAshSlaves = false
    local summonedAshSlaveId = "ash_slave"
    local summonedAshSlaveSpell = tes3.getObject("dagoth's bosom")

    timer.start({
        duration = 10,
        callback = function ()
            if (ascendedSleeper.health.current <= 1) then                
                common.debug("Ascended Sleeper Combat: Ascended sleeper has died. Timer continuing.")
                return
            end

            if (common.shouldPerformRandomEvent(95) == false) then
                common.debug("Ascended Sleeper Combat: Random Check failed. Continuing on next iteration.")
                return
            end

            if (hasCastHealSpell == false and ascendedSleeper.health.current <= 100) then
                common.debug("Ascended Sleeper Combat: Casting Self Heal.")

                -- Explodes spell, healing self and giving blight to nearby actors.
                tes3.cast({
                    reference = ascendedSleeper,
                    target = ascendedSleeper,
                    spell = ascendedSleeperHealSpell
                })            

                local distainceLimit = 450
                local actors = common.getActorsNearTargetPosition(ascendedSleeper.cell, ascendedSleeper.position, distainceLimit)
                for _, actor in pairs(actors) do
                    mwscript.addSpell({
                        reference = actor,
                        spell = "black-heart blight"
                    })

                    common.debug("Ascended Sleeper Combat: Giving actor Blight disease.")

                    if (actor == tes3.mobilePlayer) then
                        common.debug("Ascended Sleeper Combat: Giving player Blight disease.")
                        tes3.messageBox("As the Ascended Sleeper heals, you are contaminated due to your close proximity. You have contracted Black-Heat Blight.")
                    end
                end

                hasCastHealSpell = true
            end

            if (hasCastSummonAshSlaves == false) then
                common.debug("Ascended Sleeper Combat: Summoning Ash Slaves.")

                -- Explodes spell, for visual effect.
                tes3.cast({
                    reference = ascendedSleeper,
                    target = player,
                    spell = summonedAshSlaveSpell
                })   

                local summonPosition = ascendedSleeper.position:copy()
                local summonOrientation = ascendedSleeper.reference.orientation:copy()
                local summonCell = ascendedSleeper.cell

                local slave1 = tes3.createReference({
                    object = summonedAshSlaveId,
                    position = summonPosition,
                    orientation = summonOrientation,
                    cell = summonCell
                })

                mwscript.startCombat({
                    reference = slave1,
                    target = player
                })

                local slave2 = tes3.createReference({
                    object = summonedAshSlaveId,
                    position = summonPosition,
                    orientation = summonOrientation,
                    cell = summonCell
                })

                mwscript.startCombat({
                    reference = slave2,
                    target = player
                })

                hasCastSummonAshSlaves = true
            end
        end,
        iterations = 24
    })
end

event.register("death", onDeathOfAscendedSleeper)
event.register("combatStarted", onCombatStartedWithAscendedSleeper)
------------------------------------------