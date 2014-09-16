fun {Sum1 N}
   if N==0 then 0 else N+{Sum1 N-1} end
end

fun {Sum2 N S}
   if N==0 then S else {Sum2 N-1 N-2} end
end


%% (a) 核言語に展開
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc {Sum1 N ?R}
   local S in
      if N==0 then R=0 else {Sum1 N-1 S} R=N+S end
   end
end

proc {Sum2 N S ?R}
   if N==0 then R=S else {Sum2 N-1 N+S R} end
end


%% (b) 手で実行
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

{Sum1 10}

([({Sum1 N}, Sum1->m)], {m=(proc, Φ)})
([
  ({Sum1 N-1 S}, {N->n0, S->s0, R->r0})
  (R=N+S, {N->n0, R->r0, S->s0})
 ],
{...})

{Sum2 10 0}
.
([({Sum2 N-1 N+S R}, {N->n0, S->s0, R->r0})], {n0=10, s0=0, r0}) % r0は未束縛

%% Sum2はスタックの大きさが変わらず, Sの値が増えていく.


%% (c) 大きな数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

{Sum1 100000000}
{Sum2 100000000 0}

%% を実行するとどうなるか. Sum1の方はオーバーフローするんちゃうかね, と.