%% 相互再帰(mutual recursion)

%% 与えられた数をカウントダウン. 何回目の呼び出しで0になったか, で奇数偶数を調べている
fun {IsEven X}
   if X==0 then true else {IsOdd X-1} end
end

fun {IsOdd X}
   if X==0 then false else {IsEven X-1} end
end

%% 実行の様子を表すと

([{IsEven X}, {X=>x1}], {x1=N})
([{IsOdd  X}, {X=>x2}], {x2=N-1})
([{IsEven X}, {X=>x3}], {x3=N-2})
...

%% こうなるのでスタックの大きさは常に一定
%% (そうなの? 先の呼び出しのx1, x2を保持しないの?)