-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SubComponents\\Interactable.lua

local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local SubComponent = require("GameApp.Sandbox.SubComponents.SubComponent")
local SandboxConst = require("Common.Const.SandboxConst")
local Interactable = Class.LightClass("Interactable", SubComponent)

function Interactable:ctor(id, levelItem, info)
	Interactable.super.ctor(self, id, levelItem, info)
end

function Interactable:onInteract(isEnter, actionPrototypeId, pos, id)
	if isEnter then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
			dist = 1,
			interactionType = InteractionConst.INTERACTION_TYPE_SWITCH,
			interactFunc = function()
				if not self.levelItem:checkPermission(SandboxConst.Permission.OwnerInScene, true) then
					return
				end

				self:interact()
			end,
			actionPrototypeId = actionPrototypeId,
			targetPos = pos,
			globalId = id
		})
	else
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
			interactionType = InteractionConst.INTERACTION_TYPE_SWITCH,
			actionPrototypeId = actionPrototypeId,
			globalId = id
		})
	end
end

function Interactable:interact()
	self:serverMsg("RPC_CS_Interact")
end

return Interactable
