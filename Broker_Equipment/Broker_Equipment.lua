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
	L.HINTS = {' ', '|cff00ff00Shift-klicke um den set zu aktualisieren\nStrg-klicke um den set zu löschen|r'}
elseif(GetLocale() == 'frFR') then -- Soeters / Gnaf
	L.NOSET = 'Pas de set'
	L.TOOLTIP = 'Clic gauche pour changer d\'équipement\nClic droit pour ouvrir le gestionnaire d\'équipement'
	L.HINTS = {' ', '|cff00ff00Maj-clic pour mettre à jour le set\nCtrl-clic pour supprimer le set|r'}
elseif(GetLocale() == 'zhCN') then -- yleaf
	L.NOSET = '无套装'
	L.TOOLTIP = '左键点击切换套装\n右键打开套装管理器'
	L.HINTS = {' ', '|cff00ff00Shift点击覆盖套装\nCtrl点击删除套装|r'}
elseif(GetLocale() == 'zhTW') then -- yleaf
	L.NOSET = '無套裝'
	L.TOOLTIP = '左鍵點擊切換套裝\n右鍵點擊打開套裝管理器'
	L.HINTS = {' ', '|cff00ff00Shift點擊覆蓋套裝\nCtrl點擊刪除套裝|r'}
elseif(GetLocale() == 'koKR') then -- mrgyver
	L.NOSET = '세트 없음'
	L.TOOLTIP = '좌-클릭 세트 변경\n우-클릭 장비 관리창 열기'
	L.HINTS = {' ', '|cff00ff00Shift-클릭 하면 세트 업데이트\nCtrl-클릭 하면 세트 삭제|r'}
else
	L.NOSET = 'No set'
	L.TOOLTIP = 'Left-click to change your set\nRight-click to open GearManager'
	L.HINTS = {' ', '|cff00ff00Shift-click to update set\nCtrl-click to delete set|r'}
end


local menu = {}
local pendingUpdate = true
local pendingName = nil

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

local function matchEquipped(name)
	for k, v in next, GetEquipmentSetItemIDs(name) do
		local link = GetInventoryItemLink('player', k)
		if(link) then
			local id = tonumber(string.match(link, 'item:(%d+)'))
			if(id ~= v) then
				return
			end
		else
			if(v ~= 0) then
				return
			end
		end
	end

	return true
end

local function handleClick(name, icon)
	if(IsShiftKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_OVERWRITE_EQUIPMENT_SET', name)
		dialog.selectedIcon = GetTextureIndex(icon) -- Blizzard sucks
		dialog.data = name
		return
	elseif(IsControlKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', name)
		dialog.data = name
		return
	elseif(InCombatLockdown()) then
		pendingName = name
		addon:RegisterEvent('PLAYER_REGEN_ENABLED')
	end

	EquipmentManager_EquipSet(name)
end

local function updateInfo(name, icon)
	broker.text = InCombatLockdown() and '|cffff0000'..name or name
	broker.icon = icon

	Broker_EquipmentDB.text = name
	Broker_EquipmentDB.icon = icon
end

local function updateMenu()
	pendingUpdate = nil
	menu = wipe(menu)

	local temp = {text = '|cff0090ffBroker Equipment|r\n', isTitle = true}
	table.insert(menu, temp)

	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		temp = {
			notCheckable = true,
			text = name,
			icon = icon,
			func = function() handleClick(name, icon) end
		}
		table.insert(menu, temp)
	end

	for index = 1, 2 do
		temp = {
			text = L.HINTS[index],
			notCheckable = true,
			disabled = true
		}
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
	self:AddLine(L.TOOLTIP)
end

function addon:PLAYER_REGEN_ENABLED(event)
	EquipmentManager_EquipSet(pendingName)
	pendingName = nil
	self:UnregisterEvent(event)
end

function addon:ADDON_LOADED(event, addon)
	if(addon ~= 'Broker_Equipment') then return end

	Broker_EquipmentDB = Broker_EquipmentDB or {text = L.NOSET, icon = broker.icon}
	broker.text = Broker_EquipmentDB.text
	broker.icon = Broker_EquipmentDB.icon

	self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
--	self:RegisterEvent('EQUIPMENT_SWAP_FINISHED') -- 3.2
	self:RegisterEvent('UNIT_INVENTORY_CHANGED') -- experimental
	self:RegisterEvent('VARIABLES_LOADED')
	self:UnregisterEvent(event)
end

function addon:EQUIPMENT_SETS_CHANGED()
	pendingUpdate = true
end
--[[
-- new event in 3.2, needs more testing vs UIC
function addon:EQUIPMENT_SWAP_FINISHED(event, completed, setName)
	if(completed) then
		for index = 1, GetNumEquipmentSets() do
			local name, icon = GetEquipmentSetInfo(index)
			if(name == setName) then
				updateInfo(name, icon)
				break
			end
		end
	end
end
--]]
function addon:UNIT_INVENTORY_CHANGED(event, unit)
	if(unit ~= 'player') then return end

	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		if(matchEquipped(name)) then
			updateInfo(name, icon)
			break
		else
			updateInfo(UNKNOWN, [=[Interface\Icons\INV_Misc_QuestionMark]=])
		end
	end
end

function addon:VARIABLES_LOADED()
	SetCVar('equipmentManager', 1)
	GearManagerToggleButton:Show()
end

addon:RegisterEvent('ADDON_LOADED')
addon:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)