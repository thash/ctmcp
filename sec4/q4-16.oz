% Xの計算を要求し，しかし待つことはしない操作を定義する
fun {Houchi X}
   thread if X==unit then skip else skip end end
end
% 単に比較の中にXを登場させて"必要と"するが，結果は捨てるだけ．
% それを別threadに投げてやることで，Houchi呼び出しメインスレッドはXを待たない．
% 要求だけして待たない．