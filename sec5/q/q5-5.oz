% 並列フィルタ．5.6.4で定義したConcFilterを考察する．

% ConcFilter定義(再掲)
proc {ConcFilter L F ?L2}
   Send Close
in
   {NewPortClose L2 Send Close}
   {Barrier
    {Map L
     fun {$ X}
        proc {$}
           if {F X} then {Send X} end
        end
     end}}
   {Close}
end


% (a).
declare Out
{ConcFilter [5 1 2 4 0] fun {$ X} X>2 end Out}
% {Show Out} Showの出力よくわからんのでBrowse
{Browse Out}

% ConcFilterの実行は決定的か，非決定的か? その理由は?
% フィルタリングされて出てくる要素は同じだけど順番が変わる．ので非決定的


% (b).
declare Out
{ConcFilter [5 1 2 4 0] fun {$ X} X>2 end Out}
{Delay 1000}
% {Show Out}
{Browse Out}

% Delayで待ってるけど，ConcFilter呼ばれた時点で並列にばっと渡されてるから
% やはり(a)と同じように非決定的なのではないか


% (c).
declare Out A
{ConcFilter [5 1 A 4 0] fun {$ X} X>2 end Out}
{Delay 1000}
% {Show Out}
{Browse Out}


% 何が表示されるか?
% => [5 4] もしくは [4 5] ... と予測したけどBrowseだと出てこないな．Showでも? Aを待ってるのか．
% このあと
A=3
% と束縛すると，Outは [5 4 3] もしくは [4 5 3] になる
% Aを束縛した後Delayしてるくさいので，やっぱりConcFilter内でAの束縛を待ってる...


% (d).
% 入力リストの要素数がnであるときConcFilterの実行回数の計算量はO記法でどう書ける?
