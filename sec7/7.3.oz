%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7.3. 漸増的データ抽象としてのクラス
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 継承のための概念
%   1. 継承グラフ(inheritance graph)
%   2. メソッドアクセス制御 -- 動的/静的束縛, そしてself
%   3. カプセル化制御(encapsulation control)


%% 7.3.1 継承グラフ

% これはダメ
% "ラベルmのメソッドが2つ残るからである'
declare
class A1 meth m(X) X=a end end
class B1 meth m(X) X=b end end
class A from A1 end
class B from B1 end
class C from A B end

% これはOK ... 違いがわからん
% "Cの中で，2つのメソッドmが使えるからである"
declare
class A meth m(X) X=a end end
class B meth m(X) X=b end end
class C from A B end

% ラベルmのメソッドが2つ残ってるのにいいの?
% ラベルmではないのか，もしや. class C from A Bとした時点では同じラベルがあっても"Name"が異なるように継承してくれるとか


%% 7.3.2 メソッドアクセス制御(静的束縛と動的束縛)

% あるオブジェクト内から，同じオブジェクト内の別のメソッドを呼びたいようなケースがある
% 簡単そうだけど継承が絡むと大変
% 再帰的呼び出しに2通りの呼び方(静的束縛/動的束縛)が必要になるということ

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
   % 動的束縛 ... {self method}
   meth batchTransfer(AmtList)
      for A in AmtList do {self transfer(A)} end
   end
end


% Accountを拡張してログを取るようにする
class LoggedAccount from Account
   meth transfer(Amt)
      {LogObj addentry(transfer(Amt))}
      % ... ここはすぐ後に明らかにされるけど隠してる
   end
end

LogAct={New LoggedAccount transfer(100)}

% さてここで batchTransfer を呼ぶと, その中ではどちらの transfer が使われるか?
% 動的束縛の視点「データ抽象はメソッドの集合を持つ．外にあるものを取りに行くのではなく，継承を使ってクラスが定義された時点で LoggedAccount 自身はメソッド集合を持つようになる．その要素は継承された getBal, batchTransfer, そしてオーバーライドした transfer の 3 件である．したがって batchTransfer が呼ぶのは新しい方の transfer である」

{self transfer(A)} % の self は, LoggedAccount のメソッドの集合であるというアレを意味する

% 静的束縛 ... Hoge,method
% 新しい transfer のなかから古い transfer を呼ぶ時， Oz では","を使う．
% Ruby の場合は同名メソッドなら super
class LoggedAccount from Account
   meth transfer(Amt)
      {LogObj addentry(transfer(Amt))}
      Account,transfer(Amt)
   end
end


% 動的束縛 : {self M}
% 静的束縛 : C,M

% 継承でメソッドをオーバーライドするにはどちらか片方ではだめ．両方必要

% 属性の場合は動的束縛だけが可能．オーバーライドされた属性は"要するに存在しない"のでメモリが割り当てられない


%% 7.3.3. カプセル化制御

%% privateスコープとpublicスコープ
%   private: そのオブジェクトの中でしか見えない
%   public : プログラムのどこからでも見える

% Oz (とSmalltalk) の場合, 属性はprivateでメソッドはpublic
% Javaのprotectedは同じパッケージからのみ見える, というスコープ


%% その他のスコープを構築すること

% "カプセル化を制御するプログラムを書くための技法は，本質的に，字句的スコープ(lexical scoping)と名前値(name value)という2つの概念に基いている"．

% 内部メソッドは名前
% 外部メソッドはアトム
% メソッド頭部をアトムではなく名前値にすることでセキュリティが高まる
% 名前は偽造不能定数で，名前を知るには誰かからその参照を教えてもらう他ない．


%% 属性のスコープ
% メソッド頭部(頭部 = メソッド名と引数が並んでるあそこらしい)はアトムにするか名前にするか

% 名前   = object_idのイメージ? 内部でuniqueに割り振られ扱い辛い. 継承の際に矛盾が生じないという利点もある
% アトム = symbolのイメージ? 印字される文字で一意に定まるもの


%% 7.3.4. 転嫁(forwarding)と委任(delegation)

% |      -       |  inheritance  |   delegation    |   forwarding    |
% |--------------|---------------|-----------------|-----------------|
% | defined at   | class(static) | object(dynamic) | object(dynamic) |
% | self sharing | YES           | YES             | NO              |
% | bind         | tight         | tight           | soft            |


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

% 委任 delegation の syntax sugar
% オブジェクト呼び出し
%   before: {<obj> M}
%   after : {<obj> call(M)}
% self呼び出し
%   before: {self M}
%   after : {@this M}
% 属性読み出し
%   before: @<attr>
%   after : {@this get(<attr> $)}
% 属性書き込み
%   before: <attr>:=X
%   after : {@this set(<attr> X)}
% 委任設定
%   before: --
%   after : {<obj1> setDelegate(<obj2>)}


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


%% オブジェクト状態のreflection(内省)
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
