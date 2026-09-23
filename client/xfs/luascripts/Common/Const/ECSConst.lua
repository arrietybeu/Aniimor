-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\ECSConst.lua

local bit = bit
local ECSConst = {
	ELEMENT_TYPE_FIRE = 0,
	STATE_ELECTRIC_KEY = 3,
	STATE_FROZEN_KEY = 2,
	STATE_AFLAME_KEY = 1,
	ELEMENT_TYPE_NONE = 6,
	ELEMENT_TYPE_WIND = 5,
	ELEMENT_TYPE_SOIL = 4,
	ELEMENT_TYPE_CONNECT = 3,
	ELEMENT_TYPE_ICE = 2,
	ELEMENT_TYPE_WATER = 1
}

ECSConst.ELEMENT_TYPE_2_ECS_ELEMENT = {
	[2] = ECSConst.ELEMENT_TYPE_ICE,
	[3] = ECSConst.ELEMENT_TYPE_WATER,
	[4] = ECSConst.ELEMENT_TYPE_CONNECT,
	[5] = ECSConst.ELEMENT_TYPE_FIRE,
	[8] = ECSConst.ELEMENT_TYPE_SOIL,
	[9] = ECSConst.ELEMENT_TYPE_WIND
}
ECSConst.SYS_EVENT_NAME = {
	FlammableSkillFire = "FlammableSkillFire",
	FlammableAccumulate = "FlammableAccumulate",
	FlammableStop = "FlammableStop",
	FlammableEnd = "FlammableEnd",
	FlammableStart = "FlammableStart",
	StateExplosive = "StateExplosive",
	WaterConductEnd = "WaterConductEnd",
	WaterConductStart = "WaterConductStart",
	impactDestroy = "impactDestroy",
	StateWetEnd = "StateWetEnd",
	StateWetStart = "StateWetStart",
	StateFrozenEndDestroy = "StateFrozenEndDestroy",
	StateFrozenMelting = "StateFrozenMelting",
	StateFrozenEnd = "StateFrozenEnd",
	StateFrozenStart = "StateFrozenStart",
	ConductBoomStart = "ConductBoomStart",
	ConductEnd = "ConductEnd",
	ConductStart = "ConductStart",
	FlammableMeetWater = "FlammableMeetWater"
}
ECSConst.SERVER_SYS_EVENT_NAME = {
	StateFrozenStart = "StateFrozenStart",
	StateWetEnd = "StateWetEnd",
	StateFrozenEnd = "StateFrozenEnd",
	FlammableEnd = "FlammableEnd",
	FlammableStart = "FlammableStart",
	ConductEnd = "ConductEnd",
	ConductStart = "ConductStart",
	StateWetStart = "StateWetStart"
}

local EcsStateDef = {
	None = 0,
	Burning = bit.lshift(1, 0),
	Wet = bit.lshift(1, 1),
	Frozen = bit.lshift(1, 2),
	Conducted = bit.lshift(1, 3)
}

ECSConst.EcsStateDef = EcsStateDef

local EcsAbilityDef = {
	None = 0,
	Flammable = bit.lshift(1, 0),
	Wettable = bit.lshift(1, 1),
	Freezable = bit.lshift(1, 2),
	Conductive = bit.lshift(1, 3),
	Breakable = bit.lshift(1, 4),
	Explosive = bit.lshift(1, 5),
	Meltable = bit.lshift(1, 6)
}

ECSConst.EcsAbilityDef = EcsAbilityDef
ECSConst.AI_STATE_CONVERTER = {
	STATE_AFLAME_KEY = EcsStateDef.Burning,
	STATE_WET_KEY = EcsStateDef.Wet,
	STATE_FROZEN_KEY = EcsStateDef.Frozen,
	STATE_ELECTRIC_KEY = EcsStateDef.Conducted
}
ECSConst.AI_ABILITY_CONVERTER = {
	STATE_Flammable_KEY = EcsAbilityDef.Flammable,
	STATE_Wettable_KEY = EcsAbilityDef.Wettable,
	STATE_Conductive_KEY = EcsAbilityDef.Conductive,
	STATE_Freezable_KEY = EcsAbilityDef.Freezable
}
ECSConst.ELEMENT_TYPE_NAME = {
	Ice = 2,
	Water = 1,
	Fire = 0,
	None = 7,
	Count = 6,
	Wind = 5,
	Soil = 4,
	Electric = 3
}
ECSConst.ELEMENT_NAMES = {
	[0] = "Fire",
	"Water",
	"Ice",
	"Electric",
	"Wind",
	"Count",
	"None"
}
ECSConst.ECS_DESTROY_REASON = {
	Impulse = 4,
	Melt = 2,
	Flammable = 1,
	Explosive = 3,
	None = 0
}
ECSConst.CREATE_ENV_REASON = {
	ITEM_EFFECT = 2,
	SPAWN_ICE = 1,
	None = 0
}
ECSConst.TAG_RIGIDBODY = "RigidBody"
ECSConst.ECS_AMOUNT_NOTIFY_OWNER = {
	BOSS_TITLE = "BossTitle",
	LEGACY = "Legacy",
	TOP_LOGO = "TopLogo"
}

return ECSConst
