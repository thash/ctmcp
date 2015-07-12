%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7.2. 完全なデータ抽象としてのクラス
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

オブジェクト概念の核心は，カプセル化されたデータに統制あるアクセスをすること
オブジェクトの振る舞いはクラスによって規定される．


%% 7.2.1 クラスとオブジェクトの定義方法(1) - クラス構文を使う

% class という新しい構文があると仮定する(この時点では正確な実装を定義していない, 狩りの話)

% fig 7.1
declare
class Counter
   attr val
   meth init(Value)
      val:=Value
   end
   meth browse
      {Browse @val}
   end
   meth inc(Value)
      val:=@val+Value
   end
end

% 馴染みある言語っぽく見えるが，
% 実際は実行時にクラス値を生成し，それをCounterに束縛する式である．
% ということは，"Counter"を"$"に置き換えれば式の中で使える

% 使ってみる.
declare
C={New Counter init(0)} % New についてはFig7.3参照
{Browse C} % => O と表示...object?
{C inc(6)} {C inc(6)}
{C browse} % => 12

% {C inc(6)} という文はオブジェクト適用(object application)．
% オブジェクトCはinc(6) というメッセージを利用して対応するメソッドを起動する

% 以下の例はincメソッドの中でXが未束縛のままなので待ち，ブロックしてしまう
local X in {C inc(X)} X=5 end
{C browse}

% 次のようにすると動く.
declare S in
local X in thread {C inc(X)} S=unit end X=5 end
{Wait S} {C browse}


%% 7.2.2 クラスとオブジェクトの定義方法(2) - 状態ありモデルの中で定義

% 以下の例からわかるように，
% クラスとは属性名(リテラル)の集合とメソッド(メッセージとオブジェクトを引数に取る手続き)の集合を含むレコードにすぎない

% fig 7.2
% Counterクラスを定義すること(構文支援なし)
declare
local
   proc {Init M S}
      init(Value)=M in (S.val):=Value
   end
   proc {Browse2 M S}
      {Browse @(S.val)}
   end
   proc {Inc M S}
      inc(Value)=M in (S.val):=@(S.val)+Value
   end
in
   Counter=c(attrs:[val]
             methods:m(init:Init browse:Browse2 inc:Inc))
end


% fig 7.3
declare
fun {New Class Init}
   % 各attributes名をCellとくっつけてFsを作り
   Fs={Map Class.attrs fun {$ X} X#{NewCell _} end}
   % 状態Sはレコード
   S={List.toRecord state Fs}
   % オブジェクト状態Sは字句的スコープでObj内部に隠蔽
   proc {Obj M}
      {Class.methods.{Label M} M S}
   end
in
   {Obj Init}
   Obj
end

% NewCell, 手続きのarityについて復習
{NewCell _} % => illigal arity
{NewCell 1} % => illigal arity
{NewCell 1 MyCell} % => accepted -- これが本来の使い方. MyCellに新Cellが束縛される

% で, 以下のように使えば渡されない戻り値がfun自体の返り値となる
fun {GenCell} {NewCell unit} end
Hoge={GenCell}
{Browse @Hoge} % => unit

% toRecord の効果
% ref: [6.3 Lists](https://mozart.github.io/mozart-v1/doc-1.4.0/base/list.html)
S={List.toRecord state [a#1 b#2 c#3]}
{Browse S} % => state(a:1 b:2 c:3)

% Label はRecordのラベルを返す
{Label hoge(a:1 b:2)} % => hoge


%% 7.2.2 クラスとオブジェクトを定義すること

MyObj={New MyClass Init}
% Init は初期化に利用するメッセージ
{MyObj M} % という形で呼び出す. 手続きのように振る舞う．というか実装上手続きObjを返してるわけだし


%% 7.2.4 クラスメンバー

% そのクラスのオブジェクトがどれも持つような成分をメンバーという. 3個のメンバーがある
% 1. 属性(attr) ... Cell的に := で代入, @ で参照
% 2. メソッド(meth)
% 3. 性質(prop) ... オブジェクトの振る舞いを変える


%% 7.2.5 属性を初期化すること

declare
class A
   attr val
   meth init(X) @val=X end
end

MyA1={New A init(123)}
MyA2={New A init(789)}
MyA3={New A init} % 一応何も言われない

% デフォルト値を定義するには : を使う
declare
class A
   attr
      val:100
   meth init(X) @val=X end
end
MyA={New A init}

% @wallColor = white と
% wallColor := white を混同しないよう注意, とのこと


%% 7.2.6 第一級メッセージ

% メソッド定義の方法色々
% 固定引数リスト. ラベル(foo)とアリティ[a b c]が一致しないといけない
meth foo(a:A b:B c:C)
end

% 可変引数リスト
% [a b c] 以外も受け入れる
meth foo(a:A b:B c:C ...)
end

% 変数からのメソッド頭部の参照
% 変数Mはメッセージ全体(= 引数まるまる)をレコードとして参照する．
meth foo(a:A b:B c:C ...)=M
end

% オプショナル引数. デフォルト付き
% なかなか強引な構文だな
meth foo(a:A b:B<=V)
end

% プライベートメソッドラベル
% 変数識別子つまり大文字にすれば, クラス定義時に"名前"が一律に束縛され外からは参照できなくなる
meth Foo(bar:X)
end

% 動的メソッドラベル
% 「!」によりエスケープされた変数識別子を使って，実行時にメソッドラベルを決定する．
% クラス定義時にFooが何を参照してるかによって動的に名前決められる
meth !Foo(bar:X)
end

% otherwise
% 来る者拒まずメソッド. 他のどのメソッドともマッチしないメッセージを受け入れる.
% Ruby の method_missing か. 継承に変わる委任(delegation)実装時に利用する.
meth otherwise(M)
end


%% 7.2.7 第1級属性
% 属性名 A を実行時に決める. 危険機能だがデバッグには便利

class Inspector
   meth get(A ?X)
      X=@A
   end
   meth set(A X)
      A := X
   end
end
