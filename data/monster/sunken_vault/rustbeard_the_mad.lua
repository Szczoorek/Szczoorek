local mType = Game.createMonsterType("Rustbeard the Mad")
local monster = {}

monster.description = "Rustbeard the Mad"
monster.experience = 450
monster.outfit = {
	lookType = 130,
	lookHead = 20,
	lookBody = 38,
	lookLegs = 10,
	lookFeet = 0,
	lookAddons = 3,
}

monster.health = 1400
monster.maxHealth = 1400
monster.race = "blood"
monster.corpse = 2812
monster.speed = 220
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
	{ text = "You'll join the rest in the bilge!", yell = false },
}

monster.loot = {
	{ id = 2148, chance = 90000, maxCount = 120 },
	{ id = 20008, chance = 15000 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -45 },
}

monster.defenses = {
	defense = 30,
	armor = 22,
	mitigation = 1.32,
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

mType:registerEvent("RustbeardAIThink")
mType:registerEvent("RustbeardAIDeath")

mType:register(monster)
