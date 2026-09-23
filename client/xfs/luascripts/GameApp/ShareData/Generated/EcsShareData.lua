-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\ShareData\\Generated\\EcsShareData.lua

local LuaCSharpArr = require("Utils.LuaCSharpArr")
local inx2Getter = {
	compressedId = function(t)
		return t[1]
	end,
	state = function(t)
		return t[2]
	end,
	ability = function(t)
		return t[3]
	end
}
local inx2Setter = {
	compressedId = function(t, v)
		t[1] = v
	end,
	state = function(t, v)
		t[2] = v
	end,
	ability = function(t, v)
		t[3] = v
	end
}
local count = 3
local name = "EcsShareData"
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
	count = 3,
	fields = {
		compressedId = {
			slot = 1,
			kind = "double"
		},
		state = {
			slot = 2,
			kind = "int"
		},
		ability = {
			slot = 3,
			kind = "int"
		}
	}
}

return shareDataCreator
