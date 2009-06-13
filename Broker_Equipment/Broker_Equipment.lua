--[[

 Copyright (c) 2009, Adrian L Lange
 All rights reserved.

 You're allowed to use this addon, free of monetary charge,
 but you are not allowed to modify, alter, or redistribute
 this addon without express, written permission of the author.

--]]

local L = {}
if(GetLocale() == 'deDE') then -- Katharsis
	L.NOSET = 'Kein set'
	L.TOOLTIP1 = 'Left-click to change your set' -- todo
	L.TOOLTIP2 = 'Right-click to open GearManager' -- todo
	L.HINT = {' ', '|cff00ff00Shift-click to update set|r', '|cff00ff00Ctrl-click to delete set|r'} -- todo
elseif(GetLocale() == 'frFR') then -- Soeters
	L.NOSET = 'Pas de set'
	L.TOOLTIP1 = 'Left-click to change your set' -- todo
	L.TOOLTIP2 = 'Right-click to open GearManager' -- todo
	L.HINT = {' ', '|cff00ff00Maj-clic pour mettre à jour le set|r', '|cff00ff00Ctrl-clic pour supprimer le set|r'}
elseif(GetLocale() == 'zhCN') then -- yleaf
	L.NOSET = '无套装'
	L.TOOLTIP1 = 'Left-click to change your set' -- todo
	L.TOOLTIP2 = 'Right-click to open GearManager' -- todo
	L.HINT = {' ', '|cff00ff00Shift点击覆盖套装|r', '|cff00ff00Ctrl点击删除套装|r'}
elseif(GetLocale() == 'zhTW') then -- yleaf
	L.NOSET = '無套裝'
	L.TOOLTIP1 = 'Left-click to change your set' -- todo
	L.TOOLTIP2 = 'Right-click to open GearManager' -- todo
	L.HINT = {' ', '|cff00ff00Shift點擊覆蓋套裝|r', '|cff00ff00Ctrl點擊刪除套裝|r'}
elseif(GetLocale() == 'koKR') then -- mrgyver
	L.NOSET = '세트 없음'
	L.TOOLTIP1 = '좌-클릭 세트 변경'
	L.TOOLTIP2 = '우-클릭 장비 관리창 열기'
	L.HINT = {' ', '|cff00ff00Shift-클릭 하면 세트 업데이트|r', '|cff00ff00Ctrl-클릭 하면 세트 삭제|r'}
else
	L.NOSET = 'No set'
	L.TOOLTIP1 = 'Left-click to change your set'
	L.TOOLTIP2 = 'Right-click to open GearManager'
	L.HINT = {' ', '|cff00ff00Shift-click to update set|r', '|cff00ff00Ctrl-click to delete set|r'}
end


local menu = {}
local pendingUpdate = true

local addon = CreateFrame('Frame', 'Broker_EquipmentMenu', UIParent, 'UIDropDownMenuTemplate')
local broker = LibStub('LibDataBroker-1.1'):NewDataObject('Broker_Equipment', {
	type = 'data source',
	text = L.NOSET,
	icon = [=[Interface\PaperDollInfoFrame\UI-EquipmentManager-Toggle]=],
	iconCoords = {0.065, 0.935, 0.065, 0.935}
})

-- Borrowed from tekkub's EquipSetUpdater
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
	if(IsShiftKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_OVERWRITE_EQUIPMENT_SET', name)
		dialog.data = name
		dialog.selectedIcon = GetTextureIndex(icon) -- Blizzard sucks
	elseif(IsControlKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', name)
		dialog.data = name
	elseif(not InCombatLockdown()) then
		EquipmentManager_EquipSet(name)
	end
end

local function updateInfo(name, icon)
	broker.text = name
	broker.icon = icon

	Broker_EquipmentDB.text = name
	Broker_EquipmentDB.icon = icon
end

local function updateMenu()
	pendingUpdate = nil
	menu = wipe(menu)

	local title = {text = 'Broker Equipment\n ', isTitle = true}
	table.insert(menu, title)

	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		local temp = {
			text = name,
			icon = icon,
			func = function() handleClick(name, icon) end
		}
		table.insert(menu, temp)
	end

	for index = 1, 3 do
		local temp = {text = L.HINT[index], disabled = true}
		table.insert(menu, temp)
	end
end

function broker:OnClick(button)
	if(button == 'RightButton') then
		if(GearManagerDialog:IsVisible()) then
			if(PaperDollFrame:IsVisible()) then
				ToggleCharacter('PaperDollFrame')
			end
			GearManagerDialog:Hide()
		else
			if(not PaperDollFrame:IsVisible()) then
				ToggleCharacter('PaperDollFrame')
			end
			GearManagerDialog:Show()
		end
	else
		if(pendingUpdate) then updateMenu() end
		EasyMenu(menu, addon, self, 0, 0, 'MENU')

		if(GameTooltip:GetOwner() == self) then GameTooltip:Hide() end
	end
end

function broker:OnTooltipShow()
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine(L.TOOLTIP1)
	self:AddLine(L.TOOLTIP2)
end

function addon:ADDON_LOADED(event, addon)
	if(addon ~= 'Broker_Equipment') then return end

	Broker_EquipmentDB = Broker_EquipmentDB or {text = L.NOSET, icon = broker.icon}
	broker.text = Broker_EquipmentDB.text
	broker.icon = Broker_EquipmentDB.icon

	self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
	self:RegisterEvent('VARIABLES_LOADED')
	self:UnregisterEvent(event)
end

function addon:EQUIPMENT_SETS_CHANGED()
	pendingUpdate = true
end

function addon:VARIABLES_LOADED()
	SetCVar('equipmentManager', 1)
	GearManagerToggleButton:Show()
end


hooksecurefunc('EquipmentManager_EquipSet', function(funcName)
	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		if(name == funcName) then
			updateInfo(name, icon)
			break
		end
	end
end)

addon:RegisterEvent('ADDON_LOADED')
addon:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)