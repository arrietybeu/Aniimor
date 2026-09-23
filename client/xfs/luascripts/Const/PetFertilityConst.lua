-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\PetFertilityConst.lua

local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local PetFertilityConst = {}

PetFertilityConst.IsRecoverCatchBossNew = false
PetFertilityConst.PetFertilityCubeIds = {
	GeneralCubeItemId = 0,
	ShineChampionItemId = 110006,
	ChampionItemId = 110003
}
PetFertilityConst.FxGroupKeys = {
	[0] = PetFertilityConst.PetFertilityCubeIds.GeneralCubeItemId,
	PetFertilityConst.PetFertilityCubeIds.ShineChampionItemId
}
PetFertilityConst.FxKeys = {
	AllCubeSwitch = "AllCubeSwitch",
	ShineChampionEggOut = "ShineChampionEggOut",
	ShineChampionEggIn = "ShineChampionEggIn",
	ShineChampionCubeOut = "ShineChampionCubeOut",
	ShineChampionCubeIn = "ShineChampionCubeIn",
	ChampionEggOut = "ChampionEggOut",
	ChampionEggIn = "ChampionEggIn",
	ChampionCubeOut = "ChampionCubeOut",
	ChampionCubeIn = "ChampionCubeIn",
	GeneralEggOut = "GeneralEggOut",
	GeneralEggIn = "GeneralEggIn",
	GeneralCubeOut = "GeneralCubeOut",
	GeneralCubeIn = "GeneralCubeIn"
}
PetFertilityConst.FxResIds = {
	[PetFertilityConst.FxKeys.GeneralCubeIn] = AddressDataConst.FERTILITY_CUBEFX_GENERAL_CUBE_IN,
	[PetFertilityConst.FxKeys.GeneralCubeOut] = AddressDataConst.FERTILITY_CUBEFX_GENERAL_CUBE_OUT,
	[PetFertilityConst.FxKeys.GeneralEggIn] = AddressDataConst.FERTILITY_CUBEFX_GENERAL_EGG_IN,
	[PetFertilityConst.FxKeys.GeneralEggOut] = AddressDataConst.FERTILITY_CUBEFX_GENERAL_EGG_OUT,
	[PetFertilityConst.FxKeys.ChampionCubeIn] = AddressDataConst.FERTILITY_CUBEFX_CHAMPIONCUBE_IN,
	[PetFertilityConst.FxKeys.ChampionCubeOut] = AddressDataConst.FERTILITY_CUBEFX_CHAMPIONCUBE_OUT,
	[PetFertilityConst.FxKeys.ChampionEggIn] = AddressDataConst.FERTILITY_CUBEFX_CHAMPIONEGG_IN,
	[PetFertilityConst.FxKeys.ChampionEggOut] = AddressDataConst.FERTILITY_CUBEFX_CHAMPIONEGG_OUT,
	[PetFertilityConst.FxKeys.ShineChampionCubeIn] = AddressDataConst.FERTILITY_CUBEFX_SHINE_CHAMPIONCUBE_IN,
	[PetFertilityConst.FxKeys.ShineChampionCubeOut] = AddressDataConst.FERTILITY_CUBEFX_SHINE_CHAMPIONCUBE_OUT,
	[PetFertilityConst.FxKeys.ShineChampionEggIn] = AddressDataConst.FERTILITY_CUBEFX_SHINE_CHAMPIONEGG_IN,
	[PetFertilityConst.FxKeys.ShineChampionEggOut] = AddressDataConst.FERTILITY_CUBEFX_SHINE_CHAMPIONEGG_OUT,
	[PetFertilityConst.FxKeys.AllCubeSwitch] = AddressDataConst.FERTILITY_CUBEFX_ALLCUBE_SWITCH
}
PetFertilityConst.ChooseCubeFxs = {
	[PetFertilityConst.PetFertilityCubeIds.GeneralCubeItemId] = {
		fxGroupKey = PetFertilityConst.PetFertilityCubeIds.GeneralCubeItemId,
		CubeInKey = PetFertilityConst.FxKeys.GeneralCubeIn,
		CubeOutKey = PetFertilityConst.FxKeys.GeneralCubeOut,
		EggInKey = PetFertilityConst.FxKeys.GeneralEggIn,
		EggOutKey = PetFertilityConst.FxKeys.GeneralEggOut,
		EggInPos = {
			0,
			0,
			0
		},
		EggOutPos = {
			0,
			0,
			0
		}
	},
	[PetFertilityConst.PetFertilityCubeIds.ChampionItemId] = {
		fxGroupKey = PetFertilityConst.PetFertilityCubeIds.ChampionItemId,
		CubeInKey = PetFertilityConst.FxKeys.ChampionCubeIn,
		CubeOutKey = PetFertilityConst.FxKeys.ChampionCubeOut,
		EggInKey = PetFertilityConst.FxKeys.ChampionEggIn,
		EggOutKey = PetFertilityConst.FxKeys.ChampionEggOut,
		EggInPos = {
			0,
			0,
			0
		},
		EggOutPos = {
			0,
			0,
			0
		}
	},
	[PetFertilityConst.PetFertilityCubeIds.ShineChampionItemId] = {
		fxGroupKey = PetFertilityConst.PetFertilityCubeIds.ShineChampionItemId,
		CubeInKey = PetFertilityConst.FxKeys.ShineChampionCubeIn,
		CubeOutKey = PetFertilityConst.FxKeys.ShineChampionCubeOut,
		EggInKey = PetFertilityConst.FxKeys.ShineChampionEggIn,
		EggOutKey = PetFertilityConst.FxKeys.ShineChampionEggOut,
		EggInPos = {
			0,
			0,
			0
		},
		EggOutPos = {
			0,
			0,
			0
		}
	}
}
PetFertilityConst.ChooseCubeTransConfigs = {
	cube = {
		pos = {
			-0.4,
			500.493,
			0
		},
		rot = {
			20,
			39.7,
			18.2
		},
		eulerRot = {
			0.214,
			0.304,
			0.088,
			0.924
		},
		scale = {
			1.7,
			1.7,
			1.7
		},
		newPosList = {
			[110001] = {
				-0.389,
				500.493,
				0
			}
		}
	},
	egg = {
		pos = {
			0.421,
			500,
			0
		},
		rot = {
			0,
			0,
			0
		},
		eulerRot = {
			0,
			0,
			0,
			1
		},
		scale = {
			1,
			1,
			1
		}
	},
	chooseCubeCameraPos = {
		0,
		500,
		0
	}
}
PetFertilityConst.CubeOutTweenTime = 0.1
PetFertilityConst.CubeSwitchOutDelayTime = 0.01
PetFertilityConst.CubeSwitchNewCubeDelayTime = 0.1
PetFertilityConst.WaitCubeSwitchEffectTime = 0.1
PetFertilityConst.CubeSwitchEffectTime = 1
PetFertilityConst.CubeSwitchEffectScale = 0.2
PetFertilityConst.CubeSwitchEffectOffsetPos = {
	-0.032,
	0.028,
	0.057
}
PetFertilityConst.ChooseCubeggTransConfigs = {
	localScale = 1.65,
	localPos = {
		0,
		-0.35,
		0
	},
	localRot = {
		0,
		0,
		90
	}
}
PetFertilityConst.fallbackEggResId = AddressDataConst.FERTILITY_CUBE_FALLBACK_RESGG_RES

return PetFertilityConst
