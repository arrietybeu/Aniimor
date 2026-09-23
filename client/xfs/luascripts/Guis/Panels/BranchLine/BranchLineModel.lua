-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BranchLine\\BranchLineModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("BranchLineModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local SceneData = require("Data.scene_data")
local MapLineData = require("Data.map_line_config_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local SceneUtils = require("Common.Utils.SceneUtils")
local BranchLineModel = Class.LightClass("BranchLineModel", UIModel)

BranchLineModel.RANGE_OF_LINE = {
	SysConfigData.LINE_STATE_GOOD,
	SysConfigData.LINE_STATE_FEW,
	SysConfigData.LINE_STATE_CROWD
}
BranchLineModel.LINE_STATE = {
	FULL = 0,
	BUSY = 1,
	GOOD = 2,
	FREE = 3,
	MAINTENANCE = 4
}

function BranchLineModel:parseLineInfo(info)
	if pg.me.space == nil then
		return info
	end

	local res = {}
	local sceneId = pg.me.space.sceneId
	local curLineNo = pg.me.space.lineNo
	local sData = SceneData[sceneId]
	local maxPlayerNum = SceneUtils.getMaxInstanceCapacity(sceneId)
	local initNum = SceneUtils.getKeepInstanceNum(sceneId)
	local lineNo, playerNum, v

	for _, data in ipairs(info) do
		lineNo, playerNum = data[1], data[2]

		if lineNo == curLineNo and playerNum == 0 then
			playerNum = 1
		end

		v = {
			lineId = lineNo,
			playerNum = playerNum,
			name = string.format("%s %d", pg.getLocalizationText(sData.name), lineNo),
			ps = string.format("%d/%d", playerNum, maxPlayerNum)
		}

		local rate = v.playerNum / maxPlayerNum

		if rate >= 0 and rate < self.RANGE_OF_LINE[1] then
			v.mode = self.LINE_STATE.FREE
		elseif rate >= self.RANGE_OF_LINE[1] and rate < self.RANGE_OF_LINE[2] then
			v.mode = self.LINE_STATE.GOOD
		elseif rate >= self.RANGE_OF_LINE[2] and rate < self.RANGE_OF_LINE[3] then
			v.mode = self.LINE_STATE.BUSY
		elseif rate >= self.RANGE_OF_LINE[3] and rate < 1 then
			v.mode = self.LINE_STATE.FULL
		end

		res[lineNo] = v
	end

	for i = 1, initNum do
		if res[i] == nil then
			local playerNum = 0

			if curLineNo == i then
				playerNum = 1
			end

			print("pullExclusiveLineCb666: ", i, playerNum)

			res[i] = {
				lineId = i,
				playerNum = playerNum,
				name = string.format("%s %d", pg.getLocalizationText(sData.name), i),
				ps = string.format("%d/%d", playerNum, maxPlayerNum),
				mode = self.LINE_STATE.FREE
			}
		end
	end

	return res
end

return BranchLineModel
