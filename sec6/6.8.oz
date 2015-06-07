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
% もしリストが順序付きではにと，Union実行時間は2つのリストの長さの積に比例する(なぜか?

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
         if GM.I.K then
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
declare
fun {DeclTrans2 GT}
   H={Width GT}
   fun {Loop K InG}
      if K=<H then
         G={MakeTuple g H} in
         % ここと...
         for I in 1..H do
            % ここに, threadを入れると並列版ができる
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


%% 6.8.2. 単語出現頻度(状態あり辞書を使用する
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 図6.14
% 本文だと "..." で省略されてるところがweb補足資料だと明記されてる. 略すのひどいな
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
% > しかし，すべての実用的目的に大して，乱数らしく見える数はある．そういう数は擬似乱数(pseudorandom number)と言われる．

declare NewRand in

local A=333667 B=213453321 M=1000000000 in
   proc {NewRand ?Rand ?Init ?Max}
      X={NewCell 0} in
      fun {Rand} X:=(A*@X+B) mod M end
      proc {Init Seed} X:=Seed end
   end
end

% 状態(NewCell)の代わりに遅延を使う方法もある
local A=333667 B=213453321 M=1000000000 in
   fun lazy {RandList $0}
      S1=(A*S0+B) mod M in S1|{RandList S1}
   end
end

% 一様でない分布．
% ...の前にまずは0から1までの一様分布乱数を作る
FMax={IntToFloat Max}
fun {Uniform}
   {IntToFloat {Rand}}/FMax
end
fun {UniformI A B}
   A+{FloatToInt {Floor {Uniform}*{IntToFloat B-A+1}}}
end

fun {Exponential Lambda}
   % ~ ってなんだっけ
   ~{Log 1.0-{Uniform}}/Lambda
end

TwoPi=4.0*{Float.acos 0.0}
fun {Gauss}
   {Sqrt ~2.0*{Log {Uniform}}} * {Cos TwoPi*{Uniform}}
end

local GaussCell={NewCell nil} in
   fun {Gauss}
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


%% 6.8.4. 口コミ(word of mouth)シミュレーション
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 10000ユーザ, 50万ユーザで200ラウンド

declare
N=10000 M=500000 T=200
{Init 0}
{File.writeOpen 'wordofmouth.txt'}
proc {Out S}
   {File.write {Value.toVirtualString S 10 10}#"\n"}
end

Sites={MakeTuple sites N}
for I in 1..N do
   Sites.I={Record.toDictionary
            o(hits:0 performance:{IntToFloat {UniformI 1 80000}})
           }
end

Users={MakeTuple users M}
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

% Fig 6.16
% 完全な(1 stepのみじゃない)シミュレーション
declare
for J in 1..N do
   {Out {Record.adjoinAt
           {Dictionary.toRecord site Sites.J} name J}}
end
{Out endOfRound(time:0 nonZeroSites:N)}
for I in 1..T do X={NewCell 0} in
   for U in 1..M do {UserStep U} end
   for J in 1..N do H=Sites.J.hits in
      if H\=0 then
         {Out {Record.adjoinAt
                 {Dictionary.toRecord site Sites.J} name J}}
         X := @X+1
      end
   end
   {Out endOfRound(time:I nonZeroSites:@X)}
end
{File.writeClose}
