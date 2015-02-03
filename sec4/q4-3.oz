declare
fun {FibS X} % 直列版
   if X=<2 then 1
   else {Fib X-1}+{Fib X-2} end
end

fun {FibC X} % 並列版
   if X=<2 then 1
   else thread {Fib X-1} end + thread {Fib X-2} end end
end

% 性能比較せよ => 直列定義の方が早い
% どのくらいのスレッドが生成されるか

Start={Time.time}
{Browse {FibC 30}}
End={Time.time}
{Browse elapsed#(End-Start)} % 経過秒数
