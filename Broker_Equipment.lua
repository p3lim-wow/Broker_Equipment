--[[

	Copyright (c) 2009 Adrian L Lange <adrianlund@gmail.com>
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local LDB
local pendingName
local pendingIcon

local menu = {}
local localization = select(2, ...).L
local parent = CreateFrame('Frame')

local function EquipmentLocated(name)
	for slot, location in pairs(GetEquipmentSetLocations(name)) do
		local located = true
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

local function UpdateDisplay()
	if(InCombatLockdown() and pendingName) then
		LDB.text = '|cffff0000'..pendingName
		LDB.icon = pendingIcon
	else
		for index = 1, GetNumEquipmentSets() do
			local name, icon = GetEquipmentSetInfo(index)
			if(EquipmentLocated(name)) then
				LDB.text = name
				LDB.icon = icon
				return
			else
				LDB.text = UNKNOWN
				LDB.icon = [=[Interface\Icons\INV_Misc_QuestionMark]=]
			end
		end
	end
end

local function ModifiedClick(button, name, icon)
	if(IsShiftKeyDown() and not pendingName) then
		local dialog = StaticPopup_Show('CONFIRM_SAVE_EQUIPMENT_SET', name)
		dialog.data = name
	elseif(IsControlKeyDown() and not pendingName) then
		local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', name)
		dialog.data = name
	else
		EquipmentManager_EquipSet(name)

		if(InCombatLockdown()) then
			parent:RegisterEvent('PLAYER_REGEN_ENABLED')

			pendingName = name
			pendingIcon = icon
			UpdateDisplay()
		end
	end
end

local function OnTooltipShow(self)
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine('|cff00ff00<' .. localization['Left-click'] .. '>|r')
	self:AddLine('|cff00ff00<' .. localization['Right-click'] .. '>|r')
end

local function OnClick(self, button)
	if(GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end

	if(button ~= 'RightButton' and GetNumEquipmentSets() > 0) then
		ToggleDropDownMenu(1, nil, parent, self, 0, 0)
	else
		if(not PaperDollFrame:IsVisible()) then
			ToggleCharacter('PaperDollFrame')
		end

		if(not CharacterFrame.Expanded) then
			SetCVar('characterFrameCollapsed', '0')
			CharacterFrame_Expand()
		end

		if(not _G[PAPERDOLL_SIDEBARS[3].frame]:IsShown()) then
			parent:Show() -- XXX: Temporary fix
		end
	end
end

local function CreateMenu()
	menu = wipe(menu)
	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		menu.func = ModifiedClick
		menu.text = string.format('%s%s', pendingName and pendingName == name and '|cffff0000' or '', name)
		menu.icon = icon
		menu.arg1 = name
		menu.arg2 = icon
		menu.checked = EquipmentLocated(name)

		UIDropDownMenu_AddButton(menu)
	end

	menu = wipe(menu)
	menu.notCheckable = true

	menu.text = '|cff00ff00<' .. localization['Shift-click'] .. '>|r'
	UIDropDownMenu_AddButton(menu)

	menu.text = '|cff00ff00<' .. localization['Ctrl-click'] .. '>|r'
	UIDropDownMenu_AddButton(menu)
end

function parent:PLAYER_LOGIN()
	LDB = LibStub('LibDataBroker-1.1'):NewDataObject('Broker_Equipment', {
		icon = [=[Interface\PaperDollInfoFrame\UI-EquipmentManager-Toggle]=],
		iconCoords = {0.08, 0.92, 0.08, 0.92},
		text = 'Broker Equipment',
		type = 'data source',
		OnTooltipShow = OnTooltipShow,
		OnClick = OnClick,
	})

	self:RegisterEvent('UNIT_INVENTORY_CHANGED')
	self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
	self.EQUIPMENT_SETS_CHANGED = UpdateDisplay

	self.initialize = CreateMenu
	self.displayMode = 'MENU'

	UpdateDisplay()
end

function parent:UNIT_INVENTORY_CHANGED(unit)
	if(unit == 'player') then
		UpdateDisplay()
	end
end

function parent:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	ModifiedClick(nil, pendingName, pendingIcon)
	pendingName, pendingIcon = nil, nil
end

parent:SetScript('OnUpdate', function(self)
	PaperDollFrame_SetSidebar(nil, 3)
	self:Hide()
end)

parent:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
parent:RegisterEvent('PLAYER_LOGIN')
parent:Hide()
