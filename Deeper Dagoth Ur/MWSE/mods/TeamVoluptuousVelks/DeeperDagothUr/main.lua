-- Check MWSE Build.
if (mwse.buildDate == nil) or (mwse.buildDate < 20190821) then
    local function warning()
        tes3.messageBox(
            "[Deeper Dagoth Ur ERROR] Your MWSE is out of date!"
            .. " You will need to update to a more recent version to use this mod."
        )
    end
    event.register("initialized", warning)
    event.register("loaded", warning)
    return
end

-- Check Magicka Expanded framework.
local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")
if (framework == nil) then
    local function warning()
        tes3.messageBox(
            "[Deeper Dagoth Ur ERROR] Magicka Expanded framework is not installed!"
            .. " You will need to install it to use this mod."
        )
    end
    event.register("initialized", warning)
    event.register("loaded", warning)
    return
end

local combatEvent = require("TeamVoluptuousVelks.DeeperDagothUr.events.combat")

-- Initilization Section --
local function onInitialized()	
    if not tes3.isModActive("Deeper Dagoth Ur.ESP") then
        print("[Deeper Dagoth Ur: INFO] ESP not loaded")
        return
    end

	print("[Deeper Dagoth Ur: INFO] Initialized Deeper Dagoth Ur")
end
event.register("initialized", onInitialized)
----------------------------