-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareView\\MarkShareViewModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local InfoStampPresetContentData = require("Data.info_stamp_preset_content_data")
local Utils = require("Common.Utils.Utils")
local SceneUtils = require("Common.Utils.SceneUtils")
local Const = require("Common.Const.Const")
local MarkShareViewModel = Class.LightClass("MarkShareViewModel", UIModel)

function MarkShareViewModel:getPresetNpcId(stampInfoId)
	return InfoStampPresetContentData[Utils.getNoBySysMediaMarkerId(stampInfoId)].npcId
end

function MarkShareViewModel:getPresetMarkPos2(stampInfoId)
	local sceneId = pg.game.map:convertSceneId(pg.space.sceneId)
	local sceneMarkData = SceneUtils.getSceneMarkData(sceneId)

	if not sceneMarkData[Const.MAP_MARK_INFO_STAMP] then
		return nil
	end

	local no = Utils.getNoBySysMediaMarkerId(stampInfoId)

	for markId, markData in pairs(sceneMarkData[Const.MAP_MARK_INFO_STAMP]) do
		if markData.informationId == no then
			return {
				markData.markPosition[1],
				markData.markPosition[3]
			}
		end
	end

	return nil
end

function MarkShareViewModel:getOtherPlayerUId(stampInfoId)
	return pg.game.markShare.aroundMarkInfoStampGroup[stampInfoId].uid
end

function MarkShareViewModel:getContentAnimationData(stampInfoId)
	local infoStamp = pg.game.markShare:parseInfoStamp(pg.game.markShare.aroundMarkInfoStampGroup[stampInfoId].type == Const.MediaMarkerType.SystemText, stampInfoId)

	return infoStamp.animation
end

return MarkShareViewModel
