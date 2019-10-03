local common = require("TeamVoluptuousVelks.DeeperDagothUr.common")
local magickaExpanded = include("OperatorJack.MagickaExpanded.magickaExpanded")

-- Register Spells --
local function registerSpells()
    magickaExpanded.spells.createComplexSpell({
        id = common.data.spellIds.ascendedSleeperSummonAshSlaves,
        name = "Summon Ash Slaves",
        effects =
          {
            [1] = {
              id =tes3.effect.summonAshSlave,
              range = tes3.effectRange.self,
              duration = 30
            },
            [2] = {
              id =tes3.effect.summonAshSlave,
              range = tes3.effectRange.self,
              duration = 30
            }
          }
      })
      magickaExpanded.spells.createComplexSpell({
          id = common.data.spellIds.ashVampireSummonAscendedSleepers,
          name = "Summon Ascended Sleepers",
          effects =
            {
              [1] = {
                id =tes3.effect.summonAscendedSleeper,
                range = tes3.effectRange.self,
                duration = 45
              },
              [2] = {
                id =tes3.effect.summonAscendedSleeper,
                range = tes3.effectRange.self,
                duration = 45
              },
              [3] = {
                id =tes3.effect.summonAshGhoul,
                range = tes3.effectRange.self,
                duration = 45
              },
              [4] = {
                id =tes3.effect.summonAshGhoul,
                range = tes3.effectRange.self,
                duration = 45
              },
              [5] = {
                id =tes3.effect.summonAshGhoul,
                range = tes3.effectRange.self,
                duration = 45
              }
            }
        })
  end
  
  event.register("MagickaExpanded:Register", registerSpells)
------------------------------------------