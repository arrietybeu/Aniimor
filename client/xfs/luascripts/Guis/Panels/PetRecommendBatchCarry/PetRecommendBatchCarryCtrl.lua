-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetRecommendBatchCarry\\PetRecommendBatchCarryCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetRecommendBatchCarryCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetRecommendBatchCarryCtrl = Class.LightClass("PetRecommendBatchCarryCtrl", UICtrl)
local PetManagementUtils = require("Utils.PetManagementUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local NoticeDef = require("Common.NoticeDef")
local PetConfigData = require("Data.pet_config_data")
local defaultSourceId = 3

PetRecommendBatchCarryCtrl.messages = {
	[MessageName.CARRY_EQUIP] = {
		"refreshPanel",
		true
	},
	[MessageName.CARRY_UNLOAD] = {
		"refreshPanel",
		true
	},
	[MessageName.CARRY_UPGRADE] = {
		"refreshPanel",
		true
	},
	[MessageName.CARRY_ASSIST_CHANGE] = {
		"refreshPanel",
		true
	}
}

function PetRecommendBatchCarryCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petId = info.petId

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCloseUButton2.luaClick()
		self:close()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:m_refreshItem(button, index, data)
	end

	self:refreshPanel()
end

function PetRecommendBatchCarryCtrl:addListener()
	return
end

function PetRecommendBatchCarryCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetRecommendBatchCarryCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetRecommendBatchCarryCtrl:onShow()
	return
end

function PetRecommendBatchCarryCtrl:onHide()
	return
end

function PetRecommendBatchCarryCtrl:refreshPanel()
	ClientTextUtils.setText(self.view.txtTitleUBaseText, pg.getGameString("PETCARRY_RECOMMEND_TITLE"))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("PETCARRY_RECOMMEND_TIPS"))

	local data = self.model:getPetRecommendList(self.petId)

	if not data or not next(data) then
		self.view.contentUWidget:SetActive(false)
		self.view.emptyUWidget:SetActive(true)
		ClientTextUtils.setText(self.view.txtEmptyUSDFText, pg.getGameString("Pet_Carry_Without_Core"))
		ClientTextUtils.setText(self.view.txtEmptyBtnUSDFText, pg.getGameString("PETCARRY_GOTTO_SOURCE"))

		local function cbFunc()
			self:close()
		end

		LuaUIUtils.setSourceSeekButton(self.view.btnGoToUButton, PetConfigData.PETCARRY_SOURCE_ID_1 or defaultSourceId, true, cbFunc)
	else
		self.view.contentUWidget:SetActive(true)
		self.view.emptyUWidget:SetActive(false)
		self.view.listUList:SetList(data or {})
	end
end

function PetRecommendBatchCarryCtrl:m_refreshItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local textDashen = objectReference:GetRefValue("textDashen")
	local textBini = objectReference:GetRefValue("textBini")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local btnApplyUButton = objectReference:GetRefValue("btnApplyUButton")
	local btnReadyUWidget = objectReference:GetRefValue("btnReadyUWidget")
	local binniUWidget = objectReference:GetRefValue("binniUWidget")
	local btnAppliedUSDFText = objectReference:GetRefValue("btnAppliedUSDFText")
	local imgLineUWidget = objectReference:GetRefValue("imgLineUWidget")

	ClientTextUtils.setText(btnAppliedUSDFText, pg.getGameString("PETCARRY_RECOMMEND_APPLIED"))

	local recommendRatio = data.recommendRatio

	ClientTextUtils.setText(txtNumUSDFText, recommendRatio and recommendRatio .. "%" or "")
	imgLineUWidget:SetActive(recommendRatio ~= nil)

	local isBini = data.recommendType == 0

	binniUWidget:SetActive(isBini)

	if isBini then
		ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("PETCARRY_RECOMMEND_1"))
		ClientTextUtils.setText(textBini, pg.getGameString("PETCARRY_RECOMMEND_BINI"))
		ClientTextUtils.setText(textDashen, "")
	else
		ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("PETCARRY_RECOMMEND_2"))
		ClientTextUtils.setText(textBini, "")

		local daShenStr = pg.getGameString("PETCARRY_RECOMMEND_DASHEN")

		daShenStr = (not daShenStr or daShenStr == "PETCARRY_RECOMMEND_DASHEN") and "" or daShenStr

		ClientTextUtils.setText(textDashen, daShenStr)
	end

	local itemCarryUButton = objectReference:GetRefValue("itemCarryUButton")
	local listGemUList = objectReference:GetRefValue("listGemUList")
	local useUnknown = not isBini or data.carryItemData == nil
	local slotCount = data.slotCount or 0

	if not useUnknown then
		LuaUIUtils.renderItem(itemCarryUButton, data.carryItemData)

		if listGemUList then
			local gemList = {}

			for i = 1, slotCount do
				local gemItem = data.gemItemList and data.gemItemList[i]

				if gemItem then
					gemList[i] = gemItem
				else
					gemList[i] = {
						unknownIconKey = "UI_PETCARRY_GEM_UNKNOWN"
					}
				end
			end

			function listGemUList.luaRenderItem(btn, idx, gemData)
				LuaUIUtils.renderItem(btn, gemData)
			end

			listGemUList:SetList(gemList)
		end
	else
		LuaUIUtils.renderItem(itemCarryUButton, {
			unknownIconKey = "UI_PETCARRY_CORE_UNKNOWN"
		})

		if listGemUList then
			local placeholders = {}

			for i = 1, slotCount do
				placeholders[i] = {
					unknownIconKey = "UI_PETCARRY_GEM_UNKNOWN"
				}
			end

			function listGemUList.luaRenderItem(btn, idx, gemPlaceholder)
				LuaUIUtils.renderItem(btn, gemPlaceholder)
			end

			listGemUList:SetList(placeholders)
		end
	end

	function btnApplyUButton.luaClick()
		self:m_onClickApply(button, index, data)
	end

	local isApplied = self.model:isApplied(self.petId, data)

	btnApplyUButton:SetActive(not isApplied)
	btnReadyUWidget:SetActive(isApplied)

	if not isApplied then
		LuaUIUtils.generalSetBtnTextL10NCont(btnApplyUButton, "txtNameUText", pg.getGameString("PET_NEW_PROP_APPLY"))
	end
end

function PetRecommendBatchCarryCtrl:m_onClickApply(button, index, data)
	if not self.model:checkApplicable(self.petId, data) then
		pg.global.showBubbleMessageById(NoticeDef.ERROR_ITEM_NOT_FOUND)
		self:refreshPanel()

		return
	end

	self:m_sendBatchEquipRpc({
		coreCarryPos = data.coreCarryPos,
		assistCarryPosList = data.assistCarryPosList,
		recommendType = data.recommendType
	})
end

function PetRecommendBatchCarryCtrl:m_sendBatchEquipRpc(rpcData)
	pg.me:serverMsg("RPC_CS_BatchEquipCarry", self.petId, rpcData, function(res)
		if not self.view then
			return
		end

		local noticeId = res or NoticeDef.ERROR_2

		if noticeId == NoticeDef.SUCCESS then
			self:refreshPanel()
			pg.game.petManage:onRequstBatchEquipCarrySuccess()
		elseif noticeId == NoticeDef.ERROR_ITEM_NOT_FOUND then
			-- block empty
		else
			pg.global.showBubbleMessageById(noticeId or NoticeDef.ERROR_2)
		end
	end)
end

return PetRecommendBatchCarryCtrl
