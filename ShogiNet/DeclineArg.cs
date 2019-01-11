namespace ShogiNet
{
    /// <summary>
    /// Причины отказа.
    /// </summary>
    public enum DeclineArg
    {
        /// <summary>
        /// Неправильная команда.
        /// </summary>
        InvalidCommand = -2,

        /// <summary>
        /// Неизвестная причина.
        /// </summary>
        Unknown = -1,

        /// <summary>
        /// Нет отказа.
        /// </summary>
        Ok,

        /// <summary>
        /// Игра или группа заполнена.
        /// </summary>
        Full,
        
        /// <summary>
        /// Прямой отказ другого игрока.
        /// </summary>
        Direct,

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

        /// <summary>
        /// Игра или группа уже в процессе присоединения другого игрока.
        /// </summary>
        OtherPlayerInJoinProcess
    }
}
