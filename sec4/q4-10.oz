% 遅延の基礎

declare
fun lazy {Three} {Delay 1000} 3 end
Res={Three} + 0
{Browse Res}

% 3回連続して実行すると毎回1秒待つ．何故か?

declare Res1 Res2 Res3
Res1={Three} + 0
Res2={Three} + 0
Res3={Three} + 0
{Browse Res3}

% 何故か? というかThree関数の中でdelayしてるからでは