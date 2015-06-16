% 名前呼び出し

% [参考] 6.4.4 の名前呼び出し実装と利用方法
declare
proc {Sqr A}
   {A}:=@{A}*@{A}
end

local C={NewCell 0} in
   C:=25
   {Sqr fun {$} C end}
   {Browse @C}
end

% 明示的状態と引数の遅延計算が好ましくない相互作用をする例
procedure swap(callbyname x,y:integer);
var t:integer;
begin
t:=x; x:=y; y:=t
end;
var a:array [1..10] of integer;
var i:integer;
i:=1; a[1]:=2; a[2]=1; % a[2]だけ=になってるのは誤植?

[2, 1, ...]
[1, 1, ...]

swap(i, a[i]) % a[1] = 2
writeln(a[1], a[2]);
% => 期待 1, 1 (i=1とa[1]=2をswapするからiが2, a[1]が1になってほしい?)
% => 実際 2, 1

i = 2
a[1] = 1


% Q1. 上の例の挙動を, 名前呼び出しの理解に基づいて説明せよ

  i = 1, a = [2, 1, ...]
% の状態で
  swap(i, a[i])
% を実行すると
  t:=x
% x(= i)が必要とされ呼び出される. 値は1.
% 終了時点で t = 1
  x:=y
% y(= a[i])が必要とされ呼び出される.
% iはメモ化されてないので再度実行され1を返す
% a[1]を参照し，2を得る
% 終了時点で x = 2
  y:=t
% tに格納された値1がyに格納される．
% 終了時点で x = 2, y = 1
% 呼び出し側 i = 2, a[2] = 1

% よって
  writeln(a[1], a[2])
% => 2, 1


% Q2. この例を，状態あり計算モデルでコーディングせよ.

declare
proc {Swap X Y}
   T
in
   T=@{X}
   {X}:=@{Y}
   {Y}:=T
end

% 配列は以下の通りセルのタプルとして実装せよとのこと
A={MakeTuple array 10}
for J in 1..10 do A.J={NewCell 0} end

I={NewCell 1}
(A.1):=2
% (A.2):=1
(A.2):=3
for J in 1..10 do {Browse @(A.J)} end
{Swap fun {$} I end fun {$} A.@I end}
for J in 1..10 do {Browse @(A.J)} end

% Swapしない
{Browse @(A.1)} % => 2
{Browse @(A.2)} % => 1 <- もとは i のやつ
