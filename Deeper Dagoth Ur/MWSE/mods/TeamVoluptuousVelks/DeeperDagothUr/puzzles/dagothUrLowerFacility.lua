
local cellId = "Dagoth Ur, Lower Facility"
local journalId = "C3_DestroyDagoth"

local champions = {
    first = {
        id = "TEST1",
        dead = false
    },
    second = {
        id = "TEST2",
        dead = false
    }
}
local gateId = ""

local function onDeath(e)
    local id = e.reference.object.baseObject.id
    if (champions.first.id ~= id and champions.second.id ~= id) then
        return
    end

    if (champions.first.id == id) then
        champions.first.dead = true
    else
        champions.second.dead = true
    end

    if (champions.first.dead == true and champions.second.dead == true) then
        tes3.messageBox("As the last champion falls, the vibrations of nearby machinery increases.")

        tes3.unlock({
            reference = gateId
        })
    else
        tes3.messageBox("With the death of the first champion, mechanical noises begin to rise up from below.")
    end
end

local function onCellChanged(e)
    if (e.previousCell.id == cellId) then
        event.unregister("death", onDeath)
    elseif (e.cell.id == cellId) then
        event.register("death", onDeath)
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