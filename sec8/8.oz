%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                  8. 状態共有並列性
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

8.1. 状態共有並列モデルの定義
8.2. すべての並列モデルを比較
8.3. ロックという概念を導入

状態共有並列モデル(shared-state concurrent model)
  = 宣言的並列モデル + 明示的状態(セル)

セルに対する操作は最終的に一本の順序になる(interleaved)が,
スレッドの数が増えるほど取りうる場合の数が大きくなる

宣言的並列モデルは簡単であったが, スレッド同士が"lockstep"あるいは"systolic"に通信しなければならない,
つまりスレッド同士は独立に実行できない(協調しなければならない)という問題があった.

状態あり並列モデルでプログラムすること = インタリーブを管理すること


%% 8.1. 状態共有並列モデル
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

宣言的並列モデル(...スレッド生成)
+ 名前生成
+ 読み出し専用ビュー
+ 例外コンテクスト
+ 例外発生
+ セル生成
+ セル交換


%% 8.2. 並列性を持つプログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

これまで見てきた並列プログラムのまとめ

* 直列プログラミング
  * すべての操作に全順序がある
* 宣言的並列性
* メッセージ伝達並列性
* 状態共有並列性(本章)


%% 8.2.2. 状態共有並列モデルを直接使うこと

% 潜在的に膨大な数のinterleave組み合わせがあり,
% そのすべての場合で正しく動作する必要が有るため大変.
% 大変さを回避するため能動的オブジェクトや原子的アクションが導入されたのだが,
% 状態共有並列モデルを直接使うことが有効な場合もある.

% fig8.3. 並列スタック
declare
fun {NewStack}
   Stack={NewCell nil}
   proc {Push X}
   S in
      {Exchange Stack S X|S}
   end
   fun {Pop}
   X S in
      {Exchange Stack X|S S}
      X
   end
in
   stack(push:Push pop:Pop)
end

% Exchange はセルの内容を原子的に交換する. 原子的なので並列環境でも使える
% 空のスタックをpopすることだけが例外発生のトリガー.
fun {Pop}
   X S in
   try {Exchange Stack X|S S}
   catch failure(...) then raise stachEnpty end end
   X
   end
end
% それ以外は問題なく動く

%% 遅いネットワークをシミュレートする
% これは順序を保証しない.
fun {SlowNet1 Obj D}
   proc {$ M}
      thread
         {Delay D} {Obj M}
      end
   end
end

% 順序を保障する版
% token passing という技法を使っている. Wait で到着を待つ.
fun {SlowNet2 Obj D}
   C={NewCell unit} in
   proc {$ M}
      Old New in
      {Exchange C Old New}
      thread
         {Delay D} {Wait Old} {Obj M} New=unit
      end
   end
end


%% 8.2.3. 原子的アクションを使うプログラミング

% ロックを導入

% * ロックを再入可能(reentrant)にする.
%   つまりロックのある部分の中にあるスレッドは, そのロック内の任意の部分に待たずに再び入ることが出来る
% * モニタ = ロックに待機展(wait point)を設けたもの
% * トランザクション = ロックの終わり方に正常(commit)と例外(abort)の2種を設けたもの


%% 8.3. ロック
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ロックにはいろいろあるが,
% Ozが直接支援しているのはスレッド再入ロック(thread-reentrant lock)で次のような文法を持つ

% {NewLock L} -- 新しいロックを返す
% {IsLock X}  -- X があるロックを参照している時に限ってtrueとなる
% lock X then <stmt> end
%   -- <stmt> をロック X で防護する. ロックXを実行するスレッドは常に一つ.
%      ロックは, それが防護しているどの部分にも高々1つのスレッドしかいないことを保証するもの


%% 8.3.1. 状態あり並列データ抽象を構築すること

% Fig. 8.6
% 3.4.4 (p.147) の宣言的キュー
declare
fun {NewQueue}
X in
   q(0 X X)
end

fun {Insert q(N S E) X}
E1 in
   E=X|E1 q(N+1 S E1)
end

fun {Delete q(N S E) X}
S1 in
   S=X|S1 q(N-1 S1 E)
end


% Fig. 8.7
% 直列状態あり実装.
% キューのデータをカプセル化している
declare
fun {NewQueue}
   X C={NewCell q(0 X X)}
   proc {Insert X}
   N S E1 in
      q(N S X|E1)=@C
      C:=q(N+1 S E1)
   end
   fun {Delete}
   N S1 E X in
      q(N X|S1 E)=@C
      C:=q(N-1 S1 E)
      X
   end
in
   queue(insert:Insert delete:Delete)
end


% Fig. 8.8
% 状態ありキューの並列版. ロックを使う.
declare
fun {NewQueue}
   X C={NewCell q(0 X X)}
   L={NewLock}
   proc {Insert X}
   N S E1 in
      lock L then
         q(N S X|E1)=@C
         C:=q(N+1 S E1)
      end
   end
   fun {Delete}
   N S1 E X in
      lock L then
         q(N X|S1 E)=@C
         C:=q(N-1 S1 E)
      end
      X
   end
in
   queue(insert:Insert delete:Delete)
end


% Fig. 8.9
% 同じ内容をオブジェクト指向版で書いたもの.
% ロックは性質lockingで暗黙に定義される
declare
class Queue
   attr queue
   prop locking

   meth init
      queue:=q(0 X X)
   end

   meth insert(X)
      lock N S E1 in
         q(N S X|E1)=@queue
         queue:=q(N+1 S E1)
      end
   end

   meth delete(X)
      lock N S1 E in
         q(N X|S1 E)=@queue
         queue:=q(N-1 S1 E)
      end
   end
end


% Fig. 8.10
% Exchange を使う並列状態ありのキュー
declare
fun {NewQueue}
   X C={NewCell q(0 X X)}
   proc {Insert X}
   N S E1 N1 in
      {Exchange C q(N S X|E1) q(N1 S E1)}
      N1=N+1
   end
   fun {Delete}
   N S1 E N1 X in
      {Exchange C q(N X|S1 E) q(N1 S1 E)}
      N1=N-1
      X
   end
in
   queue(insert:Insert delete:Delete)
end


%% 8.3.2 タプル空間(Linda)(tuple space)

% Linda = 最初の tuple space (1985)
% 並列プログラムのための有用な抽象. タプル空間TSは基本操作write, read, readnonblockを持つ.

%   {TS write(T)}
%   {TS read(L T)}
%   {TS readnonblock(L T B)}

% Fig 8.12 タプル空間の実装(順番前後)
declare
class TupleSpace
   prop locking
   attr tupledict

   meth init tupledict:={NewDictionary} end

   meth EnsurePresent(L)
      if {Not {Dictionary.member @tupledict L}}
      then @tupledict.L:={NewQueue} end
   end

   meth Cleanup(L)
      if {@tupledict.L.size}==0
      then {Dictionary.remove @tupledict L} end
   end

   meth write(Tuple)
      lock L={Label Tuple} in
         {self EnsurePresent(L)}
         {@tupledict.L.insert Tuple}
      end
   end

   meth read(L ?Tuple)
      lock
         {self EnsurePresent(L)}
         {@tupledict.L.delete Tuple}
         {self Cleanup(L)}
      end
      {Wait Tuple}
   end

   meth readnonblock(L ?Tuple ?B)
      lock
         {self EnsurePresent(L)}
         if {@tupledict.L.size}>0 then
            {@tupledict.L.delete Tuple} B=true
         else B=false end
         {self Cleanup(L)}
      end
   end
end

% Fig. 8.11
% セルの代わりにTupleSpaceを使うバージョンのQueue
declare
fun {NewQueue}
   X TS={New TupleSpace init}
   proc {Insert X}
   N S E1 in
      {TS read(q q(N S X|E1))}
      {TS write(q(N+1 S E1))}
   end
   fun {Delete}
   N S1 E X in
      {TS read(q q(N X|S1 E))}
      {TS write(q(N-1 S1 E))}
      X
   end
in
   {TS write(q(0 X X))}
   queue(insert:Insert delete:Delete)
end


% 使ってみる
declare
TS={New TupleSpace init}
thread {Browse {TS read(foo $)}} end


%% 8.3.3. ロックを実装すること

% SimpleLock -> 例外を扱えるLock -> 再入可能Lock の順に拡張していく

% Fig. 8.13
% ロック(例外処理を行わない非再入版)
declare
fun {SimpleLock}
   Token={NewCell unit}
   proc {Lock P}
   Old New in
      {Exchange Token Old New}
      {Wait Old}
      {P}
      New=unit
   end
in
   'lock'('lock':Lock)
end


% Fig. 8.14
% ロック(例外処理を行う非再入版)
declare
fun {CorrectSimpleLock}
   Token={NewCell unit}
   proc {Lock P}
   Old New in
      {Exchange Token Old New}
      {Wait Old}
      try {P} finally New=unit end
   end
in
   'lock'('lock':Lock)
end


% Fig. 8.15
% ロック(例外処理を行う再入版)
declare
fun {NewLock}
   Token={NewCell unit}
   CurThr={NewCell unit}
   proc {Lock P}
      if {Thread.this}==@CurThr then
         {P}
      else Old New in
         {Exchange Token Old New}
         {Wait Old}
         CurThr:={Thread.this}
         try {P} finally
            CurThr:=unit
            New=unit
         end
      end
   end
in
   'lock'('lock':Lock)
end
