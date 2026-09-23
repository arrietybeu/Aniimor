-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\SubNodeComps\\PetCardCarryInfoComponent.lua

local Class = require("Core.Framework.Class")
local PetCardCarryInfoComponent = Class.LiteClass("PetCardCarryInfoComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

function PetCardCarryInfoComponent:ctor(carryItemUComponent)
	self:init(carryItemUComponent)
end

function PetCardCarryInfoComponent:init(carryItemUComponent)
	self.carryItemUComponent = carryItemUComponent

	self.carryItemUComponent.gameObject:SetActiveEx(true)

	local objectReference = self.carryItemUComponent:GetComponent("ObjectReference")

	self.iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.txtStrengthenUSDFText = objectReference:GetRefValue("txtStrengthenUSDFText")
	self.listGemsUList = objectReference:GetRefValue("listGemsUList")
	self.rootUButton = objectReference:GetRefValue("rootUButton")
	self.contactTransform = self.carryItemUComponent.transform:Find("Normal/LayoutName/Contact")
end

function PetCardCarryInfoComponent:updateAndRefresh(petId, options)
	options = options or {}

	self:clearTooltip()

	self.petId = petId

	self.carryItemUComponent.gameObject:SetActiveEx(true)

	local carryData = petId and pg.global.ui.petTrainingNew.model:getPetEquipCarry(petId)

	LuaUIUtils.generalRefreshCarryCertifyComp(self.contactTransform, carryData and carryData.certifiedBaseFormPet)

	if not carryData then
		self.carryItemUComponent:TryChangePage("Empty", 1)
	else
		self.carryItemUComponent:TryChangePage("Empty", 0)

		local isRecommend = LuaUIUtils.checkCarryIsRecommend(petId, carryData.itemId)

		self.carryItemUComponent:TryChangePage("GoodState", isRecommend and 1 or 0)
		self.carryItemUComponent:TryChangePage("Quality", carryData.quality)

		self.iconPropUImage.url = carryData.icon

		ClientTextUtils.setText(self.txtNameUSDFText, carryData.name)
		ClientTextUtils.setText(self.txtStrengthenUSDFText, "+" .. carryData.cLevel)
		LuaUIUtils.refreshCarryAssistInfo(self.listGemsUList, nil, carryData, true)

		if NotNil(self.rootUButton) then
			self.rootUButton.enabledTooltip = not options.forbidToolTip and carryData.itemId ~= nil and carryData.itemId ~= 0

			if self.rootUButton.enabledTooltip then
				if options.popupDirection then
					self.rootUButton:SetPopupDirection(options.popupDirection)
				end

				function self.rootUButton.luaRenderTooltip(btn, tooltip)
					self.m_carryTooltip = tooltip

					self:refreshCarryItemTooltip(true)
				end

				function self.rootUButton.luaTooltipPopup(btn, visible)
					if not visible then
						self.m_carryTooltip = nil
						self.m_paramInfo = nil
					end
				end
			end
		end
	end
end

function PetCardCarryInfoComponent:refreshCarryItemTooltip(isNewRender)
	if IsNil(self.m_carryTooltip) or IsNil(self.rootUButton) or not self.petId then
		return
	end

	local paramInfo = pg.global.ui.petTrainingNew.model:getPetEquipCarry(self.petId)

	if not paramInfo then
		self:clearTooltip()

		return
	end

	local previousInfo = self.m_paramInfo

	if not isNewRender and (not previousInfo or previousInfo.invId ~= paramInfo.invId or previousInfo.genID ~= paramInfo.genID) then
		self:clearTooltip()

		return
	end

	paramInfo.itemCount = paramInfo.ownNum
	paramInfo.petId = self.petId
	paramInfo.isGotoCarry = true
	paramInfo.showLock = true
	self.m_paramInfo = paramInfo

	local petId, invId, genID = self.petId, paramInfo.invId, paramInfo.genID

	function paramInfo.btnLockFunc()
		local currentInfo = self.m_paramInfo

		if self.petId == petId and currentInfo and currentInfo.invId == invId and currentInfo.genID == genID then
			pg.game.petManage:sendRpcLockCarryItemStatus(currentInfo)
		end
	end

	if isNewRender then
		LuaUIUtils.refreshItemInfo(self.m_carryTooltip, paramInfo, self.rootUButton)
	else
		self.m_carryTooltip:TryChangePage("Lock", paramInfo.isLocked and 1 or 0)
	end
end

function PetCardCarryInfoComponent:clearTooltip()
	self.m_carryTooltip = nil
	self.m_paramInfo = nil

	if NotNil(self.rootUButton) then
		self.rootUButton.enabledTooltip = false
		self.rootUButton.luaRenderTooltip = nil
		self.rootUButton.luaTooltipPopup = nil
	end
end

function PetCardCarryInfoComponent:onDestroy()
	self:clearTooltip()

	self.petId = nil
	self.carryItemUComponent = nil
	self.iconPropUImage = nil
	self.txtNameUSDFText = nil
	self.txtStrengthenUSDFText = nil
	self.listGemsUList = nil
	self.rootUButton = nil
	self.contactTransform = nil
end

return PetCardCarryInfoComponent
