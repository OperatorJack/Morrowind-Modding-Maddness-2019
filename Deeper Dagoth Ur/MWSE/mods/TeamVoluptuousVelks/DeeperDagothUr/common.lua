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