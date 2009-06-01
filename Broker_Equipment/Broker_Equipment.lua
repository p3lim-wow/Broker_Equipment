--[[

 Copyright (c) 2009, Adrian L Lange
 All rights reserved.

 You're allowed to use this addon, free of monetary charge,
 but you are not allowed to modify, alter, or redistribute
 this addon without express, written permission of the author.

--]]

local L = {}
if(GetLocale() == 'deDE') then -- Katharsis
	L.TOOLTIP1 = 'Klicke hier um das set zu wechsein'
	L.TOOLTIP2 = 'Klicke mit Strg+Alt im men/195/188 um dein set zu aktualisieren'
	L.TOOLTIP3 = 'Klicke mit Shift+Alt im men/195/188 um dein set zu l/195/182schen'
	L.NOSET = 'Kein set'
elseif(GetLocale() == 'frFR') then -- Soeters
	L.TOOLTIP1 = 'Cliquez ici pour changer de set'
	L.TOOLTIP2 = 'Ctrl+Alt click in menu to update your set (NYI)'
	L.TOOLTIP3 = 'Shift+Alt click in menu to delete your set (NYI)'
	L.NOSET = 'Pas de set'
elseif(GetLocale() == 'zhCN') then -- yleaf & yaroot
	L.TOOLTIP1 = '点击选择套装'
	L.TOOLTIP2 = 'Ctrl+Alt 点击更新套装'
	L.TOOLTIP3 = 'Shift+Alt 点击删除套装'
	L.NOSET = '无套装'
elseif(GetLocale() == 'zhTW') then -- yleaf & yaroot
	L.TOOLTIP1 = '點擊選擇套裝'
	L.TOOLTIP2 = 'Ctrl+Alt 點擊更新套裝'
	L.TOOLTIP3 = 'Shift+Alt 點擊刪除套裝'
	L.NOSET = '無套裝'
elseif(GetLocale() == 'koKR') then -- mrgyver
	L.TOOLTIP1 = '당신의 세트를 변경하려면 여기를 클릭하세요.'
	L.TOOLTIP2 = 'Ctrl+Alt click in menu to update your set (NYI)'
	L.TOOLTIP3 = 'Shift+Alt click in menu to delete your set (NYI)'
	L.NOSET = '세트 없음'
else
	L.TOOLTIP1 = 'Click here to change your set'
	L.TOOLTIP2 = 'Ctrl+Alt click in menu to update your set'
	L.TOOLTIP3 = 'Shift+Alt click in menu to delete your set'
	L.NOSET = 'No set'
end

local menuList = {}
local pendingName = nil
local pendingUpdate = true

local addonName = 'Broker_Equipment'

local addon = CreateFrame('Frame', addonName..'DropDown', UIParent, 'UIDropDownMenuTemplate')
local broker = LibStub('LibDataBroker-1.1'):NewDataObject(addonName, {
	type = 'data source',
	text = L.NOSET,
	icon = [=[Interface\PaperDollInfoFrame\UI-EquipmentManager-Toggle]=],
	iconCoords = {0.065, 0.935, 0.065, 0.935}
})

-- borrowed from tekkub's EquipSetUpdater
local function GetTextureIndex(tex)
	RefreshEquipmentSetIconInfo()
	tex = tex:lower()
	local numicons = GetNumMacroIcons()
	for i=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do if GetInventoryItemTexture("player", i) then numicons = numicons + 1 end end
	for i=1,numicons do
		local texture, index = GetEquipmentSetIconInfo(i)
		if texture:lower() == tex then return index end
	end
end

local function handleClick(name, icon)
	if(IsShiftKeyDown() and IsAltKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', name)
		dialog.data = name
	elseif(IsControlKeyDown() and IsAltKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_OVERWRITE_EQUIPMENT_SET', name)
		dialog.data = name
		dialog.selectedIcon = GetTextureIndex(icon) -- blizzard sucks
	elseif(EquipmentSetContainsLockedItems(name) or UnitOnTaxi('player') or UnitCastingInfo('player') or InCombatLockdown()) then
		return
	else
		EquipmentManager_EquipSet(name)
	end
end

local function initDropDown()
	for k, v in next, menuList do
		UIDropDownMenu_AddButton(v, level or 1)
	end
end	

local function createDropDown()
	wipe(menuList)

	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		local info = {}
		info.index = index
		info.text = name
		info.icon = icon
		info.func = function() handleClick(name, icon) end

		menuList[index] = info
	end

	table.sort(menuList, function(a, b) return a.index < b.index end)
	UIDropDownMenu_Initialize(addon, initDropDown, 'MENU')
	pendingUpdate = nil
end

local function onEvent(self, event, arg1)
	if(event == 'EQUIPMENT_SETS_CHANGED') then
		pendingUpdate = true
	else
		if(arg1 ~= addonName) then return end

		Broker_EquipmentDB = Broker_EquipmentDB or {text = L.NOSET, icon = broker.icon}
		broker.text = Broker_EquipmentDB.text
		broker.icon = Broker_EquipmentDB.icon

		self:UnregisterEvent(event)
	end
end

function broker:OnClick(button)
	if(GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end

	if(pendingUpdate) then
		createDropDown()
	end

	ToggleDropDownMenu(1, nil, addon, self, 0, 0)
end

function broker:OnTooltipShow()
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine(L.TOOLTIP1)
	self:AddLine(L.TOOLTIP2)
	self:AddLine(L.TOOLTIP3)
end

hooksecurefunc('EquipmentManager_EquipSet', function(name)
	if(name and name ~= broker.text) then
		local icon = GetEquipmentSetInfoByName(name)
		local propericon = icon:match('Interface') and icon or [=[Interface\Icons\]=] .. icon -- fixing blizzard's bug

		broker.text = name
		broker.icon = propericon

		Broker_EquipmentDB.text = name
		Broker_EquipmentDB.icon = propericon
	end
end)

addon:RegisterEvent('ADDON_LOADED')
addon:RegisterEvent('EQUIPMENT_SETS_CHANGED')
addon:SetScript('OnEvent', onEvent)