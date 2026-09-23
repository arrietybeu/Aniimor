-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogScheme\\PetTransmogSchemeCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetTransmogSchemeCtrl = Class.LightClass("PetTransmogSchemeCtrl", UICtrl)

PetTransmogSchemeCtrl.messages = {
	[MessageName.PET_TRANSMOG_SCHEME_LIST_CHANGED] = {
		"onSchemeListChanged",
		true
	}
}

function PetTransmogSchemeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setPetId(info and info.petId or nil)
end

function PetTransmogSchemeCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if self.view.tempList then
		function self.view.tempList.luaRenderItem(button, index, data)
			self:onRenderTempItem(button, index, data)
		end
	end

	if self.view.btnSave then
		function self.view.btnSave.luaClick()
			self:onBtnSave()
		end
	end
end

function PetTransmogSchemeCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetTransmogSchemeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info and info.petId then
		self.model:setPetId(info.petId)
	end
end

function PetTransmogSchemeCtrl:onShow()
	self.model:setSelected(nil)
	self:refreshList()
end

local CURRENT_SCHEME_INDEX = 0

function PetTransmogSchemeCtrl:refreshList()
	if not self.view.tempList then
		return
	end

	local petId = self.model:getPetId()
	local realSchemes = self.model:getTempSchemes() or {}
	local cap = PetTransmogUtils.getMaxTempCount()
	local currScheme = PetTransmogUtils.getCurrentDisplayScheme(petId)
	local list = {
		{
			isCurrent = true,
			index = CURRENT_SCHEME_INDEX,
			holeIds = currScheme and currScheme.holeIds or nil,
			transmogValue = currScheme and currScheme.transmogValue or 0
		}
	}

	if #realSchemes > 0 then
		for i = 1, cap do
			list[#list + 1] = realSchemes[i] or {
				isEmpty = true
			}
		end
	end

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("empty", #realSchemes > 0 and 0 or 2)
	end

	local selected = self.model:getSelected()
	local hasSelected = selected == CURRENT_SCHEME_INDEX

	for _, scheme in ipairs(realSchemes) do
		if scheme.index == selected then
			hasSelected = true

			break
		end
	end

	if not hasSelected then
		self.model:setSelected(CURRENT_SCHEME_INDEX)
	end

	if self.view.btnSave then
		local isCurrentSelected = self.model:getSelected() == CURRENT_SCHEME_INDEX

		self.view.btnSave:TryChangePage("button", isCurrentSelected and 4 or 1)

		self.view.btnSave.interactable = not isCurrentSelected
	end

	self.view.tempList:SetList(list)
end

function PetTransmogSchemeCtrl:onRenderTempItem(button, index, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local listStar = objectReference:GetRefValue("listStar")
	local txtName = objectReference:GetRefValue("txtName")
	local txtNum = objectReference:GetRefValue("txtNum")
	local tagNowUImage = objectReference:GetRefValue("tagNowUImage")
	local txtTagNow = objectReference:GetRefValue("txtTagNow")
	local txtEmpty = objectReference:GetRefValue("txtEmpty")
	local isEmpty = data.isEmpty == true or data.index == nil

	button:TryChangePage("Emtpy", isEmpty and 2 or 0)

	if txtEmpty then
		ClientTextUtils.setText(txtEmpty, pg.getGameString("PETTRANSMOGRIFY_NO_SOLUTION"))
	end

	local isSelected = data.index == self.model:getSelected()

	button.isSelected = isSelected

	function button.luaClick()
		self:onTempSelected(data)
	end

	if txtName then
		local name = data.isCurrent and pg.getGameString("PETTRANSMOGRIFY_SCHEME") or pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_CUSTOM_NAME"), index)

		ClientTextUtils.setText(txtName, name)
	end

	if txtNum then
		ClientTextUtils.setText(txtNum, tostring(data.transmogValue or 0))
	end

	if tagNowUImage then
		tagNowUImage.gameObject:SetActiveEx(isSelected)
	end

	if txtTagNow and isSelected then
		ClientTextUtils.setText(txtTagNow, pg.getGameString("PETTRANSMOGRIFY_PREVIEWING"))
	end

	if listStar then
		function listStar.luaRenderItem(innerButton, _, itemData)
			self:onRenderHoleItem(innerButton, itemData, isEmpty)
		end

		listStar:SetList(self:buildHoleData(data))
	end
end

function PetTransmogSchemeCtrl:buildHoleData(scheme)
	local result = {}
	local count = PetTransmogUtils.getHoleCount()
	local holeIds = scheme and scheme.holeIds or nil

	for i = 1, count do
		local slotId = holeIds and holeIds[i] or nil
		local cfg = PetTransmogUtils.getSlotConfig(slotId)

		result[#result + 1] = {
			index = i,
			isEmpty = not slotId or slotId == 0,
			quality = cfg and cfg.quality or 0
		}
	end

	return result
end

function PetTransmogSchemeCtrl:onRenderHoleItem(button, data, isListEmpty)
	if isListEmpty then
		button:TryChangePage("Emtpy", 2)
		button:TryChangePage("Quality", 0)
	else
		local isEmpty = data and data.isEmpty ~= false

		button:TryChangePage("Emtpy", isEmpty and 1 or 0)
		button:TryChangePage("Quality", data and data.quality or 0)
	end
end

function PetTransmogSchemeCtrl:onTempSelected(scheme)
	if not scheme or scheme.index == nil then
		return
	end

	self.model:setSelected(scheme and scheme.index or nil)

	local previewScheme = scheme

	if scheme and scheme.isCurrent then
		previewScheme = PetTransmogUtils.getCurrentScheme(self.model:getPetId())
	end

	local mainCtrl = pg.global.ui.petTransmog

	if mainCtrl then
		mainCtrl:previewTransmogScheme(previewScheme)

		if mainCtrl.schemeListComponent then
			mainCtrl.schemeListComponent:refreshPlanPartInfo(scheme)
		end
	end

	self:refreshList()
end

function PetTransmogSchemeCtrl:onBtnSave()
	local petId = self.model:getPetId()
	local tempIndex = self.model:getSelected()

	if not petId or not tempIndex then
		return
	end

	if tempIndex == CURRENT_SCHEME_INDEX then
		return
	end

	local savedValue = 0

	for _, scheme in ipairs(self.model:getTempSchemes() or EMPTY_TABLE) do
		if scheme.index == tempIndex then
			savedValue = scheme.transmogValue or 0

			break
		end
	end

	local appliedValue = PetTransmogUtils.getAppliedTransmogValue(petId)
	local confirmTextKey = appliedValue <= savedValue and "PETTRANSMOGRIFY_CONFIRM_CLEAR" or "PETTRANSMOGRIFY_CONFIRM_APPLY"

	local function confirm(action)
		pg.global.showConfirmMsgRaw(pg.getGameString("PETTRANSMOGRIFY_TIP"), pg.getGameString(confirmTextKey), action)
	end

	pg.global.ui.petTransmog:snapShot(function(imageKey)
		self:dismiss()

		if PetTransmogUtils.isCustomFull(petId) then
			confirm(function()
				pg.global.ui:open(UIConst.UI_ID_PET_TRANSMOG_REPLACE, {
					petId = petId,
					mode = PetTransmogUtils.REPLACE_MODE.SAVE_TEMP,
					newTempIndex = tempIndex,
					imageKey = imageKey
				})
			end)
		else
			confirm(function()
				pg.game.petTransmog:requestSaveTempToCustom(petId, tempIndex, imageKey)
			end)
		end
	end)
end

function PetTransmogSchemeCtrl:onSchemeListChanged()
	self:dismiss()
end

return PetTransmogSchemeCtrl
