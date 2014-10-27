%% 差分リストの限界
%% 同じ差分リストを2度以上appendするとなにがまずいのか?

%% 差分リストのappendは,
%% 差分リストの後半部分が未定義のとき, そこに別のリストを束縛することで定数時間でappendするもの

declare AppendD Dx Dy X Y
fun {AppendD D1 D2}
   S1#E1=D1
   S2#E2=D2
in
   E1=S2
   S1#E2
end

Dx=[1 2 3]#X
Dy=[9 8 7]#Y

{Browse Dx} % => [1 2 3]#_
{Browse {AppendD Dx Dy}}
{Browse Dx} % => [1 2 3]#[9 8 7]
{Browse Dy} % => [9 8 7]#_

%% この時点で, Dxの後半リストにDyの前半が束縛されている
%% 再度appendしようとしても, 差分リストのappendは単に後半部分を束縛するだけのものなので結果は同じ
{Browse {AppendD Dx Dy}}
{Browse Dx} % => [1 2 3]#[9 8 7]
{Browse Dy} % => [9 8 7]#_