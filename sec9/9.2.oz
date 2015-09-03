%% 9.2. 別の例
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
fun {Digit}
  choice 0 [] 1 [] 2 [] 3 [] 4 [] 5 [] 6 [] 7 [] 8 [] 9 end
end
{Browse {SolveAll Digit}} % => 結果が出力されない

% 2桁の数
fun {TwoDigit}
  10*{Digit}+{Digit}
end
{Browse {SolveAll TwoDigit}}

% 定義を変えると生成される結果の順も変わる(探索順)
fun {StrangeTwoDigit}
  {Digit}+10*{Digit}
end
{Browse {SolveAll StrangeTwoDigit}}


% 回文
proc {Palindrome ?X}
  X=(10*{Digit}+{Digit})*(10*{Digit}+{Digit}) % 生成
  (X>0)=true
  (X>=1000)=true
  (X div 1000) mod 10 = (X div 1)  mod 10
  (X div 100)  mod 10 = (X div 10) mod 10
end
{Browse {SolveAll Palindrome}} % => 118 個の解が表示される, らしい


%% 9.2.2 パズルと n クイーン問題

% fig 9.4 - データフロー変数を使った関係プログラミングによる解法
declare
fun {Queens N}
   fun {MakeList N}
      if N==0 then nil else _|{MakeList N-1} end
   end

   proc {PlaceQueens N ?Cs ?Us ?Ds}
      if N>0 then Ds2
         Us2=_|Us
      in
         Ds=_|Ds2
         {PlaceQueens N-1 Cs Us2 Ds2}
         {PlaceQueen N Cs Us Ds}
      else skip end
   end

   proc {PlaceQueen N ?Cs ?Us ?Ds}
      choice
         Cs=N|_ Us=N|_ Ds=N|_
      [] _|Cs2=Cs _|Us2=Us _|Ds2=Ds in
         {PlaceQueen N Cs2 Us2 Ds2}
      end
   end
   Qs={MakeList N}
in
   {PlaceQueens N Qs _ _}
   Qs
end

{Browse {SolveOne fun {$} {Queens 8} end}}
% => [[1 7 5 8 2 4 6 3]] ... が出るらしいがまぁ Solve さん動かない

% 解法の数を数える
{Browse {Length {SolveAll fun {$} {Queens 8 } end}}} % => 92

% n が大きくなると関係プログラミングでは実用的ではないが, エレガントではある
