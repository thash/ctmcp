%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                  12. 制約プログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CSP = constraint satisfaction problem.
% X は Y より小さい, とかそういう条件を集めて何かを解くもの. 力尽くでやれば必ず溶けるが,
% それをより賢く渡航という話

% CSP を攻略する一般的な方法 = 伝播・探索法 propagate-and-search,
% 伝播・分配法 propagate-and-distribute

%% 12.1 伝播・探索法
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare X Y in
X::90#110
Y::48#53

% X::90#110 は
% x ∈ {90,91,...,110} を表す.


% 上を実行すると
%** ------------------ crashed
% ...となって動かない

declare A in
A::0#10000
A=:X*Y
{Browse A>:4000} % 1 が表示される (真であるってこと)
{Browse A} % 4320#5830 が表示される

% =: が伝播子 (propagator)
% a, x, y を見て, それらの間に情報を伝播するので.

% SEND MONEY パズル:
%
%   S E N D
% + M O R E
% ---------
% M O N E Y
