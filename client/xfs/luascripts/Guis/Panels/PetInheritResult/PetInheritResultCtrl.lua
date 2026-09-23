-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetInheritResult\\PetInheritResultCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetInheritResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetInheritResultCtrl = Class.LightClass("PetInheritResultCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Utils.ItemUtils")
local UIConst = require("Const.UIConst")

PetInheritResultCtrl.messages = {}

function PetInheritResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	ClientTextUtils.setText(self.view.txtTitleUBaseText, pg.getGameString("PET_INHERIT_SUCCEED"))

	function self.view.returnItemsListUList.luaRenderItem(button, index, data)
		self:m_customRefreshItem(button, index, data)
	end
end

function PetInheritResultCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:close()
	end
end

function PetInheritResultCtrl:onDestroy()
	pg.global.ui:close(UIConst.UI_ID_PET_INHERITANCE_MAIN)
	UICtrl.onDestroy(self)
	pg.game.petManage:resetInheritDataModel()

	self.displayProp176ListData = nil
end

function PetInheritResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshInheritResult(info.sourcePetId, info.targetPetId)
	self:refreshRefundItems(info.refundItems or {})
end

function PetInheritResultCtrl:onShow()
	return
end

function PetInheritResultCtrl:onHide()
	return
end

function PetInheritResultCtrl:refreshInheritResult(sourcePetId, targetPetId)
	if not sourcePetId or not targetPetId then
		return
	end

	self:m_customRefreshPetHead(self.view.petHeadBeforeUComponent, sourcePetId, "before")
	self:m_customRefreshPetHead(self.view.petHeadAfterUComponent, targetPetId, "after")
end

function PetInheritResultCtrl:m_customRefreshPetHead(button, petId, inheritType)
	if not button or not petId or not inheritType then
		return
	end

	local petSimpleInfo

	if inheritType == "before" then
		petSimpleInfo = pg.game.petManage:getInheritSourcePetInfo()
	else
		petSimpleInfo = PetManagementUtils.getPetSimpleInfo(petId)
	end

	if not petSimpleInfo then
		return
	end

	button.enabledTooltip = false

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, petSimpleInfo.name)
	panelCPUContainer:LoadDefaultUrlManually()

	local objectReference1 = panelCPUContainer.content:GetComponent("ObjectReference")
	local numCPUText = objectReference1:GetRefValue("numCPUSDFText")
	local singleElement = objectReference1:GetRefValue("singleElement")
	local doubleElement1 = objectReference1:GetRefValue("doubleElement1")
	local doubleElement2 = objectReference1:GetRefValue("doubleElement2")

	iconUImage.url = LuaUIUtils.getPetIcon(petSimpleInfo.iconName, LuaUIUtils.PET_ICON, petSimpleInfo.label)

	ClientTextUtils.setText(numCPUText, petSimpleInfo.cpValue)

	local elementNames = petSimpleInfo.elementNames

	if #elementNames <= 0 then
		panelCPUContainer.content.gameObject:SetActiveEx(false)
	elseif #elementNames == 1 then
		panelCPUContainer.content.gameObject:SetActiveEx(true)
		panelCPUContainer.content:TryChangePage("DetailState", 0)

		local element1 = elementNames[1].element

		LuaUIUtils.setElementButtonNew(singleElement, element1)
	else
		panelCPUContainer.content.gameObject:SetActiveEx(true)
		panelCPUContainer.content:TryChangePage("DetailState", 1)

		local element1 = elementNames[1].element
		local element2 = elementNames[2].element

		LuaUIUtils.setElementButtonNew(doubleElement1, element1)
		LuaUIUtils.setElementButtonNew(doubleElement2, element2)
	end
end

function PetInheritResultCtrl:refreshRefundItems(refundItems)
	local ipairesRefundItems = LuaUIUtils.parseCostDataToIpairs(refundItems)

	self.displayProp176ListItemDatas = LuaUIUtils.setItemProp176ListData(ipairesRefundItems)

	self.view.returnItemsListUList:SetList(self.displayProp176ListItemDatas)

	if #self.displayProp176ListItemDatas > 0 then
		ClientTextUtils.setText(self.view.txtReturnUSDFText, pg.getGameString("PET_INHERIT_REFUND_ITEMS"))
		self.view.itemReturnUWidget:SetActive(true)
	else
		ClientTextUtils.setText(self.view.txtReturnUSDFText, "")
		self.view.itemReturnUWidget:SetActive(false)
	end
end

function PetInheritResultCtrl:m_customRefreshItem(button, index, data)
	if not button or not index or not data then
		return
	end

	LuaUIUtils.refreshItemProp176(button, index, data)
end

return PetInheritResultCtrl
