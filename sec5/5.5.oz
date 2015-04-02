%% 5.5 リフト制御システム
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% リフト，エレベータとは別の存在らしいが何なの

% 図5.5 リフト制御システムのコンポーネントダイアグラム
% https://github.com/memerelics/ctmcp/tree/master/sec5/img/fig5.5.png

% スケジューリングアルゴリズム: FIFO(ボタン押した順に停まる)
% FIFOよりも知的にするには?


%% 5.5.1 状態遷移図(state transition diagram)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 状態遷移図は有限状態オートマトン(finite state automaton)

% メッセージの送受信は2通り
%    * ポートのストリームを介す
%    * データフロー変数の束縛を介す(1つのメッセージしか送れない軽量級チャンネル)


%% 5.5.2 実装
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 再掲
fun {NewPortObject Init Fun}
Sin Sout in
    thread {FoldL Sin Fun Init Sout} end
    {NewPort Sin}
end

fun {NewPortObject2 Proc}
Sin in
    thread for Msg in Sin do {Proc Msg} end end
    {NewPort Sin}
end

% パーツ
declare
fun {Timer}
   {NewPortObject2
    proc {$ Msg}
       case Msg of starttimer(T Pid) then
          thread {Delay T} {Send Pid stoptimer} end
       end
   end}
end

% 制御装置(Controller)
% 状態: モーター停止，モーター稼働
% https://github.com/memerelics/ctmcp/tree/master/sec5/img/fig5.7.png
fun {Controller Init}
   Tid={Timer}
   Cid={NewPortObject Init
        fun {$ state(Motor F Lid) Msg}
           case Motor %モーターの状態
           of running then
              case stoptimer then
                 {Send Lid `at`(F)}
                 state(stopped F Lid)
              end
           [] stopped then
              case Msg
              of step(Dest) then
                 if F==Dest then
                    state(stopped F Lid)
                 elseif F<Dest then
                    {Send Tid starttimer(5000 Cid)}
                    state(running F+1 Lid)
                 else % F>Dest
                    {Send Tid starttimer(5000 Cid)}
                    state(running F-1 Lid)
                 end
              end
           end
        end}
in Cid end

% 厳密に言えば「階数」もcontrollerの状態の一つ


% 階(Floor)
% 状態: リフトを呼んでいない，リフトを呼んだがまだ来てない，リフトが来た
% https://github.com/memerelics/ctmcp/tree/master/sec5/img/fig5.9.png
fun {Floor Num Init Lifts}
   Tid={Timer}
   Fid={NewPortObject Init
        fun {$ state(Called) Msg}
           case Called % 呼ばれたかどうかの状態
           of notcalled then Lran in
              case Msg
              of arrive(Ack) then
                 {Browse `Lift at floor `#Num#`: open dorrs`}
                 {Send Tid starttimer(5000 Fid)}
                 state(doorsopen(Ack))
              [] call then
                 {Browse `Floor `#Num#` calls a lift!`}
                 Lran=Lifts.(1+{OS.rand} mod {Width Lifts})
                 {Send Lran call(Num)}
                 state(called)
              end
           [] called then
              case Msg
              of arrive(Ack) then
                 {Browse `Lift at floor `#Num#`: open doors`}
                 {Send Tid starttimer(5000 Fid)}
                 state(doorsopen(Ack))
              [] call then
                 state(called)
              end
           [] doorsopen(Ack) then
              case Msg
              of stoptimer then
                 {Browse `Lift at floor `#Num#`: close doors`}
                 Ack=unit % データフロー変数の束縛，軽量メッセージ
                 state(notcalled)
              [] arrive(A) then
                 A=Ack
                 state(doorsopen(Ack))
              [] call then
                 state(doorsopen(Ack))
              end
           end
        end}
in Fid end


% リフト
% 状態:
%   1. スケジュールなしでリフトが停止(idle)
%   2. スケジュールありで指定された階をリフトが通りすぎている
%   3. スケジュールされた階を通りすぎて，ドアを待っている
%   4. 呼ばれた階で停止して，ドアを待っている

% https://github.com/memerelics/ctmcp/tree/master/sec5/img/fig5.11.png

% どのリフトもcall(N)メッセージと`at`(N)を受け取る．リフトは
% Floorにarrive(Ack)メッセージを，
% Controllerにstep(Dest)メッセージを送ることが出来る．

fun {ScheduleLast L N}
   if L\=nil andthen {List.last L}==N then L
   else {Append L [N]} end
end

fun {Lift Num Init Cid Floors}
   {NewPortObject Init
    fun {$ state(Pos Sched Moving) Msg}
       case Msg
       of call(N) then
          {Browse `Lift `#Num#` needed at floor `#N}
          if N==Pos andthen {Not Moving} then
             % 目的階に到着してもFIFOだから
             % 別の階に向かってて通り過ぎてる場合があるのか
             % 到着をFloorに知らせつつ何かしら反応帰るまでWait.
             {Wait {Send Floors.Pos arrive($)}}
             state(Pos Sched false)
          else Sched2 in
             Sched2={ScheduleLast Sched N}
             if {Not Moving} then
                {Send Cid step(N)} end
             state(Pos Sched2 true)
          end
       [] `at`(NewPos) then
          {Browse `Lift `#Num#` at floor `#NewPos}
          case Sched
          of S|Sched2 then
             if NewPos==S then
                {Wait {Send Floors.S arrive($)}}
                if Sched2==nil then
                   state(NewPos nil false)
                else
                   {Send Cid step(Sched2.1)}
                   state(NewPos Sched2 true)
                end
             else
                {Send Cid step(S)}
                state(NewPos Sched Moving)
             end
          end
       end
    end}
end


% ビル．いままでのコンポーネントを組み立てる場．
proc {Building FN LN ?Floors ?Lifts}
   Lifts={MakeTuple lifts LN}
   for I in 1..LN do Cid in
      Cid={Controller state(stopped 1 Lifts.I)}
      Lifts.I={Lift I state(1 nil false) Cid Floors}
   end
   Floors={MakeTuple floors FN}
   for I in 1..FN do
      Floors.I={Floor I state(notcalled) Lifts}
   end
end


% 動かす
declare F L in
{Building 10 2 F L}
{Send F.9 call}
{Send F.10 call}
{Send L.1 call(4)}
{Send L.2 call(5)}


% リフト制御システムに関する推論
% 正しく動くことを証明する話．


%% 5.5.3 リフト制御システムの改良
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 5通りの改良を行う(3,4,5は練習問題とのこと)(2も実装ないじゃん)
%   1. コンポーネント合成を使って階層的にする
%   2. ドアの開閉を工夫する
%   3. 交渉により最善のリフトを呼び出す
%   4. スケジューリングを改良し，リフトの動きを減らす
%   5. 事故(動作しないリフト)に対処する


% (1). コンポーネント合成を使って階層的にする
fun {LiftShaft I state(F S M) Floors}
   Cid={Controller state(stopped F Lid)}
   Lid={Lift I state(F S M) Cid Floors}
in Lid end

% ビルが簡単になる．
proc {Building FN LN ?Floors ?Lifts}
   Lifts={MakeTuple lifts LN}
   for I in 1..LN do Cid in
      % Cidの束縛がなくなる
      Lifts.I={LiftShaft I state(1 nil false) Floors}
   end
   Floors={MakeTuple floors FN}
   for I in 1..FN do
      Floors.I={Floor I state(notcalled) Lifts}
   end
end


% (2). ドアの開閉を工夫する
% 前節で作ったシステムは，あるリフトが着くとその階のドアが全部開き，一定時間後に全部閉じる，という動きをする．もっと現実的なモノにしよう．

% (3). 交渉により最善のリフトを呼び出す
% 前節の実装ではランダムに呼び出してたので，階に最も近いリフトを選ぶようにする．
% たとえば階がすべてのリフトにメッセージを送り，到着までの時間を問い合わせる．

% (4). スケジューリングを改良し，リフトの動きを減らす
% 5階に向けて現在2階を上昇中として，3階から呼び出しがあればスルーせずに3階で止まる，みたいな．
% エレベータアルゴリズムと呼ばれ，ハードディスクヘッドの動きに採用されている．
% このスケジューラを使えば呼び出しボタンを↑↓二種類にすることができる
% (いままでは単に呼ぶだけ，だったところに進みたい向きが加わる)

% (5). 事故(動作しないリフト)に対処する
% フォールトトレランス．
% 何らかの理由で一部の階に止まれなかったりリフトが動かなくなった時も，全体は問題なく動作するようにしなければならない．5.9練習問題で解説．