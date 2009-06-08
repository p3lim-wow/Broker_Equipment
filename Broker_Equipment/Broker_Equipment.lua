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
	L.TOOLTIP1 = 'Left-click to change your set'
	L.TOOLTIP2 = 'Right-click to open GearManager'
	L.HINT = {' ', '|cff00ff00Shift-click to update set|r', '|cff00ff00Ctrl-click to delete set|r'}
elseif(GetLocale() == 'frFR') then -- Soeters
	L.NOSET = 'Pas de set'
	L.TOOLTIP1 = 'Left-click to change your set'
	L.TOOLTIP2 = 'Right-click to open GearManager'
	L.HINT = {' ', '|cff00ff00Maj-clic pour mettre à jour le set|r', '|cff00ff00Ctrl-clic pour supprimer le set|r'}
elseif(GetLocale() == 'zhCN') then -- yleaf
	L.NOSET = '无套装'
	L.TOOLTIP1 = 'Left-click to change your set'
	L.TOOLTIP2 = 'Right-click to open GearManager'
	L.HINT = {' ', '|cff00ff00Shift点击覆盖套装|r', '|cff00ff00Ctrl点击删除套装|r'}
elseif(GetLocale() == 'zhTW') then -- yleaf
	L.NOSET = '無套裝'
	L.TOOLTIP1 = 'Left-click to change your set'
	L.TOOLTIP2 = 'Right-click to open GearManager'
	L.HINT = {' ', '|cff00ff00Shift點擊覆蓋套裝|r', '|cff00ff00Ctrl點擊刪除套裝|r'}
elseif(GetLocale() == 'koKR') then -- mrgyver
	L.NOSET = '세트 없음'
	L.TOOLTIP1 = 'Left-click to change your set'
	L.TOOLTIP2 = 'Right-click to open GearManager'
	L.HINT = {' ', '|cff00ff00Shift-click to update set|r', '|cff00ff00Ctrl-click to delete set|r'}
else
	L.NOSET = 'No set'
	L.TOOLTIP1 = 'Left-click to change your set'
	L.TOOLTIP2 = 'Right-click to open GearManager'
	L.HINT = {' ', '|cff00ff00Shift-click to update set|r', '|cff00ff00Ctrl-click to delete set|r'}
end


local BEQ = CreateFrame('Frame', 'Broker_EquipmentMenu', UIParent, 'UIDropDownMenuTemplate')
BEQ:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)

local failIcon = [=[Interface\Icons\ability_seal]=]
local defaultIcon = [=[Interface\PaperDollInfoFrame\UI-EquipmentManager-Toggle]=]

local menu = {}
local pendingUpdate = true

local broker = LibStub('LibDataBroker-1.1'):NewDataObject('Broker_Equipment', {
	type = 'data source',
	text = L.NOSET,
	icon = defaultIcon,
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

		Broker_EquipmentDB.text = name
		Broker_EquipmentDB.icon = icon
	end
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
		EasyMenu(menu, BEQ, self, 0, 0, 'MENU')

		if(GameTooltip:GetOwner() == self) then GameTooltip:Hide() end
	end
end

function broker:OnTooltipShow()
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine(L.TOOLTIP1)
	self:AddLine(L.TOOLTIP2)
end

function BEQ:ADDON_LOADED(event, addon)
	if(addon ~= 'Broker_Equipment') then return end

	Broker_EquipmentDB = Broker_EquipmentDB or {text = L.NOSET, icon = broker.defaultIcon}
	broker.text = Broker_EquipmentDB.text
	broker.icon = Broker_EquipmentDB.icon

	self:UnregisterEvent(event)
end

function BEQ:EQUIPMENT_SETS_CHANGED()
	pendingUpdate = true
end

function BEQ:VARIABLES_LOADED()
	SetCVar('equipmentManager', 1)
	GearManagerToggleButton:Show()
end

hooksecurefunc('EquipmentManager_EquipSet', function(name)
	if(name) then
		local icon = GetEquipmentSetInfoByName(name)
		-- Blizzard has some odd bug not always returning the whole icon location string
		-- This is a temporary fix around it
		icon = icon:sub(1, 9) ~= 'Interface' and [=[Interface\Icons\]=] .. icon or icon

		broker.text = name
		broker.icon = icon or failIcon
	else
		broker.text = L.NOSET
		broker.icon = defaultIcon
	end
end)

BEQ:RegisterEvent('ADDON_LOADED')
BEQ:RegisterEvent('EQUIPMENT_SETS_CHANGED')
BEQ:RegisterEvent('VARIABLES_LOADED')