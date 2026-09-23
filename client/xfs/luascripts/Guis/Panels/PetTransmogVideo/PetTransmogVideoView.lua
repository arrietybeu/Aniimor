-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogVideo\\PetTransmogVideoView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogVideoView = Class.LightClass("PetTransmogVideoView", UIView)

function PetTransmogVideoView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnClose = objectReference:GetRefValue("btnClose")
	self.videoPlayer = objectReference:GetRefValue("videoPlayer")
	self.videoButton = objectReference:GetRefValue("videoButton")
	self.btnPlay = objectReference:GetRefValue("btnPlay")
	self.txtTitle = objectReference:GetRefValue("txtTitle")

	if not self.txtTitle then
		local titleTransform = self.transform:Find("Window/Text")

		self.txtTitle = titleTransform and titleTransform:GetComponent("USDFText")
	end
end

function PetTransmogVideoView:registerObjects()
	return
end

function PetTransmogVideoView:initView()
	if self.txtTitle then
		ClientTextUtils.setText(self.txtTitle, pg.getGameString("PETTRANSMOGRIFY_SHOW"))
	end
end

return PetTransmogVideoView
