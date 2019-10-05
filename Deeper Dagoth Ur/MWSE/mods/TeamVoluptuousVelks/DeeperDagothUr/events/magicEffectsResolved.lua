local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")

tes3.claimSpellEffectId("dispelLevitate", 400)

-- Dispel Levitation Effect --
local function onDispelLevitateTick(e)
	-- Trigger into the spell system.
	if (not e:trigger()) then
		return
	end

	-- Remove any levitation effects.
	tes3.removeEffects({
        reference = e.effectInstance.target,
        effect = tes3.effect.levitate
    })

    e.effectInstance.state = tes3.spellState.retired
end

local function addDispelLevitateEffect()
	framework.effects.mysticism.createBasicEffect({
		-- Base information.
		id = tes3.effect.dispelLevitate,
		name = "Dispel Levitate",
		description = "Removes any active levitation effects from the target.",

		-- Basic dials.
		baseCost = 3.0,

		-- Various flags.
		allowEnchanting = true,
        allowSpellmaking = true,
        hasNoMagnitude = true,
        hasNoDuration = true,
		canCastTarget = true,
        canCastTouch = true,
        canCastSelf = true,
        nonRecastable = false,

		-- Graphics/sounds.
        lighting = { 0, 0, 0 },
        boltVFX = "DDU_VFX_javelinBolt",

		-- Required callbacks.
		onTick = onDispelLevitateTick,
	})
end
-------------------------------------------------
event.register("magicEffectsResolved", addDispelLevitateEffect)