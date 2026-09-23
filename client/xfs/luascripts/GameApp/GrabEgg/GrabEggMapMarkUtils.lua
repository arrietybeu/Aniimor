-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\GrabEgg\\GrabEggMapMarkUtils.lua

local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GrabEggMapMarkUtils = {}

function GrabEggMapMarkUtils.getEggView(eggId)
	return pg.game.grabEgg and pg.game.grabEgg:getEggSyncData(eggId) or nil
end

function GrabEggMapMarkUtils.resolveControlInfo(eggView)
	if not eggView or not ToBool(eggView.controller) then
		return {
			controlled = false
		}
	end

	local isEnemy = Utils.isEnemy(pg.me, eggView)
	local teamIndex
	local controllerUid = eggView.controllerUid

	if controllerUid and controllerUid ~= "" and pg.me then
		local teamInfo = pg.me:getCurTeamInfo()

		if teamInfo and teamInfo.sortList then
			local contain, idx = LuaUIUtils.tableContains(teamInfo.sortList, controllerUid)

			if contain then
				teamIndex = idx
			end
		end
	end

	return {
		controlled = true,
		isEnemy = isEnemy,
		teamIndex = teamIndex
	}
end

function GrabEggMapMarkUtils.applyEggMarkView(objectReference, eggView, iconImgPath)
	if not objectReference then
		return
	end

	local uComponent = objectReference:GetRefValue("UPanel")
	local playerNumComponent = objectReference:GetRefValue("playerNum")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	if iconUImage and iconImgPath then
		iconUImage.url = iconImgPath
	end

	local info = eggView and GrabEggMapMarkUtils.resolveControlInfo(eggView) or {
		controlled = false
	}

	if NotNil(uComponent) then
		if info.controlled then
			local txtPlayerNum = objectReference:GetRefValue("playerIndexTxt")

			if info.teamIndex then
				uComponent:TryChangePage("Active", 2)

				if NotNil(playerNumComponent) then
					playerNumComponent:TryChangePage("Teammate", info.teamIndex - 1)
				end

				ClientTextUtils.setText(txtPlayerNum, info.teamIndex)
			elseif info.isEnemy then
				uComponent:TryChangePage("Active", 3)
			else
				uComponent:TryChangePage("Active", 1)
			end
		else
			uComponent:TryChangePage("Active", 1)
		end
	end
end

return GrabEggMapMarkUtils
