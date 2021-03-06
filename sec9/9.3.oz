%% 9.3. 論理型プログラミングとの関係
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 9.3.1 論理と論理型プログラミング

論理型プログラム = 操作的意味が与えられた論理の表明. つまりコンピュータで実行できるもの.
1. それは正しい(= 論理的意味を守る)
2. それは効率的である(予期通りの時間計算量・空間計算量で実行される)

恒真式(= tautology). 対偶とかド・モルガンとか

命題論理 ... データ構造が表せない
1階述語論理 ... first order predicate calculus. 命題論理 + (変数, 項, 限定記号)
述語論理のアトムは引数を持てる
論理式における識別子の自由出現(free occurrence)が定義できる


で, 論理型プログラミングとは以下で構成される
- 1階述語論理の公理の集合
- 質問(query)と言われる言明
- 定理証明器(theorem prover)
  - query を証明/反証明するために公理を使って演繹を行うシステム

演繹を行う = 論理型プログラムを実行する

1929年にクルト・ゲーデルが "完全性定理(有名な不完全の方じゃなく, 完全性定理の方)" として証明したとおり定理証明器ができることには限界がある．
つまりこいつは"すべてのモデルにおいて真となる質問に対する証明を見つける"ことが保証されているだけ.
完全性 = 任意の質問の証明/反証明を見つける能力
1930年にクルト・ゲーデルは"不完全性定理"を証明，基本算術(加算と乗算)ができる無矛盾公理の
任意の有限集合に対し，それらの公理によって証明/反証明が出来ないような, 数に関する"真である言明"が存在する

証明のための探索は指数時間を要し，非効率である
定理証明器が起きんおなう演繹は構成的であるべき.

公理の形式を制限すると効率よい構成的定理証明器が作れる．
たとえばPrologは公理をホーン節(Horn clause)に限定している.


%% 9.3.2 操作的意味と論理的意味
論理型プログラムは「論理的」「操作的」二通りに見れる.

% 決定的連結

fun {Append A B}
  case A
  of nil then B
  [] X|As then X|{Append As B}
  end
end

% 手続きにする
proc {Append A B ?C}
  case A
  of nil then C=B
  [] X|As then Cs in
    C=X|Cs
    {Append As B Cs}
  end
end

% 操作的意味は異なるが，論理的意味は同じ手続き
proc {Append ?A B C}
  if B==C then A=nil
  else
    case C of X|Cs then  As in
      A=X|As
      {Append As B Cs}
    end
  end
end

% ここで
{Append X Y [1 2 3]}
% とすると，論理的意味を満たす解が 4 ツあるため決定的ではない.
% 複数の解を出すには choice 文を使って正しい情報を推測する必要がある.


%% 9.3.3 非決定的論理型プログラミング

% > 関係プログラミングを使うと，より柔軟な操作的意味を持つプログラムが書け，
% > 宣言的プログラムがブロックするような場合にも答が出せる

proc {Append ?A ?B ?C}
  choice
    A=nil B=C
  [] As Cs X in
    A=X|As C=X|Cs {Append As B Cs}
  end
end

% これで {Append X Y [1 2 3]} 呼び出しのすべての解を探索可能
{Browse {SolveAll
         proc {$ S} X#Y=S in {Append X Y [1 2 3]} end}}

% => [nil#[1 2 3] [1]#[2 3] [1 2]#[3] [1 2 3]#nil]

% 方向性のある場合(?)
{Browse {SolveAll
         proc {$ X} {Append [1 2] [3 4 5] X} end}}

% 解が無限にある場合も呼べる. SolveAll は無理だけど Solve で一個見つけるだけなら.
L={Solve proc {$ S} X#Y#Z=S in {Append X Y Z} end}

% Touch の 定義は 4.5.6 節にある
{Touch 1 L}
{Touch 2 L}
{Touch 3 L}
% ...


%% 9.3.4 純粋 Prolog との関係

純粋Prologと関係計算モデルの違い x 3


%% 9.3.5 他のモデルにおける論理型プログラミング

ここまでは宣言的モデル中の論理型プログラミングを見てきたが，他のモデルの場合をいくつか考える

- 並列性を付加
- 5.8.1 の非決定性並列モデル
- 状態ありモデル
- 制約ベース計算モデル (12章)
