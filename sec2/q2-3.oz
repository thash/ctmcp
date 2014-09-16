%% 関数と手続き.
%% 関数本体が, else部のないif文である場合, if文の条件がfalseであると例外が発生する. なぜこの振る舞いが正しいか.
%% この状況は手続きでは起きない. 説明せよ.

declare F
fun {F X}
   if X>10 then X end
end
%% {F 12} だけでは illegal arity in application, となる
{F 12 _} %% accepted
%% 返り値捨てさせても一応通るが, Browseで表示させる.

{Browse {F 12}} %% accepted
{Browse {F  2}} %% accepted <- ?

%% falseでもaccept されたんだが...
%% Browseに表示はされない(accept可否じゃなくてこれが例外ってこと?)

declare P
proc {P X ?R}
   if X>10 then R={X-1} end % 本体が X だけではacceptされない
end
{Browse {P 12}} % accepted
{Browse {P 2}}  % accepted

%% 回答: 関数は「本体の終わりが式でなければならない(p.85)」から?