% {Cell.exchange +Cell X Y}
% returns the current content of Cell in X, and sets the content of Cell to Y.
% ref: https://mozart.github.io/mozart-v1/doc-1.4.0/base/cell.html#label489

% Cellに入っていた内容を別の変数に格納しつつ，Cellを更新する
declare NC={NewCell 0}
{Browse NC}  % => <Cell>
{Browse @NC} % => 0

declare PPP={Exchange NC $ 212}
{Browse PPP} % => 0
{Browse @NC} % => 212

% nesting markerを使わない場合
declare PPP2 in {Exchange NC PPP2 334}
{Browse PPP2} % => 212
{Browse @NC} % 334
