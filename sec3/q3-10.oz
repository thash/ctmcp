%% あるものがリストであるかチェックする

%% リストでなければtrueを返すLeaf.
declare Leaf
fun {Leaf X} case X of _|_ then false else true end end

{Browse {Leaf 1}}         % => true
{Browse {Leaf 1|2|3}}     % => false
{Browse {Leaf [1 2 3]}}   % => false

%% caseパターンマッチを使わず比較演算子の糖衣構文として
%% 次のように定義することも考えられる. これは何がまずいのか?
declare Leaf
fun {Leaf X} X\=(_|_) end

{Browse {Leaf 1}}        % => true
{Browse {Leaf 1|2|3}}    % => 何も返さない
{Browse {Leaf [1 2 3]}}  % => 何も返さない

declare Leaf
fun {Leaf X} if X\=(_|_) then true else false end end
{Browse {Leaf 1}}        % => true
{Browse {Leaf 1|2|3}}    % => 何も返さない
{Browse {Leaf [1 2 3]}}  % => 何も返さない