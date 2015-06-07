% 並列性により状態をエミュレートする
% ... 並列性が明示的状態を獲得するのに使えるかどうか調べる.

% (a).
% 並列性を使って更新可能なコンテナを生成
% "コンテナ"って表現初めて出てきた?
% 再帰的手続きを使ってストリームを読むスレッドを生成する
declare
fun {MakeState Init}
   proc {Loop S V}
      case S of access(X)|S2 then
         X=V {Loop S2 V}
      [] assign(X)|S2 then
         {Loop S2 X}
      else skip end
   end S
in
   thread {Loop S Init} end S
end

% 別threadでLoopし続け，メッセージを待ち受ける?

S={MakeState 0}
% という呼び出しにより，初期内容0の新しいコンテナが生成される．

% ストリームにコマンドを送出することによりコンテナを使用する．
declare S1 X Y in
S=access(X)|assign(3)|access(Y)|S1
% Xに0(初期内容)が束縛され，コンテナに3が入り，その後Yに3が束縛される

{Browse S}
{Browse X} % => 0
{Browse Y} % => 3

% ;; たしかにそうなってるが... 使い方がよくわからん

{Browse S}  % => access(0)|assign(3)|access(3)|_
{Browse S1} % => _


% (b). SumListを書き換え，このコンテナを使って呼び出し回数を数える.
% 元のSumList
fun {SumList Xs S}
   case Xs
   of nil then S
   [] X|Xr then {SumList Xr X+S}
   end
end

% 並列版
declare SumList in
local Prev Next S1 Container={MakeState 0} in
   fun {SumList Xs S}
      Container=access(Prev)|assign(Prev+1)|access(Next)|S1
      {Browse Next}
      case Xs
      of nil then S
      [] X|Xr then {SumList Xr X+S}
      end
   end
end

{Browse {SumList [1 2 3 4] 0}}
% NextをBrowseしてみても，呼び出し回数をCount up してくれない (常に1が出る

% さらに, 6.1.2のように内部にSumCountを追加しようとするとどうなるか?