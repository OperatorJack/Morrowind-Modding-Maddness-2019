local common = require("TeamVoluptuousVelks.DeeperDagothUr.common")
local magickaExpanded = include("OperatorJack.MagickaExpanded.magickaExpanded")

-- Forward declare spell ids.
local spellIds = {
    ascendedSleeperSummonAshSlaves = "DDU_AscendedSlprSummonAshSlvs",
    ascendedSleeperHeal = "hearth heal",
    ascendedSleeperBlackHeartBlight = "black-heart blight"
}

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
    return ashVampireIds[id] == true
end

local function onDeathOfAshVampire(e)
    local referenceId = e.mobile.object.baseObject.id
    if (isAshVampire(referenceId) == false) then
        return
    end

    local ashVampire = e.mobile

    common.debug("Ash Vampire is dying.")

    local actors = common.getActorsNearTargetPosition(ashVampire.cell, ashVampire.position, 1000)
    local countOfActors = #actors
    local ratio = -17 * countOfActors + 90
    
    if (ratio <= 0) then
        common.debug("Ash Vampire Death: Ratio is 0.")
        return
    end

    -- ratio% chance of this occuring on death.
    if (common.shouldPerformRandomEvent(ratio)) then
        if (referenceId == "dagoth araynys") then
            tes3.messageBox("")
        else if (referenceId == "dagoth endus") then
            tes3.messageBox("")
        else if (referenceId == "dagoth gilvoth") then
            tes3.messageBox("")
        else if (referenceId == "dagoth odros") then
            tes3.messageBox("")
        else if (referenceId == "dagoth tureynul") then
            tes3.messageBox("")
        else if (referenceId == "dagoth uthol") then
            tes3.messageBox("")
        else if (referenceId == "dagoth vemyn") then
            tes3.messageBox("")
        end

        return
    end

    common.debug("Ash Vampire Death: Check failed.")
end

event.register("death", onDeathOfAshVampire)
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

    -- 10% chance of this occuring on death.
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

local onCombatStartedWithAscendedSleeperInitialized = {}
local function onCombatStartedWithAscendedSleeper(e)
    local targetId = e.target.object.baseObject.id
    local targetReferenceId = e.target.object.id

    if (isAscendedSleeper(targetId) == false) then
        return
    end

    if (e.actor ~= tes3.mobilePlayer) then
        return
    end

    if (onCombatStartedWithAscendedSleeperInitialized[targetReferenceId] == true) then  
        return
    end

    common.debug("Starting Combat with Ascended Sleeper.")

    -- Mark the reference as processed.
    onCombatStartedWithAscendedSleeperInitialized[targetReferenceId] = true

    local ascendedSleeper = e.target
    local player = e.actor

    local hasCastHealSpell = false
    local hasCastSummonAshSlaves = false

    local combatTimer
    combatTimer = timer.start({
        duration = 5,
        callback = function ()
            if (ascendedSleeper.health.current < 1) then                
                common.debug("Ascended Sleeper Combat: Ascended sleeper has died. Timer Cancelled.")
                combatTimer:cancel()
                return
            end

            if (hasCastHealSpell and hasCastSummonAshSlaves) then             
                common.debug("Ascended Sleeper Combat: Ascended sleeper has used all new mechanics. Timer Cancelled.")
                combatTimer:cancel()
                return
            end

            if (common.shouldPerformRandomEvent(95) == false) then
                common.debug("Ascended Sleeper Combat: Random Check failed. Continuing on next iteration.")
                return
            end

            common.debug("Ascended Sleeper Combat: Current health at " .. ascendedSleeper.health.current)

            if (hasCastHealSpell == false and ascendedSleeper.health.current <= 100) then
                common.debug("Ascended Sleeper Combat: Casting Self Heal.")

                -- Explodes spell, healing self and giving blight to nearby actors.
                common.forceCast({
                    reference = ascendedSleeper,
                    target = ascendedSleeper,
                    spell = spellIds.ascendedSleeperHeal
                })            

                local distainceLimit = 450
                if (player.position:distance(ascendedSleeper.position) <= distainceLimit) then
                    mwscript.addSpell({
                        reference = player,
                        spell = spellIds.ascendedSleeperBlackHeartBlight
                    })

                    tes3.messageBox("As the Ascended Sleeper heals, you are contaminated due to your close proximity. You have contracted Black-Heat Blight.")
                end

                hasCastHealSpell = true
            end

            if (hasCastSummonAshSlaves == false) then
                common.debug("Ascended Sleeper Combat: Summoning Ash Slaves.")

                -- Explodes spell, for visual effect.
                common.forceCast({
                    reference = ascendedSleeper,
                    target = ascendedSleeper,
                    spell = spellIds.ascendedSleeperSummonAshSlaves
                })

                hasCastSummonAshSlaves = false
            end
        end,
        iterations = 24
    })
end

event.register("death", onDeathOfAscendedSleeper)
event.register("combatStarted", onCombatStartedWithAscendedSleeper)
------------------------------------------

-- Register Spells --
local function registerSpells()
    magickaExpanded.spells.createComplexSpell({
        id = spellIds.ascendedSleeperSummonAshSlaves,
        name = "Summon Ash Slaves",
        effects =
          {
            [1] = {
              id =tes3.effect.summonAshSlave,
              range = tes3.effectRange.self,
              duration = 30
            },
            [2] = {
              id =tes3.effect.summonAshSlave,
              range = tes3.effectRange.self,
              duration = 30
            }
          }
      })
  end
  
  event.register("MagickaExpanded:Register", registerSpells)
------------------------------------------