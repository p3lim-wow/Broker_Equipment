--[[
	Localization submitted through CurseForge
	http://wow.curseforge.com/addons/broker_equipment/localization/
--]]

local _, ns = ...
ns.L = GetLocale() == 'deDE' and {
	'Kein set',
	'Links-Klick um Set zu wechseln\nRechts-Klocl um den Ausrüstungsmanager zu öffnen',
	'|cff00ff00Shift + Links-Klick um Set zu aktualisieren\nStrg + Links-Klick um Set zu löschen|r',
} or GetLocale() == 'frFR' and {
	'Pas de set',
	'Clic gauche pour changer d\'équipement\nClic droit pour ouvrir le gestionnaire d\'équipement',
	'|cff00ff00Maj-clic pour mettre à jour le set\nCtrl-clic pour supprimer le set|r',
} or GetLocale() == 'zhCN' and {
	'无套装',
	'左键点击切换套装\n右键打开套装管理器',
	'|cff00ff00Shift点击覆盖套装\nCtrl点击删除套装|r',
} or GetLocale() == 'zhTW' and {
	'無套裝',
	'左鍵點擊切換套裝\n右鍵點擊打開套裝管理器',
	'|cff00ff00Shift點擊覆蓋套裝\nCtrl點擊刪除套裝|r',
} or GetLocale() == 'koKR' and {
	'세트 없음',
	'좌-클릭 세트 변경\n우-클릭 장비 관리창 열기',
	'|cff00ff00Shift-클릭 하면 세트 업데이트\nCtrl-클릭 하면 세트 삭제|r',
} or GetLocale() == 'esES' and {
	'Sin set',
	'Click izquierdo para cambiar tu set\nClick derecho para abrir el Administrador de Equipo',
	'|cff00ff00Shift-click para modificar set\nCtrl-click para eliminar set',
} or GetLocale() == 'esMX' and {
	'Sin set',
	'Click izquierdo para cambiar tu set\nClick derecho para abrir el Administrador de Equipo',
	'|cff00ff00Shift-click para modificar set\nCtrl-click para eliminar set',
} or GetLocale() == 'ruRU' and {
	'Нет комплекта',
	'Левый клик, чтобы изменить комплект\nПравый клик, чтобы открыть менеджер экипировки',
	'|cff00ff00Shift-клик, чтобы обновить комплект\nCtrl-клик, чтобы удалить комплект',
} or {
	'No set',
	'Left-click to change your set\nRight-click to open GearManager',
	'|cff00ff00Shift-click to update set\nCtrl-click to delete set|r',
}
