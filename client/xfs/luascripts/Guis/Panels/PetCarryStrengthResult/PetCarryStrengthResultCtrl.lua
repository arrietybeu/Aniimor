-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryStrengthResult\\PetCarryStrengthResultCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetCarryStrengthResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local PetCarryStrengthResultCtrl = Class.LightClass("PetCarryStrengthResultCtrl", UICtrl)
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local CoreCarryData = require("Data.core_carry_data")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientTextUtils = require("Utils.ClientTextUtils")

PetCarryStrengthResultCtrl.messages = {}

function PetCarryStrengthResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetCarryStrengthResultCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnClose.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onClosePanel()
		end
	end

	function self.view.btnClose.luaClick()
		self:onClosePanel()
	end

	function self.view.listAttribute.luaRenderItem(button, index, data)
		self:onRenderAttrItem(button, index, data)
	end
end

function PetCarryStrengthResultCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetCarryStrengthResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local sData = info or {}

	self.isMaxLv = sData.isMaxLv or false

	if sData.title then
		ClientTextUtils.setText(self.view.txtTitleUBaseText, sData.title)
	end

	local listAttrs = {}

	sData.carryAttrs = sData.carryAttrs or {}

	local oldLv, newLv = sData.oldLv or 0, sData.newLv or 0
	local requiredLevel = PetManagementDataHelper.getCoreCarryCertifyRequiredLevel(sData.itemId)
	local isUnlockCertify = requiredLevel and requiredLevel > 0 and oldLv < requiredLevel and requiredLevel <= newLv

	if isUnlockCertify then
		table.insert(listAttrs, 1, {
			tIndex = 2
		})
	end

	local coreCarryData = CoreCarryData[sData.itemId]

	if coreCarryData then
		for stage, energyEffect in ipairs(coreCarryData.energyEffects or EMPTY_TABLE) do
			local requiredLevel = energyEffect[3]

			if type(requiredLevel) == "number" and oldLv < requiredLevel and requiredLevel <= newLv then
				table.insert(listAttrs, {
					tIndex = 2,
					stage = stage
				})
			end
		end
	end

	for i, v in ipairs(sData.carryAttrs or EMPTY_TABLE) do
		table.insert(listAttrs, v)
	end

	self.view.listAttribute:SetList(listAttrs)

	if LoggerManager.checkLogger(LoggerConst.WARN) then
		local degbugStr = "\n"
		local itemTemp = {
			[0] = "propsAdd",
			"assistSlotAdd",
			"unlockCertify"
		}

		for i, v in ipairs(listAttrs) do
			degbugStr = degbugStr .. string.format("%s, \n", "item" .. i .. " - tIndex = " .. (v.tIndex or "nil") .. " - itemCont = " .. (itemTemp[v.tIndex] or "nil"))
		end

		logger:warn("PetCarryStrengthResultCtrl listAttrs debugCont: %s\n", degbugStr)
	end

	ClientTextUtils.setText(self.view.txtLvNow, string.format("+%d", sData.oldLv))
	ClientTextUtils.setText(self.view.txtLvAfter, string.format("+%d", sData.newLv))
	pg.game.audio:playEvent("SFX_UI_PetEquipment_Breakthrough")
end

function PetCarryStrengthResultCtrl:onClosePanel()
	local isMaxLv = self.isMaxLv

	self:dismiss()

	if isMaxLv then
		pg.global.ui:close(UIConst.UI_ID_PET_CARRY_STRENGTH)
	end
end

function PetCarryStrengthResultCtrl:onRenderAttrItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if data.tIndex == 0 then
		local txtName = objectReference:GetRefValue("txtName")
		local txtNumNow = objectReference:GetRefValue("txtNumNow")
		local txtNumAfter = objectReference:GetRefValue("txtNumAfter")
		local layoutValueUWidget = objectReference:GetRefValue("layoutValueUWidget")

		ClientTextUtils.setText(txtName, data.name)

		if data.tDesc and data.nDesc then
			layoutValueUWidget:SetActive(true)
			ClientTextUtils.setText(txtNumNow, data.tDesc)
			ClientTextUtils.setText(txtNumAfter, data.nDesc)
		else
			layoutValueUWidget:SetActive(false)
		end
	elseif data.tIndex == 1 then
		local txtName = objectReference:GetRefValue("txtName")
		local txtNum = objectReference:GetRefValue("txtNum")

		ClientTextUtils.setText(txtName, pg.getGameString("PET_EQUIPMENT_NEW_GEM_SLOT_UNLOCK"))
		ClientTextUtils.setText(txtNum, string.format("x%d", data.assistAdd))
	elseif data.tIndex == 2 then
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		if data.stage then
			ClientTextUtils.setText(txtNameUSDFText, string.format(pg.getGameString("PET_EQUIPMENT_STRENGTH_ACTIVATION"), data.stage))
		else
			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("CARRY_CERT_UNLOCK"))
		end
	end
end

function PetCarryStrengthResultCtrl:onHide()
	return
end

return PetCarryStrengthResultCtrl
