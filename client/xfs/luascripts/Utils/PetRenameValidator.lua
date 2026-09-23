-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PetRenameValidator.lua

local NoticeDef = require("Common.NoticeDef")
local PetRenameValidator = {}

function PetRenameValidator.canRenamePet()
	return false
end

function PetRenameValidator.tryShowRenamePet(showRenameCallback)
	if not PetRenameValidator.canRenamePet() then
		pg.global.showBubbleMessage(NoticeDef.FORBID_CHANGE_PET_NAME)

		return false
	end

	showRenameCallback()

	return true
end

return PetRenameValidator
