%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7.9. 能動的オブジェクト
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 能動的オブジェクト (active object) とは OOP の能力とメッセージ伝達並列性の間の子
% * ポートオブジェクトであり，
% * その振る舞いがクラスによって定義されているもの

% 構成要素
% * ポート
% * ポートストリームからメッセージを読むスレッド
% * クラスインスタンスであるオブジェクト

% 受信されたメッセージはオブジェクトのメソッドのひとつを起動する．
% active object A にメッセージ M を送ることを {A M} と書くが，
% これは標準の受動的オブジェクトの起動と同じ

declare
fun {NewActive Class Init}
  Obj={New Class Init}
  P
in
  thread S in
    {NewPort S P}
    for M in S do {Obj M} end
  end
  proc {$ M} {Send P M} end
end

% fig7.31.
declare
class BallGame
   attr other count:0
   meth init(Other)
      other:=Other
   end
   meth ball
      count:=@count+1
      {@other ball}
   end
   meth get(X)
      X=@count
   end
end

declare
B1={NewActive BallGame init(B2)}
B2={NewActive BallGame init(B1)}
{B1 ball}


%% 7.8.3. Flavius Josephus の問題
% "1 番から n 番までの n 人の兵士がいて，最初の兵士から k 番目ごとに自殺する" すごい

% fig7.34. Flavius Josephus の問題 (能動的オブジェクト版)
declare
class Victim
   attr ident step last succ pred alive:true
   meth init(I K L) ident:=I step:=K last:=L end
   meth setSucc(S) succ:=S end
   meth setPred(P) pred:=P end
   meth kill(X S)
      if @alive then
         if S==1 then @last=@ident
         elseif X mod @step==0 then
            alive:=false
            {@pred setSucc(@succ)}
            {@succ setPred(@pred)}
            {@succ kill(X+1 S-1)}
         else
            {@succ kill(X+1 S)}
         end
      else {@succ kill(X S)} end
   end
end

fun {Josephus N K}
   A={NewArray 1 N null}
   Last
in
   for I in 1..N do
      A.I:={NewActive Victim init(I K Last)}
   end
   for I in 2..N do {A.I setPred(A.(I-1))} end
   {A.1 setPred(A.N)}
   for I in 1..(N-1) do {A.I setSucc(A.(I+1))} end
   {A.N setSucc(A.1)} {A.1 kill(1 N)}
   Last
end


%% 短縮プロトコル(shortcircuit protocol)
% 死んだオブジェクトも引き続き存在してるとスキップしていく必要があり n がでかいと無駄が多い．
% そこで上の fig7.34 では死んだら取り除いてる

%% 宣言的モデルによる解
% よく見ると fig7.34 には観測可能な非決定性がなく，宣言的モデルで書ける. やってみよう

% fig7.35. - Flavius Josephus の問題 (データ駆動並列版)
declare
fun {Pipe Xs L H F}
   if L=<H then {Pipe {F Xs L} L+1 H F} else Xs end
end

fun {Josephus2 N K}
   fun {Victim Xs I}
      case Xs of kill(X S)|Xr then
         if S==1 then Last=I nil
         elseif X mod K==0 then
            kill(X+1 S-1)|Xr
         else
            kill(X+1 S)|{Victim Xr I}
         end
      [] nil then nil end
   end
   Last Zs
in
   Zs={Pipe kill(1 N)|Zs 1 N
       fun {$ Is I} thread {Victim Is I} end end}
   Last
end


%% 7.8.4. その他の能動的オブジェクト抽象

% 同期的能動的オブジェクト 的的
fun {NewSync Class Init}
  P Obj={New Class Init}
in
  thread S in
    {NewPort S P}
    for M#X in S do {Obj M} X=unit end
  end
  proc {$ M} X in {Send P M#X} {Wait X} end
end

% 例外処理を行う能動的オブジェクト
fun {NewActiveExc Class Init}
  P Obj={New Class Init}
in
  thread S in
    {NewPort S P}
    for M#X in S do
      try {Obj M} X=normal
      catch E then X-exception(E) end
    end
  end
  proc {$ M X} {Send P M#X} end
end

% 同期的な場合を考えて proc を case 使って書くことも出来る
proc {$ M}
  X
in
  {Send P M#X}
  case X
    of normal then skip
    [] exception(E) then raise E end
  end
end


%% 7.8.5. 能動的オブジェクトを使うイベントマネージャ
% "イベントマネージャはイベントハンドラの集合を含む"
% ハンドラ = Id#F#S であり， finite state machine である．
%  * F...状態更新関数
%  * S...ハンドラの状態

% fig7.36. - 能動的オブジェクトを持つイベントマネージャ
declare
class EventManager
   attr
      handlers
   meth init handlers:=nil end
   meth event(E)
      handlers:=
         {Map @handlers fun {$ Id#F#S} Id#F#{F E S} end}
   end
   meth add(F S ?Id)
      Id={NewName}
      handlers:=Id#F#S|@handlers
   end
   meth delete(DId ?DS)
      handlers:={List.partition
         @handlers fun {$ Id#F#S} DId==Id end [_#_#DS]}
   end
end

declare
EM={NewActive EventManager init}
% "メモリベースハンドラ"
MemH=fun {$ E Buf} E|Buf end
Id={EM add(MemH nil $)}

% "ディスクベースハンドラ"
DiskH=fun {$ E F} {F write(vs:E)} F end
% システムモジュールのOpenを使って書き出す
File={New Open.file init(name:'event.log')
                    flags:[write create]}
Buf={EM delete(Id $)}
for E in {Reverse Buf} do {File write(vs:E)} end
Id2={EM add(DiskH File $)}


%% 継承を使って機能を追加すること
% fig7.37.
% insert field は optional. <= がデフォルトの定義だったのを思い出す.
declare
class ReplaceEventManager from EventManager
   meth replace(NewF NewS OldId NewId
                insert:P<=proc {$ _} skip end)
      Buf=EventManager,delete(OldId $)
   in
      {P Buf}
      NewId=EventManager,add(NewF NewS $)
   end
end


% fig7.38. - メッセージと手続きのリストをバッチ処理すること
declare
class Batcher
   meth batch(L)
      for X in L do
         if {IsProcedure X} then {X} else {self X} end
      end
   end
end

% 使う
declare
class BatchingEventManager from EventManager Batcher end
EM={NewActive BatchingEventManager init}


% ここまで来てようやく，メモリベースハンドラをディスクベースハンドラに置き換えることが出来る
DiskH=fun {$ E S} {S write(vs:E)} S end
File={New Open.file init(name:'event.log' flags:[write create])}
Buf Id2
{EM batch([delete(Id Buf)
           proc {$}
             for E in {Reverse Buf} do {File write(vs:E)} end
           end
           add(DiskH File Id2)])}

% batch メソッドは能動的オブジェクト内部で実行されるため replace 同様 atomicity が保証される
