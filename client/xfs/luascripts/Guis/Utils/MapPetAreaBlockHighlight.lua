-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\MapPetAreaBlockHighlight.lua

local LuaCSharpArr = require("Utils.LuaCSharpArr")
local MapBlockPetAreaIndexData = require("Data.map_block_pet_area_index_data")
local MapHelper = require("GameApp.Map.MapHelper")
local MapPetAreaBlockHighlight = {}
local overlayComponentName = "InstancedMapPetAreaBlockOverlay"

function MapPetAreaBlockHighlight.applyPetBlocks(overlayComponent, petTemplateId, blockIds)
	if overlayComponent == nil or petTemplateId == nil or blockIds == nil then
		return
	end

	local overlay = overlayComponent

	if overlay == nil then
		return
	end

	local petTemplateIds = type(petTemplateId) == "table" and petTemplateId or {
		petTemplateId
	}
	local seen = {}
	local flat = {
		0
	}
	local n = 0

	for _, formId in ipairs(petTemplateIds) do
		local petRow = MapBlockPetAreaIndexData[formId]

		if petRow then
			for _, blockId in ipairs(blockIds) do
				local block = petRow[blockId]

				if block and block.mapPosGroup then
					local mapOffsetUI = MapHelper.getMapOffsetUI(block.sceneId)

					for x, ys in pairs(block.mapPosGroup) do
						for y, _ in pairs(ys) do
							local mapX = x
							local mapY = y

							if mapOffsetUI then
								mapX = mapX + mapOffsetUI[1]
								mapY = mapY + mapOffsetUI[2]
							end

							local key = mapX .. "_" .. mapY

							if not seen[key] then
								seen[key] = true
								n = n + 1
								flat[2 * n] = mapX
								flat[2 * n + 1] = mapY
							end
						end
					end
				end
			end
		end
	end

	flat[1] = n

	if n == 0 then
		overlay:ClearHighlights()

		return
	end

	local arr = LuaCSharpArr.NewByTable(flat)
	local access = arr:GetCSharpAccess()

	overlay:ApplyPositions(access)
	arr:DestroyCSharpAccess()
end

function MapPetAreaBlockHighlight.clear(overlayComponent)
	if not overlayComponent then
		return
	end

	local overlay = overlayComponent

	overlay:ClearHighlights()
end

return MapPetAreaBlockHighlight
