% 遅延性と並列性

declare MakeX MakeY MakeZ X Y Z
fun lazy {MakeX} {Browse startX} {Delay 3000} {Browse endX} 1 end
fun lazy {MakeY} {Browse startY} {Delay 6000} {Browse endY} 2 end
fun lazy {MakeZ} {Browse startZ} {Delay 9000} {Browse endZ} 3 end

X={MakeX}
Y={MakeY}
Z={MakeZ}

{Browse (X+Y)+Z}
% => 00:00 startX
%    -- MakeXのDelay 3000
% => 00:03 startY (yは"直ちに"じゃないと思う)
%    -- MakeYのDelay 6000
% => 00:09 startZ
%    -- MakeZのDelay 9000
% => 00:18 6 (結果) (これも本文の言うように15秒後じゃない)

% 式の評価順で必要とされる順にdelayが走って行くので遅い
% CTMCP本文では+オペレータの両方同時に走り始めるような値を書いてるけどそんなことない

{Browse X+(Y+Z)}
% => 00:00 startY
%    -- MakeYのDelay 6000
% => 00:06 startZ
%    -- MakeZのDelay 9000
% => 00:15 startX
%    -- MakeXのDelay 3000
% => 00:18 6 (結果)

{Browse thread X+Y end + Z}
% => 00:00 startX
%    -- MakeXのDelay 3000
% => 00:03 startY
%    -- MakeYのDelay 6000
% => 00:09 startZ
%    -- MakeZのDelay 9000
% => 00:18 6 (結果)

% threadを使っても()による直列評価と変わらん気がするが...
