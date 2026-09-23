-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\TrapEvent\\TrapEventSystem.lua

local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local TrapEventSystem = Class.LightClass("TrapEventSystem", SystemBase)

function TrapEventSystem:onCtor()
	self.entDict = {}
	self.needRemove = {}
end

function TrapEventSystem:getMessageBindMap()
	return {
		[MessageName.TRAP_EVENT_TRIGGER] = "onEnterTrigger",
		[MessageName.TRAP_EVENT_LEAVE] = "onLeaveTrigger"
	}
end

function TrapEventSystem:onEnterTrigger(entInfo)
	self.entDict[entInfo.globalId] = entInfo.ent
end

function TrapEventSystem:onLeaveTrigger(entInfo)
	self.entDict[entInfo.globalId] = nil
end

function TrapEventSystem:onTick()
	if EnableBotTest then
		return
	end

	local playerPos = pg.playerPos
	local count = 1
	local ent

	while count < 60 do
		self.entGlobalId, ent = next(self.entDict, self.entGlobalId)

		if self.entGlobalId == nil then
			break
		end

		count = count + 1

		if ent and ent.space then
			Vector3.enableCreateFromCache()

			local pos = ent:getPosition()

			if pos then
				local distance = Utils.distance(pos, playerPos)

				Vector3.disableCreateFromCache()

				if distance < 64 and ent.tryTriggerEvent then
					ent:tryTriggerEvent(distance)
				end
			else
				Vector3.disableCreateFromCache()
			end
		else
			self.needRemove[#self.needRemove + 1] = self.entGlobalId
		end
	end

	local id

	for idx = #self.needRemove, 1, -1 do
		id = self.needRemove[idx]
		self.entDict[id] = nil

		table.remove(self.needRemove, idx)
	end
end

function TrapEventSystem:onDestroy()
	self:clear()
end

function TrapEventSystem:clear()
	self.entDict = {}
end

return TrapEventSystem
