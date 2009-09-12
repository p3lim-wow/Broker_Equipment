--[[

	Copyright (c) 2009 Adrian L Lange <adrianlund@gmail.com>
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local L = {}
if(GetLocale() == 'deDE') then -- Katharsis / copystring
	L.NOSET = 'Kein set'
	L.TOOLTIP = 'Klicke links um dein set zu ändern\nKlicke rechts um den GearManager zu öffnen'
	L.HINTS =  '|cff00ff00Shift-klicke um den set zu aktualisieren\nStrg-klicke um den set zu löschen|r'
elseif(GetLocale() == 'frFR') then -- Soeters / Gnaf
	L.NOSET = 'Pas de set'
	L.TOOLTIP = 'Clic gauche pour changer d\'équipement\nClic droit pour ouvrir le gestionnaire d\'équipement'
	L.HINTS = '|cff00ff00Maj-clic pour mettre à jour le set\nCtrl-clic pour supprimer le set|r'
elseif(GetLocale() == 'zhCN') then -- yleaf
	L.NOSET = '无套装'
	L.TOOLTIP = '左键点击切换套装\n右键打开套装管理器'
	L.HINTS = '|cff00ff00Shift点击覆盖套装\nCtrl点击删除套装|r'
elseif(GetLocale() == 'zhTW') then -- yleaf
	L.NOSET = '無套裝'
	L.TOOLTIP = '左鍵點擊切換套裝\n右鍵點擊打開套裝管理器'
	L.HINTS = '|cff00ff00Shift點擊覆蓋套裝\nCtrl點擊刪除套裝|r'
elseif(GetLocale() == 'koKR') then -- mrgyver
	L.NOSET = '세트 없음'
	L.TOOLTIP = '좌-클릭 세트 변경\n우-클릭 장비 관리창 열기'
	L.HINTS = '|cff00ff00Shift-클릭 하면 세트 업데이트\nCtrl-클릭 하면 세트 삭제|r'
else
	L.NOSET = 'No set'
	L.TOOLTIP = 'Left-click to change your set\nRight-click to open GearManager'
	L.HINTS = '|cff00ff00Shift-click to update set\nCtrl-click to delete set|r'
end


local pending

local addon = CreateFrame('Frame', 'Broker_EquipmentMenu')
addon:RegisterEvent('ADDON_LOADED')
addon:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)

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

local function equipped(name)
	local located
	for slot, location in next, GetEquipmentSetLocations(name) do
		if(location == 0) then
			located = not GetInventoryItemLink('player', slot)
		elseif(location ~= 1) then
			local player, bank, bags = EquipmentManager_UnpackLocation(location)
			located = player and not bank and not bags
		end

		if(not located) then
			return
		end
	end

	return true
end

local function menuClick(button, name, icon)
	if(IsShiftKeyDown()) then
		local dialog = StaticPopup_Show('CUSTOM_OVERWRITE_EQUIPMENT_SET', name) -- Custom popup to update the info
		dialog.name = name
		dialog.icon = icon
	elseif(IsControlKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', name)
		dialog.data = name
	else
		EquipmentManager_EquipSet(name)

		if(InCombatLockdown()) then
			pending = name
			addon:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end
end

local function updateInfo(name, icon)
	broker.text = InCombatLockdown() and '|cffff0000'..name or name
	broker.icon = icon

	Broker_EquipmentDB.text = name
	Broker_EquipmentDB.icon = icon
end

-- Fuck blizzard!
StaticPopupDialogs.CUSTOM_OVERWRITE_EQUIPMENT_SET = {
	text = CONFIRM_OVERWRITE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self) SaveEquipmentSet(self.name, GetTextureIndex(self.icon)); GearManagerDialogPopup:Hide() updateInfo(self.name, self.icon) end,
	OnCancel = function() end,
	OnHide = function(self) self.name, self.icon = nil, nil end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

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
	elseif(GetNumEquipmentSets() > 0) then
		ToggleDropDownMenu(1, nil, addon, self, 0, 0)
	end

	if(GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end
end

function broker:OnTooltipShow()
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine(L.TOOLTIP)
end

function addon:initialize(level)
	local info = wipe(self.info)
	info.isTitle = 1
	info.notCheckable = 1
	info.text = '|cff0090ffBroker Equipment|r\n '
	UIDropDownMenu_AddButton(info, level)

	wipe(info)
	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		info.text = string.format('|T%s:20|t %s', icon, name)
		info.arg1 = name
		info.arg2 = icon
		info.func = menuClick
		info.checked = equipped(name) or pending and pending == name
		UIDropDownMenu_AddButton(info, level)
	end

	wipe(info)
	info.text = ' '
	info.disabled = 1
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, level)

	info.text = L.HINTS
	UIDropDownMenu_AddButton(info, level)
end

function addon:ADDON_LOADED(event, addon)
	if(addon ~= 'Broker_Equipment') then return end

	Broker_EquipmentDB = Broker_EquipmentDB or {text = L.NOSET, icon = broker.icon}

	self.info = {}
	self.displayMode = 'MENU'

	self:UNIT_INVENTORY_CHANGED()
	self:RegisterEvent('UNIT_INVENTORY_CHANGED')
	self:RegisterEvent('VARIABLES_LOADED')
	self:UnregisterEvent(event)
end

function addon:VARIABLES_LOADED(event)
	SetCVar('equipmentManager', 1)
	GearManagerToggleButton:Show()

	self:UnregisterEvent(event)
end

function addon:PLAYER_REGEN_ENABLED(event)
	EquipmentManager_EquipSet(pending)
	pending = nil
	self:UnregisterEvent(event)
end

function addon:UNIT_INVENTORY_CHANGED(event, unit)
	if(unit and unit ~= 'player') then return end

	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		if(equipped(name)) then
			updateInfo(name, icon)
			break
		else
			updateInfo(UNKNOWN, [=[Interface\Icons\INV_Misc_QuestionMark]=])
		end
	end
end
