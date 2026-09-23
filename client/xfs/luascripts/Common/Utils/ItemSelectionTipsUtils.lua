-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\ItemSelectionTipsUtils.lua

local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local ItemSelectionTipsUtils = {}
local longPressFired = setmetatable({}, {
	__mode = "k"
})

function ItemSelectionTipsUtils.isMultiItem(itemCount)
	return (itemCount or 0) > 1
end

function ItemSelectionTipsUtils.toggleSelectedId(selectedId, itemId)
	if selectedId == itemId then
		return nil
	end

	return itemId
end

function ItemSelectionTipsUtils.isUsingGamepad()
	return pg.game and pg.game.input and pg.game.input:isUsingGamepad() == true
end

function ItemSelectionTipsUtils.showItemTips(button, itemId, itemCount)
	if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

		return
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		id = itemId,
		num = itemCount,
		targetRect = button
	})
end

function ItemSelectionTipsUtils.bindLongPressTips(button, onTips)
	if not button then
		return
	end

	longPressFired[button] = false
	button.luaClick = nil

	function button.luaPress()
		longPressFired[button] = false
	end

	button.enabledLongPress = true
	button.luaLongPress = nil

	function button.luaBeginLongPress()
		longPressFired[button] = true

		onTips()
	end

	button:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, 0, function()
		onTips()

		return false
	end)
	button:SetHotkeyActiveOnlyInCurrentItem(true)
	button:SetHotkeyConsoleBar("GIFTPACK_TIPS", 0)
end

function ItemSelectionTipsUtils.consumeLongPressClick(button)
	if not button or not longPressFired[button] then
		return false
	end

	longPressFired[button] = false

	return true
end

function ItemSelectionTipsUtils.clearLongPressTips(button)
	if not button then
		return
	end

	longPressFired[button] = nil
	button.luaClick = nil
	button.luaPress = nil
	button.enabledLongPress = false
	button.luaLongPress = nil
	button.luaBeginLongPress = nil

	button:RemoveLuaGamepadHotkey()
end

return ItemSelectionTipsUtils
