local mType = Game.createMonsterType("Ignareth, the Cinderlord")
local monster = {}

monster.description = "Ignareth, the Cinderlord"
monster.experience = 8000
monster.outfit = {
	lookType = 34,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
}

monster.health = 20000
monster.maxHealth = 20000
monster.race = "fire"
monster.corpse = 2812
monster.speed = 230
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 8,
}

monster.strategiesTarget = {
	nearest = 100,
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = true,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = false,
	healthHidden = false,
}

monster.light = {
	level = 0,
	color = 0,
}

monster.voices = {
	interval = 6000,
	chance = 10,
	{ text = "I AM THE FORGE'S WILL MADE FLAME!", yell = false },
}

monster.loot = {
	{ id = 2148, chance = 100000, maxCount = 1000 },
	{ id = 20028, chance = 35000 },
	{ id = 20029, chance = 100000 },
}

monster.attacks = {
	{ name = "combat", type = COMBAT_FIREDAMAGE, interval = 2000, chance = 100, range = 1, minDamage = -80, maxDamage = -45 },
}

monster.defenses = {
	defense = 48,
	armor = 42,
	mitigation = 2.52,
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 0 },
	{ type = COMBAT_EARTHDAMAGE, percent = 0 },
	{ type = COMBAT_FIREDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 0 },
	{ type = COMBAT_MANADRAIN, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = 0 },
	{ type = COMBAT_ICEDAMAGE, percent = 0 },
	{ type = COMBAT_HOLYDAMAGE, percent = 0 },
	{ type = COMBAT_DEATHDAMAGE, percent = 0 },
}

monster.immunities = {
	{ type = "paralyze", condition = false },
	{ type = "outfit", condition = false },
	{ type = "invisible", condition = false },
	{ type = "bleed", condition = false },
}

mType:registerEvent("IgnarethAIThink")
mType:registerEvent("IgnarethAIDeath")

mType:register(monster)
