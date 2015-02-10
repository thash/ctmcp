%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4.5. 遅延実行
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 4.5.1. 要求駆動並列モデル
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% by-needトリガ = 活性化条件(bool式)とアクション(手続き) の対
% by-needトリガは計算モデルに組み込まれる"暗黙的トリガ"

% 計算モデルの拡張は以下のように行う
%     * 実行領域にトリガストア(trigger store) τ(タウ) を付加
%     * トリガ生成操作を定義
%     * トリガ活性化操作を定義
%     * 必要とする(needing)とはどういうことか定義する

% トリガ生成
%     ({ByNeed <x> <y>}, E)
%     * E(<y>)が決定状態でなければトリガ格納域にtrig((E(<x>), E(<y>)))を加える
%     * E(<y>)が決定状態であれば意味言明が({<x> <y>}, E)な新しいスレッドを生成

% トリガ活性化
%     * 格納域にあるtrig(x, y)についてyの必要性が検出されたら
%         * トリガ格納域からそのトリガを取り除く
%         * 新しいスレッドを生成してその意味言明を({<x> <y>}, {<x> -> x, <y> -> y})とする
%     * なお必要性が検出されるとは以下のいずれかを言う
%         * yが決定状態になるのを待つスレッドがあること，あるいは
%         * yを決定状態にするためにyを束縛しようとする試みがあること

% メモリ管理
%     * 到達可能性の拡張: trig(x, y)のyが到達可能ならxも到達可能
%     * トリガの回収: yが到達不能になればtrig(x, y)を取り去る


% 変数を必要とする，とは
thread X={ByNeed fun {$} 3 end} end
thread Y={ByNeed fun {$} 4 end} end
thread Z=X+Y end

% 失敗する例
thread X={ByNeed fun {$} 3 end} end
thread X=2 end
thread Z=X+4 end

% 以下ではまだ足りない，ここからさらにYが束縛されれば活性化される．
thread X={ByNeed fun {$} 3 end} end
thread X=Y end
thread if X==Y then Z=10 end end

% 必要とされる，という変化は一方向なので宣言的モデルがまだ成り立つ

% 動的リンクの実装
%     > アプリケーションのソースコードは，ファンクタ(functor)と言われるコンポーネント仕様の集合である
%     > コンポーネントの具体化をモジュールといい，実行しているアプリケーションはモジュールでできている．
%     > モジュールは，そのモジュールの操作をグループ化したレコードによって表される
%     > コンポーネントは，それらが必要とされるときにリンクされる(それらのファンクタがメモリにロードされ，具体化される)

% この実装にby-needが使えるよ，と．


%% 4.5.2. 宣言的計算モデル
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 遅延性と並列性は独立する概念
% 並列性によりバッチ計算が漸増敵になる
% 遅延性により結果を得るまでの計算の量を減らすことができる

% 知られている宣言的計算モデルをすべて概観(fig4.25) "&"は時期が一致することを示す．

% 正格関数型言語の，"宣言的"という性質を保ちながら，表現力を高めるべく3個の概念を追加．
%   * データフロー変数
%   * 宣言的並列性
%   * 遅延性

% これらのON/OFF組み合わせによって，↓3時点の起こり方が変わってくる．

% (1). 格納域の中で変数を宣言する
% (2). 関数に変数の値を計算するよう指定する
% (3). 関数を計算して変数を束縛する

% ちなみに全組み合わせは2*2*2の8個...なのだが，データフロー変数は必ず宣言的並列性に必須なので
%     宣言的並列性ON + データフロー変数OFF
% はありえない．その分を除外して計6パターン．

% Scheme/Standard MLなどは直列な性急実行(正格性)
declare X=11*11 % (1) & (2) & (3)

% Haskell
declare fun lazy {LazyMul A B} A*B end
declare X={LazyMul 11 11} % (1) & (2)
{Wait X} % (3)

% Prologなどデータフロー変数を扱う正格言語
declare X % (1)
X=11*11   % (2) & (3)

% この章の要求駆動並列モデル -- 最も一般的
declare X                             % (1)
thread X={fun lazy {$} 11*11 end} end % (2)
thread {Wait X} end                   % (3)


% なぜデータフローを伴う遅延性は並列でなければならないか
% => 引数を並列に計算しないといけないからだよ！
%    とのことだがmozart2ではふつーに直列に計算されちゃうっぽい．
local
   Z
   fun lazy {F1 X} X+Z end
   fun lazy {F2 Y} Z=1 Y+Z end
in
   {Browse {F1 1}+{F2 2}} % => 何も出ない
end


% 引数を明示的にthreadで並列にすればいい?
local
   Z
   % fun定義からlazyを外して，
   fun {F1 X} X+Z end
   fun {F2 Y} Z=1 Y+Z end
in
   % 引数をthreadで囲ってやる
   {Browse thread {F1 1} end + thread {F2 2} end}
   % => ...と，"5"が表示される．
end


%% 4.5.3. 遅延ストリーム
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
fun lazy {Generate N}
   N|{Generate N+1}
end

fun {Sum Xs A Limit}
   if Limit>0 then
      case Xs of X|Xr then
         {Sum Xr A+X Limit-1}
      end
   else A end
end

local Xs S in
   Xs={Generate 0}     % 生産者
   S={Sum Xs 0 150000} % 消費者
   {Browse S}
end


% 遅延関数型言語においてすべての関数はデフォルトで遅延．
% 要求駆動並列モデルではlazyと書いて明示的に遅延にする．この方がコンパイラ・プログラマ双方にとって良いだろう，と．

% Haskellは正格評価を強制することもできる (foldlに対する'付きバージョンのfoldl'とかのアレ)


%% 4.5.4. 有界バッファ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 前節: 遅延を明示的にプログラムして性急ストリームのための有界バッファを構築
% 本節: 計算モデルが持つ遅延性を利用して有界バッファを構築

% 正しくない例
fun {Buffer1 In N}
   End={List.drop In N}
   fun lazy {Loop In End}
      case In of I|In2 then
         I|{Loop In2 End.2}
      end
   end
in
   {Loop In End}
end

% 正しい例
declare
fun {Buffer2 In N}
   End=thread {List.drop In N} end     % ここと
   fun lazy {Loop In End}
      case In of I|In2 then
         I|{Loop In2 thread End.2 end} % ここをthreadで囲った
      end
   end
in
   {Loop In End}
end

% 実行例
fun lazy {Ints N}
   {Delay 1000}
   N|{Ints N+1}
end

declare
In={Ints 1}
Out={Buffer2 In 5}
{Browse Out}
{Browse Out.1} % 1個だけ要素を要求


%% 4.5.5. ファイルを遅延的に読むこと
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {ReadListLazy FN}
   {File.readOpen FN}
   fun lazy {ReadNext}
      L T I in
      {File.readBlock I L T}
      if I==0 then T=nil {File.readClose}
      else T={ReadNext} end
      L
   end
in
   {ReadNext}
end


%% 4.5.6. ハミング問題
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% (2^a)*(3^b)*(5^c) な数(a, b, c >= 0)の最初のn個を求めるという問題(fig4.28)

fun lazy {Times N H}
   case H of X|H2 then N*X|{Times N H2} end
end

fun lazy {Merge Xs Ys}
   case Xs#Ys of (X|Xr)#(Y|Yr) then
      if X<Y then X|{Merge Xr Ys}
      elseif X>Y then Y|{Merge Xs Yr}
      else X|{Merge Xr Yr}
      end
   end
end

% 解く
H=1|{Merge {Times 2 H}
     {Merge {Times 3 H}
      {Merge {Times 5 H}}}}
{Browse H}

% 単純に必要とする手続きTouchを定義
declare
proc {Touch N H}
   if N>0 then {Touch N-1 H.2} else skip end
end


%% 4.5.7. 遅延リスト操作
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 遅延連結
declare
fun lazy {LAppend As Bs}
   case As
   of nil then Bs
   [] A|Ar then A|{LAppend Ar Bs}
   end
end

L={LAppend "foo" "bar"}
{Browse L}   % => _
{Browse L.1} % => 102

L={LAppend "foo" "bar"}
{Touch 5 L}
{Browse L} % => [102 111 111 98 97 104]

% 任意のリストを遅延化する関数
fun lazy {MakeLazy Ls}
   case Ls
   of X|Lr then X|{MakeLazy Lr}
   else nil end
end

% lazy map
fun lazy {LMap Xs F}
   case Xs
   of nil then nil
      [] X|Xr then {F X}|{LMap Xr F}
   end
end

fun {LForm I J}
   fun lazy {LFromLoop I}
      if I>J then nil else I|{LFromLoop I+1} end
   end
   fun lazy {LFromInf I} I|{LFromInf I+1} end
in
   if J==inf then {LFromInf I} else {LFromLoop I} end
end

% lazy flatten
fun {LFlatten Xs}
   fun lazy {LFlattenD Xs E}
      case Xs
      of nil then E
      [] X|Xr then
         {LFlattenD X {LFlattenD Xr E}}
      [] X then X|E
      end
   end
in
   {LFlattenD Xs nil}
end

% lazy reverse
fun {LReverse S}
   fun lazy {Rev S R}
      case S
      of nil then R
      [] X|S2 then {Rev S2 X|R} end
   end
in {Rev S nil} end

% lazy filter
fun lazy {LFilter L F}
   case L
   of nil then nil
   [] X|L2 then
      if {F X} then X|{LFilter L2 F} else {LFiter L2 F} end
   end
end


%% 4.5.8. 永続的キューとアルゴリズム設計
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% 償却的永続的キュー

fun {NewQueue} q(0 nil 0 nil) end

fun {Check Q}
   case Q of q(LenF F LenR R) then
      if LenF>=LenR then Q
      else q(LenF+LenR {LAppend F {fun lazy {$} {Reverse R} end}}
             0 nil) end
   end
end

fun {Insert Q X}
   case Q of q(LenF F LenR R) then
      {Check q(LenF F LenR+1 X|R)}
   end
end

fun {Delete Q X}
   case Q of q(LenF F LenR R) then F1 in
      F=X|F1 {Check q(LenF-1 F1 LenR R)}
   end
end


%%% 最悪時永続的キュー

fun {Reverse R}
   fun {Rev R A}
      case R
      of nil then A
      [] X|R2 then {Rev R2 X|A} end
   end
in {Rev R nil} end

fun lazy {LAppend F B}
   case F
   of nil then B
   [] X|F2 then X|{LAppend F2 B}
   end
end

fun lazy {LAppRev F R B}
   case F#R
   of nil#[Y] then Y|B
   [] (X|F2)#(Y|R2) then X|{LAppRev F2 R2 Y|B}
   end
end

fun {Check Q}
   case Q of q(LenF F LenR R) then
      if LenR=<LenF then Q
      else q(LenF+LenR {LAppRev F R nil} 0 nil) end
   end
end


%% 4.5.9. リスト内包表記
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% リスト内包表記(list comprehension)
