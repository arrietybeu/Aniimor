-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\GrabEggDoor.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local GrabEggDoor = Class.LightClass("GrabEggDoor", LevelItem)
local ClientConst = require("Const.ClientConst")
local SandboxConst = require("Common.Const.SandboxConst")
local InteractionConst = require("Common.Const.InteractionConst")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local InteractData = require("Data.interact_data")
local DOOR_TO_KEY = {
	[464] = 5001102,
	[463] = 5001101,
	[465] = 5001103
}

function GrabEggDoor:ctor(sandbox, spawnInfo, syncInfo)
	GrabEggDoor.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function GrabEggDoor:onInit()
	local configData = self:getConfigData()
	local actionPrototypeIds = configData.actionPrototypeIds or {
		390
	}
	local interactListData = {}

	for _, actionPrototypeId in ipairs(actionPrototypeIds) do
		local interactData = {
			overrideType = InteractionConst.INTERACTION_TYPE_SWITCH,
			interactionType = InteractionConst.INTERACTION_TYPE_SWITCH,
			actionPrototypeId = actionPrototypeId
		}
		local cData = InteractData[actionPrototypeId]
		local name = pg.getLocalizationText(cData.actionName)
		local keyId = DOOR_TO_KEY[self.configId]
		local info = LuaUIUtils.getItemInfoById(keyId)

		interactData.name = pg.getFormatText(name, info.name)

		table.insert(interactListData, interactData)
	end

	self.interactListData = interactListData
end

function GrabEggDoor:destroy()
	GrabEggDoor.super.destroy(self)
end

function GrabEggDoor:checkCanInteract(interactUnit)
	local isOn = self.syncInfo.state == 1

	return not isOn
end

function GrabEggDoor:getInteractionListData(levelItemInteractSB, interactPartId)
	local interactListData = self.interactListData

	for _, v in ipairs(interactListData) do
		v.interactPartId = interactPartId
		v.globalId = self:getInteractGlobalId(interactPartId)

		function v.interactFunc(interactUnit)
			self:doInteract(levelItemInteractSB)
		end

		function v.canInteractiveFunc(interactUnit)
			return self:checkCanInteract(interactUnit)
		end
	end

	return interactListData
end

function GrabEggDoor:doInteract(levelItemInteractSB)
	local keyId = DOOR_TO_KEY[self.configId]

	if not pg.me:grabEgg_checkItemEnoughInBag(keyId, 1) then
		local info = LuaUIUtils.getItemInfoById(keyId)

		pg.global.showConfirmMsgRaw(pg.getFormatText(pg.getGameString("GRAB_EGG_DOOR_LACK_KEY"), info.name))

		return
	end

	if ToBool(self.syncInfo.state) then
		return
	end

	pg.me:serverMsg("RPC_CS_OpenTheDoor", self.sandbox.id, self.id)
end

return GrabEggDoor
