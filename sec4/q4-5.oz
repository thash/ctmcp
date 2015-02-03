% Waitを次のように定義してもよいのはなぜか
proc {MyWait X}
   if X==unit then skip
   else skip end
end

% まぁ何故かっつーかif式のXを評価するところで束縛するまで待ち続け,
% 比較自体とその真偽はどうでもいいのでskipで処理を手放すというそれだけ