-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchStartTips\\PetDispatchStartTipsCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local ClientConst = require("Const.ClientConst")
local PetDispatchStartTipsCtrl = Class.LightClass("PetDispatchStartTipsCtrl", UICtrl)

PetDispatchStartTipsCtrl.messages = {}

function PetDispatchStartTipsCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetDispatchStartTipsCtrl:addListener()
	function self.view.listPetSelectUList.luaRenderItem(button, index, data)
		self:onRenderPetItem(button, index, data)
	end

	function self.view.btnBack.luaClick()
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonLight")
		self:dismiss()
	end
end

function PetDispatchStartTipsCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetDispatchStartTipsCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.petList = info.patchPetList

	ClientTextUtils.setText(self.view.txtBtnBack, pg.getGameString("COMMON_CONFIRM"))
	ClientTextUtils.setText(self.view.txtTitle, pg.getLocalizationText(pg.getGameString("DISPATCH_TASK_PET_START")))

	local ratio = #self.petList > 0 and Utils.getPetDisptachReduceTimeRatio(pg.me, self.petList) or 0
	local baseHours = SysConfigData.DISPATCH_TIME
	local totalSeconds = math.floor(baseHours * 3600 * (1 - ratio))
	local des = ratio > 0 and LuaUIUtils.getCountDownString(totalSeconds, UIConst.TimeType.Short, true) or pg.getFormatText(pg.getGameString("DISPATCH_TASK_TIME_CONSUME"), baseHours)

	ClientTextUtils.setText(self.view.textDetail, des)

	local petInfoList = {}

	for i = 1, ActivityConst.PetDispatchPetMaxNum do
		local status

		if self.petList[i] then
			local petData = LuaUIUtils.getDispatchPetInfo(pg.me:getPetInfo(self.petList[i]))

			status = {
				tIndex = 0,
				petInfo = petData
			}
		else
			status = {
				tIndex = 1
			}
		end

		table.insert(petInfoList, status)
	end

	self.view.listPetSelectUList:SetList(petInfoList)
end

function PetDispatchStartTipsCtrl:onRenderPetItem(button, index, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, data.petInfo.isShiny, data.petInfo.shinyStyle or 0)

		if button.TryChangePage then
			button:TryChangePage("state", 0)
		end

		iconUImage.url = LuaUIUtils.getPetIcon(data.petInfo.iconName, LuaUIUtils.PET_ICON, data.petInfo.label)
	end
end

function PetDispatchStartTipsCtrl:onShow()
	return
end

function PetDispatchStartTipsCtrl:onHide()
	return
end

return PetDispatchStartTipsCtrl
