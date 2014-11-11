%% リストの平坦化の計算量
declare BadFlatten Flatten

%% 要素数 n, 入れ子最大深さ k のとき, (最悪時)操作回数はそれぞれいくらになるか

%% (1) BadFlatten
fun {BadFlatten Xs}
   case Xs
   of nil then nil
   [] X|Xr andthen {IsList X} then
      {Append {BadFlatten X} {BadFlatten Xr}}
   [] X|Xr then % XがListじゃない場合
      X|{BadFlatten Xr}
   end
end

%% IsList: 定数時間
%% Append: リストの長さに比例する

%% T_: シグネチャ?
%% T_BadFlatten(size(Ls))
%% size(Ls) = (n, k) と表す.

%% caseのそれぞれの場合について式を立てる. anは定数
T_BadFlatten((0,1)) = a1 % nil = [] の場合は (0, 1)
T_BadFlatten((n,1)) = a2 + T_BadFlatten((n-1, 1)) % (n>0のとき)
T_BadFlatten((n,k)) = a3 + T_BadFlatten((n, k-1)) + T_BadFlatten((0,1)) + a4*n % (n > 0, k > 0のとき)

T_BadFlatten((n,k))
= ((a1+a3) + a4*n) + T_BadFlatten((n,k-1))
= (a13 + a4*n) + ... + (a13 + a4*n) + T_BadFlatten((n,1)) % a13 = a1 + a3とおいた
= (k-1)*(a13 + a4*n) + a2 + ... + a2 + a1
= (k-1)*(a13 + a4*n) + n*a2 + a1

%% よってT_BadFlatten((n,k))の計算量は O(n*k)


%% (2) Flatten (差分リスト)
fun {Flatten Xs}
   fun {FlattenD Xs E}
      case Xs
      of nil then E
      [] X|Xr andthen {IsList X} then
         {FlattenD X {FlattenD Xr E}}
      [] X|Xr then
         X|{FlattenD Xr E}
      end
   end
in
   {FlattenD Xs nil}
end

%% 差分リストである今回は, kの値に関わらずn=0のときnil.
%% caseのそれぞれの場合について
T_Flatten((0,k)) = a1
T_Flatten((n,k)) = a2 + T_Flatten((1,k-1)) + T_Flatten((n-1,k)) % (n>0, k>0のとき)
T_Flatten((1,0)) = a3 + T_Flatten((0,0))                        % (n=1, k=0のとき)

%% よって
T_Flatten((n,k))
= a2 + T_Flatten((1,k-1)) + T_Flatten((n-1,k))
= a2 + (a4 + )

