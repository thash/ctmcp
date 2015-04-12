%% 5.6 メッセージ伝達モデルを直接使用すること
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 5.6.1 1つのスレッドを共有する複数のポートオブジェクト

% 複数のポートオブジェクトがすべて1つのスレッドを通るようにする．
% 別のオブジェクトの計算を待つことが出来ない．プログラムの書き方が特殊になる

proc {NewPortObjects ?AddPortObject ?Call}
   Sin P={NewPort Sin} % この書き方前にも出てきたっけ?
   proc {MsgLoop S1 Procs}
      case S1
      of add(I Proc Sync)|S2 then Procs2 in
         Procs2={AdjoinAt Procs I Proc}
         Sync=unit
         {MsgLoop S2 Procs2}
      [] msg(I M)|S2 then
         try {Procs.I M} catch _ then skip end
         {MsgLoop S2 Procs}
      [] nil then skip end
   end
in
   thread {MsgLoop Sin procs} end
   % AddPortObjectは，その(どの?)スレッドにIという名の新しいポートオブジェクトを付与する
   proc {AddPortObject I Proc}
      Sync in
      {Send P add(I Proc Sync)}
      {Wait Sync}
   end
   proc {Call I M}
      {Send P msg(I M)}
   end
end


%% ピンポンプログラム．1つのスレッドを共有する2つのポートオブジェクト
declare AddPortObject Call
{NewPortObjects AddPortObject Call}

InfoMsg={NewProgWindow "See ping-pong"}

fun {PingPongProc Other}
   proc {$ Msg}
      case Msg
      of ping(M) then
         {InfoMsg "ping("#N#")"}
         {Call Other pong(N+1)}
      [] pong(N) then
         {InfoMsg "pong("#N#")"}
         {Call Other ping(N+1)}
      end
   end
end

{AddPortObject pingobj {PingPongProc pongobj}}
{AddPortObject pongobj {PingPongProc pingobj}}
{Call pingobj ping(0)}


%%% 5.6.2 ポートを使う並列キュー

% FIFOキューのように振る舞うスレッド

% 図5.17 素朴版(動かない)
%   略. 読み出し専用変数が束縛を強制しているのがミス.
% 図5.18 正しい版(動く)

fun {NewQueue}
   % なにこの構文
   Given GivePort={NewPort Given}
   Taken TakePort={NewPort Taken}
   proc {Match Xs Ys}
      case Xs # Ys
      of (X|Xr) # (Y|Yr) then
         X=Y {Match Xr Yr}
      [] nil # nil then skip
      end
   end
in
   % 素朴版でGiven=Takenとしていたがその代わりにMatchを別スレッドで使う
   % 実はMatchは必要なくて別スレッドでGiven=Takenとすればいいだけ
   thread {Match Given Taken} end
   queue(put:proc {$ X} {Send GivePort X} end
         get:proc {$ X} {Send TakePort X} end)
end


%%% 5.6.3 終点検出を行うスレッド抽象

% 子が次々呼び出されるスレッドが最終的に閉じるところを検出したい．
% 4.3.3(p.271)ではスレッド間で明示的に変数を受け渡すことで終点検出を実装したが，
% 明示的にやらず，カプセル化して使いたい．

% サブスレッドを生成するとポートに+1を送り，終了すると-1．サブスレッド数が0になるとZeroExitが完了する．
local % なぜlocal?
   proc {ZeroExit N Is}
      case Is of I|Ir then
         if N+1\=0 then {ZeroExit N+1 Ir} end
      end
   end
in
   proc {NewThread P ?SubThread}
      Is Pt={NewPort Is}
   in
      proc {SubThread P}
         {Send Pt 1}
         thread
            {P} {Send Pt ~1} % チルダなんだっけ．拡大してもマイナスではなさそうだけど
         end
      end
      {SubThread P}
      {ZeroExit 0 Is}
   end
end


%% ポート送信の意味と分散システム

% Send操作は非同期的 = 直ちに終了する．終了検知システムは，
% Sendのスロット確保意味(slot-reserving semantics)に頼っている．

% Sendしたからといって直ちにスロットが確保できるとは限らず
% 「Sendはいずれスロットを確保するであろう」としか言えない．

% よって上の定義では{Send Pt ~1}が{Send Pt 1}より先に着くかもしれず，正しいとはいえなくなる．
% これを解決するには「いずれスロットを確保するような」ポートを使う．

proc {NewSPort ?S ?SSend}
   S1 P={NewPort S1} in
   proc {SSend M} X in {Send P M#X} {Wait X} end
   thread S={Map S1 fun {$ M#X} X=unit M end} end
end


%%% 5.6.4 直列依存関係の除去

% (たとえば)Filterが直列依存とはどんな状態か．

fun {Filter L F}
   for X in L collect:C do
      if {F X} then {C X} end
   end
end

% において，Xより前のLの要素がすべて計算されないと{F X}が計算出来ないことを言う．
% 本来，入力Lがわかっていればその次点で各要素は(他要素に依存せず)対応する出力を知ることが出来るはず．

% そーゆー依存関係を避ける新たなFilterを定義したい．2つの構成要素が必要．
%     * Barrier: 並列合成(4.4.3(p.287))の実装．リスト要素ごとに並列タスクを作成，すべての終了を待つ．
%     * NewPortClose: 非同期チャンネル(= 要はポート)．送信操作とクローズ操作を持つポート．定義はWebで

% booksuppl.ozよりNewPortClose(8章)
% NewCellはOz組み込み．
declare
proc {NewPortClose ?S ?Send ?Close}
   PC={NewCell S}
in
   proc {Send M}
      S in
      {Exchange PC M|S S}
   end
   proc {Close}
      nil=@PC
   end
end

% Barrierは4.4.ozから持ってくる
declare
proc {Barrier Ps} % Psは手続きのリスト
   % それぞれの手続きをthreadとして実行し, 待つ.
   fun {BarrierLoop Ps L}
      case Ps of P|Pr then M in
         thread {P} M=L end
         {BarrierLoop Pr M}
      [] nil then L
      end
   end
   S={BarrierLoop Ps unit}
in
   {Wait S}
end

declare
proc {ConcFilter L F ?L2}
   Send Close
in
   {NewPortClose L2 Send Close}
   {Barrier
    {Map L
     fun {$ X}
        proc {$}
           if {F X} then {Send X} end
        end
     end}}
   {Close}
end
