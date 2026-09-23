-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerHomeSeasonMutationComponent.lua

local Class = require("Core.Framework.Class")
local NoticeDef = require("Common.NoticeDef")
local ClientPlayerHomeSeasonMutationComponent = Class.Component("ClientPlayerHomeSeasonMutationComponent")

function ClientPlayerHomeSeasonMutationComponent:handleResponse(result, callback, responseData)
	if result ~= NoticeDef.SUCCESS then
		pg.global.showBubbleMessage(result)
	end

	if callback then
		callback(result, responseData)
	end
end

function ClientPlayerHomeSeasonMutationComponent:reqReceiveHomeSeasonMutationReward(rewardIds, callback)
	self:serverMsg("RPC_CS_ReceiveHomeSeasonMutationReward", rewardIds, function(result)
		self:handleResponse(result, callback)
	end)
end

function ClientPlayerHomeSeasonMutationComponent:reqRecordHomeSeasonMutation(itemId, callback)
	self:serverMsg("RPC_CS_RecordHomeSeasonMutation", itemId, function(result)
		self:handleResponse(result, callback)
	end)
end

function ClientPlayerHomeSeasonMutationComponent:reqDecomposeHomeSeasonMutationItems(itemDict, callback)
	self:serverMsg("RPC_CS_DecomposeHomeSeasonMutationItems", itemDict, function(result, rewardItems)
		self:handleResponse(result, callback, rewardItems)
	end)
end

function ClientPlayerHomeSeasonMutationComponent:reqSendHomeSeasonMutationGift(targetUid, itemId, callback)
	self:serverMsg("RPC_CS_SendHomeSeasonMutationGift", targetUid, itemId, function(result)
		self:handleResponse(result, callback)
	end)
end

function ClientPlayerHomeSeasonMutationComponent:reqRequestHomeSeasonMutationHelpToFriend(friendUid, itemId, callback)
	self:serverMsg("RPC_CS_RequestHelpToFriend", friendUid, itemId, function(result, cardInfo)
		self:handleResponse(result, callback, cardInfo)
	end)
end

function ClientPlayerHomeSeasonMutationComponent:reqRespondHomeSeasonMutationHelp(requestId, callback)
	self:serverMsg("RPC_CS_RespondHelp", requestId, function(result)
		self:handleResponse(result, callback)
	end)
end

return ClientPlayerHomeSeasonMutationComponent
