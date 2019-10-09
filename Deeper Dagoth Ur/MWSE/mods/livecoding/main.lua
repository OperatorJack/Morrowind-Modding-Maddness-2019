--[[
    run code without restarting the game! hotkey alt+x
--]]

function test()
    local eyevec = tes3.getPlayerEyeVector()
    local eyepos = tes3.getPlayerEyePosition()
    local rayhit = tes3.rayTest{position=eyepos, direction=eyevec}

    local node = rayhit.reference.sceneNode:getObjectByName("LookAtTarget")
    -- detach the LookAtTarget from the reference
    node.parent:detachChild(node)

    -- then attach the LookAtTarget to the player
    tes3.player.sceneNode:attachChild(node)

    tes3.messageBox("ROTATION UPDATED")
end


-- ignore stuff below here!

if testing then
    return test()
end

local function onKeyDownX(e)
    if e.isAltDown then
        testing = debug.getinfo(1).source:sub(2)
        dofile(testing)
    end
end
event.register("keyDown", onKeyDownX, {filter=tes3.scanCode.x})
