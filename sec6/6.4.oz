%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6.4. データ抽象
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% データ抽象とはその実装にとらわれずデータを使うこと．

% > データ抽象を「型(type)」といって済ますこともある．

% 3.7(p.201)で紹介した抽象データ型(ADT)は，特殊なデータ抽象．データを抽象的に扱う方法はADTだけではない．

%% 6.4.1. データ抽象を組織する8つの方法

% * 開放性と安全性 (開放 or 安全)
% * バンドリング
% * 明示的状態

% 図6.2


%% 6.4.2. スタックの変種

% コード例

%% 6.4.3. 多態性

% 多態性(polymorphism) = ある実体が多くの形態を取る能力

% ADTとオブジェクトをどう使い分けるか，の比較考察 p.441

%% 6.4.4. 引数受け渡し

% 参照呼び出し(call by reference)
  % 言語実体のアイデンティティが手続きに渡される.
  % その言語における定義を調べてから論じるべき. 命令的言語で「参照呼び出し」と言っても本書の用語では値呼び出しに相当するかもと
% 変数呼び出し(call by variable)
  % 参照呼び出しの特殊な場合.
  % "セルの"アイデンティティが手続きに渡される
% 値呼び出し(call by value)
  % 呼び出した手続き内で破壊的操作を行ってもそれが本体に及ばない
  % 本書においては「手続きに値が渡され, その手続きに局所的なセルに格納される」こと
% 入出力呼び出し(call by value-result)
% 名前呼び出し(call by name)
  % 引数を関数でwrapしてやって評価時にいちいち呼び出す. thunk.
% 要求呼び出し(call by need)
  % 名前呼び出し(call by name)の特殊な場合.
  % thunkは高々1回呼ばれ, その結果はメモ化される.

% Cで言うとポインタを投げる, のが参照呼び出し?

% 本書で使っている核言語手法の目的は基本/原始的な機能を切り出すことなので,
% 参照呼び出しを採用する. これはセル・手続き値といった余分な概念に依存しない.


%% 6.4.5. 取り消し可能資格(revocable capability)

% 明示的状態を使って, revocable capabilityをいかに構築するか.
% 「資格(capability)」という概念は3章で導入

% 任意の"手続き" Objを受け取り,
% 取り消し手続きRと,
% 取り消し可能版RObjを返す.
proc {Revocable Obj ?R ?RObj}
   C={NewCell Obj}
in
   proc {R}
      C:=proc {$ M} raise revokedError end end
   end
   proc {RObj M}
      {@C M}
   end
end