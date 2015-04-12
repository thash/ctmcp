functional(0) -> 1;
functional(N) when N>0 -> N*functional(N-1).

% > 変数識別子は定義されると値に束縛される．ということは，Erlangには値格納域があるということである．
% > 識別子の束縛は変更できない．宣言的モデル同様，単一代入である．
% > これらの約束はProlog譲りで，最初のErlangの実装(インタプリタ)はPrologで書かれた．

% モジュールmathに定義された関数sqrtを使うには
%     math:sqrt(...)
% とする．


%% 並列性とメッセージ伝達

% Erlangでは，スレッドはポートオブジェクトとメールボックスとともに生成される．この組み合わせをプロセスという．
% プロセスには3つの原始操作がある．

% 1. spawn(M, F, A) ... 新しいプロセスを生成してプロセス識別子を返す．
%                       引数はプロセス開始時に呼び出す関数で，モジュールMの関数F，Aはその引数リスト
% 2. send操作 ... Pid!Msg と書き，プロセス識別子PidにメッセージMsgを非同期的に送る．
%                 メッセージは受信者のメールボックスに入る．
% 3. receive操作 ... メールボックスからパターンにマッチするメッセージを取り除く(5.7.3節で説明)．


% ファイルのアタマにはmodule, exportの宣言を行う
-module(areaserver).
-export([start/0, loop/0]).

% 外からspawnを生で使わせるのでなくareaserver:start().で使えるようにしてる
start() -> spawn(areaserver, loop, []).

loop() ->
  receive
    {From, Shape} ->
      From!area(Shape),
      loop()
  end.

% 以上のように定義したサーバを使うのは，こうやる
Pid=areaserver:start(),
Pid!{self(), {square, 3.4}}, % self()は現在のプロセスのPidを返す
receive
  Ans -> ...
end,

% ErlangだとFromへ答えを送信するところだが，Ozだとデータフロー変数Ansを使う感じ


%% receive操作

% Erlangにおける並列プログララミングの特徴はメールボックスとその扱いによる．
% receiveは以下の様な一般形式を持つ

receive
  Pattern1 [when Guard1] -> Body1;
  ...
  PatternN [when GuardN] -> BodyN;
[ after Expr -> BodyT; ]
end

% when ... ガード節．オプショナル
% after ... タイムアウト．オプショナル

% receiveをOzで実装してみる => 5.7.oz へ
