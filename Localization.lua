--[[
	Localization submitted through CurseForge
	http://wow.curseforge.com/addons/broker_equipment/localization/
--]]

local _, ns = ...
ns.L = GetLocale() == 'deDE' and {
	'Links-Klick um Set zu wechseln',
	'Rechts-Klocl um den Ausrüstungsmanager zu öffnen',
	'|cff00ff00Shift + Links-Klick um Set zu aktualisieren|r',
	'|cff00ff00Strg + Links-Klick um Set zu löschen|r',
} or GetLocale() == 'frFR' and {
	'Clic gauche pour changer d\'équipement',
	'Clic droit pour ouvrir le gestionnaire d\'équipement',
	'|cff00ff00Maj-clic pour mettre à jour le set|r',
	'|cff00ff00Ctrl-clic pour supprimer le set|r',
} or GetLocale() == 'zhCN' and {
	'左键点击切换套装',
	'右键打开套装管理器',
	'|cff00ff00Shift点击覆盖套装|r',
	'|cff00ff00Ctrl点击删除套装|r',
} or GetLocale() == 'zhTW' and {
	'左鍵點擊切換套裝',
	'右鍵點擊打開套裝管理器',
	'|cff00ff00Shift點擊覆蓋套裝|r',
	'|cff00ff00Ctrl點擊刪除套裝|r',
} or GetLocale() == 'koKR' and {
	'좌-클릭 세트 변경',
	'우-클릭 장비 관리창 열기',
	'|cff00ff00Shift-클릭 하면 세트 업데이트|r',
	'|cff00ff00Ctrl-클릭 하면 세트 삭제|r',
} or GetLocale() == 'esES' and {
	'Click izquierdo para cambiar tu set',
	'Click derecho para abrir el Administrador de Equipo',
	'|cff00ff00Shift-click para modificar set|r',
	'|cff00ff00Ctrl-click para eliminar set',
} or GetLocale() == 'esMX' and {
	'Click izquierdo para cambiar tu set',
	'Click derecho para abrir el Administrador de Equipo',
	'|cff00ff00Shift-click para modificar set|r',
	'|cff00ff00Ctrl-click para eliminar set|r',
} or GetLocale() == 'ruRU' and {
	'Левый клик, чтобы изменить комплект',
	'Правый клик, чтобы открыть менеджер экипировки',
	'|cff00ff00Shift-клик, чтобы обновить комплект|r',
	'|cff00ff00Ctrl-клик, чтобы удалить комплект|r',
} or {
	'Left-click to change your set',
	'Right-click to open GearManager',
	'|cff00ff00Shift-click to update set|r',
	'|cff00ff00Ctrl-click to delete set|r',
}
