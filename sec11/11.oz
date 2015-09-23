%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                  11. 分散プログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 11.1 分散プログラミングの分類
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 11.2 分散モデル
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 11.3 宣言的データの分散
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 11.3.1 オープン分散と大域的ネーミング
% 分散計算がオープンである = あるプロセスが分散計算を行っているプロセスと独立に結合できる

% > The module Connection provides the basic mechanism (known as tickets)
% > for active applications to connect with each other.
% https://mozart.github.io/mozart-v1/doc-1.4.0/dstutorial/node1.html#label4

% > The module Connection provides procedures and classes that support both
% > one-to-one and many-to-one connections.
% https://mozart.github.io/mozart-v1/doc-1.4.0/system/node47.html#chapter.connection

% https://www.info.ucl.ac.be/~pvr/ds/Distribution.oz
% 分散オブジェクト, のうち URL を用いる例

% https://github.com/sjmackenzie/transdraw/blob/master/Editor.oz
% functor + import + define... end, 以上. という書き方は他にも見るけど何だっけ?
% => 下のページらへんに書いてる
% 7 Modules and Interfaces
% https://mozart.github.io/mozart-v1/doc-1.4.0/tutorial/node7.html
% functor なんちゃら, で定義したものが module に convert される.
% 本来 module は locally defined entities を束ねたもので, それを record 形式で export.

% functor 形式で定義したファイル(...を compile して ozf にした前提かな)を load.
% declare [List]= {Module.link ['/home/xxx/list.ozf']}


% ref: Connection.oz の実装を見るには $ ghq look mozart2

% 183:      % ZlibIO(compressedFile:CompressedFile) at 'x-oz://system/ZlibIO.ozf' % Not yet implemented in Mozart 3

% import Connection
% at '/Users/hash/git/clone/github.com/mozart/mozart2/lib/main/dp/Connection.oz'

% ticket = 任意の言語実体にアクセスする大域的手段. Connection module により生成

declare
X=the_novel(text:"It was a dark and stormy night. ..."
            author:"E.G.E. Bulwer-Lytton"
            year:1803)
{Browse {Connection.offerUnlimited X}} % チケットの生成と表示
% => Browse してみたが何も表示されない

% 以下動作テスト >>>
{Browse X} % => 内容表示される
{Browse Connection} % => _<Failed value>
{Browse Connection.offer} % => 出力なし
{Browse {Connection.offer X}} % => 出力なし
% {Wait {Connection.offer X}}

declare A
{Pickle.save {Connection.offerUnlimited A} '/Users/hash/work/ctmcp/tmp_ticket'}
A = 'foo'

declare B
B = {Connection.take {Pickle.load '/Users/hash/work/ctmcp/tmp_ticket'}}
{Inspect B}
{Browse B}
% <<< 動作テスト.


% 他に, 関数を共有することも出来る
% データフロー変数も.
declare X in
{Browse {Connection.offerUnlimited X}}

% 他のプロセスから参照を得る
declare X in
X={Connection.take '...X ticket...'}
{Browse X*X} % ここまでやったら掛け算でブロック. 第一のプロセスでXに束縛すると動き始める

% Pickle モジュール
{Pickle.save X FN}
% 任意の値XをFNという名前のファイルに保存する
{Pickle.load FNURL ?X}
% FNURLに格納された値をXにロードする. FNURL はファイル名 or URL


%% 両者を組み合わせて Offer, Take 操作を作る
proc {Offer X FN}
  {Pickle.save {Connection.offerUnlimited X} FN}
end

proc {Take FNURL}
  {Connection.take {Pickle.load FNURL}}
end


%% 11.3.4 ストリーム通信

%% 性急ストリーム通信
% まずプロセスAの中にconsumerを作る
declare Xs Sum in
{Offer Xs tickfile}
fun {Sum Xs A}
  case Xs of X|Xs then {Sum Xr A+X} [] nil then A end
end
{Browse {Sum Xs 0}}

% 別のプロセスBにproducerを.
declare Xs Generate in
Xs={Take tickfile}
fun {Generate N Limit}
  if N<Limit then N|{Generate N+1 Limit} else nil end
end
Xs={Generate 0 150000}


%% 遅延ストリーム通信
declare S P in
{NewPort S P}
{Offer P tickfile}
for X in S do {Browse X} end

% 別プロセスにて
P={Take tickfile}
{Send P hello}
{Send P 'keep in touch'}


%% 11.4 状態の分散
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 11.4.1 単純状態共有
% セルを共有する
declare
C={NewCell unit}
{Offer C tickfile}

declare
C1={Take tickfile} % 他のプロセスからのアクセス

% ここで C, C1は区別できない．以上, セルの振る舞い.
% 以上の性質を用いて分散ロック(distributed locking)を実装する
% a.k.a. 分散相互排除(mutual exclusion)

% fig 11.4 - 分散ロック
% 8.3節(p.598, Fig 8.14)から採ったコード
declare
fun {CorrectSimpleLock}
   Token={NewCell unit}
   proc {Lock P}
   Old New in
      {Exchange Token Old New}
      {Wait Old}
      try {P} finally New=unit end
   end
in
   'lock'('lock':Lock)
end

% 上の実装において複数スレッドが複数プロセスにまたがっている時,
% 分散トークン伝達 (distributed token passing) の実装となる

%% オブジェクトおよびその他のデータ型を共有すること
class Coder
  attr seed
  meth init(S) seed:=S end
  meth get(X)
    X=@seed
    seed:=(@seed*1234+4999) mod 33667
  end
end
C={New Coder init(100)}
{Offer C tickfile}

% Mozart システムは, そのオブジェクトが非分散時のオブジェクトのように振る舞うことを保障する.
% たとえばそのオブジェクトが例外を発生させれば，そのオブジェクトを呼んだスレッドで例外が発生する.


%% 11.4.2 分散字句的スコープ
% distributed lexical scope
% 11.7 でこれをどう実装してるのか, がわかる
declare
C={NewCell 0}
fun {Inc X} X+@C end % どのプロセスから呼ばれようと, Inc は同一の C を参照
{Offer C tickfile1}
{Offer Inc tickfile2}


%% 11.5 ネットワークアウェアネス
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 11.7 で説明するようにネットワーク透過性を実現するためにいろいろ裏でやってるんだが,
% 結局のところ問題を整理すると
% (1). 透過性を実現するためにシステムはどんなネットワーク操作を行うのか
% (2). ネットワーク操作は単純で予測可能か? すなわち予測可能な方法で通信できるアプリケーションを構築できるか?


%% 11.6 共通分散プログラミングパターン
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 11.6.1 静止オブジェクトとモバイルオブジェクト

% fig 11.5 - 静止オブジェクト
declare
fun {NewStat Class Init}
P Obj={New Class Init} in
   thread S in
      {NewPort S P}
      for M#X in S do
         try {Obj M} X=normal
         catch E then X=exception(E) end
      end
   end
   proc {$ M}
   X in
      {Send P M#X}
      case X of normal then skip
      [] exception(E) then raise E end end
   end
end

% Coder オブジェクトの静止版を作る
C={NewStat Coder init(100)}
{Offer C tickfile}

% 別のプロセスが C への参照を得たとすると,
C2={Take tickfile}
% その第二プロセスは手続き C のコピーを持ち C2 によってそれを参照する.
local A in
  {C2 get(A)} % ここでポート通信 {Send get(A)#X} が実行されてる
  {Browse A}
end


%% 11.6.2 非同期オブジェクトとデータフロー
% 非同期にオブジェクトを呼び出す．つまり，送って，結果を待たない．
% その後結果が必要になったら待つ．
% データフロー変数を使うととてもうまくいく．自動的にブロックする．


%% 11.6.3 サーバ
% 与えられた計算を行うサーバ，計算サーバ．
class ComputeServer
  meth init skip end
  meth run(P) {P} end
end

% 計算サーバの問題として，ひとつのプロセスに限定された実体，たとえば
% Show や Browse による表示操作，File モジュールによるファイル入出力，
% OS 操作 (OS モジュール) などを適切に扱えない，というものがある．．

% ポートオブジェクトを使えば制限を取り去ることが出来る．
% 送られてくるすべてのメッセージを Browse する Browse Server を用意しておいて，
declare S P in
{NewPort S P}
{Offer proc {$ M} {Send P M} end tickfile}
for X in S do {Browse X} end

% 計算サーバは Browse を呼ぶ代わりに Browse サーバにメッセージを渡す．
declare Browse2 in
Browse2={Take tickfile}
{Browse2 message}


%% 無停止更新可能サーバ
% MakeStat の定義は "この本のウェブサイトの補遺ファイル" にあるそうな
proc {NewUpgradableStat Class Init ?Upg ?Srv}
  Obj={New Class Init}
  C={NewCell Obj}
in
  Srv={MakeStat
    proc {$ M} {@C M} end}
  Upg={MakeStat
    proc {$ Class2#Init2} C:={New Class2 Init2} end}
end


%% 11.7 分散プロトコル
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mozart の実装を切り口に分散プロトコルを詳しく．

%% 11.7.1 言語実体
%% 11.7.2 モバイル状態プロトコル
%% 11.7.3 分散束縛プロトコル
%% 11.7.4 メモリ管理


%% 11.8 部分的失敗
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 11.8.1 失敗モデル
%% 11.8.2 失敗処理の簡単な場合

%% 11.8.3 回復可能サーバ

% fig 11.11 - 回復可能サーバ
declare
fun {NewStat Class Init}
   Obj={New Class Init}
   P
in
   thread S in
      {NewPort S P}
      for M#X in S do
         try {Obj M} X=normal
         catch E then
            try X=exception(E)
            catch system(dp(...) ...) then
                  skip  /* client failure detected */
            end
         end
      end
   end
   proc {$ M}
   X in
      try {Send P M#X} catch system(dp(...) ...) then
          raise serverFailure end
      end
      case X of normal then skip
      [] exception(E) then raise E end end
   end
end


%% 11.8.4 アクティブフォールトトレランス
% 活発な研究領域ですと．
% Mozart には GlobalStore という複製トランザクショナルオブジェクト格納域がある．


%% 11.9 セキュリティ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% アプリケーションが安全である，とは
% => そのコンポーネントの意図的な(つまり悪意のある( ;; 誰の悪意だよ)) 失敗にもかかわらず，
%    その仕様を満たし続けること．

% アプリケーション，言語，実装，OS(network, hardware) の各レイヤーを考えないといけない


%% 11.10 アプリケーションを構築すること
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% まずは集中して構築，のちに分散
% 部分的失敗に対処する．
% 同期/非同期, 失敗検出/局限機構 の間にトレードオフがある


%% 11.11 練習問題
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
