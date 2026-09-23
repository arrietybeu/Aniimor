-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformWorkShopCostumeStainModel.lua

local M = {}
local EventConst = require("Const.EventConst")

function M:onSubmitChanged(index, name, sprite, callback)
	local function wrappedCallback(res, ...)
		if res and pg and pg.global and pg.global.eventEmitter then
			pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_COSTUME_DYED, {
				clothId = self.clothId,
				slotId = self.slotId,
				designIndex = index
			})
		end

		if callback then
			callback(res, ...)
		end
	end

	self:_onSubmitChangedImpl(index, name, sprite, wrappedCallback)
end

return M
