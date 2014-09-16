%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.7 例外
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare %% 最初のdeclareが省略されてるので注意
fun {Eval E}
   if {IsNumber E} then E
   else
      case E
      of plus(X Y) then {Eval X} + {Eval Y}
      [] times(X Y) then {Eval X} * {Eval Y}
      else raise illFormedExpr(E) end
      end
   end
end

try
   {Browse {Eval plus(plus(5 5) 10)}}
   {Browse {Eval times(6 11)}}
   {Browse {Eval minus(7 10)}}
catch illFormedExpr(E) then
   {Browse '*** Illegal expression '#E#' ***'}
end

%% 実行結果
%% https://dl.dropboxusercontent.com/s/nqlaykb9941rc8c/2014-09-16%20at%207.46%20PM.png?dl=0