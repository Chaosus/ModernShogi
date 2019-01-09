namespace ShogiNet
{
    public enum DeclineArg
    {
        InvalidCommand = -2,
        Unknown = -1,
        Ok,
        Full,
        Joining,
        Disconnection,
        UserAlreadyExisted,
        UserNotExist,
        UserCancelTakeback,
        GameNotStarted,
        GameIsDone,
        GameNotExist,
        PasswordIsIncorrect,
        MalformedNameData,
        MalformedPasswordData,
        MalformedData,
        OtherPlayerInJoinProcess
    }
}
