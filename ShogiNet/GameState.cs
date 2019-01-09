namespace ShogiNet
{
    /// <summary>
    /// Возможные результаты партии.
    /// </summary>
    public enum GameState
    {
        /// <summary>
        /// Игра приостановлена - не все игроки присоединены. 
        /// </summary>
        Suspended,

        /// <summary>
        /// Игра в процессе.
        /// </summary>
        Ok,

        /// <summary>
        /// Игра закончена - проигрыш одного из игроков.
        /// </summary>
        Resign,

        /// <summary>
        /// Игра закончена - ничья.
        /// </summary>
        Draw
    }
}
