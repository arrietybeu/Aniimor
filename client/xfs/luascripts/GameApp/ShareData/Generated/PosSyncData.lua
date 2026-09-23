-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\ShareData\\Generated\\PosSyncData.lua

local LuaCSharpArr = require("Utils.LuaCSharpArr")
local inx2Getter = {
	playerDistance = function(t)
		return t[1]
	end,
	playerYDistance = function(t)
		return t[2]
	end,
	syncPosFrameCount = function(t)
		return t[3]
	end,
	syncRotFrameCount = function(t)
		return t[4]
	end,
	syncPlayerDistanceFrameCount = function(t)
		return t[5]
	end,
	syncPlayerYDistanceFrameCount = function(t)
		return t[6]
	end,
	rotationRevision = function(t)
		return t[7]
	end
}
local inx2Setter = {
	playerDistance = function(t, v)
		t[1] = v
	end,
	playerYDistance = function(t, v)
		t[2] = v
	end,
	syncPosFrameCount = function(t, v)
		t[3] = v
	end,
	syncRotFrameCount = function(t, v)
		t[4] = v
	end,
	syncPlayerDistanceFrameCount = function(t, v)
		t[5] = v
	end,
	syncPlayerYDistanceFrameCount = function(t, v)
		t[6] = v
	end,
	rotationRevision = function(t, v)
		t[7] = v
	end
}
local count = 7
local name = "PosSyncData"

local function voidFunc()
	return
end

setmetatable(inx2Getter, {
	__index = voidFunc
})
setmetatable(inx2Setter, {
	__index = voidFunc
})

local meta = {
	__index = function(t, k)
		local getter = inx2Getter[k]

		return getter(t)
	end,
	__newindex = function(t, k, v)
		local setter = inx2Setter[k]

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
	count = 7,
	fields = {
		playerDistance = {
			kind = "double",
			slot = 1
		},
		playerYDistance = {
			kind = "double",
			slot = 2
		},
		syncPosFrameCount = {
			kind = "int",
			slot = 3
		},
		syncRotFrameCount = {
			kind = "int",
			slot = 4
		},
		syncPlayerDistanceFrameCount = {
			kind = "int",
			slot = 5
		},
		syncPlayerYDistanceFrameCount = {
			kind = "int",
			slot = 6
		},
		rotationRevision = {
			kind = "int",
			slot = 7
		}
	}
}

return shareDataCreator
