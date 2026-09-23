-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\ItemBag\\ItemPileSimulator.lua

local ItemUtils = require("Common.Utils.ItemUtils")
local Time = require("Core.Common.Time")
local ItemPileSimulator = {}
local math_min = math.min
local pairs = pairs

local function appendPile(pilesById, item, count)
	local id = item.id
	local piles = pilesById[id]

	if piles == nil then
		piles = {}
		pilesById[id] = piles
	end

	piles[#piles + 1] = {
		item = item,
		count = count,
		maxCount = item:maxCount()
	}
end

function ItemPileSimulator.calcSpace(bag, items, allowMultiPile)
	local pileCount = 0

	if not allowMultiPile then
		for _, item in bag:items() do
			if item ~= nil and item.count > 0 then
				pileCount = pileCount + 1
			end
		end

		for _, item in pairs(items) do
			if item ~= nil and item.count > 0 then
				pileCount = pileCount + 1
			end
		end

		return pileCount
	end

	local pilesById = {}

	for _, item in bag:items() do
		if item ~= nil and item.count > 0 then
			appendPile(pilesById, item, item.count)

			pileCount = pileCount + 1
		end
	end

	local now = Time.secondCache

	for _, inItem in pairs(items) do
		local remaining = inItem and inItem.count or 0

		if remaining > 0 then
			if inItem:getGenID() > 0 then
				pileCount = pileCount + 1
			else
				if not inItem:isFullPile() then
					local piles = pilesById[inItem.id]

					if piles ~= nil then
						for _, pile in pairs(piles) do
							if remaining <= 0 then
								break
							end

							local available = pile.maxCount - pile.count

							if available > 0 and ItemUtils.canPileItemObjects(pile.item, inItem, now) then
								local piled = math_min(available, remaining)

								pile.count = pile.count + piled
								remaining = remaining - piled
							end
						end
					end
				end

				if remaining > 0 then
					appendPile(pilesById, inItem, remaining)

					pileCount = pileCount + 1
				end
			end
		end
	end

	return pileCount
end

return ItemPileSimulator
