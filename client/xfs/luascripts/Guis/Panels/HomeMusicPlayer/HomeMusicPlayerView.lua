-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeMusicPlayer\\HomeMusicPlayerView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeMusicPlayerView = Class.LightClass("HomeMusicPlayerView", UIView)

function HomeMusicPlayerView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listMusicPlayerUList = objectReference:GetRefValue("ListMusicPlayer")
	self.btnBackUButton = objectReference:GetRefValue("BtnBack")
	self.btnInfoUButton = objectReference:GetRefValue("BtnInfo")
end

function HomeMusicPlayerView:getMusicNameText(button)
	local objectReference = button:GetComponent("ObjectReference")

	return objectReference:GetRefValue("TxtName")
end

function HomeMusicPlayerView:registerObjects()
	return
end

function HomeMusicPlayerView:initView()
	return
end

return HomeMusicPlayerView
