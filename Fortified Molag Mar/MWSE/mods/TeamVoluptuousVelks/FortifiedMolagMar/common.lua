local config = require("TeamVoluptuousVelks.FortifiedMolagMar.config")

local this = {}
this.debug = function (message)
    if (config.showDebug == true) then
        local prepend = '[Fortified Molag Mar: DEBUG] '
        message = prepend .. message
        mwse.log(message)
        tes3.messageBox(message)
    end
end

this.error = function (message)
    if (config.showErrors == true) then
        local prepend = '[Fortified Molag Mar: ERROR] '
        message = prepend .. message
        mwse.log(message)
        tes3.messageBox(message)
    end
end

this.data = {
    journalIds = {
        aFriendLost = "FMM_BA_01",
        aFriendMourned = "FMM_BA_02",
        aFriendReturned = "",
        aFriendAvenged = "",
        aFriendReborn = ""
    },
    spellIds = {
        slowTime = "FMM_SlowTimeSpell",
        annihilate = "FMM_AnnihilateSpell",
        dispelEnchantedBarrier = ""
    },
    npcIds = {
        armiger = "FMM_SarisLerano",
        indaram = "birer indaram",
        mage = "",
        dremoraLord = "",
        cultist = "",
        weakCultist = "",
        genericArmiger = ""
    },
    objectIds = {
        enchantedBarrier = "",
        cultActivator = ""
    },
    cellIds = {
        underworks = "Molag Mar, Underworks",
        tunnel = "",
        armigersStronghold = "Molag Mar, Armigers Stronghold"
    },

    messageBoxes = {
        enchantedBarrierActivate = "No no sir, no es here.",
        mageSkirmishDialogue = "You hear your companion yell, 'This one looks especially tough, be careful against him!'"
    }
}


this.shouldPerformRandomEvent = function (percentChanceOfOccurence)
    if (math.random(-1, 101) <= percentChanceOfOccurence) then
        return true
    end
    return false
end

this.getActorsNearTargetPosition = function(cell, targetPosition, distanceLimit)
    local actors = {}
    -- Iterate through the references in the cell.
    for ref in cell:iterateReferences() do
        -- Check that the reference is a creature or NPC.
        if (ref.object.objectType == tes3.objectType.npc or
            ref.object.objectType == tes3.objectType.creature) then
            -- Check that the distance between the reference and the target point is within the distance limit. If so, save the reference.
            local distance = targetPosition:distance(ref.position)
            if (distance <= distanceLimit) then
                table.insert(actors, ref)
            end
        end
    end
    return actors
end

return this