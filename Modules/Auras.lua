sArenaMixin.interruptList = {
    -- Rogue
    ["Kick"] = 5,
    
    -- Mage
    ["Counterspell"] = 8,
    
    -- Warrior
    ["Pummel"] = 5,
    ["Shield Bash"] = 6,
    
    -- Warlock
    ["Spell Lock"] = 6,
    ["Unstable Affliction"] = 5,  -- Silence effect
    
    -- Druid
    ["Feral Charge"] = 4,  -- Interrupt effect
    
    -- Rogue
    ["Deadly Throw"] = 3,
}

local function CreateAuraList(spellNames)
    local result = {}
    for priority, name in ipairs(spellNames) do
        result[name] = priority
    end
    return result
end

sArenaMixin.auraList = CreateAuraList({
    -- Higher up = higher priority

    -- HARD CCs (Mayor prioridad)
    -- Cyclone/Mind Control
    "Cyclone",
    "Mind Control",
    
    -- Polymorph variants
    "Polymorph",
    "Polymorph: Turtle",
    "Polymorph: Pig",
    
    -- Stuns
    "Deep Freeze",
    "Kidney Shot",
    "Hammer of Justice",
    "Bash",
    "Concussion Blow",
    "Cheap Shot",
    "Pounce",
    "Intercept",
    "Shadowfury",
    "War Stomp",
    "Intimidation",
    "Charge Stun",
    "Death Coil",
    
    -- Stun Procs
    "Stormherald",
    "Mace Stun Effect",
    "Improved Concussive Shot",
    "Seal of Justice",
    "Pyroclasm",
    "Starfire Stun",
    "Blackout",
    "Impact",
    
    -- Disorients/Fears/Incapacitates
    "Blind",
    "Scatter Shot",
    "Dragon's Breath",
    "Hibernate",
    "Freezing Trap Effect",
    "Freezing Arrow Effect",
    "Wyvern Sting",
    "Seduction",
    "Howl of Terror",
    "Fear",
    "Psychic Scream",
    "Intimidating Shout",
    "Turn Evil",
    "Repentance",
    "Maim",
    "Sap",
    "Gouge",

    -- IMMUNITIES 
    "Divine Shield",
    "Divine Protection",
    "Ice Block",
    "The Beast Within",
    "Shell Shield",
    "Bestial Wrath",
    "Intervene",
    "Hand of Protection",
    "Blessing of Freedom",
    "Phase Shift",
    "Stoneform",
    "Cloak of Shadows",
    "Spirit of Redemption",

    -- INTERRUPTS
    "Kick",
    "Counterspell",
    "Pummel",
    "Shield Bash",
    "Spell Lock",
    "Unstable Affliction",
    "Feral Charge",
    "Silencing Shot",
    "Improved Shield Bash",
    "Deadly Throw",
    "Garrote - Silence",
    "Silence",

    -- ANTI-CCs
    "Spell Reflection",
    "Grounding Totem Effect",
    "Divine Sacrifice",
    "Hand of Sacrifice",
    "Feign Death",

    -- DISARMS
    "Disarm",
    "Riposte",

    -- ROOTS
    "Entangling Roots",
    "Nature's Grasp",
    "Boar Charge",
    "Web",
    "Frost Nova",
    "Freeze",
    "Counterattack",
    "Chastise",
    
    -- Root Procs
    "Improved Wing Clip",
    "Entrapment",
    "Frostbite",
    "Improved Hamstring",

    -- REFRESHMENTS 
    "Refreshment",
    "Food",
    "Drink",
    "Conjured Food",
    "Conjured Water",
    "Conjured Manna Biscuit",

    -- OFFENSIVE BUFFS
    "Innervate",
    "Rapid Fire",
    "Arcane Power",
    "Combustion",
    "Icy Veins",
    "Avenging Wrath",
    "Power Infusion",
    "Adrenaline Rush",
    "Backlash",
    "Nightfall",
    "Fel Domination",
    "Blade Flurry",
    "Death Wish",
    "Sweeping Strikes",

    -- DEFENSIVE BUFFS
    "Pain Suppression",
    "Improved Blink",
    "Evasion",
    "Shamanistic Rage",
    "Berserker Rage",
    "Divine Illumination",
    "Barkskin",
    "Deterrence",

    -- MISCELLANEOUS
    "Hypothermia",
    "Invisibility",
})
