local mType = Game.createMonsterType("The Flameseer")
local monster = {}

monster.description = "The Flameseer"
monster.experience = 3200
monster.outfit = {
	lookType = 34,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
}

monster.health = 6500
monster.maxHealth = 6500
monster.race = "fire"
monster.corpse = 2812
monster.speed = 240
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
	{ text = "Burn in righteous fire!", yell = false },
}

monster.loot = {
	{ id = 2148, chance = 100000, maxCount = 400 },
	{ id = 20009, chance = 100000 },
}

monster.attacks = {
	{ name = "combat", type = COMBAT_FIREDAMAGE, interval = 2000, chance = 100, range = 1, minDamage = -60, maxDamage = -30 },
}

monster.defenses = {
	defense = 40,
	armor = 34,
	mitigation = 2.04,
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

mType:registerEvent("FlameseerAIThink")
mType:registerEvent("FlameseerAIDeath")

mType:register(monster)
