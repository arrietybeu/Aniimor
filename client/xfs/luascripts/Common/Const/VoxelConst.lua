-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\VoxelConst.lua

local VoxelConst = {}
local bit = bit

VoxelConst.Perceptions = {
	NONE = "NONE",
	WATER = "WATER",
	GRASS = "GRASS"
}
VoxelConst.VoxelMaterialDef = {
	Ground = 1,
	Default = 0,
	AirWall = bit.lshift(1, 1),
	UnWalkable = bit.lshift(1, 2),
	Ocean = bit.lshift(1, 3),
	Grass = bit.lshift(1, 4),
	WaterBottom = bit.lshift(1, 5),
	Sand = bit.lshift(1, 6),
	Metal = bit.lshift(1, 7),
	Water = bit.lshift(1, 8),
	Soil = bit.lshift(1, 9),
	Concrete = bit.lshift(1, 10),
	Wood = bit.lshift(1, 11),
	Shoal = bit.lshift(1, 12),
	Ice = bit.lshift(1, 13),
	CustomGrass = bit.lshift(1, 14),
	GrassGround = bit.lshift(1, 15),
	Stone = bit.lshift(1, 16),
	Swamp = bit.lshift(1, 17),
	Bush = bit.lshift(1, 18),
	WallEdge = bit.lshift(1, 19),
	Ocean_1 = bit.lshift(1, 20),
	Ocean_2 = bit.lshift(1, 21),
	Ash = bit.lshift(1, 22),
	Snow = bit.lshift(1, 23)
}
VoxelConst.FootStepMaterialVal = 0
VoxelConst.FootStepMaterialVal = bit.bor(VoxelConst.VoxelMaterialDef.Sand, VoxelConst.FootStepMaterialVal)
VoxelConst.FootStepMaterialVal = bit.bor(VoxelConst.VoxelMaterialDef.Snow, VoxelConst.FootStepMaterialVal)
VoxelConst.FootStepMaterialVal = bit.bor(VoxelConst.VoxelMaterialDef.Ash, VoxelConst.FootStepMaterialVal)
VoxelConst.CannotStandOnVoxelMaterialDef = {
	Water = bit.lshift(1, 8)
}
VoxelConst.BurningOffset = 1
VoxelConst.ForceBurningOffset = 2
VoxelConst.VoxelStateDef = {
	Default = 0,
	Burning = bit.lshift(1, 0),
	ForceBurning = bit.lshift(1, 1),
	Burned = bit.lshift(1, 2),
	WaterPool = bit.lshift(1, 3),
	Wet = bit.lshift(1, 4),
	Electricity = bit.lshift(1, 5),
	GrassGrowFlower = bit.lshift(1, 6),
	PlantGrass = bit.lshift(1, 8)
}
VoxelConst.VoxelPathFindResultCode = {
	PATHFIND_NO_VOXEL_SCENE = 1,
	PATHFIND_SUCCESS = 0,
	PATHFIND_PART_SUCCESS = 5,
	PATHFIND_FAILED = 4,
	PATHFIND_END_POS_INVALID = 3,
	PATHFIND_START_POS_INVALID = 2
}
VoxelConst.VoxelNavSwimType = {
	VOXEL_NAV_WATER_BOTTOM = 2,
	VOXEL_NAV_CAN_SWIM = 1,
	VOXEL_NAV_CANT_SWIM = 0
}
VoxelConst.CellSize = 0.5
VoxelConst.InvCellSize = 2
VoxelConst.InvCellHeight = 20
VoxelConst.CellHeight = 0.05
VoxelConst.REGION_LENGTH = 64
VoxelConst.MAX_VOXEL_NAV_DEPTH = 3000
VoxelConst.MIN_NAV_ASTAR_SEARCH_COUNT = 400
VoxelConst.MAX_NAV_ASTAR_SEARCH_COUNT = 10000
VoxelConst.MUTABLE_REGION_TICK_FRAME_COUNT = {
	MOBILE = 24,
	DEFAULT = 12
}

return VoxelConst
