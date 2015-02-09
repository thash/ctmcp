% ディジタル論理シミュレーション
% nビット数を加算する回路. 4.3.5節の手法を使う.

declare
fun {NotLoop Xs}
   case Xs of X|Xr then (1-X)|{NotLoop Xr} end
end

fun {NotG Xs}
   thread {NotLoop Xs} end
end

fun {GateMaker F}
   fun {$ Xs Ys}
      fun {GateLoop Xs Ys}
         case Xs#Ys of (X|Xr)#(Y|Yr) then
            {F X Y}|{GateLoop Xr Yr}
         end
      end
   in
      thread {GateLoop Xs Ys} end
   end
end
AndG  = {GateMaker fun {$ X Y} X*Y end}
OrG   = {GateMaker fun {$ X Y} X+Y-X*Y end}
NandG = {GateMaker fun {$ X Y} 1-X*Y end}
NorG  = {GateMaker fun {$ X Y} 1-X+Y-X*Y end}
XorG  = {GateMaker fun {$ X Y} X+Y-2*X*Y end}
proc {FullAdder X Y Z ?C ?S}
   K L M
in
   K={AndG X Y}
   L={AndG Y Z}
   M={AndG X Z}
   C={OrG K {OrG L M}}
   S={XorG Z {XorG X Y}}
end


% nビット2進数を, 全加算器の連鎖を使い, 手計算をマネて数を足す
% 例: n=4
local
   X1s=0|1|0|1|0|1|0|1|0|1|0|1|0|1|0|1|_
   X2s=0|0|1|1|0|0|1|1|0|0|1|1|0|0|1|1|_
   X3s=0|0|0|0|1|1|1|1|0|0|0|0|1|1|1|1|_
   X4s=0|0|0|0|0|0|0|0|1|1|1|1|1|1|1|1|_
   Y1s=1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|_
   Y2s=1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|_
   Y3s=0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|_
   Y4s=0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|_
   C0s=0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|_
   C1s C2s C3s C4s
   S1s S2s S3s S4s
   % FullAdderの最後2個は返り値
   {FullAdder X1s Y1s C0s C1s S1s} % 1 (LSB: Least significant bit, 最下位ビット)
   {FullAdder X2s Y2s C1s C2s S2s} % 2
   {FullAdder X3s Y3s C2s C3s S3s} % 3
   {FullAdder X4s Y4s C3s C4s S4s} % 4 (MSB: Most significant bit, 最上位ビット)
   proc {BrowseOutBits S1s S2s S3s S4s C4s}
      case S1s#S2s#S3s#S4s#C4s
      of (S1|S1r)#(S2|S2r)#(S3|S3r)#(S4|S4r)#(C4|C4r) then
         {Browse s#[S4 S3 S2 S1]}
         {Browse c#C4}
         {Delay 1000}
         {BrowseOutBits S1r S2r S3r S4r C4r}
      end
   end
in
   {BrowseOutBits S1s S2s S3s S4s C4s}
end
