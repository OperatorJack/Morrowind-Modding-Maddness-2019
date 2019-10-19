local magickaExpanded = include("OperatorJack.MagickaExpanded.magickaExpanded")
local common = require("TeamVoluptuousVelks.FortifiedMolagMar.common")

-- Register Spells --
local function registerSpells()
  magickaExpanded.spells.createBasicSpell({
    id = common.data.spellIds.slowTime,
    name = "Slow Time",
    effect = tes3.effect.slowTime,
    range = tes3.effectRange.self,
    duration = 10
  })
  magickaExpanded.spells.createBasicSpell({
    id = common.data.spellIds.annihilate,
    name = "Annihilate",
    effect = tes3.effect.annihilate,
    range = tes3.effectRange.target,
    radius = 10
  })
end
  
  event.register("MagickaExpanded:Register", registerSpells)
------------------------------------------