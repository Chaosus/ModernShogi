using Godot;
using System;
using System.Collections.Generic;

public class AI : Node
{
    private Queue<Message> log = new Queue<Message>();

    public int Hash()
    {
        return UCIEngine.Hash;
    }

    [Signal]
    public delegate void ReadyOk();

    public int DepthLimit()
    {
        return UCIEngine.DepthLimit;
    }

    bool paused = false;
    bool focused = true;

    public void Init(string processFolder, string processName, bool reset = false)
	{
        if(reset)
        {
            Shutdown();
        }

        paused = false;

        UCIEngine.Init(processFolder, processName);
	}

    public bool IsReady { get { return UCIEngine.IsReady; } }

    public enum MessageType
    {
        Output,
        Input,
        Info
    }

    public struct Message
    {
        public string Str;
        public MessageType Type;

        public Message(string str, MessageType mtype)
        {
            Str = str;
            Type = mtype;
        }
    }

    public void SendToLog(string str, MessageType type)
    {
        log.Enqueue(new Message(str, type));
    }

    public void Display()
    {
        UCIEngine.Display();
    }

    public void Stop()
    {
        UCIEngine.Stop();
    }

	public void NewGame(string sfen = null)
    {
        UCIEngine.NewGame(sfen, 1);
    }

    public void IsOK()
    {
        UCIEngine.SendWhenOK(UCIEngine.ReadyAnswer.OK);
    }

    public bool Hint(string moves)
    {
        return UCIEngine.SendMoves(moves, UCIEngine.ThinkingMode.Hint);
    }

    public void SendMoves(string moves, bool thinking)
    {
        UCIEngine.SendMoves(moves, thinking ? UCIEngine.ThinkingMode.Move : UCIEngine.ThinkingMode.None);
    }

	public void FindBestMove()
	{
        UCIEngine.GoDepth();
	}

    public void SetSkillLevel(int level)
    {
        UCIEngine.SkillLevel = level;
    }

    public int GetSkillLevel()
    {
        return UCIEngine.SkillLevel;
    }

    public void Shutdown()
    {
        UCIEngine.Shutdown();
    }

    private Node game;

    public bool MoveLock()
    {
        return (bool)game.Call("get_movelock");
    }

    public override void _Ready()
    {
        game = GetParent();
        UCIEngine.AINode = this;
    }

    public void Pause()
    {
        paused = true;
    }

    public void Resume()
    {
        paused = false;
    }

    public override void _Notification(int what)
    {
        if (what == MainLoop.NotificationWmFocusIn)
            focused = true;
        else if (what == MainLoop.NotificationWmFocusOut)
            focused = false;

        base._Notification(what);
    }

    public void SetSkipLoadingEval(bool enabled)
    {
        UCIEngine.SkipLoadingEval = enabled;
    }

    public bool ProcessHasExited()
    {
        return UCIEngine.ProcessHasExited();
    }

    public bool SFXPause = false;

    public void SetSFXPause(bool pause)
    {
        SFXPause = pause;
    }

    public override void _PhysicsProcess(float delta)
    {
        if (!SFXPause && focused && !paused && UCIEngine.HasMove)
        {
            game.Call("make_ai_move", UCIEngine.Move, UCIEngine.Thinking == UCIEngine.ThinkingMode.Hint);
            UCIEngine.AcceptMove();
        }
        if(log.Count > 0)
        {
            var message = log.Dequeue();
            game.Call("send_to_ai_log", message.Str, message.Type);
        }
        base._PhysicsProcess(delta);
    }
}
