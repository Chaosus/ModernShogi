namespace ShogiNet
{
    /// <summary>
    /// Сохраненные данные игры.
    /// </summary>
    public class GameData
    {
        public Side HostSide;

        public GameData(Side hostSide)
        {
            HostSide = hostSide;
        }
    }
}
