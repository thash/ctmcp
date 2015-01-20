%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4.3. ストリーム
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 宣言的並列モデルにおいては「束縛されていないデータフロー変数を末尾に持つリスト」
% ストリームを使ったスレッド間通信を行えばMutex, lockは不要

%% 4.3.1. 基本的生産者/消費者(Basic producer/consumer)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare Xs Xs2 in
Xs=0|1|2|3|4|Xs2

% 漸増
Xs2=5|6|7|Xs3

% producer threadがストリームを生成し, consumerが読む.

fun {Generate N Limit}
   if N<Limit then
      N|{Generate N+1 Limit}
   else nil end
end

local Xs S in
   thread Xs={Generate 0 150000} end % 生産者
   thread S={Sum Xs 0} end % 消費者
   {Browse S}
end

% 高階イテレータを使用すること
% ↑のSumの代わりにFoldで手続き与えてやる事出来るよねーと

% 複数の消費者
local Xs S1 S2 S3 in
   thread Xs={Generate 0 150000} end
   thread S1={Sum Xs 0} end
   thread S2={Sum Xs 0} end
   thread S3={Sum Xs 0} end
end
% 「消費」と言ってるけど実際には破壊的操作を加えるわけじゃなく「読む」で, 複数同時に使える.


%% 4.3.2. 変換器とパイプライン(Transducers and pipelines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% transducer

% 一番単純なtransducerはfilter.
local
   Xs Ys S
   fun {IsOdd X} X mod 2 \= 0 end
in
   thread Xs={Generate 0 150000} end
   thread Ys={Filter Xs IsOdd} end
   thread S={Sum Ys 0} end
   {Browse S}
end

% エラトステネスの篩(Sieve)例. 略.


%% 4.3.3. 資源を管理し, 処理能力を改善すること(Managing resources and improving throughput)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 遅延実行(あるいは要求駆動並列性): 最も簡単なフロー制御
% 消費者が明示的に要求したときのみ要素を生成する

% 性急実行(あるいは供給駆動実行): 生産者が自分の好きなときに要素を生成する
% これは無制限だとメモリを食いつぶしてしまうので, 必要なときに合図を送る必要がある.
% 消費者が要求するだけ生成し続ければいいので, Limitを指定する必要がない

% 4.3.3.1 要求駆動並列性によるフロー制御
proc {DGenerate N Xs}
   case Xs of X|Xr then
      X=N
      {DGenerate N+1 Xr}
   end
end

fun {DSum ?Xs A Limit}
   if Limit>0 then
      X|Xr=Xs
   in
      {DSum Xr A+X Limit-1}
   else A end
end

% 遅延実行を明示的にプログラム. 3.6.5節で触れたプログラムされたトリガの例.
% * データフロー変数Xsを通じてつながっている
% * 消費側DSumがLimitを指定
local Xs S in
   thread {DGenerate 0 Xs} end % producer
   thread S={DSum Xs 0 150000} end % consumer
   {Browse S}
end


% 4.3.3.2 有界バッファを使うフロー制御

% 性急実行: [x] 資源利用の爆発的増大
% 遅延実行: [x] 処理能力(単位時間に送れる出来るメッセージ数)の大幅な減少

% 処理能力(throughput)
%   <-> 待ち時間(latency): 1つのメッセージが送信されてから受信されるまでに要する時間

% 有界バッファ
% 生産者が消費者の先へ行くことを許しつつ, かつ
% 無制限に先に行くとメモリを食いつぶさないようにする方法.

% 生産者は非同期的にbufferがいっぱいになるまで勝手に生産すればよく,
% 消費者は必要なだけbufferから取り出して使う.

proc {Buffer N ?Xs Ys}
   fun {Startup N ?Xs}
      if N==0 then Xs
      else Xr in Xs=_|Xr {Startup N-1 Xr} end
   end

   % Buffer要素の更新はBuffer自身が行うのでconsumerが複数いても大丈夫
   proc {AskLoop Ys ?Xs ?End}
      case Ys of Y|Yr then Xr End2 in
         Xs=Y|Xr    % バッファから要素を取り出す
         End=_|End2 % バッファに補充する
         {AskLoop Yr Xr End2}
      end
   end
   End={Startup N Xs}
in
   {AskLoop Ys Xs End}
end

% 実行例
local Xs Ys S in
   thread {DGenerate 0 Xs} end % 生産者
   thread {Buffer 4 Xs Ys} end % バッファスレッド
   thread S={DSum Ys 0 150000} end % 消費者
   {Browse Xs} {Browse Ys}
   {Browse S}
end

% デメリット(1): 遅延実行を実現するために"辻褄合わせ"が必要になる.
% デメリット(2): 最後のバッファが無駄になる
%   余分なメモリは束縛されてないn個のリストに過ぎないのでまぁ大したことない.

% 性急実行も遅延実行も有界バッファの極端な場合にすぎない.
% バッファ無限大: 性急実行
% バッファゼロ: 遅延実行

% 4.3.3.3 スレッドの優先順位を利用するフロー制御


%% 4.3.4. ストリームオブジェクト
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 値と操作をひとまとめにした実体なので「オブジェクト」と呼ぶ.
%   (手続きBufferはその中にバッファXsとそれに対する操作AskLoopを持つ)
% ADTとオブジェクトの違い: ADTは値と操作は別々の実体だがオブジェクトはそれが一体.

% 一般的なストリームオブジェクト実装(テンプレート)
proc {StreamObject X1 X1 ?T1}
   case S1
   of M|S2 then N X2 T2 in
      {NextState M X1 N X2}
      T1=N|T2
      {StreamObject S2 X2 T2}
   [] nil then T1=nil end
end

declare S0 X0 T0 in
thread
   {StreamObject X0 X0 T0}
end

% ストリームオブジェクトのパイプラインを接続する例
declare S0 T0 U0 V0 in
thread {StreamObject S0 0 T0} end
thread {StreamObject T0 0 U0} end
thread {StreamObject U0 0 V0} end


%% 4.3.5. ディジタル論理のシミュレーション(Digital logic simulation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ![](./img/fig4.15.png)

fun {NotGate Xs}
   case Xs of X|Xr then (1-X)|{NotGate Xr} end
end

% 組み合わせ論理(combinational logic)

local
   fun {NotLoop Xs}
      case Xs of X|Xr then (1-X)|{NotLoop Xr} end
   end
in
   fun {NotG Xs}
      thread {NotLoop Xs} end
   end
end

% NotGを呼ぶと, 新しいNotゲートがスレッドとして生成される. 論理ゲートはただの関数ではなく, 他の並列的実体と通信する並列的実体なのである

% このゲート生成を汎用化したGateMaker
fun {GateMaker F}
   fun {$ Xs Ys}
      case Xs#Ys of (X|Xr)#(Y|Yr) then
         {F X Y}|{GateLoop Xr Yr}
      end
   in
      thread {GateLoop Xs Ys} end
   end
end

AndG  = {GateMaker fun {$ X Y} X*Y end}
OrG   = {GateMaker fun {$ X Y} X+Y-X*Y end}
NandG = {GateMaker fun {$ X Y} 1-X*Y end}
NorG  = {GateMaker fun {$ X Y} 1-X-Y+X*Y end}
XorG  = {GateMaker fun {$ X Y} X+Y-2*X*Y end}

% 全加算器を作ろう ![](./img/fig4.16.png)
% c(carry)が繰り上がり, s(sum)がその桁の合計

% 出力がふたつあるので手続き(そういう使い分けするのか).
proc {FullAdder X Y Z ?C ?S}
   K L M
in
   K={AndG X Y}
   L={AndG Y Z}
   M={AndG X Z}
   C={OrG K {OrG L M}}
   S={XorG Z {XorG X Y}}
end

% 利用例. 入力の3組のbitを足す.
declare
X=1|1|0|_
Y=0|1|0|_
Z=1|1|1|_ C S in
{FullAdder X Y Z C S}
{Browse inp(X Y Z)#sum(C S)}


% 4.3.5.3 クロッキング

% 回路実行をシミュレートするには
% 「時間とともに離散化された初期入力ストリーム」
% が必要になる. 1ツの方法はクロックを定義することで,
% クロックは周期的な信号のストリームとして考えられる

% Mozartの最高速度で成長し続けるストリームが得られる.
fun {Clock}
   fun {Loop B}
      B|{Loop B}
   end
in
   thread {Loop 1} end
end


% 4.3.5.4 論理ゲートのための言語抽象

% Mozartのパーサージェネレータ"gump"を使えばDSLが作れるので,
% 論理ゲートを扱う言語抽象例をいろいろ.
