extends Node

# Network.gd
# Содержит методы соединяющие игру и удалённый сервер

var connection

var login_screen

var server_screen

var account_screen

var game_instance

var connection_established = false

var saved_username = null

var saved_password = null

func get_username() -> String:
	return saved_username

func get_password() -> String:
	return saved_password

func setup_connection_data(ip:String, port:int) -> void:
	connection.SetupAddress(ip, port)

# Вход на главный сервер
func sign_in(name:String, password:String) -> void:
	saved_username = name
	saved_password = password
	connection.SignIn(name, password)

# Регистрация на главном сервере
func sign_up(name:String, password:String, country:int) -> void:
	connection.SignUp(name, password, country)

# Установка базовых параметров
func setup(connection, login_screen, server_screen, account_screen, game_instance):
	self.connection = connection
	self.login_screen = login_screen
	self.server_screen = server_screen
	self.account_screen= account_screen
	self.game_instance = game_instance
	self.connection.SetupEventHandlers(login_screen, server_screen, account_screen, game_instance)

# Вспомогательная функция вызываемая при успешном соединении с главным сервером
func notify_connect_to_server():
	connection_established = true
	
# Возвращает текущее имя игрока в сети
func get_login_name():
	if connection_established:
		return saved_username
	return null
		
# Разрыв соединения с главным сервером
func disconnect_if_connected():
	if connection_established:
		connection.Disconnect()
		connection_established = false

func request_account_info(id):
	if connection_established:
		connection.RequestAccountInfo(id)

# Посылает запрос на создание игры на главный сервер
func request_create_game(game_type, is_rated, game_name, handicap, side, password):
	if connection_established:
		connection.RequestCreateGame(game_type, is_rated, game_name, handicap, side, password)
	
# Посылает запрос на присоединение к указанной игре на главный сервер
func request_join(key, is_obs):
	if connection_established:
		connection.RequestJoin(key, is_obs)

func request_join_protected(key, is_obs, password):
	if connection_established:
		connection.RequestJoinProtected(key, is_obs, password)

# Посылает сигнал на главный сервер при закрытии активной игры
func request_close_game():
	if connection_established:
		connection.RequestCloseGame()

# Посылает сигнал на получение строки SFEN и истории у главного сервера
func request_game_data():
	if connection_established:
		connection.RequestGameData()
		
# Посылает сигнал на получение данных игроков у главного сервера
func request_player_data():
	if connection_established:
		connection.RequestPlayerData()

# Запрос возврата хода.
func request_takeback():
	if connection_established:
		connection.RequestTakeback()

# Удаление своего аккаунта - доступно всем пользователям
func delete_yourself(password:String) -> void:
	if connection_established:
		connection.DeleteYourself(password)

# Посылает сигнал о готовности на главный сервер
func request_ready() -> void:
	if connection_established:
		connection.NotifyReady()

func request_player_list() -> void:
	if connection_established:
		connection.RequestPlayerList()

func send_move_string(s:String) -> void:
	if connection_established:
		connection.SendMoveString(s)
		
# Посылает ход на главный сервер
func send_move(piece_type:int, is_promoted:bool, from_x:int, from_y:int, to_x:int, to_y:int, promotion:bool) -> void:
	if connection_established:
		connection.SendMove(piece_type, is_promoted, from_x, from_y, to_x, to_y, promotion)
		
# Посылает ход-сброс на главный сервер
func send_drop(side:int, type:int, to_x:int, to_y:int) -> void:
	if connection_established:
		connection.SendDrop(side, type, to_x, to_y)

func send_result(reason:int) -> void:
	if connection_established:
		connection.SendResult(reason)

func send_accept(caller_index:int) -> void:
	if connection_established:
		connection.AcceptRequest(caller_index)

func send_decline(caller_index:int) -> void:
	if connection_established:
		connection.DeclineRequest(caller_index)

func send_accept_takeback() -> void:
	if connection_established:
		connection.AcceptTakeback()
		
func send_decline_takeback() -> void:
	if connection_established:
		connection.DeclineTakeback()

# Принятие другого игрока
func accept_joining_request(user_id:int) -> void:
	if connection_established:
		connection.AcceptJoiningRequest(user_id)
		
# Отклонение другого игрока
func decline_joining_request(user_id:int) -> void:
	if connection_established:
		connection.DeclineJoiningRequest(user_id)

# Остановка присоединения к игре	
func stop_joining():
	if connection_established:
		connection.StopJoining()

# Запросы на изменение данных аккаунта

# Запрос на изменение пароля
func request_change_password(old_password:String, new_password:String) -> void:
	if connection_established:
		connection.RequestChangePassword(old_password, new_password)

# Запрос на изменение страны
func request_change_country(tag:int) -> void:
	if connection_established:
		connection.RequestChangeCountry(tag)

# ENET handlers

var saved_ip
var saved_port

var server_peer
var client_peer

#  Функция создания сервера
func create_server(port):
	
	var setup_screen = UI.get_root().setup_screen
	var loading_screen = UI.get_root().loading_screen
	
	#print("host : " + str(port))
	if server_peer == null:
		server_peer = NetworkedMultiplayerENet.new()
		server_peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_NONE)
	var err = server_peer.create_server(int(port), 1 + 30)
	if err != OK:
		setup_screen.create_click = false
		loading_screen.show_message("DESC_HOST_ERROR", 0)
		if err == ERR_ALREADY_IN_USE:
			loading_screen.show_message("DESC_HOST_ERROR_ALREADY_IN_USE", 1)
		else:
			loading_screen.show_message("DESC_HOST_ERROR2", 1)
		loading_screen.stop_rotating()
		UI.show_back_btn()
		return false
	get_tree().set_network_peer(server_peer)
	return true

#  Функция создания клиента
func create_client(address, port):
	
	var setup_screen = UI.get_root().setup_screen
	var loading_screen = UI.get_root().loading_screen
	
	#print("join : " + address + "," + str(port))
	if client_peer == null:
		client_peer = NetworkedMultiplayerENet.new()
		client_peer.set_target_peer(NetworkedMultiplayerENet.TARGET_PEER_SERVER)
		client_peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_NONE)
	var err = client_peer.create_client(address, port)
	if err != OK:
		setup_screen.create_click = false
		loading_screen.show_message("DESC_JOIN_ERROR", 0)
		if err == ERR_ALREADY_IN_USE:
			loading_screen.show_message("DESC_JOIN_ERROR_ALREADY_IN_USE", 1)
		else:
			loading_screen.show_message("DESC_JOIN_ERROR_SERVER_NOT_ANSWER", 1)
		loading_screen.stop_rotating()
		UI.show_back_btn()
		return false
	Network.saved_ip = address
	Network.saved_port = port
	get_tree().set_network_peer(client_peer)
	return true
	
func reconnect():
	var loading_screen = UI.get_root().loading_screen
	loading_screen.clear_messages()
	loading_screen.show_message(TranslationServer.translate("DESC_JOINING_TO"), 0)
	loading_screen.show_message(Network.saved_ip + " : " + str(Network.saved_port), 1)	
	create_client(Network.saved_ip, Network.saved_port)

func reconnect_from_game():
	var err = client_peer.create_client(Network.saved_ip, Network.saved_port)
	if err != OK:
		return false
	get_tree().set_network_peer(client_peer)
	return true
