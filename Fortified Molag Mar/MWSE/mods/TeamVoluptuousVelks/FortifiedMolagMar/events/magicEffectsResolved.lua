local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")
local common = require("TeamVoluptuousVelks.FortifiedMolagMar.common")

tes3.claimSpellEffectId("slowTime", 402)
tes3.claimSpellEffectId("annihilate", 403)

-- Slow Time Effect --
local timeShift = false
local function onSimulate()
    if (timeShift) then
        tes3.worldController.deltaTime = tes3.worldController.deltaTime * timeShift
    end
end

local function onSlowTimeTick(e)
	-- Trigger into the spell system.
	if (not e:trigger()) then
		return
	end

	if (timeShift == false and e.effectInstance.state ~= tes3.spellState.ending) then
		common.debug("Slow Time Effect: Slowing time.")
		event.register("simulate", onSimulate)
		timeShift = .5
	end

	if (e.effectInstance.state == tes3.spellState.ending) then		
		common.debug("Slow Time Effect: Removing Slow time.")
		event.unregister("simulate", onSimulate)
		timeShift = false
	end
end

local function addSlowTimeEffect()
	framework.effects.alteration.createBasicEffect({
		-- Base information.
		id = tes3.effect.slowTime,
		name = "Slow Time",
		description = "Slows time by 50%.",

		-- Basic dials.
		baseCost = 3.0,

		-- Various flags.
		allowEnchanting = false,
        allowSpellmaking = false,
        hasNoMagnitude = true,
        canCastSelf = true,
        nonRecastable = false,

		-- Graphics/sounds.
        lighting = { 0, 0, 0 },

		-- Required callbacks.
		onTick = onSlowTimeTick,
	})
end
-------------------------------------------------

-- Annihilate Effect --
local function onAnnihilateTick(e)
	-- Trigger into the spell system.
	if (not e:trigger()) then
		return
	end

	e.effectInstance.target.mobile:applyHealthDamage(999999)
	
    e.effectInstance.state = tes3.spellState.retired
end

local function addAnnihilateEffect()
	framework.effects.destruction.createBasicEffect({
		-- Base information.
		id = tes3.effect.annihilate,
		name = "Annihilate",
		description = "Instantly kills anything that it touches.",

		-- Basic dials.
		baseCost = 3.0,

		-- Various flags.
		allowEnchanting = false,
        allowSpellmaking = false,
		hasNoMagnitude = true,
		hasNoDuration = true,
		canCastTouch = true,
		canCastTarget = true,
        nonRecastable = false,

		-- Graphics/sounds.
        lighting = { 0, 0, 0 },

		-- Required callbacks.
		onTick = onAnnihilateTick,
	})
end
-------------------------------------------------
event.register("magicEffectsResolved", addSlowTimeEffect)
event.register("magicEffectsResolved", addAnnihilateEffect)