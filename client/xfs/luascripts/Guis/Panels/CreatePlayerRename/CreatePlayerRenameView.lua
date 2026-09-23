-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreatePlayerRename\\CreatePlayerRenameView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CreatePlayerRenameView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CreatePlayerRenameView = Class.LightClass("CreatePlayerRenameView", UIView)

function CreatePlayerRenameView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.inputField = self.objectReference:GetRefValue("inputField")
	self.txtTips = self.objectReference:GetRefValue("txtTips")
	self.btnRandom = self.objectReference:GetRefValue("btnRandom")
	self.btnEnter = self.objectReference:GetRefValue("btnEnter")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function CreatePlayerRenameView:registerObjects()
	return
end

function CreatePlayerRenameView:initView()
	return
end

return CreatePlayerRenameView
