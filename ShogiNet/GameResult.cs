namespace ShogiNet
{
    /// <summary>
    /// Результат игры.
    /// </summary>
    public enum GameResult
    {
        None,

        /// <summary>
        /// Обычная сдача партии.
        /// </summary>
        Resign,

        /// <summary>
        /// Разрыв связи.
        /// </summary>
        Disconnect,

        /// <summary>
        /// Неправильный ход.
        /// </summary>
        IllegalMove,

        /// <summary>
        /// Ничья повторами ходов.
        /// </summary>
        Repetition,
        
        PerpetualCheck,
        DeclareWin,
        Checkmate,

        /// <summary>
        /// Выигрыш постановкой короля на место вражеского короля.
        /// </summary>
        TryRule
    }
}
