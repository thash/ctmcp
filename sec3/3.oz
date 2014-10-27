%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3.1 宣言的とはどういうことか？
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 宣言的とは: 「どのように」を説明せず「何」を定義することでプログラムすること


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3.2 反復計算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 反復計算はループで, そのスタックの大きさは反復回数によらず, 一定を超えないものである.
%% あるプログラムが反復的であるかどうかは必ずしも明らかではない.

%% 一般的図式
%% S0 -> S1 -> ... -> Sfinal
fun {Iterate S_i}
   if {IsDone S_i} then S_i
   else S_(i+1) in
      S_(i+1)={Transform S_i}
      {Iterate S_(i+1)}
   end
end


%% 3.2.2 数についての反復
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ニュートン法


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3.3 再帰計算
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% > 反復計算は, 再帰計算(recursive computation)というもっと一般的な計算の特殊ケースである
%% 反復計算とは要するに, あるアクションが何回か繰り返されるループである.
%% 再帰はより一般的で, その本体のどこででも自分自身を呼び出すことが出来, 2度以上呼び出すことも出来る.

%% 階乗をそのまま核言語に翻訳した以下の式は, 再帰呼び出しのあとに掛け算があることから,
%% 再帰呼び出しの最中に掛け算のための情報を保持しておく必要があり, スタックが大きくなりそうだと推測できる.
proc {Fact N ?R}
   if N==0 then R=1
   elseif N>0 then N1 R1 in
      N1=N-1
      {Fact N1 R1}
      R=N*R1
   else raise domainError end
   end
end

%% https://dl.dropboxusercontent.com/s/qunxux05hjbywy4/2014-10-14%20at%2011.02%20PM.png?dl=0


%% 3.3.3 再帰計算を反復計算に変換すること
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% R = (5*(4*(3*(2*1))))
%% これはそれぞれ「後で結果にかけるべき数」を記憶していく必要があるので, 記憶領域が増大していく.
%%
%% R = (((5*4)*3)*2)*1))
%% このように左結合に書き換えることで, 結果を次々置き換えるだけでstack消費しない.


%% 数学的な定義から反復にもってくのは自明ではないように見える. なんか小細工を弄してる感.
%% "何らかの理由付けをしなければならない" p.132
%% ;; あとで説明されるらしい

%% ;; メモ: 3.4.7は実際に動かない話なのでskipして3.4.8を先にやっていいかもとのこと.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3.4 再帰を用いるプログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 静的型付言語的なチェックをするのが目的ではない
%%
%% "手続きの型はその手続きのシグニチャ(signature)と言われることがある. その手続に関する主要情報を簡潔に伝えるからである."
%% CTMCP p.133
%%
%% 状態変換の列に作りなおすと反復にできる.
%%
%% 状態 Si = (i, Ys)
%%   i: 通過したものから持ち越した"結果". Lengthだと長さの値
%%   Ys: まだ通過してないもの
%%
%% 状態不変表明(state invariant)
%%
%% "状態不変表明になるようにiとYsが結合されている" とは?
%%
%% わかった(たぶん)
%%
%% まずS0,S1,...Sfinalまでのすべての状態において成り立つような状態の性質 P(Si) を見つける(この時点では正しいっぽい, とだけ)
%% それを帰納法で証明できる(証明できるなら他の方法でもいいだろうけど状態列だから帰納法が簡単だろう)
%%
%% 状態列の全てで成り立つ性質(状態不変表明: state invariant)を見つけて帰納法で証明することで関数の正しさが証明できる みたいな感じか. 再帰から(可能な場合)反復に変換することで証明できるようになる?


%% 3.4.3 アキュムレータ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 3.4.4 差分リスト
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 差分リストとは: 2つのリストの対として表現され, どちらのリストにも束縛されていない尾部がある"かもしれない"もの.
%% 最初のリストの先頭から0個以上の要素を削除したら2番目のリストが現れる.

% 空リスト x 3
X#X
nil#nil
[a]#[a]

 % [a b c]を表す x 3
(a|b|c|X)#X
(a|b|c|d|X)#(d|X)
[a b c d]#[d]

%% 要は第一リストから第二リストの要素を引いた"差分"が, 本来表したいリストであるような構造

%% 差分リストの利点
%%   1. 簡単に反復を作れるようになる(これは差分構造であれば木なんかでも言える)
%%   2. 第二リストが未束縛変数であれば定数時間でappendが可能.

%% (2)の例
fun {AppendD D1 D2}
   S1#E1=D1 % E1は未束縛変数, という前提だった
   S2#E2=D2
in
   E1=S2 % 未束縛だったE1にS2, 第二引数前半部を束縛
   %% S1は第一引数の前半...だったが, D1のケツにS2を束縛した時点で既に連結済.
   %% E2は第二引数の元々の後半. 返すリストも差分リストの形にしてるだけ.
   S1#E2
end


%% SICPではfringeとして実装した. 効率化しようとしてloopの中にloopを入れる, としたがそれと同じ.
%% 差分リストという概念を使わず辿り着いていた

%% 差分listに対して何か操作を行うと新しいqueueを作って返す.
%% 参考スライドは後ろのほうが逆だけどCTMCPは表現が違う.




%% 3.4.5 キュー
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% キュー(queue, 待ち行列)は挿入操作と削除操作をもつ要素の列. リストを使って実装できる.
%% 単純なFIFOを実装する場合, "out"時に ... が発生する
%%

%% Amortized constant-time ephemeral queue(償却的一定時間単用的キュー)
declare NewQueue Check Insert Delete IsEmpty
fun {NewQueue} q(nil nil) end
fun {Check Q}
   case Q of q(nil R) then q({Reverse R} nil) else Q end
end
fun {Insert Q X}
   case Q of q(F R) then {Check q(F X|R)} end
end
fun {Delete Q X}
   case Q of q(F R) then F1 in F=X|F1 {Check q(F1 R)} end
end
fun {IsEmpty Q}
   case Q of q(F R) then F==nil end
end

%% Rの各要素をFへ移動するという操作が遅かれ早かれ必要になる.
%% 要素が挿入されるたびやってしまうと毎回最後まで辿っていく処理が必要になり非効率.
%% 解としては「たまに行う」. Checkでそれを行う.

%% 宣言的モデルからデータフロー変数を除いた"正格関数型プログラミング"(p.98)だと 償却的一時時間操作が関の山
%% だが, ozにはデータフロー変数がある(= 完全な宣言的モデル)ので差分リストが使える

%% Worst-case constant-time ephemeral queue(最悪時一定時間単用的キュー)
declare NewQueue Check Insert Delete IsEmpty
fun {NewQueue} X in q(0 X X) end % タプルの第一要素に"長さ"を持つ.
fun {Insert Q X}
   case Q of q(N S E) then E1 in E=X|E1 q(N+1 S E1) end
end
fun {Delete Q X}
   case Q of q(N S E) then S1 in S=X|S1 q(N-1 S1 E) end
end
fun {IsEmpty Q}
   case Q of q(N S E) then N==0 end
end

%% キューの内容はS#Eで表せる.

declare Q1 Q2 Q3 Q4 Q5 Q6 Q7 in
Q1={NewQueue}
Q2={Insert Q1 peter}
Q3={Insert Q2 paul}
local X in Q4={Delete Q3 X} {Browse X} end % => peter
Q5={Insert Q4 mary}
local X in Q6={Delete Q5 X} {Browse X} end % => paul
local X in Q7={Delete Q6 X} {Browse X} end % => mary


%% 3.4.6 木
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% リストは一分木(unary tree)であるとも言える.
%% この章では二分木を描画するアルゴリズム, 木を処理する高次の技法,
%% 順序付き二分木(ordered binary tree)を使って辞書(dictionary)を実装する.

%% 3.4.6.1 順序付き二分木(OBTree)

<OBTree> ::= leaf
           | tree(<OValue> <Value> <OBTree1> <OBTree2>)


%% 実装例
%% fig0 (from: http://www.cs.cmu.edu/~adamchik/15-121/lectures/Trees/pix/pix03.bmp)
%%   * leafは値を持たない
%%   * 今は整数を考えるのでOValueとValueが同じ
declare T
T=tree(10 10
       tree(6 6
            tree(4 4 leaf leaf)
            tree(8 8 leaf leaf))
       tree(18 18
            tree(15 15 leaf leaf)
            tree(21 21 leaf leaf)))
{Browse T}

%% 3.4.6.2 木に情報を格納すること
declare Lookup Insert

%% 木Tの中から要素Xを探す
fun {Lookup X T}
   case T
   of leaf then notfound
   [] tree(Y V T1 T2) then
      if X<Y then {Lookup X T1}
      elseif X>Y then {Lookup X T2}
      else found(V) end
   end
end

%% andthenを使って読みやすく
fun {Lookup X T}
   case T
   of leaf then notfound
   [] tree(Y V T1 T2) andthen X==Y then found(V)
   [] tree(Y V T1 T2) andthen X<Y then {Lookup X T1}
   [] tree(Y V T1 T2) andthen X>Y then {Lookup X T2}
   end
end

{Browse {Lookup 6 T}} % => found(6)


fun {Insert X V T}
   case T
   of leaf then tree(X V leaf leaf)
   [] tree(Y W T1 T2) andthen X==Y then
      tree(X V T1 T2) % OValueをY->X, ValueをW->Vに置き換え
   [] tree(Y W T1 T2) andthen X<Y then
      tree(Y W {Insert X V T1} T2)
   [] tree(Y W T1 T2) andthen X>Y then
      tree(Y W T1 {Insert X V T2})
   end
end

{Browse {Insert 5 5 T}}


%% 3.4.6.3 削除と木の再構成
%% Deleteしたあとも"順序付けられている"という大局的条件を満たさなければならないため難しさがある
declare Delete RemoveSmallest

fun {IncorrectDelete X T}
   case T
   of leaf then leaf
   [] tree(Y W T1 T2) andthen X==Y then leaf %% <== 間違い
   [] tree(Y W T1 T2) andthen X<Y then
      tree(Y W {IncorrectDelete X T1} T2)
   [] tree(Y W T1 T2) andthen X>Y then
      tree(Y W T1 {IncorrectDelete X T2})
   end
end

%% 節を削除するときのパターン
%%   (A). T1 leaf, T2 leaf => 節自体を削除
%%   (B). T1 tree, T2 leaf => T1に置き換え
%%   (C). T1 tree, T2 tree => T2の最小値を新たな値Ypとする(Yp = T2 min > T1 max)

%% パターン(C)を実現するRemoveSmallestを実装する
fun {RemoveSmallest T}
   case T
   of leaf then none
   [] tree(Y V T1 T2) then
      case {RemoveSmallest T1}
      of none then Y#V#T2
      [] Yp#Vp#Tp then Yp#Vp#tree(Y V Tp T2)
      end
   end
end

%% 完全版Delete
fun {Delete X T}
   case T
   of leaf then leaf
   [] tree(Y W T1 T2) andthen X==Y then
      case {RemoveSmallest T2}
      of none then T1
      [] Yp#Vp#Tp then tree(Yp Vp T1 Tp)
      end
   [] tree(Y W T1 T2) andthen X<Y then
      tree(Y W {Delete X T1} T2)
   [] tree(Y W T1 T2) andthen X>Y then
      tree(Y W T1 {Delete X T2})
   end
end

{Browse T}
{Browse {Delete 8 T}}
{Browse {Delete 6 T}}
{Browse {Delete 10 T}}

%% fig1


%% 3.4.6.4 木の走査(traverse)

%% ある決まった順序で, 木のすべての節にある操作を施す. タイプは大きく分けてふたつ
%%   1. 深さ優先走査(depth-first traversal: DFS)
%%   2. 幅優先走査(breadth-first traversal: BFS)

%% 深さ優先で描画するだけ
declare DFS
proc {DFS T}
   case T
   of leaf then skip
   [] tree(Key Val L R) then
      {Browse Key#Val}
      {DFS L}
      {DFS R}
   end
end

{DFS T} % => fig2

%% つぎに, 走査してすべてのKeyと情報の対をリストにして返すアキュームレータを作成する.
declare DFSAccLoop DFSAcc

%% 以前3.4.2.4(p.139)で定義した反復版のReverse再掲
declare IterReverse Reverse
fun {IterReverse Rs Ys}
   case Ys
   of nil then Rs
   [] Y|Yr then {IterReverse Y|Rs Yr}
   end
end
fun {Reverse Xs}
   {IterReverse nil Xs}
end


proc {DFSAccLoop T S1 ?Sn}
   case T
   of leaf then Sn=S1
      [] tree(Key Val L R) then S2 S3 in
      S2=Key#Val|S1 % (Key, (Val, S1))
      {DFSAccLoop L S2 S3}
      {DFSAccLoop R S3 Sn}
   end
end
fun {DFSAcc T} {Reverse {DFSAccLoop T nil $}} end

{Browse {DFSAcc T}}
%% => [10#10 6#6 4#4 8#8 18#18 15#15 21#21]


%% 先の定義は, あとからReverseで正しい順序に直していたが,
%% 以下2点によって最初から正しい順序で実行するパターンも実装できる.
%%   * 束縛されていないデータフロー変数を使う
%%   * S1#Snを差分リストとみなしている
declare DFSAccLoop2 DFSAcc2
proc {DFSAccLoop2 T ?S1 Sn}
   case T
   of leaf then S1=Sn
   [] tree(Key Val L R) then S2 S3 in
      S1=Key#Val|S2
      {DFSAccLoop2 L S2 S3}
      {DFSAccLoop2 R S3 Sn}
   end
end
fun {DFSAcc2 T} {DFSAccLoop2 T $ nil} end

{Browse {DFSAcc2 T}}


%% 幅優先探索(breadth-first traversal)
declare BFS
%% 与えられた深さのすべての節を保持するためにキューが必要.
%% こちらもまず単純にBrowseしていく例から.
proc {BFS T}
   fun {TreeInsert Q T}
      if T\=leaf then {Insert Q T} else Q end
   end
   proc {BFSQueue Q1}
      if {IsEmpty Q1} then skip
      else X Q2 Key Val L R in
         Q2={Delete Q1 X}
         tree(Key Val L R)=X
         {Browse Key#Val}
         {BFSQueue {TreeInsert {TreeInsert Q2 L} R}}
      end
   end
in
   {BFSQueue {TreeInsert {NewQueue} T}}
end

{BFS T} % => fig3

%% 先程と同様にアキュームレータを作成する
declare BFSAcc
fun {BFSAcc T}
   fun {TreeInsert Q T}
      if T\=leaf then {Insert Q T} else Q end
   end
   proc {BFSQueue Q1 ?S1 Sn}
      if {IsEmpty Q1} then S1=Sn
      else X Q2 Key Val L R S2 in
         Q2={Delete Q1 X}
         tree(Key Val L R)=X
         S1=Key#Val|S2
         {BFSQueue {TreeInsert {TreeInsert Q2 L} R} S2 Sn}
      end
   end
in
   {BFSQueue {TreeInsert {NewQueue} T} $ nil}
end

{Browse {BFSAcc T}}
%% => [10#10 6#6 18#18 4#4 8#8 15#15 21#21]


%% 明示的スタックを使う深さ優先探索バージョン
declare DFS
proc {DFS T}
   fun {TreeInsert S T}
      if T\=leaf then T|S else S end
   end
   proc {DFSStack S1}
      case S1
      of nil then skip
      [] X|S2 then
         tree(Key Val L R)=X
      in
         {Browse Key#Val}
         {DFSSTack {TreeInsert {TreeInsert S2 R} L}}
      end

   end
in
   {DFSStack {TreeInsert nil T}}
end

%% 末尾再帰になっているためスタックは大きくならない.

%% 2^n個の葉と2^n - 1個の葉でない節をもつ深さnの木
%%   * スタック(DFS): 高々n+1個
%%   * キュー(BFS): 高々2^n個
%% DFSの方が経済的.


%% 3.4.7 木を描画すること
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% タプルの代わりにレコードで木の型を定義する.

<Tree> ::= tree(key:<Literal> val:<Value> left:<Tree> right:<Tree>)
         | leaf

%% 例
declare MyTree
MyTree=tree(key:10 val:10
            left:  tree(key:6  val:6
                        left:  tree(key:4 val:4 left:leaf right:leaf)
                        right: tree(key:8 val:8 left:leaf right:leaf))
            right: tree(key:18 val:18
                        left:  tree(key:15 val:15 left:leaf right:leaf)
                        right: tree(key:21 val:21 left:leaf right:leaf)))

{Browse MyTree} % => fig4

%% 深さ優先走査で各節の座標(x, y)を計算する.
declare DepthFirst AddXY
proc {DepthFirst Tree}
   case Tree
   of tree(left:L right:R ...) then
      {DepthFirst L}
      {DepthFirst R}
   [] leaf then
      skip
   end
end

%% 下準備として, 以下のAddXY関数により各節にフィールド(x, y)を追加して新しい木を返す.
fun {AddXY Tree}
   case Tree
   of tree(left:L right:R ...) then
      %% Adjoinはレコードにフィールドを追加する標準の関数(ref: 付録B.3.2)
      {Adjoin Tree
       tree(x:_ y:_ left:{AddXY L} right:{AddXY R})}
   [] leaf then
      leaf
   end
end

{Browse {Adjoin e(a:1 b:2) e(a:2 b:3 c:5)}}
{Browse {Adjoin e(a:1 b:2) e(a:2 b:3 c:_)}}

{Browse {AddXY MyTree}} % => fig5


%% 上から下に走査していく時は継承引数(inherited arguments)として
%%   * 節の深さ
%%   * 部分木の左端の位置の限界
%% を渡す. また逆に,
%% 下から上に戻る際には合成引数(synthesized arguments)として
%%   * 部分木の根の水平位置
%%   * 部分木の右端の位置
%% を渡す.
declare Scale
Scale=30
proc {DepthFirst Tree Level LeftLim ?RootX ?RightLim}
   case Tree
   of tree(x:X y:Y left:leaf right:leaf ...) then
      %% 下には葉しかない(= 末端まで辿り着いた)とき
      X=RootX=RightLim=LeftLim
      Y=Scale*Level
   [] tree(x:X y:Y left:L right:leaf ...) then
      %% 木が左の枝のみ続いているとき
      X=RootX
      Y=Scale*Level
      %% 下に降りるときLevelを1増加
      {DepthFirst L Level+1 LeftLim RootX RightLim}
   [] tree(x:X y:Y left:leaf right:R ...) then
      X=RootX
      Y=Scale*Level
      {DepthFirst R Level+1 LeftLim RootX RightLim}
   [] tree(x:X y:Y left:L right:R ...) then
      %% 左右両方の枝にまだ続いている時
      LRootX LRightLim RRootX RLeftLim
   in
      Y=Scale*Level
      {DepthFirst L Level+1 LeftLim LRootX LRightLim} % LRootX, LRightLim は未束縛
      RLeftLim=LRightLim+Scale
      {DepthFirst R Level+1 RLeftLim RRootX RightLim} % RRootX は未束縛
      X=RootX=(LRootX+RRootX) div 2
   end
end

{Browse {DepthFirst MyTree 1 Scale $ $}}


%% 3.4.8 構文解析
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 最も基本的なコンパイラの構成要素
%%   1. 字句解析ルーチン(tokenizer) -- 文字列を読みtoken列を出力
%%   2. パーサ(parser) -- token列を読み抽象構文木を出力
%%   3. コード生成ルーチン(code generator) -- 構文木を走査しマシンに入力する低水準命令を生成

%% この節では(2)のパーサだけを扱う.
%% > パーサの役割は, 平坦な入力から構造を抽出することである.
%% 1つの字句のみ先読みする, top-down, left-to-right型のパーサをかく.

%% パーサの呼び出しは {Prog S1 Sn} で, 解析結果の木(レコード)を返す.
%%   * S1: 入力tokenのリスト
%%   * Sn: 構文解析後のリストの残り
declare Prog Stat
fun {Prog S1 Sn}
   Y Z S2 S3 S4 S5
in
   S1=program|S2  % "program"というatomとS2のリスト
   Y={Id S2 S3}   % Idの定義はずっと下
   S3=';'|S4
   Z={Stat S4 S5} % Stat定義は後述
   S5='end'|Sn
   prog(Y Z)      % 最終出力: 名前とコード内容のタプル
end

%% Statement(文)
fun {Stat S1 Sn}
   % 引数tokenリスト(S1)から最初の1tokenのみ先読みしてTに束縛. S2は「のこり」
   T|S2=S1 in
   case T
   of begin then
      %% Sequenceの定義は後で出てくる
      {Sequence Stat fun {$ X} X==';' end S2 'end'|Sn}
   [] 'if' then C X1 X2 S3 S4 S5 S6 in
      C={Comp S2 S3}
      S3='then'|S4
      X1={Stat S4 S5}
      S5='else'|S6
      X2={Stat S6 Sn}
      'if'(C X1 X2) % 返り値. ifラベルのタプル. Conditionとexpression1,2
      %% whileはozの予約語じゃないので引用符不要
   [] while then C X S3 S4 in
      C={Comp S2 S3}
      S3='do'|S4
      X={Stat S4 Sn}
      while(C X)
   [] read then I in
      I={Id S2 Sn}
      read(I)
   [] write then E in
      E={Expr S2 Sn}
      write(E)
   elseif {IsIdent T} then E S3 in
      S2=':='|S3 % 代入
      E={Expr S3 Sn}
      assign(T E)
   else
      S1=Sn
      raise error(S1) end
   end
end


%% 様々な"列"を処理する汎用関数
%% NonTermには"列が終了する条件"が入る
declare Sequence
fun {Sequence NonTerm Sep S1 Sn}
   fun {SequenceLoop Prefix S2 Sn}
      case S2 of T|S3 andthen {Sep T} then Next S4 in
         Next={NonTerm S3 S4}
         %% パターンマッチで束縛したTを使ってラベルを動的に決める
         {SequenceLoop T(Prefix Next) S4 Sn}
      else
         Sn=S2 Prefix
      end
   end
   First S2
in
   First={NonTerm S1 S2}
   {SequenceLoop First S2 Sn}
end

%% 下準備. それぞれ比較(Comp), 式(Expr), 項(Term)であるかどうかを判別する関数
declare COP EOP TOP
fun {COP Y}
   Y=='<' orelse Y=='>' orelse Y=='=<' orelse
   Y=='>=' orelse Y=='==' orelse Y=='!='
end
fun {EOP Y} Y=='+' orelse Y=='-' end
fun {TOP Y} Y=='*' orelse Y=='/' end

%% Sequenceを使って比較(Comp), 式(Expr), 項(Term),
%% および因子(Fact)を解析
declare Comp Expr Term Fact
fun {Comp S1 Sn} {Sequence Expr COP S1 Sn} end
fun {Expr S1 Sn} {Sequence Term EOP S1 Sn} end
fun {Term S1 Sn} {Sequence Fact TOP S1 Sn} end
fun {Fact S1 Sn}
   T|S2=S1 in
   if {IsInt T} orelse {IsIdent T} then
      S2=Sn
      T
   else E S2 S3 in
      S1='('|S2
      E={Expr S2 S3}
      S3=')'|Sn
      E
   end
end

%% アトム
declare Id IsIdent
fun {Id S1 Sn}
   X
in
   S1=X|Sn
   true={IsIdent X}
   X
end
fun {IsIdent X} {IsAtom X} end

{Browse {IsIdent asdf}}
{Browse {Id a a}} % ?
{Browse {Id hoge [hoge fuga piyo]}} % ?

%% 文法解釈に2個以上の字句先読みを必要とする場合は,
%% 9章で取り上げる非決定性選択(nondeterministic choise)が必要になる.

%% 確認
declare A Sn in
A={Prog
   [program foo ';'
    while a '+' 3 '<' b 'do' b ':=' b '+' 1 'end']
   Sn}
{Browse A}