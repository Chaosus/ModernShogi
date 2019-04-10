namespace ShogiNet
{
    public enum ClientRequest
    {
        None,
        Login,
        SignUp,
        SignUpInfo,
        AccountInfo,
        UserInfo,
        ChangeMode,
        CreateGame,
        CloseGame,
        HostData,
        JoinGame,
        StopJoining,
        /// <summary>
        /// Запрос на получение полного списка пользователей.
        /// </summary>
        UserList,
        GameStart,
        GameData,
        PlayerData,
        SendMove,
        SendDrop,
        GameResult,
        Takeback,
        TakebackYes,
        TakebackNo,
        SendMoveString,
        NotifyReady,
        ChangeAvatar,
        ChangeCountry,
        ChangePassword,
        DeleteYourself,
        DeleteAccount,
        AcceptJoiner,
        DeclineJoiner
    }
}
