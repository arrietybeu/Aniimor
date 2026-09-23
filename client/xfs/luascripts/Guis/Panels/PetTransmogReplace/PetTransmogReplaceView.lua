-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogReplace\\PetTransmogReplaceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogReplaceView = Class.LightClass("PetTransmogReplaceView", UIView)

function PetTransmogReplaceView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnCancel = objectReference:GetRefValue("btnCancel")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.customList = objectReference:GetRefValue("customList")
	self.title = objectReference:GetRefValue("title")
	self.txtDesc = objectReference:GetRefValue("txtDesc")
	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtBtnConfirm = objectReference:GetRefValue("txtBtnConfirm")
end

function PetTransmogReplaceView:registerObjects()
	return
end

function PetTransmogReplaceView:initView()
	ClientTextUtils.setText(self.title, pg.getGameString("PETTRANSMOGRIFY_REPLACE"))
	ClientTextUtils.setText(self.txtDesc, pg.getGameString("PETTRANSMOGRIFY_REPLACE_TIP"))
	ClientTextUtils.setText(self.txtBtnConfirm, pg.getGameString("PETTRANSMOGRIFY_DELETE_ENTER_OK"))
end

return PetTransmogReplaceView
