%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7.4. 継承を使うプログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 継承をどう見るか?
% 1. 型である
%  クラスは型であり，代替性(substitution property)を満たす．
%  すなわちクラスCのオブジェクトのオブジェクトに使える操作はCの下位クラスのオブジェクトにも使える.
% 2. 構造である
%  プログラムを構造化するための1つのツールにすぎない, と. この見方は"全く進められない"
%  クラスが代替性を満たさないためである．

% 継承を構造ではなく型と見るべき理由. 例を挙げる
% fig7.6 で定義したAccountのオブジェクトAは次の代数的規則を満たす
{A getBalance(b)} {A transfer(s)} {A getBalance(b2)}
% ここで b2 = b + s である．これを "Accountの仕様" "プログラムとオブジェクトの契約" など色々見方はあるが
% クラスを型と見る見方によれば，Account下位クラスはこの契約を実装すべきである
% ;; え，親クラスで定義されてるのに?

class VerboseAccount from Account
  meth verboseTransfer(Amt)
    {self transfer(Amt)}
    {Browse 'Balance:'#@balance}
  end
end

% さてもっと危険な拡張をしよう
class AccountWithFee from VerboseAccount
  attr fee:5
  meth transfer(Amt)
    VerboseAccount,transfer(Amt-@fee)
  end
end

% feeの追加によってb2 = b + sという契約が破られてしまった
% ;; ん? 型と見ろさもなくば危険，という話の流れじゃなかったっけ??


%% 契約による設計(design by contract)
% 契約による設計の中心思想「データ抽象には抽象の設計者とユーザの間の契約が含まれる」

% D言語，契約による設計をサポートしてたりする


%% 訓話 (読み物)
% OOP の誤用による失敗プロジェクトの辛い話


%% 7.4.2 型に従って階層を構成すること

% fig7.14
% そんなnilやconsより上位の抽象クラスをListって付けていいの感
declare
class ListClass
   meth isNil(_) raise undefinedMethod end end
   meth append(_ _) raise undefinedMethod end end
   meth display raise undefinedMethod end end
end

class NilClass from ListClass
   meth init skip end
   meth isNil(B) B=true end
   meth append(T U) U=T end
   meth display {Browse nil} end
end

class ConsClass from ListClass
   attr head tail
   meth init(H T) head:=H tail:=T end
   meth isNil(B) B=false end
   meth append(T U)
      U2={@tail append(T $)}
   in
      U={New ConsClass init(@head U2)}
   end
   meth display {Browse @head} {@tail display} end
end


%% 7.4.3 汎用クラス(generic class)

% 実現方法(1). 継承を使う
% 実現方法(2). 高階プログラミングを利用する

% fib 7.15 汎用クラスの使い方(継承バージョン)
% クイックソート
declare
class GenericSort
   meth init skip end
   meth qsort(Xs Ys)
      case Xs
      of nil then Ys = nil
      [] P|Xr then S L in
         {self partition(Xr P S L)}
         {Append {self qsort(S $)}
                 P|{self qsort(L $)} Ys}
      end
   end
   meth partition(Xs P Ss Ls)
      case Xs
      of nil then Ss=nil Ls=nil
      [] X|Xr then Sr Lr in
         if {self less(X P $)} then
            Ss=X|Sr Ls=Lr
         else
            Ss=Sr Ls=X|Lr
         end
         {self partition(Xr P Sr Lr)}
      end
   end
end

% fig 7.16
declare
class IntegerSort from GenericSort
   meth less(X Y B)
      B=(X<Y)
   end
end

class RationalSort from GenericSort
   meth less(X Y B)
      '/'(P Q)=X
      '/'(R S)=Y
   in B=(P*S<Q*R) end
end


% fig 7.18
% 汎用ソートクラス
% 比較ロジック"Less"を渡してやる
declare
fun {MakeSort Less}
   class $
      meth init skip end
      meth qsort(Xs Ys)
         case Xs
         of nil then Ys = nil
         [] P|Xr then S L in
            {self partition(Xr P S L)}
            {Append {self qsort(S $)}
                    P|{self qsort(L $)} Ys}
         end
      end
      meth partition(Xs P Ss Ls)
         case Xs
         of nil then Ss=nil Ls=nil
         [] X|Xr then Sr Lr in
            if {Less X P} then
               Ss=X|Sr Ls=Lr
            else
               Ss=Sr Ls=X|Lr
            end
            {self partition(Xr P Sr Lr)}
         end
      end
   end
end

% fig 7.19
declare
IntegerSort = {MakeSort fun {$ X Y} X<Y end}

RationalSort = {MakeSort fun {$ X Y}
                            '/'(P Q) = X
                            '/'(R S) = Y
                         in P*S<Q*R end}

% これで次の例が実行できる
ISort={New IntegerSort init}
RSort={New RationalSort init}
{Browse {ISort qsort([1 2 5 3 4] $)}}
{Browse {RSort qsort(['/'(23 3) '/'(34 11) '/'(47 17)] $)}}


%% 7.4.4 多重継承
% そもそもなるべく継承を避けるというのが方針であるべきなのであんま現場では使わない
% 多重継承は要は mixin ;; 最近いくつかの言語で登場する trait = mixin 専用のモノ

class Figure
  meth otherwise(M)
    raise undefinedMethod end
  end
end

class Line from Figure
  attr canvas x1 y1 x2 y2
  meth init(Can X1 Y1 X2 Y2)
    canvas:=Can
    x1:=X1 y1:=Y1
    x2:=X2 y2:=Y2
  end
  meth move(X Y)
    x1:=@x1+X y1:=@y1+Y
    x2:=@x2+X y2:=@y2+Y
  end
  meth display
    {@canvas create(line @x1 @y1 @x2 @y2)}
  end
end

class Circle from Figure
  attr canvas x y r
  meth init(Can X Y R)
    canvas:=Can
    x:=X y:=Y r:=R
  end
  meth move(X Y)
    x:=@x+X y:=@y+Y
  end
  meth display
    % circleじゃなくて?
    {@canvas create(oval @x-@r @y-@r @x+@r @y+@r)}
  end
end

% 図形をまとめてLinkedListクラスを定義する
class LinkedList
  attr elem next
  meth init(elem:E<=null next:N<=null)
    elem:=E next:=N
  end
  meth add(E)
    next:={New LinkedList init(elem:E next:@next)}
  end
  meth forall(M)
    if @elem\=null then {@elem M} end
    if @next\=null then {@next forall(M)} end
  end
end

% 合成図形
class CompositeFigure from Figure LinkedList
  meth init
    LinkedList,init
  end
  meth move(X Y)
    {self forall(move(X Y))}
  end
  meth display
    {self forall(display)}
  end
end

% 実行例
declare
W=250 H=150 Can
Wind={QTk.build td(title:"wei" canvas(width:W height:H bg:white handle:Can))}
{Wind show}

declare
F1={New CompositeFigure init}
{F1 add({New Line init(Can .....)})}
{F1 add({New Line init(Can .....)})}
{F1 add({New Line init(Can .....)})}
{F1 add({New Circle init(Can .....)})}
{F1 display}

for I in 1..10 do {F1 display} {F1 move(3 ~2)} end


%% 7.4.5 多重継承に関するおおざっぱな指針

% * 完全に独立の抽象を結合するとき多重継承はうまくいく
% * 実装共有問題(implementation-sharing problem)
%   * A, B それぞれの親クラスが兄弟で, 状態ありオブジェクト(属性)を持つようなケース
% * 名前衝突, つまり同レベルの上位クラスに同じメソッドラベルがあるとき,
%   衝突を起こしたメソッドをオーバーライドする局所的メソッドを定義すべき．さもなければエラー．
%   メソッド頭部に名前値を使えば一応名前衝突は回避できる．多重継承を行うことの多い mixin クラスには有用
