%% 9.4. 自然言語構文解析
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

3.4.8 (p.167) で差分リストを使う構文解析法を紹介した.
関係プログラミングを使うことで "1つの字句の先読み" という制限を取り除ける. あいまいな文法の解析ができる.

% fig 9.5 - 自然言語構文解析 (単純非終端記号)
declare
fun {Determiner S P1 P2 X0 X}
   choice
      X0=every|X
      all(S imply(P1 P2))
   [] X0=a|X
      exists(S and(P1 P2))
   end
end

fun {Noun N X0 X}
   choice
      X0=man|X
      man(N)
   [] X0=woman|X
      woman(N)
   end
end

fun {Name X0 X}
   choice
      X0=john|X
      john
   [] X0=mary|X
      mary
   end
end

fun {TransVerb S O X0 X}
   X0=loves|X
   loves(S O)
end

fun {IntransVerb S X0 X}
   X0=lives|X
   lives(S)
end


% fig 9.6 自然言語構文解析 (復号非終端記号)
declare
fun {Sentence X0 X}
P P1 N X1 in
   P={NounPhrase N P1 X0 X1}
   P1={VerbPhrase N X1 X}
   P
end

fun {NounPhrase N P1 X0 X}
   choice P P2 P3 X1 X2 in
      P={Determiner N P2 P1 X0 X1}
      P3={Noun N X1 X2}
      P2={RelClause N P3 X2 X}
      P
   [] N={Name X0 X}
      P1
   end
end

fun {VerbPhrase S X0 X}
   choice O P1 X1 in
      P1={TransVerb S O X0 X1}
      {NounPhrase O P1 X1 X}
   [] {IntransVerb S X0 X}
   end
end

fun {RelClause S P1 X0 X}
   choice P2 X1 in
      X0=who|X1
      P2={VerbPhrase S X1 X}
      and(P1 P2)
   [] X0=X
      P1
   end
end


% 9.4.6 パーサを逆向きに走らせる
% 9.4.7 単一化文法


%% 9.5. 文法インタプリタ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 文法をコード化する
% fig 9.7 - s式文法のコード化
declare
Rules=
r(sexpr:[fun {$} As in
            rule(sexpr(s(As)) [t('(') seq(As) t(')')])
         end]
  seq:  [fun {$}
            rule(seq(nil) nil)
         end
         fun {$} As A in
            rule(seq(A|As) [atom(A) seq(As)])
         end
         fun {$} As A in
            rule(seq(A|As) [sexpr(A) seq(As)])
         end]
  atom: [fun {$} X in
            rule(atom(X)
                 [t(X)
                  fun {$}
                     {IsAtom X} andthen X\='(' andthen X\=')'
                  end])
         end])

% 9.5.4 文法インタプリタを実装すること
declare
fun {NewParser Rules}
   proc {Parse Goal S0 S}
      case Goal
      of nil then S0=S
      [] G|Gs then S1 in
         {Parse G S0 S1}
         {Parse Gs S1 S}
      [] t(X) then S0=X|S
      else if {IsProcedure Goal} then
         {Goal}=true
         S0=S
      else Body Rs in /* Goal is a nonterminal */
         Rs=Rules.{Label Goal}
         {ChooseRule Rs Goal Body}
         {Parse Body S0 S}
      end end
   end
   proc {ChooseRule Rs Goal Body}
      I={Space.choose {Length Rs}}
   in
      rule(Goal Body)={{List.nth Rs I}}
   end
in
   Parse
end


%% 9.6. データベース
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% "データベースは，明確な構造を持つデータの集まりである"
% 永続性(persistence)は今回は関心外とする

% 関係の集合として組織化されたデータベース = relational database
% 関係を定義する.


%% 9.7. Prolog 言語
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Prolog は現実的な論理型プログラミングのための最もよく知られた言語
% Prolog の計算モデルは3層構造
%   1. 簡単な定理証明器でホーン節を使い, SLDNF導出を使って実行する
%   2. 非論理的機能からなる. 導出ベースの定理証明器を変更・拡張する.
%   3. 明示的状態を提供する. assert/1, retract/1.

% 将来の発展
%   1. Mercury. Prolog の進化系, 完全に宣言的
%   2. Oz ｗｗｗｗｗｗｗｗｗｗｗｗ
%   3. 制約プログラミング. これも Prolog の進化.
