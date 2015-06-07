% セルを使う状態
% 6.1で定義したSumListは，2つの引数の値としてコード化された状態を持っている．
% SumListを，セルによって状態を持つversionに書き換えよ．

% 元の定義
declare
fun {SumList Xs S}
   case Xs
   of nil then S
   [] X|Xr then {SumList Xr X+S}
   end
end

{Browse {SumList [1 2 3 4] 0}} % => 10

% セルを使うversion
declare
local
   S={NewCell 0}
in
   fun {SumList Xs}
      case Xs
      of nil then @S
      [] X|Xr then
         S:=@S+X
         {SumList Xr}
      end
   end
end

{Browse {SumList [1 2 3 4 5]}}

% 状態が明示的に存在するので，途中で{Browse @S}したりできる
