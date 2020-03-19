using Godot;
using LiteNetLib;
using LiteNetLib.Utils;
using ShogiNet;

public class LiteConnection : Node
{
	static NetManager client;
	static EventBasedNetListener listener;
	static NetPeer server;

	[Signal]
	public delegate void SetGame(int key, bool isRated, bool isProtected, int gameType, string gameName, int handicap, string userName, int playerCount, int observerCount, int turnCount);

	[Signal]
	public delegate void RemoveGame(int key);

	[Signal]
	public delegate void GameListBegin(int count);

	[Signal]
	public delegate void GameListEnd(int count);

	[Signal]
	public delegate void ConnectionSuccess();

	[Signal]
	public delegate void SignUpSuccess();

	[Signal]
	public delegate void SignUpFail(int reason);

	[Signal]
	public delegate void ConnectionFail(int reason);

	[Signal]
	public delegate void AlreadyConnected();

	[Signal]
	public delegate void NetworkError();

	[Signal]
	public delegate void StartSession(bool isObs);
	
	[Signal]
	public delegate void JoinPlayerFail(int gameId, int reason);

	[Signal]
	public delegate void JoinObserverFail(int gameId, int reason);

	[Signal]
	public delegate void CallJoiningDialog();

	[Signal]
	public delegate void DestroyJoiningDialog();

	[Signal]
	public delegate void AddPlayer(int id, int side, string name);

	[Signal]
	public delegate void AddObserver(int id, string name);
	
	[Signal]
	public delegate void GameSuspend(int reason);

	[Signal]
	public delegate void GameActivate();

	[Signal]
	public delegate void GameData(int side, string sfen, string[] history);

	[Signal]
	public delegate void PlayerData(string name, int index, bool is_obs);

	[Signal]
	public delegate void PlayerDataEnd();

	[Signal]
	public delegate void AddRecordString(string record);

	#region UserList

	[Signal]
	public delegate void UserListBegin(int count);

	[Signal]
	public delegate void UserReceived(int id, bool is_online, int account_type, string name, int country, int points, int wins, int losses, int draws);

	[Signal]
	public delegate void UserListEnd();

	#endregion

	[Signal]
	public delegate void PlayerJoined(int index, bool is_obs, string name);

	[Signal]
	public delegate void ReceiveMove(int from_x, int from_y, int to_x, int to_y, bool promotion);

	[Signal]
	public delegate void ReceiveDrop(int side, int type, int to_x, int to_y);

	[Signal]
	public delegate void ReceiveMoveString(string s);

	[Signal]
	public delegate void GameDone(int result, int index);

	[Signal]
	public delegate void Accept(int what);

	[Signal]
	public delegate void Decline(int reason);

	[Signal]
	public delegate void TakebackRequest();

	[Signal]
	public delegate void ShowAccountInfo(string name, int country, int rating, int winCount, int loseCount, int drawCount, int visitCount);

	[Signal]
	public delegate void AcceptChangeAccountInfo(int what);

	[Signal]
	public delegate void DeclineChangeAccountInfo(int what, int reason);

	[Signal]
	public delegate void PlayerWantsToJoin(string name, int id, int avatar, int country, int ratingPoints, int winCount, int loseCount, int drawCount);


	public struct SavedGameData
	{
		public int Id;
		public int GameType;
		public bool IsRated;
		public string GameName;
		public ShogiHandicaps Handicap;
		public Side HostSide;
	}

	public SavedGameData GData;

	public void SetupEventHandlers(Node loginScreen, Node serverScreen, Node accountScreen, Node gameScreen)
	{
		Connect(nameof(SignUpSuccess), loginScreen, "on_signup_success");
		Connect(nameof(SignUpFail), loginScreen, "on_signup_fail");
		Connect(nameof(ConnectionSuccess), loginScreen, "on_connection_success");
		Connect(nameof(ConnectionFail), loginScreen, "on_connection_fail");
		Connect(nameof(AlreadyConnected), loginScreen, "on_already_connected");

		Connect(nameof(NetworkError), serverScreen, "on_network_error");
		Connect(nameof(CallJoiningDialog), serverScreen, "call_joining_dialog");
		Connect(nameof(StartSession), serverScreen, "start_session");
		Connect(nameof(JoinPlayerFail), serverScreen, "join_fail");
		Connect(nameof(JoinObserverFail), serverScreen, "join_obs_fail");
		Connect(nameof(AddPlayer), serverScreen, "add_player");
		Connect(nameof(AddObserver), serverScreen, "add_observer");
		Connect(nameof(GameListBegin), serverScreen, "list_begin");
		Connect(nameof(SetGame), serverScreen, "set_game");
		Connect(nameof(RemoveGame), serverScreen, "remove_game");
		Connect(nameof(GameListEnd), serverScreen, "list_end");
		Connect(nameof(ShowAccountInfo), serverScreen, "show_account_info");
		Connect(nameof(UserListBegin), serverScreen, "user_list_begin");
		Connect(nameof(UserReceived), serverScreen, "user_received");
		Connect(nameof(UserListEnd), serverScreen, "user_list_end");

		Connect(nameof(AcceptChangeAccountInfo), accountScreen, "on_accept_change");
		Connect(nameof(DeclineChangeAccountInfo), accountScreen, "on_decline_change");

		Connect(nameof(PlayerWantsToJoin), gameScreen, "ms_show_joining_dialog");
		Connect(nameof(DestroyJoiningDialog), gameScreen, "ms_destroy_joining_dialog");
		Connect(nameof(Accept), gameScreen, "ms_accept");
		Connect(nameof(Decline), gameScreen, "ms_decline");
		Connect(nameof(GameSuspend), gameScreen, "ms_suspend");
		Connect(nameof(GameActivate), gameScreen, "ms_activate");
		Connect(nameof(PlayerJoined), gameScreen, "ms_player_joined");
		Connect(nameof(GameData), gameScreen, "ms_game_data");
		Connect(nameof(PlayerData), gameScreen, "ms_player_data");
		Connect(nameof(PlayerDataEnd), gameScreen, "ms_player_data_end");
		Connect(nameof(ReceiveMove), gameScreen, "mp_move");
		Connect(nameof(ReceiveDrop), gameScreen, "mp_drop");
		Connect(nameof(ReceiveMoveString), gameScreen, "mp_smove");
		Connect(nameof(GameDone), gameScreen, "mp_gamedone");
		Connect(nameof(TakebackRequest), gameScreen, "ms_takeback");
	}

	public string ClientUserName;

	public string ClientPassword;

	public int ClientCountry;

	public ClientRequest CurrentRequest;

	public string IP;

	public int Port;

	private bool ConnectMode
	{
		get
		{
			return CurrentRequest == ClientRequest.SignUp;
		}
	}
	
	public override void _Ready()
	{
		base._Ready();
	}

	private void Print(string s)
	{
		GD.Print(s);
	}

	private void CreateClient()
	{
		listener = new EventBasedNetListener();

		listener.NetworkErrorEvent += (ep, error) =>
		{
			EmitSignal(nameof(NetworkError), (int)error);
		};

		listener.PeerDisconnectedEvent += (peer, info) =>
		{
			if (peer == server)
			{
				ServerAnswer answer;
				int result = 0;
				info.AdditionalData.TryGetInt(out result);
				answer = (ServerAnswer)result;
				if (!ConnectMode)
				{
					EmitSignal(nameof(ConnectionFail), result);
				}
				else
				{
					if(answer == ServerAnswer.SignUpDone)
					{
						int desc = -1;
						info.AdditionalData.TryGetInt(out desc);
						var resultDesc = (DeclineArg)desc;
						if (resultDesc == DeclineArg.Ok)
						{
							EmitSignal(nameof(SignUpSuccess));
						}
						else
						{
							EmitSignal(nameof(SignUpFail), desc);
						}
					}
				}
			}
		};

		listener.NetworkReceiveEvent += (peer, reader, dmethod) =>
		{
			if (peer == server)
			{
				var what = (ServerAnswer)reader.GetInt();
				switch (what)
				{
					case ServerAnswer.What:
						{
							var writer = new NetDataWriter();
							writer.Put((int)CurrentRequest);
							server.Send(writer, DeliveryMethod.ReliableOrdered);
						}
						break;
					case ServerAnswer.AlreadyConnected:
						EmitSignal(nameof(AlreadyConnected));
						break;
					case ServerAnswer.AccountInfo:
						EmitSignal(nameof(ShowAccountInfo), reader.GetString(), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetInt());
						break;
					case ServerAnswer.SignUpInfo:
						{
							var writer = new NetDataWriter();
							writer.Put((int)ClientRequest.SignUpInfo);
							writer.Put(ClientUserName);
							writer.Put(ClientPassword);
							writer.Put(ClientCountry);
							server.Send(writer, DeliveryMethod.ReliableOrdered);
						}
						break;
					case ServerAnswer.UserInfo:
						{
							var writer = new NetDataWriter();
							writer.Put((int)ClientRequest.UserInfo);
							writer.Put(ClientUserName);
							writer.Put(ClientPassword);
							peer.Send(writer, DeliveryMethod.ReliableOrdered);
						}
						break;
					case ServerAnswer.SignUpDone:
						{
							var reason = (DeclineArg)reader.GetInt();
							if(reason == DeclineArg.Ok)
							{
								EmitSignal(nameof(SignUpSuccess));
							}
							else if(reason == DeclineArg.UserAlreadyExisted)
							{
								EmitSignal(nameof(SignUpFail), (int)reason);
							}
						}
						break;
					case ServerAnswer.LoginDone:
						{
							EmitSignal(nameof(ConnectionSuccess));
						}
						break;
					//case ServerAnswer.GameInfo:
					//    {
					//        var gameType = reader.GetInt();
					//        var isRated = reader.GetBool();
					//        var gameName = reader.GetString();
					//        var handicap = reader.GetInt();
					//        var hostSide = reader.GetInt();
					//        var yourSide = reader.GetInt();

					//        EmitSignal(nameof(CallJoiningDialog), gameType, isRated, gameName, handicap, hostSide, yourSide);
					//    }
					//    break;
					case ServerAnswer.GameData:
						{
							var yourSide = reader.GetInt();
							var sfen = reader.GetString();

							var turnCount = reader.GetInt();
							var history = new string[turnCount];
							for (int i = 0; i < turnCount; i++)
							{
								history[i] = reader.GetString();
							}

							EmitSignal(nameof(GameData), yourSide, sfen, history);

							break;
						}
					case ServerAnswer.PlayerData:
						{
							var playerCount = reader.GetInt();

							for(int i = 0; i < playerCount; i++)
							{
								var name = reader.GetString();
								var side = reader.GetInt();
								EmitSignal(nameof(PlayerData), name, side, false);
							}

							var observerCount = reader.GetInt();

							for (int i = 0; i < observerCount; i++)
							{
								var name = reader.GetString();
								EmitSignal(nameof(PlayerData), name, -1, true);
							}

							EmitSignal(nameof(PlayerDataEnd));
						}
						break;
					// Обработка получения списка пользователей.
					case ServerAnswer.UserList:
						{
							var userCount = reader.GetInt();
							EmitSignal(nameof(UserListBegin), userCount);

							for(int i = 0; i < userCount; i++)
							{
								var id = reader.GetInt();
								var isOnline = reader.GetBool();
								var accountType = reader.GetInt();
								var name = reader.GetString();
								var country = reader.GetInt();
								var points = reader.GetInt();
								var wins = reader.GetInt();
								var losses = reader.GetInt();
								var draws = reader.GetInt();
								EmitSignal(nameof(UserReceived), id, isOnline, accountType, name, country, points, wins, losses, draws);
							}
							EmitSignal(nameof(UserListEnd));
						}
						break;
					case ServerAnswer.NotifyPlayerJoined:
						{
							var index = reader.GetInt();
							var is_obs = reader.GetBool();
							var userName = reader.GetString();
							EmitSignal(nameof(PlayerJoined), index, is_obs, userName);
						}
						break;
					case ServerAnswer.Suspend:
						EmitSignal(nameof(GameSuspend), reader.GetInt());
						break;
					case ServerAnswer.Activate:
						EmitSignal(nameof(GameActivate));
						break;
					case ServerAnswer.NotifyMove:
						EmitSignal(nameof(ReceiveMove), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetBool());
						break;
					case ServerAnswer.NotifyDrop:
						EmitSignal(nameof(ReceiveDrop), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetInt());
						break;
					case ServerAnswer.NotifyMoveString:
						EmitSignal(nameof(ReceiveMoveString), reader.GetString());
						break;
					case ServerAnswer.NotifyGameClosed:
						EmitSignal(nameof(RemoveGame), reader.GetInt());
						break;
					case ServerAnswer.NotifyGameList:
						{
							var count = reader.GetInt();

							EmitSignal(nameof(GameListBegin), count);
							for (int i = 0; i < count; i++)
							{
								var key = reader.GetInt();
								var is_rated = reader.GetBool();
								var is_protected = reader.GetBool();
								var game_type = reader.GetInt();
								var game_name = reader.GetString();
								var handicap = reader.GetInt();
								var username = reader.GetString();
								var player_count = reader.GetInt();
								var obs_count = reader.GetInt();
								var turn_count = reader.GetInt();

								EmitSignal(nameof(SetGame), key, is_rated, is_protected, game_type, game_name, handicap, username, player_count, obs_count, turn_count);
							}
							EmitSignal(nameof(GameListEnd), count);
						}
						break;
					case ServerAnswer.Accept:
						EmitSignal(nameof(Accept), reader.GetInt());
						break;
					case ServerAnswer.Decline:
						EmitSignal(nameof(Decline), reader.GetInt());
						break;
					case ServerAnswer.NotifyChangeStatus:
						{
							EmitSignal(nameof(GameDone), reader.GetInt(), reader.GetInt());
						}
						break;
					case ServerAnswer.TakebackRequest:
						EmitSignal(nameof(TakebackRequest));
						break;
					case ServerAnswer.AcceptChangeAccountData:
						EmitSignal(nameof(AcceptChangeAccountInfo), reader.GetInt());
						break;
					case ServerAnswer.DeclineChangeAccountData:
						EmitSignal(nameof(DeclineChangeAccountInfo), reader.GetInt(), reader.GetInt());
						break;
					case ServerAnswer.JoinedPlayerData:
						EmitSignal(nameof(PlayerWantsToJoin), reader.GetString(), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetInt(), reader.GetInt());
						break;
					case ServerAnswer.AwaitPlayerAccept:
						EmitSignal(nameof(CallJoiningDialog));
						break;
					case ServerAnswer.StopJoining:
						EmitSignal(nameof(DestroyJoiningDialog));
						break;
					case ServerAnswer.AcceptJoinPlayer: // принять игрока
						{
							var gameId = reader.GetInt();

							if(gameId != GData.Id)
							{
								break;
							}

							var is_obs = reader.GetBool();

							EmitSignal(nameof(StartSession), is_obs);
						}
						break;
					case ServerAnswer.DeclineJoinPlayer: // отказать присоединять игрока
						EmitSignal(nameof(JoinPlayerFail), reader.GetInt(), reader.GetInt());
						break;
					case ServerAnswer.DeclineJoinObserver:  // отказать присоединять игрока
						EmitSignal(nameof(JoinObserverFail), reader.GetInt(), reader.GetInt());
						break;
				}
			}
			reader.Recycle();
		};

		client = new NetManager(listener);
	}
	
	public void RequestJoin(int game_key, bool is_obs)
	{
		GData.Id = game_key;

		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.JoinGame);
		writer.Put(game_key);
		writer.Put(is_obs);
		writer.Put((string)null);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestJoinProtected(int game_key, bool is_obs, string password)
	{
		GData.Id = game_key;

		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.JoinGame);
		writer.Put(game_key);
		writer.Put(is_obs);
		writer.Put(password);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	private void StartClient()
	{
		client.Start();
	}

	private void StopClient()
	{
		client.Stop();
	}

	public void SetupAddress(string ip, int port)
	{
		IP = ip;
		Port = port;
	}

	public void SignIn(string name, string password)
	{
		CurrentRequest = ClientRequest.Login;

		ClientUserName = name;
		ClientPassword = password;

		if (client == null)
		{
			CreateClient();
		}
		else
		{
			client.DisconnectPeer(server);
		}

		StartClient();

		server = client.Connect(IP, Port, "mshogi");
	}

	public void SignUp(string name, string password, int country)
	{
		CurrentRequest = ClientRequest.SignUp;

		ClientUserName = name;
		ClientPassword = password;
		ClientCountry = country;

		if (client == null)
		{
			CreateClient();
		}
		else
		{
			client.DisconnectPeer(server);
		}
		StartClient();

		server = client.Connect(IP, Port, "mshogi");
	}

	public void ChangeMode(int mode)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.ChangeMode);
		writer.Put(mode);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestPlayerList()
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.UserList);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestAccountInfo(int accountId)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.AccountInfo);
		writer.Put(accountId);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestCreateGame(int gameType, bool isRated, string gameName, int handicap, int side, string password)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.CreateGame);
		writer.Put(gameType);
		writer.Put(isRated);
		writer.Put(handicap);
		writer.Put(side);
		writer.Put(gameName);
		writer.Put(password);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestCloseGame()
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.CloseGame);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void SendMoveString(string record)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.SendMoveString);
		writer.Put(record);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void SendMove(int piece_type, bool is_promoted, int from_x, int from_y, int to_x, int to_y, bool promotion)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.SendMove);
		writer.Put(piece_type); writer.Put(is_promoted);
		writer.Put(from_x); writer.Put(from_y);
		writer.Put(to_x); writer.Put(to_y);
		writer.Put(promotion);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void SendDrop(int piece_side, int piece_type, int to_x, int to_y)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.SendDrop);
		writer.Put(piece_side); writer.Put(piece_type);
		writer.Put(to_x); writer.Put(to_y);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}
	
	public void SendResult(int result)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.GameResult);
		writer.Put(result);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestGameData()
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.GameData);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestPlayerData()
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.PlayerData);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void DeleteYourself(string password)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.DeleteYourself);
		writer.Put(password);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestTakeback()
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.Takeback);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void NotifyReady()
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.NotifyReady);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public override void _Process(float delta)
	{
		if (client != null)
		{
			if (client.IsRunning)
			{
				client.PollEvents();
			}
		}

		base._Process(delta);
	}
	

	public void Disconnect()
	{
		if (client != null)
		{
			if (client.IsRunning)
			{
				client.Stop();
			}
			client = null;
		}
	}

	public void StopJoining()
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.StopJoining);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void AcceptTakeback()
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.TakebackYes);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void DeclineTakeback()
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.TakebackNo);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestChangePassword(string old_password, string new_password)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.ChangePassword);
		writer.Put(old_password);
		writer.Put(new_password);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void RequestChangeCountry(int tag)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.ChangeCountry);
		writer.Put(tag);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void AcceptJoiningRequest(int joiner)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.AcceptJoiner);
		writer.Put(joiner);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}

	public void DeclineJoiningRequest(int joiner)
	{
		var writer = new NetDataWriter();
		writer.Put((int)ClientRequest.DeclineJoiner);
		writer.Put(joiner);
		server.Send(writer, DeliveryMethod.ReliableOrdered);
	}
}
