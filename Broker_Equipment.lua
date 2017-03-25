local addonName, L = ...

local QUESTION_MARK_ICON = [[Interface\Icons\INV_MISC_QUESTIONMARK]]
local BACKDROP = {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {top = 3, bottom = 3, left = 3, right = 3}
}

local items, pending = {}
local LDB = LibStub('LibDataBroker-1.1'):NewDataObject('Broker_Equipment', {
	type = 'data source',
})

local Broker_Equipment = CreateFrame('Frame', addonName, UIParent)
Broker_Equipment:RegisterEvent('PLAYER_LOGIN')
Broker_Equipment:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
Broker_Equipment:Hide()

local Fader = Broker_Equipment:CreateAnimationGroup()
Fader:CreateAnimation():SetDuration(UIDROPDOWNMENU_SHOW_TIME)
Fader:SetScript('OnFinished', function()
	Broker_Equipment:Hide()
end)

local function FadePause()
	Fader:Stop()
end

local function FadeOut()
	Fader:Play()
end

function LDB:OnTooltipShow()
	if(Broker_EquipmentDB.showTooltipDisplay) then
		self:SetEquipmentSet(LDB.text)
		self:AddLine(' ')
		self:AddLine(L['|cff33ff33Left-Click|r to open equipment menu.'])
		self:AddLine(L['|cff33ff33Right-Click|r to open character window.'])
	end
end

local hooked = {}
function LDB:OnClick(button)
	if(GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end

	if(button ~= 'RightButton' and GetNumEquipmentSets() > 0) then
		if(Broker_Equipment:IsShown()) then
			Broker_Equipment:Hide()
		else
			Broker_Equipment:Update()
			Broker_Equipment:ClearAllPoints()
			Broker_Equipment:SetPoint('TOP', self, 'BOTTOM') -- temporary anchor

			local sideAnchor = ''
			if(Broker_Equipment:GetRight() > GetScreenWidth()) then
				sideAnchor = 'RIGHT'
			elseif(Broker_Equipment:GetLeft() <= 0) then
				sideAnchor = 'LEFT'
			end

			Broker_Equipment:ClearAllPoints()
			if(Broker_Equipment:GetBottom() <= 0) then
				Broker_Equipment:SetPoint('BOTTOM' .. sideAnchor, self, 'TOP' .. sideAnchor)
			else
				Broker_Equipment:SetPoint('TOP' .. sideAnchor, self, 'BOTTOM' .. sideAnchor)
			end

			Broker_Equipment:Show()
		end

		PlaySound('igMainMenuOptionCheckBoxOn')

		if(not hooked[self]) then
			self:HookScript('OnEnter', FadePause)
			self:HookScript('OnLeave', FadeOut)

			hooked[self] = true
		end
	else
		if(not PaperDollFrame:IsVisible()) then
			ToggleCharacter('PaperDollFrame')
		end

		if(not CharacterFrame.Expanded) then
			SetCVar('characterFrameCollapsed', '0')
			CharacterFrame_Expand()
		end

		if(not _G[PAPERDOLL_SIDEBARS[3].frame]:IsShown()) then
			PaperDollFrame_SetSidebar(nil, 3)
		end
	end
end

local function OnItemClick(self)
	if(IsShiftKeyDown() and not pending) then
		local dialog = StaticPopup_Show('CONFIRM_SAVE_EQUIPMENT_SET', self.name)
		dialog.data = self.name
	elseif(IsControlKeyDown() and not pending) then
		local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', self.name)
		dialog.data = self.name
	else
		if(InCombatLockdown()) then
			Broker_Equipment:RegisterEvent('PLAYER_REGEN_ENABLED')
			pending = self.name

			Broker_Equipment:UpdateDisplay()
		else
			EquipmentManager_EquipSet(pending or self.name)
		end
	end

	Broker_Equipment:Hide()
end

local function OnItemEnter(self)
	if(Broker_EquipmentDB.showTooltipMenu) then
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		GameTooltip:SetEquipmentSet(self.name)

		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(L['|cff33ff33Click|r to equip set.'])
		GameTooltip:AddLine(L['|cff33ff33Shift-Click|r to update set with current equipment.'])
		GameTooltip:AddLine(L['|cff33ff33Ctrl-Click|r to |cffff3333delete|r set.'])
		GameTooltip:Show()
	end

	Fader:Stop()
end

local function OnItemLeave(self)
	GameTooltip_Hide(self)
	Fader:Play()
end

function Broker_Equipment:CreateItem(index)
	local Item = CreateFrame('Button', nil, self)
	Item:SetPoint('TOPLEFT', 11, -((index - 1) * 18) - UIDROPDOWNMENU_BORDER_HEIGHT)
	Item:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	Item:GetHighlightTexture():SetBlendMode('ADD')
	Item:SetScript('OnClick', OnItemClick)
	Item:SetScript('OnEnter', OnItemEnter)
	Item:SetScript('OnLeave', OnItemLeave)

	local Button = CreateFrame('CheckButton', nil, Item)
	Button:SetPoint('LEFT')
	Button:SetSize(16, 16)
	Button:SetNormalTexture([[Interface\Common\UI-DropDownRadioChecks]])
	Button:GetNormalTexture():SetTexCoord(0.5, 1, 0.5, 1)
	Button:SetCheckedTexture([[Interface\Common\UI-DropDownRadioChecks]])
	Button:GetCheckedTexture():SetTexCoord(0, 0.5, 0.5, 1)
	Button:EnableMouse(false)
	Item.Button = Button

	local Label = Item:CreateFontString(nil, nil, 'GameFontHighlightSmall')
	Label:SetPoint('LEFT', 20, 0)
	Item:SetFontString(Label)
	Item.Label = Label

	local Icon = Item:CreateTexture(nil, 'ARTWORK')
	Icon:SetPoint('RIGHT')
	Icon:SetSize(16, 16)
	Item.Icon = Icon

	items[index] = Item

	return Item
end

function Broker_Equipment:Update()
	local maxWidth = 0

	local numEquipmentSets = GetNumEquipmentSets()
	for index = 1, numEquipmentSets do
		local Item = items[index] or self:CreateItem(index)

		local name, icon, _, equipped, _, _, _, missing = GetEquipmentSetInfo(index)
		Item.Button:SetChecked(equipped)
		Item.Icon:SetTexture(icon or [[Interface\Icons\INV_MISC_QUESTIONMARK]])
		Item.name = name
		Item:Show()

		if(pending == name) then
			Item:SetFormattedText('|cffffff00%s|r', name)
		elseif(missing > 0) then
			Item:SetFormattedText('|cffff0000%s|r', name)
		else
			Item:SetText(name)
		end

		local width = Item.Label:GetWidth() + 50
		if(width > maxWidth) then
			maxWidth = width
		end
	end

	for index = numEquipmentSets + 1, #items do
		items[index]:Hide()
	end

	for _, Item in next, items do
		Item:SetSize(maxWidth, 18)
	end

	self:SetSize(maxWidth + 25, (numEquipmentSets * 18) + (UIDROPDOWNMENU_BORDER_HEIGHT * 2))
end

function Broker_Equipment:UpdateDisplay()
	if(InCombatLockdown() and pending) then
		LDB.text = '|cffffff00' .. pending
		LDB.icon = [[Interface\Icons\]] .. GetEquipmentSetInfoByName(pending)
	else
		for index = 1, GetNumEquipmentSets() do
			local name, icon, _, equipped = GetEquipmentSetInfo(index)
			if(equipped) then
				LDB.text = name
				LDB.icon = icon or QUESTION_MARK_ICON
				return
			end
		end

		LDB.text = UNKNOWN
		LDB.icon = QUESTION_MARK_ICON
	end
end

function Broker_Equipment:PLAYER_LOGIN()
	self:RegisterEvent('UNIT_INVENTORY_CHANGED')
	self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
	self.EQUIPMENT_SETS_CHANGED = self.UpdateDisplay


	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0)
	self:SetFrameStrata('DIALOG')
	self:SetScript('OnEnter', FadePause)
	self:SetScript('OnLeave', FadeOut)
	self:UpdateDisplay()
end

function Broker_Equipment:UNIT_INVENTORY_CHANGED(unit)
	if(unit == 'player') then
		self:UpdateDisplay()
	end
end

function Broker_Equipment:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')

	OnItemClick()
	pending = nil
end
