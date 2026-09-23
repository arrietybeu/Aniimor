-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientKnowledgeComponent.lua

local class = require("Core.Framework.Class")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local KnowledgeManager = require("GameApp.Knowledge.KnowledgeManager")
local logger = LoggerManager.getLogger("ClientKnowledgeComponent")
local MAIN_TYPE_COUNT = 6
local ClientKnowledgeComponent = class.Component("ClientKnowledgeComponent")

function ClientKnowledgeComponent:destroy()
	KnowledgeManager.getInstance():clearAllData()
end

function ClientKnowledgeComponent:refreshKnowledgeRedDots()
	for mainTypeId = 1, MAIN_TYPE_COUNT do
		pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.KNOWLEDGE_MAIN_TYPE, mainTypeId))
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.KNOWLEDGE_ENTRY)
end

function ClientKnowledgeComponent:onUnlockedKnowledgeAdded(knowledgeId)
	local knowledgeManager = KnowledgeManager.getInstance()

	if knowledgeManager:isInitialized() then
		knowledgeManager:initAllData()
		self:refreshKnowledgeRedDots()
	end
end

function ClientKnowledgeComponent:onKnowledgeReadStateChanged(oldValue, newValue, knowledgeId)
	local knowledgeManager = KnowledgeManager.getInstance()

	knowledgeManager:updateKnowledgeReadState(knowledgeId, newValue)
	self:refreshKnowledgeRedDots()
end

function ClientKnowledgeComponent:onUnlockedKnowledgeDeleted(knowledgeId)
	local knowledgeManager = KnowledgeManager.getInstance()

	if knowledgeManager:isInitialized() then
		knowledgeManager:initAllData()
		self:refreshKnowledgeRedDots()
	end
end

function ClientKnowledgeComponent:RPC_SC_OpenKnowledgeUI(knowledgeId)
	knowledgeId = tonumber(knowledgeId)

	if knowledgeId == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("RPC_SC_OpenKnowledgeUI received invalid knowledgeId: %s", tostring(knowledgeId))
		end

		return
	end

	local knowledgeManager = KnowledgeManager.getInstance()

	knowledgeManager:initAllData()

	local location = knowledgeManager:getKnowledgeLocation(knowledgeId)

	if location == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("RPC_SC_OpenKnowledgeUI cannot locate unlocked knowledge, knowledgeId: %d", knowledgeId)
		end

		return
	end

	pg.global.ui:open(UIConst.UI_ID_KNOWLEDGE_Details, {
		mainTypeId = location.mainTypeId,
		knowledgeId = knowledgeId
	})
end

return ClientKnowledgeComponent
