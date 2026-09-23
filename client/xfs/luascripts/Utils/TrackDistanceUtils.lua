-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\TrackDistanceUtils.lua

local TrackDistanceUtils = {}
local MIN_DISTANCE = 1
local MAX_DISTANCE = 30

function TrackDistanceUtils.getDistanceRange()
	return MIN_DISTANCE, MAX_DISTANCE
end

function TrackDistanceUtils.getDistance(targetPos, sourcePos)
	if targetPos == nil then
		return nil
	end

	if sourcePos == nil then
		if pg == nil or pg.me == nil then
			return nil
		end

		sourcePos = pg.me:getPosition()
	end

	if sourcePos == nil then
		return nil
	end

	return Vector3.Distance(targetPos, sourcePos)
end

function TrackDistanceUtils.canShowTrack(distance)
	return distance ~= nil and distance > MIN_DISTANCE
end

function TrackDistanceUtils.canShowDistance(distance)
	return distance ~= nil and distance > MIN_DISTANCE and distance < MAX_DISTANCE
end

function TrackDistanceUtils.formatDistanceText(distance)
	if TrackDistanceUtils.canShowDistance(distance) ~= true then
		return nil
	end

	local unitText = pg.getGameString("METER") or ""

	return string.format("%.0f%s", distance, unitText)
end

return TrackDistanceUtils
