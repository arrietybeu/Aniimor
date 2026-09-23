-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitEntFunc.lua

local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local ItemData = require("Data.item_data")
local NoticeDef = require("Common.NoticeDef")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local InteractionConst = require("Common.Const.InteractionConst")
local CommonSwitch = require("Common.CommonSwitch")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local InteractionUnitEntFunc = Class.LightClass("InteractionUnitEntFunc", InteractionUnitBase)

function InteractionUnitEntFunc:ctor(info, interactId)
	InteractionUnitEntFunc.super.ctor(self, info, interactId)

	self.interactFunc = info.interactFunc
	self.canInteractiveFunc = info.canInteractiveFunc
end

function InteractionUnitEntFunc:interactive()
	local ignoreNeedItem = false

	if self.showDetail then
		local needItemId = self.needItem and self.needItem[1]

		if needItemId and InteractionConst.ChestInteractShowSpecialItemId[needItemId] and needItemId == Const.CommonEnergyType_Stamina then
			local isUnlock = CommonSwitch.COMMONENERGY ~= false and pg.me:checkFunctionUnlock("VITALITY")

			if isUnlock then
				ignoreNeedItem = true
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("ENERGY_NOT_OPEN"))

				return
			end
		end
	end

	if ignoreNeedItem or self:checkNeedItemValid() then
		if self.interactFunc then
			self.interactFunc(self)
		else
			local ent = self:getEntity()

			if ent then
				ent:interact(self)
			end
		end
	end
end

function InteractionUnitEntFunc:checkNeedItemValid()
	if self.needItem then
		local needItemId = self.needItem[1]
		local needItemCount = self.needItem[2]
		local itemCount = ClientUtils.getItemCountById(needItemId)

		if itemCount < needItemCount then
			pg.global.showBubbleMessage(NoticeDef.OPEN_BOX_NEED_ITEM, needItemCount, ItemData[needItemId].itemName)

			if InteractionConst.ChestInteractShowSpecialItemId[needItemId] and needItemId == Const.CommonEnergyType_Stamina then
				LuaUIUtils.openVitalityGot(Const.CommonEnergyType_Stamina)
			end

			return false
		end
	end

	return true
end

function InteractionUnitEntFunc:canInteractive()
	local canInteract = InteractionUnitEntFunc.super.canInteractive(self)

	if not canInteract then
		return false
	end

	if self.canInteractiveFunc then
		return self.canInteractiveFunc(self)
	end

	return true
end

return InteractionUnitEntFunc
