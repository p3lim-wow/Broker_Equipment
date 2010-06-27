--[[

	Copyright (c) 2009 Adrian L Lange <adrianlund@gmail.com>
	All rights reserved.

	You're allowed to use this addon, free of monetary charge,
	but you are not allowed to modify, alter, or redistribute
	this addon without express, written permission of the author.

--]]

local addonName, ns = ...

local pending = {}
local addon = CreateFrame('Frame', addonName)
local broker = LibStub('LibDataBroker-1.1'):NewDataObject(addonName, {
	iconCoords = {0.08, 0.92, 0.08, 0.92},
	type = 'data source'
})

-- Borrowed from tekkub's EquipSetUpdater (modified)
-- We really need a proper API for this
local function GetTextureIndex(tex)
	RefreshEquipmentSetIconInfo()
	tex = tex:lower()
	local numicons = GetNumMacroIcons()
	for i=INVSLOT_FIRST_EQUIPPED,INVSLOT_LAST_EQUIPPED do if GetInventoryItemTexture("player", i) then numicons = numicons + 1 end end
	for i=1,numicons do
		local texture, index = GetEquipmentSetIconInfo(i)
		if texture and texture:lower() == tex then return index end
	end
	return 1
end

local function ModifiedClick(button, name, icon)
	if(IsShiftKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_OVERWRITE_EQUIPMENT_SET', name)
		dialog.data = name
		dialog.selectedIcon = GetTextureIndex(icon)
	elseif(IsControlKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', name)
		dialog.data = name
	else
		EquipmentManager_EquipSet(name)

		if(InCombatLockdown()) then
			pending.name, pending.icon = name, icon
			addon:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end
end

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

function broker:OnTooltipShow()
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine(ns.L[1])
	self:AddLine(ns.L[2])
end

function broker:OnClick(button)
	if(button ~= 'RightButton' and GetNumEquipmentSets() > 0) then
		ToggleDropDownMenu(1, nil, addon, self, 0, 0)
	else
		local paperdoll = PaperDollFrame:IsVisible()
		if(not paperdoll) then
			ToggleCharacter('PaperDollFrame')
			GearManagerDialog:Show()
		elseif(paperdoll and not GearManagerDialog:IsVisible()) then
			GearManagerDialog:Show()
		end
	end
end

function addon:initialize(...)
	local info = wipe(self.info)
	info.isTitle = 1
	info.notCheckable = 1
	info.text = '|cff0090ffBroker Equipment|r\n '
	UIDropDownMenu_AddButton(info, ...)

	wipe(info)
	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		info.text = '|T'..icon..':20|t '..name
		info.arg1 = name
		info.arg2 = icon
		info.func = ModifiedClick
		info.checked = EquipmentLocated(name) or pending.name and pending.name == name
		UIDropDownMenu_AddButton(info, ...)
	end

	if(SHOW_NEWBIE_TIPS == '1') then
		wipe(info)
		info.disabled = 1
		info.notCheckable = 1

		info.text = ns.L[3]
		UIDropDownMenu_AddButton(info, ...)

		info.text = ns.L[4]
		UIDropDownMenu_AddButton(info, ...)
	end
end

function addon:PLAYER_LOGIN()
	self.info = {}
	self.displayMode = 'MENU'
	self:RegisterEvent('UNIT_INVENTORY_CHANGED')
	self:RegisterEvent('VARIABLES_LOADED')
	self:UNIT_INVENTORY_CHANGED()
end

function addon:ADDON_LOADED(name, event)
	if(name == addonName) then
		self:UnregisterEvent(event)
		self:PLAYER_LOGIN()
	end
end

function addon:UNIT_INVENTORY_CHANGED(unit, event)
	if(unit and unit ~= 'player') then return end

	if(InCombatLockdown() and pending.name) then
		broker.text = '|cffff0000'..pending.name
		broker.icon = pending.icon
	else
		for index = 1, GetNumEquipmentSets() do
			local name, icon = GetEquipmentSetInfo(index)
			if(EquipmentLocated(name)) then
				broker.text = name
				broker.icon = icon
				return
			else
				broker.text = UNKNOWN
				broker.icon = [=[Interface\Icons\INV_Misc_QuestionMark]=]
			end
		end
	end
end

function addon:PLAYER_REGEN_ENABLED(event)
	ModifiedClick(nil, pending.name, pending.icon)
	self:UnregisterEvent(event)
	pending = {}
end

function addon:VARIABLES_LOADED(var, event)
	SetCVar('equipmentManager', 1)
	GearManagerToggleButton:Show()
	self:UnregisterEvent(event)
end

addon:RegisterEvent(IsAddOnLoaded('AddonLoader') and 'ADDON_LOADED' or 'PLAYER_LOGIN')
addon:SetScript('OnEvent', function(self, event, ...) self[event](self, ..., event) end)
