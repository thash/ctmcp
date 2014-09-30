%% 整列されたリストをマージする以下の関数を核言語に展開せよ

fun {SMerge Xs Ys}
   case Xs#Ys
   of nil#Ys then Ys
   [] Xx#nil then Xs
   [] (X|Xr)#(Y|Yr) then
      if X=<Y then X|{SMerge Xr Ys}
      else Y|{SMerge Xs Yr} end
   end
end

%% 無名手続きを束縛(?)
%% パターンマッチは入れ子のcaseに展開される.
declare SMerge Result
SMerge = proc {$ Xs Ys ?T}
            case Xs of nil then T = Ys
            else
               case Ys of nil then T = Xs
               else
                  local X Y Xr Yr T1 T2 in
                     Xs = '#'(X Xr) % 単一化, XとXrを束縛している
                     Ys = '#'(Y Yr)
                     {Browse Xs}
                     T1 = X=<Y
                     if T1 then % bool以外を取るのはsyntax sugarか.
                        T = '#'(X T2) % T2が↓の呼び出しで束縛されるのを待つ
                        {SMerge Xr Ys T2}
                     else
                        T = '#'(Y T2)
                        {SMerge Xs Yr T2}
                     end
                  end
               end
            end
         end

{SMerge '#'(1 3) '#'(2 4) ?Result} % => 1#3 ???
{Browse Result} % => 1#_ ???

%% リストリテラルでは動かない?
%% {SMerge [1 2 4] [3 5] ?Result}