-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Qte\\QteCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local QteCtrl = Class.LightClass("QteCtrl", UICtrl)

function QteCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function QteCtrl:addListener()
	return
end

function QteCtrl:onShow()
	return
end

function QteCtrl:destroyQtePrefab(gameObject)
	self.view:destroyInstance(gameObject)
end

function QteCtrl:instanceQtePrefab(clip, resID)
	self.view:addPrefabWithPathAsync(self.view.gameObject, resID, function(objInfo)
		if clip:isFinish() then
			self.view:destroyInstance(objInfo.gameObject)
		else
			clip:prefabLoaded(objInfo.gameObject)
		end
	end, false)
end

return QteCtrl
