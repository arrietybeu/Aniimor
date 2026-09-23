-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogScheme\\PetTransmogSchemeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogSchemeView = Class.LightClass("PetTransmogSchemeView", UIView)

function PetTransmogSchemeView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnClose = objectReference:GetRefValue("btnClose")
	self.title = objectReference:GetRefValue("title")
	self.tempList = objectReference:GetRefValue("tempList")
	self.txtDesc = objectReference:GetRefValue("txtDesc")
	self.btnSave = objectReference:GetRefValue("btnSave")
	self.txtBtnSave = objectReference:GetRefValue("txtBtnSave")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.txtEmptyTextPlus = objectReference:GetRefValue("txtEmptyTextPlus")
end

function PetTransmogSchemeView:registerObjects()
	return
end

function PetTransmogSchemeView:initView()
	ClientTextUtils.setText(self.txtBtnSave, pg.getGameString("PETTRANSMOGRIFY_SAVE_CUSTOM"))
	ClientTextUtils.setText(self.title, pg.getGameString("PETTRANSMOGRIFY_SAVE_BEST"))
	ClientTextUtils.setText(self.txtDesc, pg.getGameString("PETTRANSMOGRIFY_AUTO_TEMP_TIP"))
	ClientTextUtils.setText(self.txtEmptyTextPlus, pg.getGameString("PETTRANSMOGRIFY_HISTORY"))
end

return PetTransmogSchemeView
