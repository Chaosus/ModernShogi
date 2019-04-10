extends CanvasLayer

# Game handlers

var game
var is_mp

# Сигналы

signal fade_completed

onready var box = $Box

# Диалоги

onready var leave_dialog = $Box/LeavePopup
onready var promotion_dialog = $Box/PromotionDialog
onready var resign_dialog = $Box/ResignDialog
onready var gameover_dialog = $Box/GameOverDialog
onready var save_dialog = $Box/SaveDialog
onready var takeback_dialog = $Box/TakebackDialog
onready var ssd_dialog = $Box/ServerSDDialog
onready var leave_forced_dialog = $Box/LeavePopup2

# Панели

onready var history_panel = $Box/HistoryPanel
onready var ai_log_panel = $Box/AILog
onready var piece_style_panel = $Box/PieceStylesPanel

# Инфо-вставки

onready var infopanel = $Box/PopupList
onready var check_popup = $Box/PopupList/CC1/CheckPopup
onready var await_answer_popup = $Box/PopupList/CC2/AwaitAnswerPopup
onready var await_answer_disconnected = $Box/PopupList/CC2/AwaitAnswerDisconnectedPopup
onready var await_answer_gameover = $Box/PopupList/CC2/AwaitAnswerGameOverPopup
onready var takeback_yes_popup = $Box/PopupList/CC3/TakebackYes
onready var takeback_no_popup = $Box/PopupList/CC4/TakebackNo
onready var replaydone_popup = $Box/PopupList/CC5/ReplayDonePanel
onready var connected_popup = $Box/PopupList/CC7/ConnectedPopup
onready var disconnected_popup = $Box/PopupList/CC6/DisconnectPanel
onready var connected_obs_popup = $Box/PopupList/CC8/ObsConnectedPopup
onready var disconnected_obs_popup = $Box/PopupList/CC9/ObsDisconnectedPopup
onready var reconnected_popup = $Box/PopupList/CC10/ReconnectedPopup

# Правые кнопки

onready var save_btn = $Box/RightGameBar/VBox/SaveButton
onready var history_btn = $Box/RightGameBar/VBox/HistoryButton
onready var right_hide_btn = $Box/RightGameBar/VBox/RightHideWidget

# Разное

onready var await_label = $Box/AwaitLabel
onready var save_edit = $Box/SaveDialog/VBoxContainer/HBoxSave/SavePathEdit
onready var save_edit2 = $Box/GameOverDialog/VBox/VBox/HBoxSave/SavePathEdit

func setup(game):
	self.game = game
	self.is_mp = game.session.is_multiplayer()
	history_panel.mp_mode = is_mp

func get_dialog(dialog):
	match dialog:
		UI.GUI_DLG_LEAVE:
			dialog = leave_dialog
		UI.GUI_DLG_LEAVE2:
			dialog = leave_forced_dialog
		UI.GUI_DLG_PROMOTION:
			dialog = promotion_dialog
		UI.GUI_DLG_RESIGN:
			dialog = resign_dialog
		UI.GUI_DLG_GAMEOVER:
			dialog = gameover_dialog
		UI.GUI_DLG_SAVE:
			dialog = save_dialog
		UI.GUI_DLG_TAKEBACK:
			dialog = takeback_dialog
		UI.GUI_DLG_SERVER_SHUTDOWN:
			dialog = ssd_dialog
	return dialog

# Кнопки

func _on_SaveButton_pressed():
	var prefix = "mp_" if is_mp else "sp_"
	var counter = Utility.get_file_count("user://Library/Replays/MKIF", prefix)
	save_edit.text = prefix + str(counter)
	show_dialog(UI.GUI_DLG_SAVE)

func _on_HistoryButton_pressed():
	if history_panel.get_show_state() == BeautyElement.ShowState.NONE:
		history_panel.beautiful_hide()
		UI.history_was_visible = false
	elif history_panel.get_show_state() == BeautyElement.ShowState.HIDDEN:
		history_panel.beautiful_show()
		UI.history_was_visible = true

# Кнопки панели AI

func _on_AISettingsButton_pressed():
	UI.get_root().open_ai_settings()

func _on_StylesSettingsButton_pressed():
	UI.get_root().open_styles_settings()

func _on_AIRestart_pressed():
	game.reinit_ai(true)
	
func _on_AIHint_pressed():
	game.hint()

# Диалог превращения

func show_promotion_dialog(piece):
	game.nest_select_lock = true
	if piece != null:
		promotion_dialog.get_node("VBox/HBox/VBox/UnpromotionBtn/Sprite").texture = piece.piece_template.get_texture()
		promotion_dialog.get_node("VBox/HBox/VBox/Label").text = piece.piece_template.name
		promotion_dialog.get_node("VBox/HBox/VBox3/PromotionBtn/Sprite").texture = piece.piece_template.get_texture()
		promotion_dialog.get_node("VBox/HBox/VBox3/Label").text = piece.piece_template.promoted_name
	if promotion_dialog.get_show_state() == 0:
		yield(promotion_dialog.beautiful_hide(), "fade_completed")
	elif promotion_dialog.get_show_state() == 1:
		yield(promotion_dialog.beautiful_show(), "fade_completed")
	return promotion_dialog

func get_promotion_dialog():
	return promotion_dialog

func get_promotion_dialog_result():
	return promotion_dialog.result
	
# Диалог выхода из текущей сессии и перехода в главное меню

func _on_LeaveYesButton_pressed():
	hide_dialog(UI.GUI_DLG_LEAVE)
	await_label.hide()
	game.leave()

func _on_LeaveOK_pressed():
	leave_forced_dialog.hide()
	await_label.hide()
	game.leave()
	
func _on_LeaveNoButton_pressed():
	hide_dialog(UI.GUI_DLG_LEAVE)

# Диалог окончания игры

func _on_ContinueButton_pressed():
	hide_dialog(gameover_dialog)

func _on_LeaveButton_pressed():
	hide_dialog(gameover_dialog)
	game.save_current_game(save_edit2.text, ReplayParser.ReplayFormat.KIF_MODERNSHOGI)
	game.leave()

# Предупреждение о завершении работы сервера на стороне клиента

func _on_ServerSDOkButton_pressed():
	hide_dialog(UI.GUI_DLG_SERVER_SHUTDOWN)

# Диалог сдачи партии

func _on_ResignYesButton_pressed():
	hide_dialog(UI.GUI_DLG_RESIGN)
	game.resign_host()

func _on_ResignNoButton_pressed():
	hide_dialog(UI.GUI_DLG_RESIGN)

# Диалог возврата хода

func _on_TakebackYesButton_pressed():
	hide_dialog(UI.GUI_DLG_TAKEBACK)
	show_await_label(false, "DESC_AWAITING", true)
	history_panel.history_back(false, true)
	history_panel.erase_next_moves()
	game.takeback_accept()

func _on_TakebackNoButton_pressed():
	hide_dialog(UI.GUI_DLG_TAKEBACK)
	game.takeback_cancel()

# Диалог сохранения игры

func _on_SaveOkButton_pressed():
	game.save_current_game(save_edit.text, ReplayParser.ReplayFormat.KIF_MODERNSHOGI)
	hide_dialog(UI.GUI_DLG_SAVE)

func _on_SaveCancelButton_pressed():
	hide_dialog(UI.GUI_DLG_SAVE)

# История

func get_history_log():
	return history_panel.history.get_log()

func update_history_panel():
	if Profiles.get_current_settings().get_value(Settings.SV_HISTORY_AUTOSHOW_ENABLED):
		if history_panel.get_show_state() == BeautyElement.ShowState.HIDDEN:
			history_panel.update_panel_position(false)
			history_panel.show()
			UI.history_was_visible = true

func add_history_record(record, increase_selection):
	history_panel.add_record(record, increase_selection)

func get_history_record_count():
	return history_panel.get_record_count()

func history_has_focus() -> bool:
	return history_panel.has_focus()

func history_erase_next_moves() -> void:
	history_panel.erase_next_moves()

func enable_playback_revert_button(toggled):
	history_panel.enable_playback_revert_button(toggled)
	
# Разное

func beautiful_hide():
	
	ai_log_panel.beautiful_hide()
	UI.game_left_hbar.beautiful_hide()
	UI.game_right_hbar.beautiful_hide()
	
	yield(history_panel.beautiful_hide(), "fade_completed")
	
	if UI.game_right_bar.get_show_state() == BeautyElement.ShowState.HIDDEN:
		yield(UI.get_left_bar().beautiful_hide(), "fade_completed")
	else:
		UI.get_left_bar().beautiful_hide()
		yield(UI.game_right_bar.beautiful_hide(), "fade_completed")
	
	emit_signal("fade_completed")
	return self

func set_visible(visible):
	$Box.visible = visible
	
func cleanup():
	promotion_dialog.beautiful_hide()
	gameover_dialog.beautiful_hide()
	infopanel.beautiful_hide()
	history_panel.clear()
	
func show_await_label(show, text, blink):
	await_label.visible = show
	await_label.text = text
	await_label.set_blink(blink)

func show_dialog(dialog):
	var t = dialog
	dialog = get_dialog(dialog)
	UI.dialog_visible = true
	if dialog is BeautyElement:
		dialog.beautiful_show()
	else:
		dialog.show()

func hide_dialog(dialog):
	dialog = get_dialog(dialog)
	if dialog is BeautyElement:
		yield(dialog.beautiful_hide(), "fade_completed")
	else:
		dialog.hide()
	UI.dialog_visible = false

# Кнопки стилей фигур

func _on_PSKanjiButton_pressed():
	game.set_piece_theme(Games.PieceThemeName.KANJI)

func _on_PSSymbolicButton_pressed():
	game.set_piece_theme(Games.PieceThemeName.SYMBOLIC)

func _on_PSWesternButton_pressed():
	game.set_piece_theme(Games.PieceThemeName.WESTERN)

func _on_PSKanji2Button_pressed():
	game.set_piece_theme(Games.PieceThemeName.KANJI2)

func open_ps_panel():
	piece_style_panel.show_or_hide()

func _on_PieceStylesButton_pressed():
	open_ps_panel()

func _on_PlayerInfoButton_pressed():
	$WhitePlayerPanel.show_or_hide()
	$BlackPlayerPanel.show_or_hide()
