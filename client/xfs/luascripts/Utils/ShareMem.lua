-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ShareMem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local LuaCSharpArr = require("Utils.LuaCSharpArr")
local ShareMem = Class.LightClass("ShareMem")
local ShareDataType = require("Const.ClientConst").ShareDataType
local CSShareMem = CS.FunPlus.WorldX.Utils.ShareMem
local logger = LoggerManager.getLogger("ShareMem")
local SCHEMA = require("GameApp.ShareData.Generated.LevelItemShareData").schema
local SLOT_COUNT = SCHEMA.count
local FIELDS = SCHEMA.fields

function ShareMem:ctor()
	self.dataCache = {}
	self.initMap = {}
	self.shell = CSShareMem()
	self.arr = LuaCSharpArr.New(SLOT_COUNT)

	local access = self.arr:GetCSharpAccess()

	self.shell:BindArr(access)
end

function ShareMem:set(k, v)
	if type(v) == "string" or v == nil then
		return
	end

	local f = FIELDS[k]

	if f then
		local slot = f.slot
		local kind = f.kind

		if kind == "vec3" then
			if v.x ~= nil then
				self.arr[slot] = v.x
				self.arr[slot + 1] = v.y
				self.arr[slot + 2] = v.z
			else
				self.arr[slot] = v[1]
				self.arr[slot + 1] = v[2]
				self.arr[slot + 2] = v[3]
			end
		elseif kind == "bool" then
			self.arr[slot] = v and 1 or 0
		else
			self.arr[slot] = v
		end

		self.dataCache[k] = v

		return
	end

	if self.initMap[k] and self.dataCache[k] == v then
		return
	end

	self.initMap[k] = true

	self.shell:UpdateValue(k, v)

	self.dataCache[k] = v
end

function ShareMem:get(k)
	return self.dataCache[k]
end

function ShareMem:flush()
	self.shell:Flush()
end

function ShareMem:destroy()
	self.shell:Destroy()

	self.shell = nil

	if self.arr then
		self.arr:DestroyCSharpAccess()

		self.arr = nil
	end

	self.dataCache = nil
end

return ShareMem
