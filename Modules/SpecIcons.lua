local metaDB = {
    ["DEATHKNIGHT"] = {
        ["Unholy"] = "spell_deathknight_unholypresence",
        ["Blood"] = "spell_deathknight_bloodpresence",
        ["Frost"] = "spell_deathknight_frostpresence",
    },
    ["DRUID"] = {
        ["Balance"] = "spell_nature_starfall",
        ["Feral"] = "ability_racial_bearform",
        ["Restoration"] = "spell_nature_healingtouch",
    },
    ["HUNTER"] = {
        ["BeastMastery"] = "ability_hunter_beasttaming",
        ["Marksmanship"] = "ability_marksmanship",
        ["Survival"] = "ability_hunter_swiftstrike",
    },
    ["MAGE"] = {
        ["Arcane"] = "spell_holy_magicalsentry",
        ["Fire"] = "spell_fire_firebolt02",
        ["Frost"] = "spell_frost_frostbolt02",
    },
    ["PALADIN"] = {
        ["Holy"] = "spell_holy_holybolt",
        ["Protection"] = "spell_holy_devotionaura",
        ["Retribution"] = "spell_holy_auraoflight",
    },
    ["PRIEST"] = {
        ["Discipline"] = "spell_holy_wordfortitude",
        ["Shadow"] = "spell_shadow_shadowwordpain",
        ["Holy"] = "spell_holy_holybolt",
    },
    ["ROGUE"] = {
        ["Assassination"] = "ability_rogue_shadowstrikes",
        ["Combat"] = "ability_backstab",
        ["Subtlety"] = "ability_stealth",
    },
    ["SHAMAN"] = {
        ["Elemental"] = "spell_nature_lightning",
        ["Enhancement"] = "spell_nature_lightningshield",
        ["Restoration"] = "spell_nature_magicimmunity",
    },
    ["WARLOCK"] = {
        ["Affliction"] = "spell_shadow_deathcoil",
        ["Demonology"] = "spell_shadow_metamorphosis",
        ["Destruction"] = "spell_shadow_rainoffire",
    },
    ["WARRIOR"] = {
        ["Arms"] = "ability_warrior_savageblow",
        ["Fury"] = "ability_warrior_innerrage",
        ["Protection"] = "ability_warrior_defensivestance",
    }
}


local spellDB = {
    -- DEATH KNIGHT
    ["Heart Strike"] = "Blood",
    ["Vampiric Blood"] = "Blood",
    ["Dancing Rune Weapon"] = "Blood",
    ["Abomination's Might"] = "Blood",
    ["Blood Shield"] = "Blood",
    ["Bone Shield"] = "Blood",
    ["Bloodworm"] = "Blood",
    ["Will of the Necropolis"] = "Blood",
    ["Rune Tap"] = "Blood",
    ["Frost Strike"] = "Frost",
    ["Chilblains"] = "Frost",
    ["Pillar of Frost"] = "Frost",
    ["Hungering Cold"] = "Frost",
    ["Howling Blast"] = "Frost",
    ["Improved Icy Talons"] = "Frost",
    ["Killing Machine"] = "Frost",
    ["Scourge Strike"] = "Unholy",
    ["Ebon Plague"] = "Unholy",
    ["Anti-Magic Zone"] = "Unholy",
    ["Summon Gargoyle"] = "Unholy",
    ["Desolation"] = "Unholy",
    ["Unholy Blight"] = "Unholy",
    ["Runic Corruption"] = "Unholy",
    ["Unholy Frenzy"] = "Unholy",
    ["Shadow Infusion"] = "Unholy",
    ["Dark Transformation"] = "Unholy",
    
    -- DRUID
    ["Moonkin Form"] = "Balance",
    ["Typhoon"] = "Balance",
    ["Starfall"] = "Balance",
    ["Owlkin Frenzy"] = "Balance",
    ["Eclipse (Solar)"] = "Balance",
    ["Eclipse (Lunar)"] = "Balance",
    ["Earth and Moon"] = "Balance",
    ["Force of Nature"] = "Balance",
    ["Moonkin Aura"] = "Balance",
    ["Sunfire"] = "Balance",
    ["Shooting Stars"] = "Balance",
    ["Lunar Shower"] = "Balance",
    ["Fungal Growth"] = "Balance",
    ["Solar Beam"] = "Balance",
    ["Leader of the Pack"] = "Feral",
    ["Infected Wounds"] = "Feral",
    ["Mangle (Cat)"] = "Feral",
    ["Mangle (Bear)"] = "Feral",
    ["Mangle"] = "Feral",
    ["Berserk"] = "Feral",
    ["Stampede"] = "Feral",
    ["King of the Jungle"] = "Feral",
    ["Survival Instincts"] = "Feral",
    ["Pulverize"] = "Feral",
    ["Feral Charge"] = "Feral",
    ["Tree of Life"] = "Restoration",
    ["Wild Growth"] = "Restoration",
    ["Swiftmend"] = "Restoration",
    ["Living Seed"] = "Restoration",
    ["Nature's Swiftness"] = "Restoration",
    ["Fury of Stormrage"] = "Restoration",
    ["Efflorescence"] = "Restoration",
    
    -- HUNTER
    ["Bestial Wrath"] = "BeastMastery",
    ["Cobra Strikes"] = "BeastMastery",
    ["The Beast Within"] = "BeastMastery",
    ["Ferocious Inspiration"] = "BeastMastery",
    ["Intimidation"] = "BeastMastery",
    ["Killing Streak"] = "BeastMastery",
    ["Focus Fire"] = "BeastMastery",
    ["Fervor"] = "BeastMastery",
    ["Trueshot Aura"] = "Marksmanship",
    ["Chimera Shot"] = "Marksmanship",
    ["Silencing Shot"] = "Marksmanship",
    ["Piercing Shots"] = "Marksmanship",
    ["Improved Steady Shot"] = "Marksmanship",
    ["Aimed Shot"] = "Marksmanship",
    ["Marked for Death"] = "Marksmanship",
    ["Posthaste"] = "Marksmanship",
    ["Ready, Set, Aim..."] = "Marksmanship",
    ["Readiness"] = "Marksmanship",
    ["Resistance is Futile!"] = "Marksmanship",
    ["Bombardment"] = "Marksmanship",
    ["Concussive Barrage"] = "Marksmanship",
    ["Wyvern Sting"] = "Survival",
    ["Black Arrow"] = "Survival",
    ["Explosive Shot"] = "Survival",
    ["Master Tactician"] = "Survival",
    ["Sniper Training"] = "Survival",
    ["Counterattack"] = "Survival",
    ["Lock and Load"] = "Survival",
    ["Hunting Party"] = "Survival",
    
    -- MAGE
    ["Slow"] = "Arcane",
    ["Arcane Barrage"] = "Arcane",
    ["Arcane Power"] = "Arcane",
    ["Incanter's Absorption"] = "Arcane",
    ["Improved Mana Gem"] = "Arcane",
    ["Focus Magic"] = "Arcane",
    ["Arcane Potency"] = "Arcane",
    ["Presence of Mind"] = "Arcane",
    ["Arcane Tactics"] = "Arcane",
    ["Living Bomb"] = "Fire",
    ["Dragon's Breath"] = "Fire",
    ["Combustion"] = "Fire",
    ["Hot Streak"] = "Fire",
    ["Fiery Payback"] = "Fire",
    ["Firestarter"] = "Fire",
    ["Blast Wave"] = "Fire",
    ["Pyroblast"] = "Fire",
    ["Pyromaniac"] = "Fire",
    ["Critical Mass"] = "Fire",
    ["Cauterize"] = "Fire",
    ["Ice Barrier"] = "Frost",
    ["Deep Freeze"] = "Frost",
    ["Summon Water Elemental"] = "Frost",
    ["Shattered Barrier"] = "Frost",
    ["Fingers of Frost"] = "Frost",
    ["Brain Freeze"] = "Frost",
    ["Frostfire Orb"] = "Frost",
    ["Icy Veins"] = "Frost",
    ["Cold Snap"] = "Frost",
    
    -- PALADIN
    ["Holy Shock"] = "Holy",
    ["Beacon of Light"] = "Holy",
    ["Divine Favor"] = "Holy",
    ["Light's Grace"] = "Holy",
    ["Judgements of the Pure"] = "Holy",
    ["Infusion of Light"] = "Holy",
    ["Light of Dawn"] = "Holy",
    ["Aura Mastery"] = "Holy",
    ["Conviction"] = "Holy",
    ["Speed of Light"] = "Holy",
    ["Daybreak"] = "Holy",
    ["Denounce"] = "Holy",
    ["Holy Shield"] = "Protection",
    ["Avenger's Shield"] = "Protection",
    ["Hammer of the Righteous"] = "Protection",
    ["Judgements of the Just"] = "Protection",
    ["Redoubt"] = "Protection",
    ["Ardent Defender"] = "Protection",
    ["Grand Crusader"] = "Protection",
    ["Shield of the Righteous"] = "Protection",
    ["Reckoning"] = "Protection",
    ["Sacred Duty"] = "Protection",
    ["Divine Guardian"] = "Protection",
    ["Vindication"] = "Protection",
    ["Crusader Strike"] = "Retribution",
    ["Divine Storm"] = "Retribution",
    ["Repentance"] = "Retribution",
    ["The Art of War"] = "Retribution",
    ["Templar's Verdict"] = "Retribution",
    ["Zealotry"] = "Retribution",
    ["Long Arm of the Law"] = "Retribution",
    ["Sacred Shield"] = "Retribution",
    ["Word of Glory"] = "Retribution",
    
    -- PRIEST
    ["Power Infusion"] = "Discipline",
    ["Pain Suppression"] = "Discipline",
    ["Focused Will"] = "Discipline",
    ["Divine Aegis"] = "Discipline",
    ["Grace"] = "Discipline",
    ["Borrowed Time"] = "Discipline",
    ["Inner Focus"] = "Discipline",
    ["Power Word: Barrier"] = "Discipline",
    ["Strength of Soul"] = "Discipline",
    ["Atonement"] = "Discipline",
    ["Circle of Healing"] = "Holy",
    ["Lightwell"] = "Holy",
    ["Blessed Resilience"] = "Holy",
    ["Body and Soul"] = "Holy",
    ["Serendipity"] = "Holy",
    ["Guardian Spirit"] = "Holy",
    ["Spirit of Redemption"] = "Holy",
    ["Chakra"] = "Holy",
    ["Chakra: Sanctuary"] = "Holy",
    ["Chakra: Chastise"] = "Holy",
    ["Chakra: Serenity"] = "Holy",
    ["Chastise"] = "Holy",
    ["Shadowform"] = "Shadow",
    ["Vampiric Touch"] = "Shadow",
    ["Misery"] = "Shadow",
    ["Psychic Horror"] = "Shadow",
    ["Dispersion"] = "Shadow",
    ["Vampiric Embrace"] = "Shadow",
    ["Silence"] = "Shadow",
    ["Shadow Orb"] = "Shadow",
    ["Mind Melt"] = "Shadow",
    ["Shadowy Apparition"] = "Shadow",
    ["Mind Quickening"] = "Shadow",
    ["Sin and Punishment"] = "Shadow",
    
    -- ROGUE
    ["Mutilate"] = "Assassination",
    ["Overkill"] = "Assassination",
    ["Hunger For Blood"] = "Assassination",
    ["Turn the Tables"] = "Assassination",
    ["Cold Blood"] = "Assassination",
    ["Vendetta"] = "Assassination",
    ["Master Poisoner"] = "Assassination",
    ["Adrenaline Rush"] = "Combat",
    ["Killing Spree"] = "Combat",
    ["Savage Combat"] = "Combat",
    ["Blade Flurry"] = "Combat",
    ["Blade Twisting"] = "Combat",
    ["Bandit's Guile"] = "Combat",
    ["Throwing Specialization"] = "Combat",
    ["Revealing Strike"] = "Combat",
    ["Shallow Insight"] = "Combat",
    ["Shadowstep"] = "Subtlety",
    ["Shadow Dance"] = "Subtlety",
    ["Premeditation"] = "Subtlety",
    ["Cheat Death"] = "Subtlety",
    ["Waylay"] = "Subtlety",
    ["Master of Subtlety"] = "Subtlety",
    ["Hemorrhage"] = "Subtlety",
    ["Honor Among Thieves"] = "Subtlety",
    ["Preparation"] = "Subtlety",
    
    -- SHAMAN
    ["Totem Wrath"] = "Elemental",
    ["Thunderstorm"] = "Elemental",
    ["Elemental Mastery"] = "Elemental",
    ["Earthgrab"] = "Elemental",
    ["Astral Shift"] = "Elemental",
    ["Elemental Oath"] = "Elemental",
    ["Knockdown"] = "Elemental",
    ["Clearcasting"] = "Elemental",
    ["Lava Flows"] = "Elemental",
    ["Stormstrike"] = "Enhancement",
    ["Lava Lash"] = "Enhancement",
    ["Shamanistic Rage"] = "Enhancement",
    ["Maelstrom Weapon"] = "Enhancement",
    ["Feral Spirit"] = "Enhancement",
    ["Seasoned Winds"] = "Enhancement",
    ["Freeze"] = "Enhancement",
    ["Earth Shield"] = "Restoration",
    ["Riptide"] = "Restoration",
    ["Cleanse Spirit"] = "Restoration",
    ["Mana Tide Totem"] = "Restoration",
    ["Tidal Waves"] = "Restoration",
    ["Nature's Guardian"] = "Restoration",
    ["Ancestral Fortitude"] = "Restoration",
    ["Soul Link Totem"] = "Restoration",
    ["Ancestral Vigor"] = "Restoration",
    ["Earthliving"] = "Restoration",
    ["Ancestral Awakening"] = "Restoration",
    
    -- WARLOCK
    ["Unstable Affliction"] = "Affliction",
    ["Haunt"] = "Affliction",
    ["Eradication"] = "Affliction",
    ["Curse of Exhaustion"] = "Affliction",
    ["Soul Swap"] = "Affliction",
    ["Shadow Trance"] = "Affliction",
    ["Nightmare"] = "Affliction",
    ["Shadow Embrace"] = "Affliction",
    ["Demonic Empowerment"] = "Demonology",
    ["Decimation"] = "Demonology",
    ["Summon Felguard"] = "Demonology",
    ["Metamorphosis"] = "Demonology",
    ["Demonic Pact"] = "Demonology",
    ["Hand of Gul'dan"] = "Demonology",
    ["Molten Core"] = "Demonology",
    ["Demonic Knowledge"] = "Demonology",
    ["Conflagrate"] = "Destruction",
    ["Shadowfury"] = "Destruction",
    ["Chaos Bolt"] = "Destruction",
    ["Backdraft"] = "Destruction",
    ["Backlash"] = "Destruction",
    ["Improved Soul Fire"] = "Destruction",
    ["Shadowburn"] = "Destruction",
    ["Burning Ember"] = "Destruction",
    ["Nether Ward"] = "Destruction",
    ["Nether Protection"] = "Destruction",
    ["Empowered Imp"] = "Destruction",
    ["Bane of Havoc"] = "Destruction",
    
    -- WARRIOR
    ["Mortal Strike"] = "Arms",
    ["Bladestorm"] = "Arms",
    ["Second Wind"] = "Arms",
    ["Juggernaut"] = "Arms",
    ["Sudden Death"] = "Arms",
    ["Trauma"] = "Arms",
    ["Taste for Blood"] = "Arms",
    ["Improved Hamstring"] = "Arms",
    ["Deadly Calm"] = "Arms",
    ["Blood Frenzy"] = "Arms",
    ["Slaughter"] = "Arms",
    ["Enrage"] = "Arms",
    ["Throwdown"] = "Arms",
    ["Bloodthirst"] = "Fury",
    ["Heroic Fury"] = "Fury",
    ["Furious Attacks"] = "Fury",
    ["Bloodsurge"] = "Fury",
    ["Flurry"] = "Fury",
    ["Death Wish"] = "Fury",
    ["Die by the Sword"] = "Fury",
    ["Raging Blow"] = "Fury",
    ["Rampage"] = "Fury",
    ["Meat Cleaver"] = "Fury",
    ["Devastate"] = "Protection",
    ["Shockwave"] = "Protection",
    ["Vigilance"] = "Protection",
    ["Safeguard"] = "Protection",
    ["Sword and Board"] = "Protection",
    ["Last Stand"] = "Protection",
    ["Concussion Blow"] = "Protection",
}

function sArenaFrameMixin:DetectSpec(unit, spellParam)
    local unit = unit or self.unit
    local _, class = UnitClass(unit)
    local specClass = class and metaDB[class]

    
    if spellParam ~= nil then
        local spellName = spellParam
        
        
        if type(spellParam) == "number" then
            spellName = GetSpellInfo(spellParam)
        end
        
        if spellName and spellDB[spellName] and specClass then
            local specTex = specClass[spellDB[spellName]]
            if specTex then
                self.specTexture = specTex
                if not self.parent.db.profile.specIcons then
                    self.SpecIcon.Texture:SetTexture("Interface\\Icons\\" .. self.specTexture)
                    self.SpecIcon:Show()
                    self.SpecBorderOverlay:Show()
                else
                    self:UpdateClassIcon()
                end
            end
        end
        return
    end


    for i = 1, 40 do
        local name, _, icon, _, _, _, _, source = UnitAura(unit, i, "HELPFUL")
        if name then
            if spellDB[name] and specClass and source and UnitIsUnit(source, unit) then
                local specTex = specClass[spellDB[name]]
                if specTex then
                    self.specTexture = specTex
                    if not self.parent.db.profile.specIcons then
                        self.SpecIcon.Texture:SetTexture("Interface\\Icons\\" .. self.specTexture)
                        self.SpecBorderOverlay:Show()
                        self.SpecIcon:Show()
                    else
                        self:UpdateClassIcon()
                    end
                end
            end
        else
            break
        end
    end
end