--[[

 Copyright (c) 2009, Adrian L Lange
 All rights reserved.

 You're allowed to use this addon, free of monetary charge,
 but you are not allowed to modify, alter, or redistribute
 this addon without express, written permission of the author.

--]]

local L = {}
if(GetLocale() == 'deDE') then
	L.TOOLTIP = 'Klicke hier um das set zu wechsein'
	L.NOSET = 'Kein set'
elseif(GetLocale() == 'frFR') then
	L.TOOLTIP = 'Cliquez ici pour changer de set'
	L.NOSET = 'Pas de set'
elseif(GetLocale() == 'zhCN') then
	L.TOOLTIP = '点击选择套装'
	L.NOSET = '无套装'
elseif(GetLocale() == 'zhTW') then
	L.TOOLTIP = '點擊選擇套裝'
	L.NOSET = '無套裝'
else
	L.TOOLTIP = 'Click here to change your set'
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


local function equipSet(name, icon)
	EquipmentManager_EquipSet(name)

	if(InCombatLockdown()) then
		pendingName = name
		broker.text = '|cffff0000'..name
	else
		broker.text = name
	end

	broker.icon = icon
	EquipmentDB.text = name
	EquipmentDB.icon = icon
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
		info.func = function() equipSet(name, icon) end

		menuList[index] = info
	end

	table.sort(menuList, function(a, b) return a.index < b.index end)
	UIDropDownMenu_Initialize(addon, initDropDown, 'MENU')
	pendingUpdate = nil
end

local function onEvent(self, event, arg1)
	if(event == 'PLAYER_REGEN_ENABLED') then
		if(pendingName) then
			broker.text = pendingName
			pendingName = nil
		end
	elseif(event == 'EQUIPMENT_SETS_CHANGED') then
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
	if(button == 'RightButton') then
		-- open the frame
		ToggleCharacter('PaperDollFrame')

		if(PaperDollFrame:IsShown()) then
			
		end
		-- now click the damn button
	else
		if(GameTooltip:GetOwner() == self) then
			GameTooltip:Hide()
		end

		if(pendingUpdate) then
			createDropDown()
		end

		ToggleDropDownMenu(1, nil, addon, self, 0, 0)
	end
end

function broker:OnTooltipShow()
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine(L.TOOLTIP)
end


addon:RegisterEvent('ADDON_LOADED')
addon:RegisterEvent('PLAYER_REGEN_ENABLED')
addon:RegisterEvent('EQUIPMENT_SETS_CHANGED')
addon:SetScript('OnEvent', onEvent)