-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRCommonNode.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local CTRCommonNodeDefine = require("Common.AICt.CTRCommonNodeDefine")
local CTRCommonNode = Class.LightClass("CTRCommonNode", CTRNode)
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CTRCommonNode")

function CTRCommonNode:registerPorts()
	self.nodeDefine = CTRCommonNodeDefine[self.nodeData.className]
	self.valueCount = #self.nodeDefine.inPort
	self.valueInputs = {}
	self.values = {}

	for i = 1, self.valueCount do
		local key = self.nodeDefine.inPort[i]

		if string.sub(key, 1, 1) == "$" then
			key = string.sub(key, 2)
			self.valueInputs[i] = nil
			self.values[i] = self.nodeData[key]
		else
			self.valueInputs[i] = self:addValueInput(key)
		end
	end

	local outPort = self.nodeDefine.outPort or "out"

	self:addValueOutput(outPort, function(flow)
		return self:Get_out_Value(flow)
	end)
end

function CTRCommonNode:Get_out_Value(flow)
	local actorId = flow.context._entActorId
	local entity = pg.getEntityByActorId(actorId)

	if not entity or not entity.agent then
		return
	end

	for i = 1, self.valueCount do
		if self.valueInputs[i] then
			self.values[i] = self:getInputValue(self.valueInputs[i], flow)
		end
	end

	local status, res = xpcall(self.nodeDefine.outFunc, debug.traceback, entity.agent, table.unpack(self.values, 1, self.valueCount))

	if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(string.format("GRAPH: 【%s】, CTRNode: 【%s】, Pos: 【%s】, StaticId: 【%s】 execute with error: %s", flow.graphId, self.nodeId, flow.__owner and inspect(flow.__owner:getPosition()) or "", flow.__owner and flow.__owner.staticId or "", res))
	end

	return res
end

return CTRCommonNode
