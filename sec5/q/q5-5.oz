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
% Erlangみたいに別サーバで実行させたりすると，4の方が先になる可能性もある

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
% なのでまぁ非決定的だよと

% // Aを束縛した後Delayしてるくさいので，やっぱりConcFilter内でAの束縛を待ってる...


% (d-1). 入力リストの要素数がnであるときConcFilterの実行回数の計算量はO記法でどう書ける?

% ConcFilterは途中でブロックする要素があるかどうかにかかわらず
% リストすべての要素について計算を行うため，実行回数の計算量はO(n).

% (d-2). FilterとConcFilterの実行時間の差は?
% すべての計算がブロックしないなら，スレッド生成のオーバーヘッドがない分普通のFilterが速い．
% しかし一定の確率でブロックする要素がある場合を考えると，平均的にConcFiterの方が速い(?)