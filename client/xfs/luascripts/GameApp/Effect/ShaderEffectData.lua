-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Effect\\ShaderEffectData.lua

local data = {
	switchAppearDissolve = {
		endValue = 10,
		presetName = "CharacterEdgeDissolve",
		recipeName = "modelDissolve",
		startValue = -0.1,
		duration = 0.5,
		changeMatResId = "$Eff_Merge_GeomDissolve_01.mat",
		pos = {
			0,
			0,
			0
		}
	},
	switchAppearDissolveTall = {
		height = 4,
		presetName = "CharacterEdgeDissolve",
		recipeName = "modelDissolve",
		startValue = -0.1,
		duration = 0.5,
		endValue = 50,
		changeMatResId = "$Eff_Merge_GeomDissolve_01.mat",
		pos = {
			0,
			0,
			0
		}
	},
	shaderFrozen = {
		endValue = 1,
		stopKey = "shaderFrozen",
		recipeName = "shaderFrozen"
	}
}

return data
