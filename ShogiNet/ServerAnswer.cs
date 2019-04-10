namespace ShogiNet
{
    public enum ServerAnswer
    {
        What,
        SignUpInfo,
        SignUpDone,
        AccountInfo,
        UserInfo,
        LoginDone,
        InvalidLogin,
        BannedLogin,
        AlreadyConnected,
        AcceptJoinPlayer,
        DeclineJoinPlayer,
        DeclineJoinObserver,
        SendPlayerInfo,
        AwaitPlayerAccept,
        JoinedPlayerData,
        GameInfo,
        GameData,
        /// <summary>
        /// Сервер возвратил список пользователей.
        /// </summary>
        UserList,
        PlayerData,
        NotifyGameList,
        NotifyPlayerList,
        NotifyGameClosed,
        NotifyPlayerJoined,
        NotifyMove,
        NotifyDrop,
        NotifyMoveString,
        NotifyChangeStatus,
        Suspend,
        Activate,
        GameReady,
        Accept,
        Decline,
        TakebackRequest,
        DeclineChangeAccountData,
        AcceptChangeAccountData,
        StopJoining
    }
}
