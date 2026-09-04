local mType = Game.createMonsterType("Dross Cinderhand")
local monster = {}

monster.description = "Dross Cinderhand"
monster.experience = 1400
monster.outfit = {
	lookType = 128,
	lookHead = 0,
	lookBody = 20,
	lookLegs = 20,
	lookFeet = 0,
	lookAddons = 0,
}

monster.health = 5200
monster.maxHealth = 5200
monster.race = "fire"
monster.corpse = 2812
monster.speed = 210
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
	{ text = "Kex! Watch your flank!", yell = false },
}

monster.loot = {
	{ id = 2148, chance = 100000, maxCount = 300 },
	{ id = 20025, chance = 25000 },
}

monster.attacks = {
	{ name = "combat", type = COMBAT_FIREDAMAGE, interval = 2000, chance = 100, range = 1, minDamage = -50, maxDamage = -30 },
}

monster.defenses = {
	defense = 32,
	armor = 28,
	mitigation = 1.68,
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 0 },
	{ type = COMBAT_EARTHDAMAGE, percent = 0 },
	{ type = COMBAT_FIREDAMAGE, percent = 0 },
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

mType:registerEvent("TwinsAIThink")
mType:registerEvent("TwinsAIDeath")

mType:register(monster)
