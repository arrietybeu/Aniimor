-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\ShareData\\Generated\\ShaderEffectShareData.lua

local LuaCSharpArr = require("Utils.LuaCSharpArr")
local inx2Getter = {
	recipeName = function(t)
		return t[1]
	end,
	presetName = function(t)
		return t[2]
	end,
	duration = function(t)
		return t[3]
	end,
	disableWhenFinished = function(t)
		return t[4]
	end,
	changeMatResId = function(t)
		return t[5]
	end,
	startValue = function(t)
		return t[6]
	end,
	endValue = function(t)
		return t[7]
	end,
	border = function(t)
		return t[8]
	end,
	loopCnt = function(t)
		return t[9]
	end,
	vec0 = function(t)
		return Vector3(t[10], t[11], t[12])
	end,
	floatParam0 = function(t)
		return t[13]
	end,
	isWorldPosition = function(t)
		return t[14]
	end
}
local inx2Setter = {
	recipeName = function(t, v)
		t[1] = v
	end,
	presetName = function(t, v)
		t[2] = v
	end,
	duration = function(t, v)
		t[3] = v
	end,
	disableWhenFinished = function(t, v)
		t[4] = v
	end,
	changeMatResId = function(t, v)
		t[5] = v
	end,
	startValue = function(t, v)
		t[6] = v
	end,
	endValue = function(t, v)
		t[7] = v
	end,
	border = function(t, v)
		t[8] = v
	end,
	loopCnt = function(t, v)
		t[9] = v
	end,
	vec0 = function(t, v)
		t[10] = v[1]
		t[11] = v[2]
		t[12] = v[3]
	end,
	floatParam0 = function(t, v)
		t[13] = v
	end,
	isWorldPosition = function(t, v)
		t[14] = v
	end
}
local count = 14
local name = "ShaderEffectShareData"
local meta = {
	__index = function(t, k)
		local getter = inx2Getter[k]

		if not getter then
			return
		end

		return getter(t)
	end,
	__newindex = function(t, k, v)
		local setter = inx2Setter[k]

		if not setter then
			return
		end

		setter(t, v)
	end
}
local shareDataCreator = {
	create = function()
		local t = {}

		for i = 1, count do
			t[i] = 0
		end

		local access = LuaCSharpArr.GetCSharpAccess(t)

		t.shell = ShareDataFactory.CreateShareData(name, access)

		setmetatable(t, meta)

		return t
	end,
	destroy = function(t)
		t.shell:Destroy()

		t.shell = nil

		LuaCSharpArr.DestroyCSharpAccess(t)
	end
}

shareDataCreator.schema = {
	count = 14,
	fields = {
		recipeName = {
			kind = "string",
			slot = 1
		},
		presetName = {
			kind = "string",
			slot = 2
		},
		duration = {
			kind = "double",
			slot = 3
		},
		disableWhenFinished = {
			kind = "bool",
			slot = 4
		},
		changeMatResId = {
			kind = "string",
			slot = 5
		},
		startValue = {
			kind = "double",
			slot = 6
		},
		endValue = {
			kind = "double",
			slot = 7
		},
		border = {
			kind = "double",
			slot = 8
		},
		loopCnt = {
			kind = "int",
			slot = 9
		},
		vec0 = {
			kind = "vec3",
			slot = 10
		},
		floatParam0 = {
			kind = "double",
			slot = 13
		},
		isWorldPosition = {
			kind = "bool",
			slot = 14
		}
	}
}

return shareDataCreator
