local config = require("TeamVoluptuousVelks.FortifiedMolagMar.config")

local this = {}
this.debug = function (message)
    if (config.showDebug == true) then
        local prepend = '[Fortified Molag Mar: DEBUG] '
        message = prepend .. message
        mwse.log(message)
        tes3.messageBox(message)
    end
end

this.error = function (message)
    if (config.showErrors == true) then
        local prepend = '[Fortified Molag Mar: ERROR] '
        message = prepend .. message
        mwse.log(message)
        tes3.messageBox(message)
    end
end

this.data = {
    playerData = {
        shrines = {
            ["furn_shrine_vivec_cure_02"] = false,
            ["furn_shrine_vivec_cure_03"] = false,
            ["ac_shrine_palace"] = false,
            ["ac_shrine_stopmoon"] = false,
            ["ac_shrine_puzzlecanal"] = false,
            ["ac_shrine_koalcave"] = false,
            ["ac_shrine_gnisis"] = false,
        },
        artifactCharged = true
    },
    journalIds = {
        aFriendLost = "FMM_BA_01",
        aFriendMourned = "FMM_BA_02",
        aFriendReturned = "FMM_BA_03",
        aFriendAvenged = "",
        aFriendReborn = ""
    },
    spellIds = {
        slowTime = "FMM_SlowTimeSpell",
        slowTimeShrine = "FMM_SlowTimeShrineSpell",
        annihilate = "FMM_AnnihilateSpell",
        dispelEnchantedBarrier = "FMM_DispelBarrierSpell",
        banishDaedra = "FMM_LesserBanishDaedraSpell",
        firesOfOblivion = "FMM_FiresOfOblivion"
    },
    enchantmentIds = {
        banishDaedra = "FMM_BanishWeapon_e",
        slowTime = "FMM_SlowTimeRing_e",
        bucketHelm = "FMM_BucketHelmet_e"
    },
    npcIds = {
        armiger = "FMM_SarisLerano",
        indaram = "birer indaram",
        mage = "FMM_Ulyll",
        vivec = "",
        dremoraLord = "",
        cultist = "FMM_Cultist_u",
        weakCultist = "FMM_GenericCultist",
        genericArmiger = "FMM_BuoyantArmigerGuard"
    },
    objectIds = {
        enchantedBarrier = "FMM_EnchantedBarrier",
        cultActivator = "FMM_CultFightMarker",
        ritualSiteActivator = "FMM_RitualSiteMarker",
        amulet = "FMM_Amulet_01",
        banishWeapon = "FMM_BanishWeapon",
        artifactChargedRing = "FMM_SlowTimeChargedRing",
        artifactDischargedRing = "FMM_SlowTimeDischargedRing",
        artifactShrine = "FMM_TempleShrine",
        firesOfOblivion = "FMM_FiresOfOblivionVFX",
        grateA = "FMM_grate_03a",
        grateB = "FMM_grate_03b"
    },
    cellIds = {
        underworks = "Molag Mar, Underworks",
        armigersStronghold = "Molag Mar, Armigers Stronghold",
        battlements = ""
    },

    messageBoxes = {
        enchantedBarrierActivate = "No no sir, no es here.",
        mageSkirmishDialogue = "You hear your companion yell, 'This one looks especially tough, be careful against him!'",
        shrinesCompletedDialogue = "Finished shrines",
        shrinesInProgressDialogue = "Amulet get bigger",
        shrinesNoAmuletDialogue = "wear amulet bro",
        mageDeathDialogue = "Plz take artifact",
        cultistRetreatDialogue = "Cultists retreated",
        artifactShrineWithDischargedArtifact = "Hello w Artifacnt",
        artifactShrineNoDischargedArtifact = "Hello no artifact"
    }
}


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