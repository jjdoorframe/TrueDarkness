local function InitSpellTable(list)
    local spellTable = {}
    for _, spell in ipairs(list) do
        spellTable[spell] = true
    end
    return spellTable
end

---Spells that target the ground
---@type table
CheckPlaceDarkness = InitSpellTable {"Target_ConjureElementals_Minor_Container", "Target_ConjureElemental_Container",
    "Target_BlackTentacles", "Target_GuardianOfFaith", "Target_MagicCircle", "Target_MistyStep", "Target_FarStep",
    "Teleportation_ThunderStep", "Target_ConjureIntellectDevour", "Target_SummonShadowspawn",
    "Target_ConjureWoodlandBeings", "Teleportation_ArcaneGate", "Target_CallLightning", "Target_ControlFlames",
    "Target_CreateBonfire", "Target_CursedTome_WakeTheDead", "Target_DustDevil", "Target_EruptingEarth",
    "Target_HealingSpirit", "Target_Maelstrom", "Target_ShapeWater", "Target_SummonBeholderkin",
    "Target_SummonConstruct", "Target_SummonElemental", "Target_SummonFey"}

---Spells that target creatures
---Source: https://homebrewery.naturalcrit.com/share/Hk7zwD4Gxr
---Credit for collecting: Zerd (https://www.nexusmods.com/baldursgate3/mods/1329)
---@type table
CheckTargetDarkness = InitSpellTable {"Projectile_AcidSplash", "Target_AnimalFriendship", "Target_Bane",
    "Target_Banishment", "Target_Blight", "Target_Blindness", "Projectile_ChainLightning", "Target_CharmPerson",
    "Projectile_ChromaticOrb", "Target_Command_Container", "Target_CompelledDuel", "Target_CrownOfMadness",
    "Projectile_Disintegrate", "Target_DominateBeast", "Target_DominatePerson", "Target_EnlargeReduce",
    "Target_Enthrall", "Target_Eyebite", "Target_FleshToStone", "Target_Harm", "Target_Haste", "Target_Heal",
    "Target_HealingWord", "Target_HeatMetal", "Target_Hex", "Target_HoldMonster", "Target_HoldPerson",
    "Target_HuntersMark", "Target_Knock", "Projectile_MagicMissile", "Shout_HealingWord_Mass",
    "Target_IrresistibleDance", "Target_PhantasmalForce", "Target_PhantasmalKiller", "Projectile_PoisonSpray",
    "Target_Polymorph", "Target_PowerWordKill", "Shout_PrayerOfHealing", "Target_SacredFlame", "Target_Seeming",
    "Target_HideousLaughter", "Throw_Telekinesis", "Target_ViciousMockery", "Target_Catnap", "Target_CauseFear",
    "Target_CharmMonster", "Target_Frostbite", "Target_Infestation", "Target_LifeTransference",
    "Target_MaximiliansEarthenGrasp", "Target_MindSpike", "Projectile_NegativeEnergyFlood", "Target_PowerWordStun",
    "Target_SteelWindStrike", "Target_TollTheDead", "Shout_WordOfRadiance", "Target_IntellectFortress",
    "Target_LightningLure", "Target_MindSliver", "Target_TashasMindWhip", "Target_Feeblemind", "Target_FingerOfDeath",
    "Shout_WaterWalk", "Target_EnemiesAbound"}

---Spells that target creatures that should be ignored
---@type table
CheckTargetDarknessIgnore = InitSpellTable {"Projectile_ChainLightning_Explosion", "Target_HeatMetal_Reapply",
    "Target_HAV_DevilishOX_AlternateForm_DireWolf", "Target_EPI_PartyTime_GaleGod", "Target_HAV_TakingIsobel_TakeMol",
    "Target_Polymorph_Shapechanger", "Target_WYR_SentientAmulet_MonkHeal", "Projectile_Belch_Acid_Brewer",
    "Projectile_Belch_Cold_Brewer", "Projectile_Belch_Cold_Brewer", "Projectile_Belch_Fire_Brewer",
    "Projectile_Belch_Lightning_Brewer", "Projectile_Belch_Necro_Brewer", "Projectile_Belch_Poison_Brewer",
    "Projectile_ToxicSpit_Bulette", "Target_DampenElements_Interrupt", "Target_SteelWatcher_Biped_RetrievingShot",
    "Target_WarGodsBlessing_Interrupt", "Target_Counterspell", "Target_HellishRebuke"}

---Spell interrupts that target creatures
---@type table
CheckInterruptDarkness = InitSpellTable {"Interrupt_Counterspell", "Interrupt_HellishRebuke"}
