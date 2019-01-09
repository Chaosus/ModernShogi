using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

public static class UCIEngine
{
	/// <summary>
	/// Означает что движок инициализирован.
	/// </summary>
	public static bool IsReady { get; private set; } = false;
	
    public enum ThinkingMode
    {
        None,
        Move,
        Hint
    }

	/// <summary>
	/// Режим текущего размышления AI.
	/// </summary>
	public static ThinkingMode Thinking { get; private set; }

	/// <summary>
	/// Папка процесса.
	/// </summary>
	public static string ProcessFolder { get; private set; }

	/// <summary>
	/// Имя процесса.
	/// </summary>
	public static string ProcessName { get; private set; }

	/// <summary>
	/// Процесс.
	/// </summary>
	public static Process Process { get; private set; }

	public enum ConfigType
	{
		BlackPlayerVsCPU,
		WhitePlayerVsCPU,
		CPUVsCPU
	}

	#region Опции

	public enum OptionType
	{ 
		Check,
		Spin,
		Combo,
		String
	}

	class Option
	{
		public string Name;
		public OptionType OpType;
		public Regex Regex;

		public Option(string name, OptionType opType, Regex regex)
		{
			Name = name;
			OpType = opType;
			Regex = regex;
		}
	}

	#region Check

	private class CheckOption : Option
	{
		public bool Default;
		public bool Value;

		public void SetValue(bool value)
		{
			if (!IsReady)
			{
				return;
			}
			if (value == this.Value)
			{
				return;
			}
            var str = "setoption name " + Name + " value " + value.ToString().ToLower();
            Print(str, AI.MessageType.Input);
            Send(str);
            this.Value = value;
		}

		public bool GetValue()
		{
			return Value;
		}

		public CheckOption(string name, Regex regex) : base(name, OptionType.Check, regex)
		{
			Default = false;
			Value = false;
		}
	}

	private static Dictionary<string, CheckOption> check_options = new Dictionary<string, CheckOption>();

	#region WriteDebugLog

	public static bool WriteDebugLogDefault
	{
		get { return check_options["WriteDebugLog"].Default; }
	}

	public static bool WriteDebugLog
	{
		get
		{
			return check_options["WriteDebugLog"].GetValue();
		}
		set
		{
			check_options["WriteDebugLog"].SetValue(value);
		}
	}

	#endregion

	#region ContemptFromBlack

	public static bool ContemptFromBlackDefault
	{
		get { return check_options["ContemptFromBlack"].Default; }
	}

	public static bool ContemptFromBlack
	{
		get
		{
			return check_options["ContemptFromBlack"].GetValue();
		}
		set
		{
			check_options["ContemptFromBlack"].SetValue(value);
		}
	}

	#endregion

	#region SkipLoadingEval

	public static bool SkipLoadingEvalDefault
	{
		get { return check_options["SkipLoadingEval"].Default; }
	}

	public static bool SkipLoadingEval
	{
		get { return check_options["SkipLoadingEval"].GetValue(); }
		set { check_options["SkipLoadingEval"].SetValue(value); }
	}

	#endregion

	#region NarrowBook

	public static bool NarrowBookDefault
	{
		get { return check_options["NarrowBook"].Default; }
	}

	public static bool NarrowBook
	{
		get { return check_options["NarrowBook"].GetValue(); }
		set { check_options["NarrowBook"].SetValue(value); }
	}

	#endregion

	#region BookOnTheFly

	public static bool BookOnTheFlyDefault
	{
		get { return check_options["BookOnTheFly"].Default; }
	}

	public static bool BookOnTheFly
	{
		get { return check_options["BookOnTheFly"].GetValue(); }
		set { check_options["BookOnTheFly"].SetValue(value); }
	}

	#endregion

	#region ConsiderBookMoveCount

	public static bool ConsiderBookMoveCountDefault
	{
		get { return check_options["ConsiderBookMoveCount"].Default; }
	}

	public static bool ConsiderBookMoveCount
	{
		get { return check_options["ConsiderBookMoveCount"].GetValue(); }
		set { check_options["ConsiderBookMoveCount"].SetValue(value); }
	}

	#endregion

	#region ConsiderationMode

	public static bool ConsiderationModeDefault
	{
		get { return check_options["ConsiderationMode"].Default; }
	}

	public static bool ConsiderationMode
	{
		get
		{
			return check_options["ConsiderationMode"].GetValue();
		}
		set
		{
			check_options["ConsiderationMode"].SetValue(value);
		}
	}

	#endregion

	#region OutputFailLHPV

	public static bool OutputFailLHPVDefault
	{
		get { return check_options["OutputFailLHPV"].Default; }
	}

	public static bool OutputFailLHPV
	{
		get
		{
			return check_options["OutputFailLHPV"].GetValue();
		}
		set
		{
			check_options["OutputFailLHPV"].SetValue(value);
		}
	}

	#endregion

	#endregion

	#region Spin

	private class SpinOption : Option
	{
		public int Default;
		public int Min;
		public int Max;
		public int Value;

		public void SetValue(int value)
		{
			if (!IsReady)
			{
                //Print("!IsReady", AI.MessageType.Info);
                return;
			}
			if (value == Value)
            {
                //Print("value == Value", AI.MessageType.Info);
                return;
			}
			if (value < Min || value > Max)
            {
                //Print("value < Min || value > Max", AI.MessageType.Info);
                return;
			}
            var str = "setoption name " + Name + " value " + value;
            Print(str, AI.MessageType.Input);
			Send(str);
			Value = value;
		}

		public int GetValue()
		{
			return Value;
		}

		public SpinOption(string name, Regex regex) : base(name, OptionType.Spin, regex)
		{
			Min = -1;
			Max = -1;
			Default = -1;
			Value = -1;
		}
	}

	private static Dictionary<string, SpinOption> spin_options = new Dictionary<string, SpinOption>();

    #region SkillLevel

    public static int SkillLevelDefault { get { return spin_options["SkillLevel"].Default; } }

    public static int SkillLevelMin { get { return spin_options["SkillLevel"].Min; } }

    public static int SkillLevelMax { get { return spin_options["SkillLevel"].Max; } }

    public static int SkillLevel
    {
        get
        {
            return spin_options["SkillLevel"].GetValue();
        }
        set
        {
            spin_options["SkillLevel"].SetValue(value);
        }
    }

    #endregion

    #region Threads

    /// <summary>
    /// Количество потоков в данном движке по умолчанию. Определяется при загрузке движка.
    /// </summary>
    public static int ThreadsDefault { get { return spin_options["Threads"].Default; } }

	/// <summary>
	/// Минимальное количество потоков в данном движке. Определяется при загрузке движка.
	/// </summary>
	public static int ThreadsMin { get { return spin_options["Threads"].Min; } }

	/// <summary>
	/// Максимальное количество потоков в данном движке. Определяется при загрузке движка.
	/// </summary>
	public static int ThreadsMax { get { return spin_options["Threads"].Max; } }

	/// <summary>
	/// Текущее количество используемых потоков.
	/// </summary>
	public static int Threads
	{
		get
		{
			return spin_options["Threads"].GetValue();
		}
		set
		{
			spin_options["Threads"].SetValue(value);
		}
	}

	#endregion

	#region Hash

	/// <summary>
	/// Объём памяти в МБ для хэш таблиц по умолчанию. Определяется при загрузке движка.
	/// </summary>
	public static int HashDefault { get { return spin_options["Hash"].Default; } }

	/// <summary>
	/// Минимальный объём памяти(в МБ) для хэш таблиц в данном движке. Определяется при загрузке движка.
	/// </summary>
	public static int HashMin { get { return spin_options["Hash"].Min; } }

	/// <summary>
	/// Максимальный объём памяти(в МБ) для хэш таблиц в данном движке. Определяется при загрузке движка.
	/// </summary>
	public static int HashMax { get { return spin_options["Hash"].Max; } }

	/// <summary>
	/// Текущий объём памяти в МБ для хэш таблиц.
	/// </summary>
	public static int Hash
	{
		get
		{
			return spin_options["Hash"].GetValue();
		}
		set
		{
			spin_options["Hash"].SetValue(value);
		}
	}

	#endregion

	#region MultiPV

	/// <summary>
	/// Количество k-линий определения лучшего хода движка по умолчанию. Определяется при загрузке движка.
	/// </summary>
	public static int MultiPVDefault { get { return spin_options["MultiPV"].Default; } }

	/// <summary>
	/// Минимальное количество k-линий определения лучшего хода движка. Определяется при загрузке движка.
	/// </summary>
	public static int MultiPVMin { get { return spin_options["MultiPV"].Min; } }

	/// <summary>
	/// Максимальное количество k-линий определения лучшего хода движка. Определяется при загрузке движка.
	/// </summary>
	public static int MultiPVMax { get { return spin_options["MultiPV"].Max; } }

	/// <summary>
	/// Количество k-линий определения лучшего хода движка.
	/// </summary>
	public static int MultiPV
	{
		get
		{
			return spin_options["MultiPV"].GetValue();
		}
		set
		{
			spin_options["MultiPV"].SetValue(value);
		}
	}


	#endregion

	#region NetworkDelay

	public static int NetworkDelayDefault { get { return spin_options["NetworkDelay"].Default; } }

	public static int NetworkDelayMin { get { return spin_options["NetworkDelay"].Min; } }

	public static int NetworkDelayMax { get { return spin_options["NetworkDelay"].Max; } }

	public static int NetworkDelay
	{
		get
		{
			return spin_options["NetworkDelay"].GetValue();
		}
		set
		{
			spin_options["NetworkDelay"].SetValue(value);
		}
	}

	#endregion

	#region NetworkDelay2

	public static int NetworkDelay2Default { get { return spin_options["NetworkDelay2"].Default; } }

	public static int NetworkDelay2Min { get { return spin_options["NetworkDelay2"].Min; } }

	public static int NetworkDelay2Max { get { return spin_options["NetworkDelay2"].Max; } }

	public static int NetworkDelay2
	{
		get
		{
			return spin_options["NetworkDelay2"].GetValue();
		}
		set
		{
			spin_options["NetworkDelay2"].SetValue(value);
		}
	}

	#endregion

	#region MinimumThinkingTime

	/// <summary>
	/// Минимальное время на размышление по умолчанию. Определяется при загрузке движка.
	/// </summary>
	public static int MinimumThinkingTimeDefault { get { return spin_options["MinimumThinkingTime"].Default; } }

	/// <summary>
	/// Максимальное минимальное время на размышление. Определяется при загрузке движка.
	/// </summary>
	public static int MinimumThinkingTimeMin { get { return spin_options["MinimumThinkingTime"].Min; } }

	/// <summary>
	/// Минимальное минимальное время на размышление. Определяется при загрузке движка.
	/// </summary>
	public static int MinimumThinkingTimeMax { get { return spin_options["MinimumThinkingTime"].Max; } }

	/// <summary>
	/// Минимальное время на размышление.
	/// </summary>
	public static int MinimumThinkingTime
	{
		get
		{
			return spin_options["MinimumThinkingTime"].GetValue();
		}
		set
		{
			spin_options["MinimumThinkingTime"].SetValue(value);
		}
	}

	#endregion

	#region SlowMover

	public static int SlowMoverDefault { get { return spin_options["SlowMover"].Default; } }

	public static int SlowMoverMin { get { return spin_options["SlowMover"].Min; } }

	public static int SlowMoverMax { get { return spin_options["SlowMover"].Max; } }

	public static int SlowMover
	{
		get
		{
			return spin_options["SlowMover"].GetValue();
		}
		set
		{
			spin_options["SlowMover"].SetValue(value);
		}
	}

	#endregion

	#region MaxMovesToDraw

	/// <summary>
	/// Количество шагов до ничьи по умолчанию. Определяется при загрузке движка.
	/// </summary>
	public static int MaxMovesToDrawDefault { get { return spin_options["MaxMovesToDraw"].Default; } }

	/// <summary>
	/// Минимальное количество шагов до ничьи. Определяется при загрузке движка.
	/// </summary>
	public static int MaxMovesToDrawMin { get { return spin_options["MaxMovesToDraw"].Min; } }

	/// <summary>
	/// Максимальное количество шагов до ничьи. Определяется при загрузке движка.
	/// </summary>
	public static int MaxMovesToDrawMax { get { return spin_options["MaxMovesToDraw"].Max; } }

	/// <summary>
	/// Количество шагов до ничьи.
	/// </summary>
	public static int MaxMovesToDraw
	{
		get
		{
			return spin_options["MaxMovesToDraw"].GetValue();
		}
		set
		{
			spin_options["MaxMovesToDraw"].SetValue(value);
		}
	}

	#endregion

	#region DepthLimit

	public static int DepthLimitDefault { get { return spin_options["DepthLimit"].Default; } }

	public static int DepthLimitMin { get { return spin_options["DepthLimit"].Min; } }

	public static int DepthLimitMax { get { return spin_options["DepthLimit"].Max; } }

	public static int DepthLimit
	{
		get
		{
			return spin_options["DepthLimit"].GetValue();
		}
		set
		{
			spin_options["DepthLimit"].SetValue(value);
		}
	}

	#endregion

	#region NodesLimit

	public static int NodesLimitDefault { get { return spin_options["NodesLimit"].Default; } }

	public static int NodesLimitMin { get { return spin_options["NodesLimit"].Min; } }

	public static int NodesLimitMax { get { return spin_options["NodesLimit"].Max; } }

	public static int NodesLimit
	{
		get
		{
			return spin_options["NodesLimit"].GetValue();
		}
		set
		{
			spin_options["NodesLimit"].SetValue(value);
		}
	}

	#endregion

	#region Contempt

	public static int ContemptDefault { get { return spin_options["Contempt"].Default; } }

	public static int ContemptMin { get { return spin_options["Contempt"].Min; } }

	public static int ContemptMax { get { return spin_options["Contempt"].Max; } }

	public static int Contempt
	{
		get { return spin_options["Contempt"].GetValue(); }
		set { spin_options["Contempt"].SetValue(value); }
	}

	#endregion

	#region BookMoves

	public static int BookMovesDefault { get { return spin_options["BookMoves"].Default; } }

	public static int BookMovesMin { get { return spin_options["BookMoves"].Min; } }

	public static int BookMovesMax { get { return spin_options["BookMoves"].Max; } }

	public static int BookMoves
	{
		get { return spin_options["BookMoves"].GetValue(); }
		set { spin_options["BookMoves"].SetValue(value); }
	}

	#endregion

	#region BookIgnoreRate

	public static int BookIgnoreRateDefault { get { return spin_options["BookIgnoreRate"].Default; } }

	public static int BookIgnoreRateMin { get { return spin_options["BookIgnoreRate"].Min; } }

	public static int BookIgnoreRateMax { get { return spin_options["BookIgnoreRate"].Max; } }

	public static int BookIgnoreRate
	{
		get { return spin_options["BookIgnoreRate"].GetValue(); }
		set { spin_options["BookIgnoreRate"].SetValue(value); }
	}

	#endregion

	#region BookEvalDiff

	public static int BookEvalDiffDefault { get { return spin_options["BookEvalDiff"].Default; } }

	public static int BookEvalDiffMin { get { return spin_options["BookEvalDiff"].Min; } }

	public static int BookEvalDiffMax { get { return spin_options["BookEvalDiff"].Max; } }

	public static int BookEvalDiff
	{
		get { return spin_options["BookEvalDiff"].GetValue(); }
		set { spin_options["BookEvalDiff"].SetValue(value); }
	}

	#endregion

	#region BookEvalBlackLimit

	public static int BookEvalBlackLimitDefault { get { return spin_options["BookEvalBlackLimit"].Default; } }

	public static int BookEvalBlackLimitMin { get { return spin_options["BookEvalBlackLimit"].Min; } }

	public static int BookEvalBlackLimitMax { get { return spin_options["BookEvalBlackLimit"].Max; } }

	public static int BookEvalBlackLimit
	{
		get { return spin_options["BookEvalBlackLimit"].GetValue(); }
		set { spin_options["BookEvalBlackLimit"].SetValue(value); }
	}

	#endregion

	#region BookEvalWhiteLimit

	public static int BookEvalWhiteLimitDefault { get { return spin_options["BookEvalWhiteLimit"].Default; } }

	public static int BookEvalWhiteLimitMin { get { return spin_options["BookEvalWhiteLimit"].Min; } }

	public static int BookEvalWhiteLimitMax { get { return spin_options["BookEvalWhiteLimit"].Max; } }

	public static int BookEvalWhiteLimit
	{
		get { return spin_options["BookEvalWhiteLimit"].GetValue(); }
		set { spin_options["BookEvalWhiteLimit"].SetValue(value); }
	}

	#endregion

	#region BookDepthLimit

	public static int BookDepthLimitDefault { get { return spin_options["BookDepthLimit"].Default; } }

	public static int BookDepthLimitMin { get { return spin_options["BookDepthLimit"].Min; } }

	public static int BookDepthLimitMax { get { return spin_options["BookDepthLimit"].Max; } }

	public static int BookDepthLimit
	{
		get { return spin_options["BookDepthLimit"].GetValue(); }
		set { spin_options["BookDepthLimit"].SetValue(value); }
	}

	#endregion

	#region PvInterval

	public static int PvIntervalDefault { get { return spin_options["PvInterval"].Default; } }

	public static int PvIntervalMin { get { return spin_options["PvInterval"].Min; } }

	public static int PvIntervalMax { get { return spin_options["PvInterval"].Max; } }

	public static int PvInterval
	{
		get
		{
			return spin_options["PvInterval"].GetValue();
		}
		set
		{
			spin_options["PvInterval"].SetValue(value);
		}
	}

	#endregion

	#region ResignValue

	public static int ResignValueDefault { get { return spin_options["ResignValue"].Default; } }

	public static int ResignValueMin { get { return spin_options["ResignValue"].Min; } }

	public static int ResignValueMax { get { return spin_options["ResignValue"].Max; } }

	public static int ResignValue
	{
		get
		{
			return spin_options["ResignValue"].GetValue();
		}
		set
		{
			spin_options["ResignValue"].SetValue(value);
		}
	}

	#endregion

	#region NodesTime

	public static int NodesTimeDefault { get { return spin_options["nodestime"].Default; } }

	public static int NodesTimeMin { get { return spin_options["nodestime"].Min; } }

	public static int NodesTimeMax { get { return spin_options["nodestime"].Max; } }

	public static int NodesTime
	{
		get { return spin_options["nodestime"].GetValue(); }
		set { spin_options["nodestime"].SetValue(value); }
	}

	#endregion

	#endregion

	#region String

	private class StringOption : Option
	{
		public string Default;
		public string Value;

		public void SetValue(string value)
		{
			if (!IsReady)
			{
				return;
			}
			if (value == this.Value)
			{
				return;
			}
            var str = "setoption name " + Name + " value " + value;
            Print(str, AI.MessageType.Input);
            Send(str);
            this.Value = value;
		}

		public string GetValue()
		{
			return Value;
		}

		public StringOption(string name, Regex regex) : base(name, OptionType.String, regex)
		{
			Default = null;
			Value = null;
		}
	}

	private static Dictionary<string, StringOption> string_options = new Dictionary<string, StringOption>();

	#region EvalDir

	/// <summary>
	/// Директория для хранения вычислений по умолчанию.
	/// </summary>
	public static string EvalDirDefault
	{
		get { return string_options["EvalDir"].Default; }
	}

	/// <summary>
	/// Директория для хранения вычислений.
	/// </summary>
	public static string EvalDir
	{
		get { return string_options["EvalDir"].GetValue(); }
		set { string_options["EvalDir"].SetValue(value); }
	}

	#endregion

	#region EvalSaveDir

	/// <summary>
	/// Директория для хранения вычислений по умолчанию.
	/// </summary>
	public static string EvalSaveDirDefault
	{
		get { return string_options["EvalSaveDir"].Default; }
	}

	/// <summary>
	/// Директория для хранения вычислений.
	/// </summary>
	public static string EvalSaveDir
	{
		get { return string_options["EvalSaveDir"].GetValue(); }
		set { string_options["EvalSaveDir"].SetValue(value); }
	}

	#endregion

	#endregion

	#region Combo

	private class ComboOption : Option
	{
		public List<string> PossibleValues;
		public string Default;
		public string Value;

		public ComboOption(string name, Regex regex) : base(name, OptionType.Combo, regex)
		{
			PossibleValues = new List<string>();
		}

		public void AddValue(string name)
		{
			PossibleValues.Add(name);
		}

		public void SetValue(string value)
		{
			if (!IsReady)
			{
				return;
			}
			if(!PossibleValues.Contains(value))
			{
				return;
			}
			if (value == this.Value)
			{
				return;
			}
            var str = "setoption name " + Name + " value " + value;
            Print(str, AI.MessageType.Input);
            Send(str);
            this.Value = value;
		}

		public string GetValue()
		{
			return Value;
		}
	}

	private static Dictionary<string, ComboOption> combo_options = new Dictionary<string, ComboOption>();

    #region EnteringKingRule

    public static List<string> GetEnteringKingValues
	{
		get
		{
			return combo_options["EnteringKingRule"].PossibleValues;
		}
	}

	public static string EnteringKingRuleDefault
	{
		get { return combo_options["EnteringKingRule"].Default; }
	}

	public static string EnteringKingRule
	{
		get
		{
			return combo_options["EnteringKingRule"].GetValue();
		}
		set
		{
			combo_options["EnteringKingRule"].SetValue(value);
		}
	}

    #endregion

    #region BookFile

    public static List<string> GetBookFileValues
    {
        get
        {
            return combo_options["BookFile"].PossibleValues;
        }
    }

    public static string BookFileDefault
    {
        get { return combo_options["BookFile"].Default; }
    }

    public static string BookFile
    {
        get
        {
            return combo_options["BookFile"].GetValue();
        }
        set
        {
            combo_options["BookFile"].SetValue(value);
        }
    }

    #endregion

    #endregion

    #endregion

    private static int moveCount;

    public static int Depth
    {
        get;
        set;
    }

    public static ulong Nodes
    {
        get;
        set;
    }

    /// <summary>
    /// Читает опции из движка.
    /// </summary>
    private static void ReadUSI()
    {
        spin_options.Clear();
        check_options.Clear();
        string_options.Clear();
        combo_options.Clear();

        var symbol = Process.StandardOutput.Peek();
        var answer = "usiok";
        var temp_spin_opts = new List<SpinOption>();
        var temp_check_opts = new List<CheckOption>();
        var temp_string_opts = new List<StringOption>();
        var temp_combo_opts = new List<ComboOption>();

        var spin_opts_str = new string[]
        {
            "Threads",
            "Hash",
            "MultiPV",
            "SkillLevel",
            "NetworkDelay",
            "NetworkDelay2",
            "MinimumThinkingTime",
            "SlowMover",
            "MaxMovesToDraw",
            "DepthLimit",
            "NodesLimit",
            "Contempt",
            "BookMoves",
            "BookIgnoreRate",
            "BookEvalDiff",
            "BookEvalBlackLimit",
            "BookEvalWhiteLimit",
            "BookDepthLimit",
            "PvInterval",
            "ResignValue",
            "nodestime",
        };

        var check_opts_str = new string[]
        {
            "WriteDebugLog",
            "ContemptFromBlack",
            "EvalShare",
            "SkipLoadingEval",
            "GenerateAllLegalMoves",
            "NarrowBook",
            "BookOnTheFly",
            "ConsiderBookMoveCount",
            "ConsiderationMode",
            "OutputFailLHPV"
        };

        var string_opts_str = new string[]
        {
            "EvalDir",
            "EvalSaveDir",
            "BookDir"
        };

        var combo_opts_str = new string[]
        {
            "EnteringKingRule",
            "BookFile"
        };

        bool enable_combos = true;

        foreach (var s in spin_opts_str)
        {
            temp_spin_opts.Add(new SpinOption(s, BuildUSIRegex(s, OptionType.Spin)));
        }

        foreach (var s in check_opts_str)
        {
            temp_check_opts.Add(new CheckOption(s, BuildUSIRegex(s, OptionType.Check)));
        }

        foreach (var s in string_opts_str)
        {
            temp_string_opts.Add(new StringOption(s, BuildUSIRegex(s, OptionType.String)));
        }

        foreach (var s in combo_opts_str)
        {
            temp_combo_opts.Add(new ComboOption(s, BuildUSIRegex(s, OptionType.Combo)));
        }

        if (symbol != '\0')
        {
            while (true)
            {
                var str = Process.StandardOutput.ReadLine();
                if (!String.IsNullOrEmpty(str))
                {
                    // INT OPTS

                    var int_remove_list = new List<SpinOption>();

                    foreach (var op in temp_spin_opts)
                    {
                        var result = op.Regex.Match(str);
                        if (result.Success)
                        {
                            int_remove_list.Add(op);
                            int counter = 0;
                            foreach (Group group in result.Groups)
                            {
                                int parse_result;
                                if (int.TryParse(group.Value, out parse_result))
                                {
                                    if (counter == 0)
                                    {
                                        op.Default = parse_result;
                                        op.Value = op.Default;
                                    }
                                    else if (counter == 1)
                                    {
                                        op.Min = parse_result;
                                    }
                                    else if (counter == 2)
                                    {
                                        op.Max = parse_result;
                                    }

                                    counter++;
                                }
                            }
                        }
                    }
                    foreach (var op in int_remove_list)
                    {
                        spin_options.Add(op.Name, op);
                        temp_spin_opts.Remove(op);
                    }

                    // CHECK OPTS

                    var check_remove_list = new List<CheckOption>();

                    foreach (var op in temp_check_opts)
                    {
                        var result = op.Regex.Match(str);
                        if (result.Success)
                        {
                            check_remove_list.Add(op);
                            var groups = result.Groups;
                            if (groups.Count >= 2)
                            {
                                var group = result.Groups[1];
                                bool parse_result;
                                if (bool.TryParse(group.Value, out parse_result))
                                {
                                    op.Default = parse_result;
                                    op.Value = op.Default;
                                }
                            }
                        }
                    }
                    foreach (var op in check_remove_list)
                    {
                        check_options.Add(op.Name, op);
                        temp_check_opts.Remove(op);
                    }

                    // STRING OPTS

                    var string_remove_list = new List<StringOption>();

                    foreach (var op in temp_string_opts)
                    {
                        var result = op.Regex.Match(str);
                        if (result.Success)
                        {
                            string_remove_list.Add(op);
                            var groups = result.Groups;
                            if (groups.Count >= 2)
                            {
                                var parse_result = result.Groups[1].Value;
                                op.Default = parse_result;
                                op.Value = op.Default;
                            }
                        }
                    }
                    foreach (var op in string_remove_list)
                    {
                        string_options.Add(op.Name, op);
                        temp_string_opts.Remove(op);
                    }

                    // COMBO OPTS

                    if (enable_combos)
                    {
                        var combo_remove_list = new List<ComboOption>();

                        foreach (var op in temp_combo_opts)
                        {
                            var result = op.Regex.Match(str);
                            if (result.Success)
                            {
                                combo_remove_list.Add(op);

                                var regex2 = new Regex(@"((?<=default\s)|(?<=var\s))(\w+)");
                                int counter = 0;
                                var results = regex2.Matches(str);
                                foreach (Match match in results)
                                {
                                    var group = match.Groups[2];
                                    string parse_result = group.Value;
                                    if (counter == 0)
                                    {
                                        op.Default = parse_result;
                                        op.Value = op.Default;
                                    }
                                    else
                                    {
                                        op.AddValue(parse_result);
                                    }

                                    counter++;
                                }

                            }
                        }

                        foreach (var op in combo_remove_list)
                        {
                            combo_options.Add(op.Name, op);
                            temp_combo_opts.Remove(op);
                        }
                    }
                }

                if (str.Substring(0, answer.Length) == answer)
                {
                    break;
                }
            }
        }
    }
    
    public class Quest
    {
        public string Ask;
        public string Answer;
    }

    /// <summary>
    /// Печатает строку в процесс движка.
    /// </summary>
    /// <param name="line">Строка запроса.</param>
    /// <param name="waitFor">Строка ответа.</param>
    /// <param name="printAll">Печатать ли весь вывод или только ответ ?</param>
    private static void Send(string line, string waitFor = null, bool printAll = true)
    {
        PrintAll = printAll;
        Asks.Enqueue(new Quest() { Ask = line, Answer = waitFor });
    }

    public static void SendWhenOK(ReadyAnswer what)
    {
        IsReadyAnswer = what;
        Send("isready", "readyok");
    }
    
    public static bool HasMove { get; private set; }

    public static void AcceptMove()
    {
        HasMove = false;
        Thinking = ThinkingMode.None;
    }

    private static string CurrentAnswer;

    private static bool PrintAll = true;

    private static Queue<Quest> Asks = new Queue<Quest>();

    private static Task Reader;

    private static Task Writer;



    public enum ReadyAnswer
    {
        None,
        OK,
        Position,
        Go,
        Move
    }

    private static ReadyAnswer IsReadyAnswer;
    
    public static bool ProcessHasExited()
    {
        if(Process != null)
        {
            return Process.HasExited;
        }
        return false;
    }

    /// <summary>
    /// Инициализирует движок. Если движок уже инициализирован не делает ничего, 
    /// если же processFolder или processName при этом не будет равен предыдущим параметрам,
    /// то переинициализирует процесс на новый движок.
    /// </summary>
    /// <param name="processFolder">Папка процесса.</param>
    /// <param name="processName">Имя процесса.</param>
    public static void Init(string processFolder = null, string processName = null)
	{
        if(string.IsNullOrEmpty(processFolder))
        {
            Print("ERROR: processFolder == null", AI.MessageType.Info);
            IsReady = false;
            return;
        }
        if(string.IsNullOrEmpty(processName))
        {
            Print("ERROR: processName == null", AI.MessageType.Info);
            IsReady = false;
            return;
        }

        var path = processFolder + "\\" + processName;

        if(!File.Exists(path))
        {
            Print($"ERROR: Process {path} not exist !", AI.MessageType.Info);
            IsReady = false;
            return;
        }

        if (IsReady)
        {
            if(ProcessFolder != processFolder || ProcessName != processName)
            {
                    Print($"New engine is loaded : {ProcessFolder}\\{ProcessName} -> {processFolder}\\{processName}", AI.MessageType.Info);
                    Process.CloseMainWindow();
                    Process.Dispose();
            }
            else
            {
                // Тот же самый движок - можно ничего не менять
                return;
            }
        }
        else
        {
            Print($"Engine loading : {path}", AI.MessageType.Info);
        }
        
        ProcessFolder = processFolder;
        ProcessName = processName;

        IsReady = true;
        HasMove = false;
        Asks.Clear();
        CurrentAnswer = null;
        Message = null;
        Move = null;
        Thinking = ThinkingMode.None;

        try
        {
            ProcessStartInfo info = new ProcessStartInfo(path)
            {
                UseShellExecute = false,
                WorkingDirectory = ProcessFolder,
                CreateNoWindow = true,
                RedirectStandardInput = true,
                RedirectStandardOutput = true
            };
            Process = Process.Start(info);
            Writer = Task.Factory.StartNew(() =>
            {
                while (!Process.HasExited)
                {
                    if (CurrentAnswer == null)
                    {
                        if (Asks.Count > 0)
                        {
                            var t = Asks.Dequeue();

                            Process.StandardInput.WriteLine(t.Ask);
                            Process.StandardInput.Flush();

                            if (t.Answer != null)
                            {
                                CurrentAnswer = t.Answer;
                            }
                            else
                            {
                                CurrentAnswer = null;
                            }
                        }
                    }
                }
            });

            Reader = Task.Factory.StartNew(() =>
            {
                while (!Process.HasExited)
                {
                    if (!string.IsNullOrEmpty(CurrentAnswer))
                    {
                        var symbol = Process.StandardOutput.Peek();

                        if (symbol != '\0')
                        {
                            var str = Process.StandardOutput.ReadLine();

                            if (string.IsNullOrEmpty(str))
                            {
                                continue;
                            }

                            if (PrintAll)
                            {
                                if (str != "readyok")
                                {
                                    Print(str, AI.MessageType.Output);
                                }
                            }

                            if (str.Length >= CurrentAnswer.Length)
                            {
                                if (str.Substring(0, CurrentAnswer.Length) == CurrentAnswer)
                                {
                                    if (!PrintAll)
                                    {
                                        if (str != "readyok")
                                        {
                                            Print(str, AI.MessageType.Output);
                                        }
                                    }

                                    if (CurrentAnswer == "bestmove")
                                    {
                                        Move = str.Substring(9);
                                        HasMove = true;
                                    }
                                    else if(CurrentAnswer == "readyok")
                                    {
                                        switch (IsReadyAnswer)
                                        {
                                            case ReadyAnswer.OK:
                                                Print(str, AI.MessageType.Output);
                                                break;
                                            case ReadyAnswer.Position:
                                                if (Message != null)
                                                {
                                                    string engineLine;
                                                    if(moveCount == 0)
                                                    {
                                                        engineLine = $"position {StartPos}";
                                                    }
                                                    else
                                                    {
                                                        engineLine = $"position {StartPos} moves " + Message;
                                                        Message = null;
                                                    }
                                                    Send(engineLine);

                                                    if (Thinking != ThinkingMode.None)
                                                    {
                                                        Print(engineLine, AI.MessageType.Input);
                                                        Go();
                                                    }
                                                }
                                                break;
                                            case ReadyAnswer.Go:
                                               
                                                break;
                                            case ReadyAnswer.Move:
                                                break;
                                        }

                                    }
                                    IsReadyAnswer = ReadyAnswer.None;
                                    CurrentAnswer = null;
                                }
                            }
                        }
                    }
                }
            });

            Send("usi");
            ReadUSI();
        }
        catch(Exception ex)
        {
            Print($"ERROR: Exception throwed: {ex.ToString()}", AI.MessageType.Info);
        }
        
        Send("isready", "readyok");
    }

    /// <summary>
    /// Строит регулярное выражение для опции USI.
    /// </summary>
    /// <param name="option">Опция.</param>
    /// <param name="type">Тип опции.</param>
    /// <returns>Регулярное выражение для опции USI.</returns>
    private static Regex BuildUSIRegex(string option, OptionType type)
    {
        string pattern = null;
        switch(type)
        {
            case OptionType.Spin:
                pattern = $@"{option}.+?(\d+)\smin\s+(\d+)\smax\s+(\d+)";
                break;
            case OptionType.Check:
                pattern = $@"{option}.+(false|true)";
                break;
            case OptionType.String:
                pattern = $@"{option}.+(?<=default)\s(\D+)";
                break;
            case OptionType.Combo:
                pattern = $@"{option}";
                break;
        }
        return new Regex(pattern);
    }

    private static string StartPos;

    public static void NewGame(string sfen = null, int moveCounter = 1)
	{
		if(!IsReady)
		{
			return;
		}
        Send("usinewgame");
        if (sfen == null)
        {
            StartPos = "startpos";
        }
        else
        {
            StartPos = sfen;
        }
        HasMove = false;
        //Send($"position {StartPos} {moveCounter}");
    }

	/// <summary>
	/// Устанавливает позицию.
	/// </summary>
	/// <param name="sfen">Строка позиции.</param>
	/// <param name="move_index">Номер хода.</param>
	public static void SetSFEN(string sfen = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b", int move_index = 1)
    {
        if (!IsReady)
        {
            return;
        }
        Send("sfen " + sfen + " " + move_index);
	}
	
	/// <summary>
	/// Установка опции usi.
	/// </summary>
	/// <param name="name">Имя опции.</param>
	/// <param name="value">Значение опции.</param>
	private static void SetOption(string name, string value)
    {
        if (!IsReady)
        {
            return;
        }
        Send("setoption name " + name + " value " + value);
	}

	/// <summary>
	/// Закрывает движок.
	/// </summary>
	public static void Shutdown()
	{
        if (IsReady)
        {
            IsReady = false;
            Process.Kill();
        }
	}

    /// <summary>
    /// Ожидание получения ответа от движка.
    /// </summary>
    private static void WaitTillAnswer()
    {
        
    }

    public static AI AINode;

    private static void Print(string line, AI.MessageType type)
	{
        AINode.Call("SendToLog", line, type);
	}

    public static string Message;

    public static string Move;

	public static bool SendMoves(string moves, ThinkingMode thinking)
	{
        if (!IsReady)
        {
            return false;
        }

        if(HasMove)
        {
            return false;
        }

        if(Thinking != ThinkingMode.None)
        {
            return false;
        }
        
        Thinking = thinking;
        Message = moves;
        var strs = moves.Split(' ');
        moveCount = strs.Length;
        SendWhenOK(ReadyAnswer.Position);

        return true;
    }



  

    /// <summary>
    /// Начинает безконечный анализ.
    /// </summary>
	public static void GoInifinity()
    {
        if (!IsReady)
        {
            return;
        }

        var str = $"go infinite";
        Print(str, AI.MessageType.Input);
        Send(str, "bestmove");
	}

    /// <summary>
    /// Начинает поиск лучшего хода на заданной глубине(параметр Depth).
    /// </summary>
    public static void GoDepth()
    {
        var str = $"go depth {Depth}";
        Print(str, AI.MessageType.Input);
        Send(str, "bestmove");
    }

    /// <summary>
    /// Начинает поиск лучшего хода.
    /// </summary>
    public static void Go()
    {
        var str = $"go";
        Print(str, AI.MessageType.Input);
        Send(str, "bestmove");
    }

    /// <summary>
    /// Остановка анализа.
    /// </summary>
    public static void Stop()
    {
        if (!IsReady)
        {
            return;
        }
        Send("stop");
	}

    /// <summary>
    /// Показ расстановки игры.
    /// </summary>
	public static void Display()
	{
        if(!IsReady)
        {
            return;
        }
		Send("d", "sfen");
	}
}
