%% 8.5. トランザクション
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 大規模共有データベースを管理するための概念としてトランザクションが導入された

% 今では"トランザクション"というコトバはACID特性を満たすものとして定義されている
% - Atomic: 原子性. トランザクションの実行に中間状態がないこと.
% - Consistent: 一貫性. 観測可能な状態変化がシステム不変表明を破らないこと(?)
% - Isolation: 孤立性. いくつかのトランザクションが並列に，相互に干渉せず実行されること.
% - Durability: 耐久性. 状態変化がシステムシャットダウン後も有効であること. 永続性とも.

% Durability はディスクへの書き込みによって実現されるが, データベースに固有の性質で，
% D を除いた ACI だけでも "計量トランザクション" として意味はある.
% ACI は要するにアボート可能な原子的アクションである.


%% 8.5.1 並列性制御

% * ロックベース並列性制御
%   トランザクションがセルを使うにはそのロックを持っていなければならない
% * タイムスタンプベース並列性制御
%   生存性に関する性質. つまり"いずれ真になる"

% 「常に真である(is always true)」と「いずれ真になる(eventually becomes true)」の違い.
% 「アクティブトランザクションはいずれアボートするかコミットする」という性質はこのタイプ.
% 時相論理(temporal logic).

% 2相ロック two-phase locking
% 最も普及してるロック技法
% 2相ロックを使うとトランザクションが直列化可能であることが保証される. 特徴:
%   * growing phase で ロックを獲得するが手放さない
%   * shrinking phase でロックを手放すが獲得しない
%   * 1つのトランザクションでロックを手放した後，引き続き別のロックを獲得することはしない.

% ちょっとバージョンアップした"厳正2相ロック"は，
% トランザクション終了(commit/abort)と同時にすべてのロックが手放される.


%% 8.5.2 簡易トランザクションマネージャ

% 簡易な実装だとデッドロックが起こる, という入りから.
% 対策はふたつ. 予防と治療. どちらも wait-for 関係グラフのデータを元にする.
% デッドロックは wait-for グラフの閉路に相当する.
% 基本的には, ロックを獲得しようとする時，すでに獲得しているトランザクションと"優先度"を比較する. たとえば新しさで優劣付けるかもしれない.
% で，こうすると"トランザクションが任意の場所で終了してしまう"という問題が発生する. 割り込み, プリエンプション... と同じよね

% 3つの状態があるstate machineとして設計する
%   * running: "印"なしの状態. 自由に実行中，ロックを獲得できる
%   * probation: "印"が付いた状態. 次にロックを獲得しようとすると"リスタート"になる
%   * waiting_for(C): セルCのロックを待ってる. 待ってる間に，別の優先度の高いトランザクションがCを望めば，こいつはリスタートになる


%% 8.5.3 セルについてのトランザクション

% e.g.
declare Trans NewCellT in
{NewTrans Trans NewCellT}

C1={NewCellT 0}
C2={NewCellT 0}

% 出力に関心がないので手続き構文を使う
{Trans proc {$ T _}
          {T.assign C1 {T.access C1}+1}
          {T.assign C2 {T.access C2}+1}
       end _ _}
% トランザクションは原子的なので@C1+@C2=0が常に成り立つ．不変表明.

{Browse {Trans fun {$ T} {T.access C1}#{T.access C2} end _}}


% トランザクションの利点がわかる別の例. ロックに比べた利点はつまり
%   1. アボートするとセルの元の状態が回復する
%   2. ロックをどんな順序にしてもよく，しかもデッドロックにならない

D={MakeTuple db 100}
for I in 1..100 do D.i={NewCellT I} end

fun {Rand} {OS.rand} mod 100 + 1 end
proc {Mix} {Trans
            proc {$ T _}
               I={Rand} J={Rand} K={Rand}
               A={T.access D.I} B={T.access D.J} C={T.access D.K}
            in
               {T.assign D.I A+B-C}
               {T.assign D.J A-B+C}
               if I==J orelse I==K orelse J==K then {T.abort} end
               {T.assign D.K ~A+B+C}
            end _ _}
end

% Sumの定義.
S={NewCellT 0}
fun {Sum}
   {Trans
    fun {$ T} {T.assign $ 0}
       for I in 1..100 do
          {T.assign S {T.access S}+{T.access D.I}} end
       {T.access S}
    end _}
end


{Browse {Sum}} % => 5050
for I in 1..1000 do thread {Mix} end end
{Browse {Sum}} % => 5050

% セルの内容がうまく入れ替わっているかどうかチェック
{Browse {Trans fun {$ T} {T.access D.1}#{T.access D.2} end _}}


%% 8.5.4 セルについてのトランザクションを実装すること
% 楽観的2相ロックアルゴリズムを実装するトランザクションシステム.
% トランザクションマネージャ (トランザクション処理モニタ transaction processing monitor) を作る
% トランザクションマネージャは常にアクティブ
% あるトランザクションがリスタートするとき，別のスレッドで再開するが，その時タイムスタンプを受け継ぐ.

% fig 8.23 - トランザクションシステムの実装(第1部)
declare
class TMClass
   attr timestamp tm
   meth init(TM) timestamp:=0 tm:=TM end

   meth Unlockall(T RestoreFlag)
      for save(cell:C state:S) in {Dictionary.items T.save} do
         (C.owner):=unit
         if RestoreFlag then (C.state):=S end
         if {Not {C.queue.isEmpty}} then
         Sync2#T2={C.queue.dequeue} in
            (T2.state):=running
            (C.owner):=T2 Sync2=ok
         end
      end
   end

   meth Trans(P ?R TS) /* See next figure */ end
   meth getlock(T C ?Sync) /* See next figure */ end

   meth newtrans(P ?R)
      timestamp:=@timestamp+1 {self Trans(P R @timestamp)}
   end
   meth savestate(T C ?Sync)
      if {Not {Dictionary.member T.save C.name}} then
         (T.save).(C.name):=save(cell:C state:@(C.state))
      end Sync=ok
   end
   meth commit(T) {self Unlockall(T false)} end
   meth abort(T) {self Unlockall(T true)} end
end

proc {NewTrans ?Trans ?NewCellT}
TM={NewActive TMClass init(TM)} in
   fun {Trans P ?B} R in
      {TM newtrans(P R)}
      case R of abort then B=abort unit
      [] abort(Exc) then B=abort raise Exc end
      [] commit(Res) then B=commit Res end
   end
   fun {NewCellT X}
      cell(name:{NewName} owner:{NewCell unit}
           queue:{NewPrioQueue} state:{NewCell X})
   end
end


% fig 8.24 - トランザクションシステムの実装 (第2部)
% さっき "See next figure" として切りだされてた Trans, getlock の実装
meth Trans(P ?R TS)
   Halt={NewName}
   T=trans(stamp:TS save:{NewDictionary} body:P
           state:{NewCell running} result:R)
   proc {ExcT C X Y} S1 S2 in
      {@tm getlock(T C S1)}
      if S1==halt then raise Halt end end
      {@tm savestate(T C S2)} {Wait S2}
      {Exchange C.state X Y}
   end
   proc {AccT C ?X} {ExcT C X X} end
   proc {AssT C X} {ExcT C _ X} end
   proc {AboT} {@tm abort(T)} R=abort raise Halt end end
in
   thread try Res={T.body t(access:AccT assign:AssT
                            exchange:ExcT abort:AboT)}
          in {@tm commit(T)} R=commit(Res)
          catch E then
             if E\=Halt then {@tm abort(T)} R=abort(E) end
   end end
end

meth getlock(T C ?Sync)
   if @(T.state)==probation then
      {self Unlockall(T true)}
      {self Trans(T.body T.result T.stamp)} Sync=halt
   elseif @(C.owner)==unit then
      (C.owner):=T Sync=ok
   elseif T.stamp==@(C.owner).stamp then
      Sync=ok
   else /* T.stamp\=@(C.owner).stamp */ T2=@(C.owner) in
      {C.queue.enqueue Sync#T T.stamp}
      (T.state):=waiting_on(C)
      if T.stamp<T2.stamp then
         case @(T2.state) of waiting_on(C2) then
         Sync2#_={C2.queue.delete T2.stamp} in
            {self Unlockall(T2 true)}
            {self Trans(T2.body T2.result T2.stamp)}
            Sync2=halt
         [] running then
            (T2.state):=probation
         [] probation then skip end
      end
   end
end


% fig 8.25 - 優先順位キュー
declare
fun {NewPrioQueue}
   Q={NewCell nil}
   proc {Enqueue X Prio}
      fun {InsertLoop L}
         case L of pair(Y P)|L2 then
            if Prio<P then pair(X Prio)|L
            else pair(Y P)|{InsertLoop L2} end
         [] nil then [pair(X Prio)] end
      end
   in Q:={InsertLoop @Q} end

   fun {Dequeue}
      pair(Y _)|L2=@Q
   in
      Q:=L2 Y
   end

   fun {Delete Prio}
      fun {DeleteLoop L}
         case L of pair(Y P)|L2 then
            if P==Prio then X=Y L2
            else pair(Y P)|{DeleteLoop L2} end
         [] nil then nil end
      end X
   in Q:={DeleteLoop @Q} X end

   fun {IsEmpty} @Q==nil end
in
   queue(enqueue:Enqueue dequeue:Dequeue
         delete:Delete isEmpty:IsEmpty)
end
