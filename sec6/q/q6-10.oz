% 要求呼び出し

% 名前呼び出しの場合，引数は必要になるたびに計算される．要求呼び出しの場合，引数の計算は高々1回である．
% q6-9のswapを要求呼び出しに変更するとどうなるか?

%%% q6-9.oz のもの
proc {Swap X Y}
   T
in
   T=@{X}
   {X}:=@{Y}
   {Y}:=T
end

% Q1a. 要求呼び出しに変更せよ
declare
proc {Swap X Y}
   T
   XMem={X} % メモ化したもの. セル.
   YMem={Y}
in
   T=@XMem
   XMem:=@YMem
   YMem:=T
end

A={MakeTuple array 10}
for J in 1..10 do A.J={NewCell 0} end

I={NewCell 1}
(A.1):=2
% (A.2):=1
(A.2):=3

for J in 1..10 do {Browse @(A.J)} end
{Swap fun {$} I end fun {$} A.@I end}

% Swapが起こる
{Browse @(A.1)} % => 1
{Browse @(A.2)} % => 1

% Q1b. swapの定義を変更すると要求呼び出しでも似たような問題が起きるか?
% たとえば
%     XMem={X}  とセルを束縛する代わりに
%     XMem=@{X} のように中身を取り出してしまうと，挙動は6-9と同じになる


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Q2. 6.4.4 の要求呼び出しの中でSqr本体は必ず関数Aを呼んでいた．
% Aを遅延呼び出しするように変更せよ．
% Aが呼ばれるのは高々1回(= メモ化すること)

% 比較: 元の実装
declare
proc {Sqr A}
   % ここで必ずAを呼び出している
   B={A}
in
   {Browse aaa}
   % B:=@B*@B
   {Browse bbb}
end

% 遅延呼び出しにする
declare
proc {Sqr A}
   % lazy無名関数でくるむ
   B={fun lazy {$} {A} end}
in
   {Browse aaa}
   % B:=@B*@B % この行をコメントアウトするとhikisuuが出ないことが確認できる
   {Browse bbb}
end

local C={NewCell 0} in
   C:=25
   {Sqr fun {$}
           {Browse hikisuu}
            C end}
   {Browse @C}
end
