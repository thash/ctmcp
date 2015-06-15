%% 6.8.1. 遷移的閉包(transitive closure)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% グラフ問題の一例．有向グラフG=(V,E)をノードの集合Vと辺の集合Eで定義する．
% 頂点x,yの間に辺があればその辺を対(x,y)で表す.

% 遷移的閉包を求めるアルゴリズム
%   すべての辺について，その辺に向かってきてる先行ノードAから，
%   その辺から出発して辿り着く後続ノードBへ，A->Bという辺を追加する．

% グラフ表現方法 -- まず両者を相互に変換する関数を定義
%   1. 隣接リスト adjacency list (コード中GL)
%   2. 行列 matrix (コード中GM)

declare
fun {L2M GL}
   M={Map GL fun {$ I#_} I end}
   L={FoldL M Min M.1}
   H={FoldL M Max M.1}
   GM={NewArray L H unit}
in
   for I#Ns in GL do
      % true/falseで1/0行列を表現
      GM.I:={NewArray L H false}
      for J in Ns do GM.I.J:=true end
   end
   GM
end

fun {M2L GM}
   L={Array.low GM}
   H={Array.high GM}
in
   for I in L..H collect:C do
      {C I#for J in L..H collect:D do
              if GM.I.J then {D J} end
           end}
   end
end

% グラフの行列表現の確認
declare GM I J in
GM={L2M [1#[2 3] 2#[1] 3#nil]}
{Browse GM}     % => <Array> 中見えない
{Browse GM.1}   % => <Array> 行列なので二重Array
{Browse GM.1.1} % => false
{Browse {Array.low GM}}  % => 1
{Browse {Array.high GM}} % => 3
for I in {Array.low GM}..{Array.high GM} do
   for J in {Array.low GM}..{Array.high GM} do
      {Browse GM.I.J}
   end
end

% [[0 1 1]
%  [1 0 0]
%  [0 0 0]]


%% 宣言的アルゴリズム (本章は状態についての賞なので，比較対象として)

% 以下のユーティリティルーチンを後で定義.
%   Succ : 与えられたノードの後続ノードリストを返す
%   Union: 2つの順序付きリストの合併(?)を求める
declare
fun {DeclTrans G}
   Xs={Map G fun {$ X#_} X end}
in
   {FoldL Xs
    fun {$ InG X}
    SX={Succ X InG} in
       {Map InG
        fun {$ Y#SY}
           Y#if {Member X SY} then
             {Union SY SX} else SY end
        end}
    end G}
end

% XというkeyでGという辞書を検索, 見つかった(X==Y)らvalueを返す.
% なければ次の要素を再帰的に検索していくもの
fun {Succ X G}
   case G of Y#SY|G2 then
      if X==Y then SY else {Succ X G2} end
   end
end

fun {Union A B}
   case A#B
   of nil#B then B
   [] A#nil then A
   [] (X|A2)#(Y|B2) then
      if X==Y then X|{Union A2 B2}
      elseif X<Y then X|{Union A2 B}
      elseif X>Y then X|{Union A B2}
      end
   end
end

% 実行例
{Browse {DeclTrans [1#[2 3] 2#[1] 3#nil]}}
% => [1#[2 2 3] 2#[1 2 3] 3#nil]

% 今回のリストは順序付きなので，Union実行時間は短い方のリストの長さに比例
% もしリストが順序付きではないと，Union実行時間は2つのリストの長さの積に比例する(なぜか?
% => O(mn) になるから.

%% 状態ありアルゴリズム
% グラフは行列として表されている．初期グラフを破壊的に更新して遷移的閉包を作る．
% ref: ../misc/array.oz
declare
proc {StateTrans GM}
   L={Array.low GM}
   H={Array.high GM}
in
   for K in L..H do
      for I in L..H do
         % この部分で全elemを舐めてる
         if GM.I.K then % 自身がtrue(1)なら他要素の更新を試みる
            for J in L..H do
               % "GM.K.Jが真であれば，Jがsucc(K,GM)の中にあることに注意する"
               if GM.K.J then GM.I.J:=true end
            end
         end
      end
   end
end

% 実行例
declare GM in
GM={L2M [1#[2 3] 2#[1] 3#nil]}
{StateTrans GM}
{Browse {M2L GM}}
% => [1#[2 2 3] 2#[1 2 3] 3#nil]


%% 第二の宣言的アルゴリズム (状態ありアルゴリズムをヒントに改良
% 宣言的といいつつ, Haskellみたいな未束縛変数を許さない言語だと実装できない作りになってる
declare
fun {DeclTrans2 GT}
   H={Width GT}
   fun {Loop K InG}
      if K=<H then
         G={MakeTuple g H} in
         % ここと...
         for I in 1..H do
            % ここに, threadを入れると並列版ができる.
            % 行列で見て各要素が裏返るかどうかの判断は独立に可能であるため
            G.I={MakeTuple g H}
            for J in 1..H do
               G.I.J = InG.I.J orelse (InG.I.K andthen InG.K.J)
            end
         end
         {Loop K+1 G}
      else InG end
   end
in
   {Loop 1 GT}
end


%% 検討
% Floyd-Warshall アルゴリズム (Floydの方がリスト, Warshallが行列)
% 漸近的実行時間はO(n^3)
% 理解しやすいのは状態あり版アルゴリズム. 条件付きの3重入れ子ループであり行列を明白な方法で更新する．
% 状態あり版で書くと，プログラムが分解不可能になりやすい.

% グラフが疎である場合，隣接リスト定義(+ 第一の宣言的アルゴリズム)が最も効率が良い
% グラフが疎かどうかは"任意のノード対の間に辺がある確率p"を用いて考える．


%% 6.8.2. 単語出現頻度(状態あり辞書を使用する
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 図6.14
% 本文だと "..." で省略されてるところがweb補足資料だと明記されてる
% => 略してたのはp.205(Fig3.30)と同じだからか.
declare
fun {WordChar C}
   (&a=<C andthen C=<&z) orelse
   (&A=<C andthen C=<&Z) orelse (&0=<C andthen C=<&9) end

fun {WordToAtom PW} {StringToAtom {Reverse PW}} end

fun {CharsToWords PW Cs}
   case Cs
   of nil andthen PW==nil then
      nil
   [] nil then
      [{WordToAtom PW}]
   [] C|Cr andthen {WordChar C} then
      {CharsToWords {Char.toLower C}|PW Cr}
   [] _|Cr andthen PW==nil then
      {CharsToWords nil Cr}
   [] _|Cr then
      {WordToAtom PW}|{CharsToWords nil Cr}
   end
end

Put=Dictionary.put
CondGet=Dictionary.condGet

proc {IncWord D W}
   {Put D W {CondGet D W 0}+1}
end

proc {CountWords D Ws}
   case Ws
   of W|Wr then
      {IncWord D W}
      {CountWords D Wr}
   [] nil then skip
   end
end

fun {WordFreq Cs}
   D={NewDictionary}
in
   {CountWords D {CharsToWords nil Cs}}
   D
end

declare
T="Oh my darling, oh my darling, oh my darling Clementine.
She is lost and gone forever, oh my darling Clementine."
{Browse {WordFreq T}}


%% 6.8.3. 乱数を生成すること
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 真のランダム性を得たい.
% * コンピュータ上の予測不能なイベントは有用な確率分布にはならず，乱数の源としてはイマイチ
% * 電気回路の雑音は"量子の世界の深みから来る"ために完全なるランダム．しかし以下の問題がある
%   * 確率分布が正確にわからない
%   * 乱数を保存して再生しない限り再現不可能

% > 真のランダム性を望み，しかも再現可能であることを望む
% > このジレンマから抜け出すには? 簡単である．乱数を計算すればよい．
% > どうやって真の乱数を発生するのか? 早い話，それはできない．
% > しかし，すべての実用的目的に大して，乱数らしく見える数はある．
% > そういう数は擬似乱数(pseudorandom number)と言われる．

% 参考文献 Knuth[114] = The Art of computer Programming: Seminumerical Algorithm, vol 2.
% 原著: http://www.amazon.com/dp/0201896842
% 邦訳: http://www.amazon.co.jp/dp/4756145434

% 乱数発生器の満たすべき条件
%   1. 発生した乱数が強い統計的性質を満たす
%   2. 正しい分布をする
%   3. 周期が十分長い

% 乱数発生器は内部状態をもち，それを基に次の乱数と次の内部状態を計算する
% seed で初期化，seedが同じであれば同じ乱数列が出てくる (再現性)


% NewRandは3個の参照を返す.
% Rand (乱数発生法 (原文ではa random number generator)), Init (Randの初期化手続き), Max (Randの最大値)
declare NewRand
local A=333667 B=213453321 M=1000000000 in
   proc {NewRand ?Rand ?Init ?Max}
      X={NewCell 0} in
      fun {Rand} X:=(A*@X+B) mod M end
      proc {Init Seed} X:=Seed end % Randの利用する内部状態Cell XをSeed(0..(Max-1))で初期化
      Max=M
   end
end

% 使ってみる
declare Rand Init Max in
{NewRand Rand Init Max}
{Init 100}
{Browse Max} % => 1000000000
{Browse {Rand}} % => 100
{Browse {Rand}} % => 246820021
{Browse {Rand}} % => 909400328 ...

declare Rand Init Max in
{NewRand Rand Init Max}
{Init 9999}
{Browse {Rand}} % => 9999
{Browse {Rand}} % => 549789654
{Browse {Rand}} % => 877934539 ...

% Seedが同じなら再現性があることを確認
declare Rand Init Max in
{NewRand Rand Init Max}
{Init 100}
{Browse {Rand}} % => 100, 246820021, 909400328 ...


% 状態(NewCell)の代わりに遅延を使う方法もある
% Cellの代わりに再帰関数RandListの引数に状態を保存する

declare RandList
local A=333667 B=213453321 M=1000000000 in
   fun lazy {RandList S0}
      S1=(A*S0+B) mod M in S1|{RandList S1}
   end
end

declare RList
RList={RandList 100}

% 一様でない分布
% まずは0から1までの一様分布乱数を作る.

% random number generatorを初期化
declare Rand Init Max in {NewRand Rand Init Max}

declare FMax Uniform % UniformI Exponential TwoPi Gauss in
FMax={IntToFloat Max}
fun {Uniform}
   {IntToFloat {Rand}}/FMax
end
% {Browse {Uniform}} % => 0.0
% {Browse {Uniform}} % => 0.21345
% {Browse {Uniform}} % => 0.54271

declare UniformI
fun {UniformI A B}
   A+{FloatToInt {Floor {Uniform}*{IntToFloat B-A+1}}}
end
% {Browse {UniformI 1 100}}

declare
fun {Exponential Lambda}
   % ~ は否定の論理演算
   % ref: https://mozart.github.io/mozart-v1/doc-1.4.0/base/number.html
   ~{Log 1.0-{Uniform}}/Lambda
end

% TwoPi=4.0*{Float.acos 0.0}
% fun {Gauss}
%    {Float.sqrt ~2.0*{Float.log {Uniform}}} * {Float.cos TwoPi*{Uniform}}
% end

declare Gauss
local
   TwoPi=4.0*{Float.acos 0.0}
   GaussCell={NewCell nil}
in
   fun {Gauss}
      % {Exchange +C X Y}: Swaps atomically the content of C from X to Y
      Prev={Exchange GaussCell $ nil}
   in
      if Prev\=nil then Prev
      else R Phi in
         R={Sqrt ~2.0*{Log {Uniform}}}
         Phi=TwoPi*{Uniform}
         GaussCell:=R*{Cos Phi}
         R*{Sin Phi}
      end
   end
end
% {Browse {Gauss}} % => 1.7224
% {Browse {Gauss}} % => -1.2222
% {Browse {Gauss}} % => 1.3879

% Floor, Sin, Cos, Log, Sqrt などFloat以下の関数が定義されていない問題
% => Mozart2入れなおしたら直った...
% ref: https://mozart.github.io/mozart-v1/doc-1.4.0/base/float.html

% Exchangeの処理を確認 => ../misc/exchange.oz


%% 6.8.4. 口コミ(word of mouth)シミュレーション
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 10000ユーザ, 50万ユーザで200ラウンド
% 前節で定義した関数Init, UniformI, Gaussを利用

% Fileを使う方法がうまく行かなかったので
% https://mozart.github.io/mozart-v1/doc-1.4.0/op/node6.html
% でファイルに書き出す

% % declare [File]={Module.link ['File.ozf']}

% "この本のウェブサイトのFileモジュールにある漸増的書き出し操作を使用する"
% https://www.info.ucl.ac.be/~pvr/ds/File.oz
%     $ /path/to/ozc -c File.oz

declare [File]={Module.link ['/Users/hash/work/ctmcp/File.ozf']}
{File.writeOpen '/Users/hash/work/ctmcp/wordofmouth.txt'}
proc {Out S}
   {File.write {Value.toVirtualString S 10 10}#"\n"}
end

%%% test >>>
% {Browse File}
% {Browse File.write}
% {Out aaaaaaaa}
% {File.writeClose}
%%% test <<<

% declare N=10000 M=500000 T=200
declare N M T in N=100 M=5000 T=2

% random number generatorを初期化
declare Rand Init Max in {NewRand Rand Init Max}
{Init 0}

declare Sites={MakeTuple sites N}
% {Browse Sites}

for I in 1..N do
   Sites.I={Record.toDictionary
            o(hits:0 performance:{IntToFloat {UniformI 1 80000}})
           }
end
% {Browse Sites}

declare Users={MakeTuple users M}
for I in 1..M do S={UniformI 1 N} in
   Users.I={Record.toDictionary o(currentSite:S)}
   Sites.S.hits := Sites.S.hits + 1
end

% Fig 6.15
% 口コミの1 step.
declare
proc {UserStep I}
   U=Users.I
   % Ask three users for their performance information
   L={List.map [{UniformI 1 M} {UniformI 1 M} {UniformI 1 M}]
       fun {$ X}
          (Users.X.currentSite) #
          Sites.(Users.X.currentSite).performance
             + {Gauss}*{IntToFloat N}
       end}
   % Calculate the best site
   MS#MP = {List.foldL L
            fun {$ X1 X2} if X2.2>X1.2 then X2 else X1 end end
            U.currentSite #
            Sites.(U.currentSite).performance
               + {Abs {Gauss}*{IntToFloat N}}}
in
   if MS\=U.currentSite then
      Sites.(U.currentSite).hits :=
         Sites.(U.currentSite).hits - 1
      U.currentSite := MS
      Sites.MS.hits := Sites.MS.hits + 1
   end
end

% {Browse Users}

% Fig 6.16
% 完全な(1 stepのみじゃない)シミュレーション
for J in 1..N do
   % {Browse {Dictionary.toRecord site Sites.J}}
   {Out {Record.adjoinAt {Dictionary.toRecord site Sites.J} name J}}
end
{Out endOfRound(time:0 nonZeroSites:N)}

for I in 1..T do X={NewCell 0} in
   for U in 1..M do {UserStep U} end
   for J in 1..N do H=Sites.J.hits in
      if H\=0 then
         % {Browse {Record.adjoinAt {Dictionary.toRecord site Sites.J} name J}}
         {Out {Record.adjoinAt {Dictionary.toRecord site Sites.J} name J}}
         X := @X+1
      end
   end
   % {Browse endOfRound(time:I nonZeroSites:@X)}
   {Out endOfRound(time:I nonZeroSites:@X)}
end

{File.writeClose}
