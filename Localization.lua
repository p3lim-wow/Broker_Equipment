
local _, ns = ...
ns.L = GetLocale() == 'deDE' and {-- Katharsis / copystring
	'Kein set',
	'Klicke links um dein set zu ändern\nKlicke rechts um den GearManager zu öffnen',
	'|cff00ff00Shift-klicke um den set zu aktualisieren\nStrg-klicke um den set zu löschen|r',
} or GetLocale() == 'frFR' and { -- Soeters / Gnaf
	'Pas de set',
	'Clic gauche pour changer d\'équipement\nClic droit pour ouvrir le gestionnaire d\'équipement',
	'|cff00ff00Maj-clic pour mettre à jour le set\nCtrl-clic pour supprimer le set|r',
} or GetLocale() == 'zhCN' and { -- yleaf
	'无套装',
	'左键点击切换套装\n右键打开套装管理器',
	'|cff00ff00Shift点击覆盖套装\nCtrl点击删除套装|r',
} or GetLocale() == 'zhTW' and { -- yleaf
	'無套裝',
	'左鍵點擊切換套裝\n右鍵點擊打開套裝管理器',
	'|cff00ff00Shift點擊覆蓋套裝\nCtrl點擊刪除套裝|r',
} or GetLocale() == 'koKR' and { -- mrgyver
	'세트 없음',
	'좌-클릭 세트 변경\n우-클릭 장비 관리창 열기',
	'|cff00ff00Shift-클릭 하면 세트 업데이트\nCtrl-클릭 하면 세트 삭제|r',
} or {
	'No set',
	'Left-click to change your set\nRight-click to open GearManager',
	'|cff00ff00Shift-click to update set\nCtrl-click to delete set|r',
}
