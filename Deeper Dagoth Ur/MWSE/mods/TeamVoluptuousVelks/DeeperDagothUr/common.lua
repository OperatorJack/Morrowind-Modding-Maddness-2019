local this = {}

local debug = true

this.debug = function (message)
    if (debug) then
        local prepend = '[Deeper Dagoth Ur: DEBUG] '
        message = prepend .. message
        mwse.log(message)
        tes3.messageBox(message)
    end
end

this.error = function (message)
    local prepend = '[Deeper Dagoth Ur: ERROR] '
    message = prepend .. message
    mwse.log(message)
    tes3.messageBox(message)
end

this.data = {
    spellIds = {
        ascendedSleeperSummonAshSlaves = "DDU_AscendedSlprSummonAshSlvs",
        ascendedSleeperHeal = "hearth heal",
        ashVampireSummonAscendedSleepers = "DDU_AshVmprSummonAscndSlprs"
    },
    diseaseIds = {
        blackHeartBlight = {
            id = "black-heart blight",
            name = "Black-Heart Blight"
        },
        ashWoeBlight = {
            id = "ash woe blight",
            name = "Ash Woe Blight"
        },
        ashChancreBlight = {
            id = "ash-chancre",
            name = "Ash-chancre"
        },
        chanthraxBlight = {
            id = "chanthrax blight",
            name = "Chanthrax Blight"
        }
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

this.forceCast = function(params)
    tes3.playAnimation({
        reference = params.reference,
        group = tes3.animationGroup.idle,
        startFlag = 1
    })

    tes3.cast({
        reference = params.reference,
        target = params.target,
        spell = params.spell
    })
end

return this