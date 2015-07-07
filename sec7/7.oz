%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                  7. オブジェクト指向プログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7.1. データ抽象
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% fig 7.2
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
% ☆
declare
fun {New Class Init}
   Fs={Map Class.attrs fun {$ X} X#{NewCell _} end}
   S={List.toRecord state Fs}
   proc {Obj M}
      {Class.methods.{Label M} M S}
   end
in
   {Obj Init}
   Obj
end


% 2015-07-07

%% 7.3.2 メソッドアクセス制御(静的束縛と動的束縛)

% あるオブジェクト内から，同じオブジェクト内の別のメソッドを呼びたいようなケースがある
% 簡単そうだけど継承が絡むと大変

% fig 7.6
declare
class Account
   attr balance:0
   % 入金
   meth transfer(Amt)
      balance:=@balance+Amt
   end

   % 残高を調べる
   meth getBal(Bal)
      Bal=@balance
   end

   % 連続入金
   meth batchTransfer(AmtList)
      for A in AmtList do {self transfer(A)} end
   end
end

% Accountを拡張してログを取るようにする
class LoggedAccount...
end

LogAct={New LoggedAccount transfer(100)}


% 動的束縛 {self M}
% 静的束縛 C,M

% 属性の場合は動的束縛だけが可能
% オーバーライドされた属性は要するに存在しないのでメモリが割り当てられない
% 属性 = ...


%% privateスコープとpublicスコープ

% それぞれの定義
% private: そのオブジェクトの中でしか見えない
% public : プログラムのどこからでも見える

% Oz (とSmalltalk) の場合, 属性はprivateでメソッドはpublic

% Javaのprotectedは同じパッケージからのみ見える, というスコープ

%% メソッド頭部(頭部とは)はアトムにするか名前にするか

% 内部メソッドは名前
% 外部メソッドはアトム

% 名前   = object_idのイメージ, 内部でuniqueに割り振られ扱い辛い. 継承の際に矛盾が生じないという利点もある
% アトム = symbolイメージ, 印字される文字で一意に定まるもの
% みたいなイメージか

% 委任(delegate)はselfを共有するが転嫁(forward)はselfを共有しない


% fig 7.9
% 転嫁の実装.
declare
local
   class ForwardMixin
      attr Forward:none
      meth setForward(F) Forward:=F end
      meth otherwise(M)
         if @Forward==none then raise undefinedMethod end
         else {@Forward M} end
      end
   end
in
   % 無名クラスだ
   fun {NewF Class Init}
      {New class $ from Class ForwardMixin end Init}
   end
end

% Obj2がObj1にforwardするようにしてみる...
class C1
   meth init skip end
   meth cube(A B) B=A*A*A end
end

class C2
   meth init skip end
   meth square(A B) B=A*A end
end


% 委任は(クラス間ではなく)オブジェクト間に階層を構成
% 探索経路をオブジェクトで繋げていく

% fig 7.10
% 委任(delegate)
declare
local
   SetSelf={NewName}
   class DelegateMixin
      % attr = ...
      % Hoge:x のコロン
      attr this Delegate:none
      % !Hoge = ...
      meth !SetSelf(S) this:=S end
      meth set(A X) A:=X end
      meth get(A ?X) X=@A end
      meth setDelegate(D) Delegate:=D end
      meth Del(M S) SS in
         SS=@this this:=S
         try {self M} finally this:=SS end
      end
      meth call(M) SS in
         SS=@this this:=self
         try {self M} finally this:=SS end
      end
      meth otherwise(M)
         if @Delegate==none then
            raise undefinedMethod end
         else
            {@Delegate Del(M @this)}
         end
      end
   end
in
   fun {NewD Class Init}
      Obj={New class $ from Class DelegateMixin end Init}
   in
      {Obj SetSelf(Obj)}
      Obj
   end
end


% fig 7.11
% 委任の構文を利用
declare
class C1
   attr i:0
   meth init skip end
   meth inc(I)
      {@this set(i {@this get(i $)}+I)}
   end
   meth browse
      {@this inc(10)}
      {Browse c1#{@this get(i $)}}
   end
   meth c {@this browse} end
end
Obj1={NewD C1 init}

class C2
   attr i:0
   meth init skip end
   meth browse
      {@this inc(100)}
      {Browse c2#{@this get(i $)}}
   end
end
Obj2={NewD C2 init}
{Obj2 setDelegate(Obj1)}


%% 内省(reflection)
% システムがreflectiveであるとは，実行中にその実行状態の一部を検査できること
% meta-object protocol

% オブジェクト上体のreflection

% fig 7.14
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7.4. 継承を使うプログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 継承をどう見るか?
% 1. 型である
%  クラスは型であり，代替性(substitution property)を満たす．
%  すなわちクラスCのオブジェクトのオブジェクトに使える操作はCの下位クラスのオブジェクトにも使える.
% 2. 構造である
%  プログラムを構造化するための1つのツールにすぎない, と. この見方は"全く進められない"
%  クラスが代替性を満たさないためあえである．


%% 契約による設計
% D言語，契約による設計をサポートしてたりする

%% 訓話 (読み物)

%% 7.4.2 型に従って階層を構成すること

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


% Rationalの書き方.


%% 7.4.4 多重継承
% そもそもなるべく継承を避けるというのが方針であるべきなのであんま現場では使わない
% 多重継承は要はmixin
% trait = mixin用の専用のモノ