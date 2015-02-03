% 並列状況におけるデータフロー的振る舞い
declare
fun {Filter In F}
   case In
   of X|In2 then
      % 要素をFした結果が真であるものをフィルタリング
      if {F X} then X|{Filter In2 F}
      else {Filter In2 F} end
   else
      nil
   end
end

% ShowはBroweseとは違い, 未束縛のものをそのまま_で表示する.
{Show {Filter [5 1 2 4 0] fun {$ X} X>2 end}}
% => [5 4]

% (a)
declare A
{Show {Filter [5 1 A 4 0] fun {$ X} X>2 end}}

% (b)
declare Out A
thread Out={Filter [5 1 A 4 0] fun {$ X} X>2 end} end
{Show Out} % Showは待ってくれない.

% (c) mainの方で1秒delayしてからshow
declare Out A
thread Out={Filter [5 1 A 4 0] fun {$ X} X>2 end} end
{Delay 1000} % ヒマなので↑のthreadが実行される
{Show Out}

% Showはまってくれず, delay, show, delay, showとかやると変化がわかってくるのか

% (d)
declare Out A
thread Out={Filter [5 1 A 4 0] fun {$ X} X>2 end} end
thread A=6 end
{Delay 1000}
{Show Out}
