local common = require("TeamVoluptuousVelks.FortifiedMolagMar.common")

local function charge()
    common.debug("Artifact: Charging Artifact.")

    tes3.modStatistic({
        reference = tes3.mobilePlayer,
        name = "health",
        base = tes3.mobilePlayer.health.base * .9
    })

    tes3.player.data.fortifiedMolarMar.artifactCharged = true

    local equipped = mwscript.hasItemEquipped({
        reference = tes3.player,
        item = common.objectIds.artifactDischargedRing
    })

    mwscript.removeItem({
        reference = tes3.player,
        item = common.objectIds.artifactDischargedRing
    })
    if (equipped == true) then
        mwscript.equip({
            reference = tes3.player,
            item = common.objectIds.artifactChargedRing
        })
    else
        mwscript.addItem({
            reference = tes3.player,
            item = common.objectIds.artifactChargedRing,
            count = 1
        })
    end
end

local function discharge()
    common.debug("Artifact: Discharging Artifact.")
    
    tes3.player.data.fortifiedMolarMar.artifactCharged = false

    local equipped = mwscript.hasItemEquipped({
        reference = tes3.player,
        item = common.objectIds.artifactChargedRing
    })

    mwscript.removeItem({
        reference = tes3.player,
        item = common.objectIds.artifactChargedRing
    })
    if (equipped == true) then
        mwscript.equip({
            reference = tes3.player,
            item = common.objectIds.artifactDischargedRing
        })
    else
        mwscript.addItem({
            reference = tes3.player,
            item = common.objectIds.artifactDischargedRing,
            count = 1
        })
    end
end

local function onArtifactEnchantmentCasted(e)
    if (e.caster ~= tes3.player) then
        return
    end

    common.debug("Artifact: Enchantment casted.")
    
    if (e.source.id == common.data.enchantmentIds.slowTime) then
        discharge()
    end
end
event.register("magicCasted", onArtifactEnchantmentCasted)

local function castAlterSpell(alter)
    common.debug("Artifact: Casting alter spell.")
    
    tes3.cast({
        reference = alter,
        target = tes3.player,
        spell = common.data.spellIds.slowTimeShrine
    })
end

local function onShrineActivate(e)
    if (e.target.object.id ~= common.data.objectIds.artifactShrine) then
        return
    end

    common.debug("Artifact: Shrine Activated.")

    local dischargedArtifactCount = mwscript.getItemCount({
        reference = tes3.player,
        item = common.objectIds.artifactDischargedRing
    })

    if (dischargedArtifactCount > 0) then
        tes3.messageBox({
            message = common.data.messageBoxes.artifactShrineWithDischargedArtifact,
            buttons = { "Pray at Alter", "Recharge Artifact", "Cancel"},
            callback = function(e)
                if (e ~= nil) then
                    if (e.button == 0) then
                        castAlterSpell(e.target)
                    elseif (e.button == 1) then
                        charge()
                    else
                        return
                    end
                end
            end
        })
    else
        tes3.messageBox({
            message = common.data.messageBoxes.artifactShrineNoDischargedArtifact,
            buttons = { "Pray at Alter", "Cancel"},
            callback = function(e)
                if (e ~= nil) then
                    if (e.button == 0) then
                        castAlterSpell(e.target)
                    else
                        return
                    end
                end
            end
        })
    end
end
event.register("activate", onShrineActivate)