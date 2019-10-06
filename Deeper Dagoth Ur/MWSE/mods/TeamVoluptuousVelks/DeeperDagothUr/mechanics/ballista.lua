local common = require("TeamVoluptuousVelks.DeeperDagothUr.common")

local journalId = "C3_DestroyDagoth"
local ballistaId = ""
local cellIds = {
    ["OJ_TEST"] = true,
    ["Dagoth Ur"] = true
}
local ballistaTimers = {}

local function getLoadedBallistae()
    local cells = tes3.dataHandler.exteriorCells
    local ballistae = {}
    for _, cell in pairs(cells) do
        for ref in cell:iterateReferences() do
            -- Check that the reference is an activator.
            if (ref.object.objectType == tes3.objectType.activator) then
                -- Check that the object is a ballista
                if (ref.object.baseObject.id == ballistaId) then
                    table.insert(ballistae, ref)
                end
            end
        end
    end
end

local function rotateToTarget(reference, target)
    -- Modify vector to face player.    
    -- Modified from: https://stackoverflow.com/questions/23692077/rotate-object-to-face-point
    local distanceVector = reference.orientation:copy()
    distanceVector.x = distanceVector.x - target.orientation.x
    distanceVector.y = distanceVector.y - target.orientation.y
    distanceVector.z = distanceVector.z - target.orientation.z

    local directionA = tes3vector3.new(0, 1, 0):normalized()
    local directionB = distanceVector:copy():normalized()

    local rotationAxis = directionA:cross(directionB):normalized()

    reference.orientation = rotationAxis
end

local function isWithinFireZone(reference, target)
    if (reference.position.z >= target.position.z) then
        local distance = reference.position:distance(target.position)
        if (distance >= 400 and distance <= 2500) then
            return true
        end
    end
    return false
end

local function isBallistaDelayed(ballista, timestamp)
    if (ballistaTimers[ballista.id] == nil) then
        return true
    elseif (ballistaTimers[ballista.id] - timestamp <= 10) then
        return true
    end
    return false
end

local function onSimulate(e)
    -- Get the loaded Ballistae
    local mobilePlayer = tes3.mobilePlayer
    local ballistae = getLoadedBallistae()

    -- Check if player has levitation active.
    local isLevitationActive = tes3.isAffectedBy({
        reference = mobilePlayer,
        effect = tes3.effect.levitate
    })

    for _, ballista in pairs(ballistae) do
        -- Track the player
        rotateToTarget(ballista, mobilePlayer)

        if (isBallistaDelayed(ballista, e.timeStamp) == false) then
            if (isLevitationActive == true) then
                -- Check if ballista is within distance parameters
                if(isWithinFireZone(ballista, mobilePlayer)) then
                    tes3.cast({
                        reference = ballista,
                        target = mobilePlayer,
                        spell = common.data.spellIds.dispelLevitationBallista
                    })

                    ballistaTimers[ballista.id] = e.timeStamp
                end
            end
        end
    end
end

local function onCellChanged(e)
    if (cellIds[e.previousCell.id] == true) then
        event.unregister("simulate", onSimulate)
    elseif (cellIds[e.cell.id] == true) then
        event.register("simulate", onSimulate)
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