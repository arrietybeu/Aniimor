-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\AoiLodConst.lua

local Const = require("Common.Const.Const")
local AoiLodConst = {
	default_aoi_range = 6000,
	default_max_player_count_in_aoi = 30,
	normal_aoi_max_level = 3,
	default_aoi_leave_cache_range = 1000,
	lod_level_ranges = {
		6000,
		6000,
		9000,
		12800,
		25600,
		51200,
		102400
	},
	mobile_lod_level_ranges = {
		5400,
		5400,
		7200,
		11520,
		23040,
		46080,
		92160
	}
}

AoiLodConst.aoiScaleRatioMap = {
	Phone = 1,
	PC = 1
}
AoiLodConst.Pet = 1
AoiLodConst.Creation = 1
AoiLodConst.TrapBall = 1
AoiLodConst.Puppet = 3
AoiLodConst.EnvObject = 2
AoiLodConst.Interactor = 1
AoiLodConst.BattleField = 1
AoiLodConst.CylinderTrapItem = 1
AoiLodConst.Chest = {
	2,
	2,
	3,
	5
}
AoiLodConst.CollectItem = {
	2,
	2,
	2
}
AoiLodConst.TitanDistanceLevel = {
	[128] = 4,
	[512] = 6,
	[256] = 5,
	[1024] = 7
}
AoiLodConst.TypeMap = {
	Pet = AoiLodConst.Pet,
	Puppet = AoiLodConst.Puppet,
	Creation = AoiLodConst.Creation,
	TrapBall = AoiLodConst.TrapBall,
	EnvObject = AoiLodConst.EnvObject,
	BattleField = AoiLodConst.BattleField,
	CylinderTrapItem = AoiLodConst.CylinderTrapItemm
}
AoiLodConst.SPACE_TILE_SIZE = 64
AoiLodConst.SPACE_MARKER_TILE_SIZE = 32

return AoiLodConst
