Ozの文法

    {Browse 'asdf'}
    declare
    V=9999*9999
    {Browse V*V}
    declare
    fun {Fact N}
       if N==0 then 1 else N*{Fact N-1} end
    end
    % {Browse {Fact 10}}
    
    /* list -- 実際はリンク(link)の連鎖(chain) */
    {Browse [5 6 7 8]}
    /* リンクの結合は「|」, car, cdrは「.」 */
    
    declare
    H=1
    T=[2 3 4]
    {Browse H|T}
    {Browse T.1} /* => 2 */
    {Browse T.2} % => [3 4]
    {Browse T.3} % => なんもなし


Pascalの実装

    declare Pascal AddList ShiftLeft ShiftRight
    fun {Pascal N}
       if N==1 then [1]
       else
          {AddList {ShiftLeft {Pascal N-1}} {ShiftRight {Pascal N-1}}}
       end
    end
    
    fun {ShiftLeft L}
       case L of H|T then
          H|{ShiftLeft T}
       else [0] end
    end
    
    fun {ShiftRight L} 0|L end
    
    fun {AddList L1 L2}
       case L1 of H1|T1 then
          case L2 of H2|T2 then
             H1+H2|{AddList T1 T2}
          end
       else nil end % nilあるのか
    end
    
    {Browse {Pascal 20}}

上記のPascal関数は遅い. 局所変数を使って速くする.

    declare
    fun {FastPascal N}
       if N==1 then [1]
       else L in
          L={FastPascal N-1}
          {AddList {ShiftLeft L} {ShiftRight L}}
       end
    end
    
    declare
    fun lazy {Ints N}
       N|{Ints N+1}
    end
    
    declare
    L={Ints 0}
    {Browse L} % => _, と表示され, テキストにあるようなL<Future>ではない

    case L of A|B|C|_ then {Browse A+B+C} end
    % => 0|1|2
    %    3
    
    declare
    fun lazy {PascalList Row}
       Row|{PascalList
            {AddList {ShiftLeft Row} {ShiftRight Row}}}
    end
    L={PascalList [1]}
    {Browse L} % 何も表示されない (_, となる)
    {Browse L.1}
    {Browse L.2.1}
    {Browse L.2.2.2.2.1} % => [1 4 6 4 1]
    
    declare
    fun {PascalList2 N Row}
       if N==1 then [Row]
       else
          Row|{PascalList2 N-1
               {AddList {ShiftLeft Row} {ShiftRight Row}}}
       end
    end
    {Browse {PascalList2 10 [1]}}


高階プログラミング

    declare GenericPascal OpList
    fun {GenericPascal Op N}
       if N==1 then [1]
       else L in
          L={GenericPascal Op N-1}
          {OpList Op {ShiftLeft L} {ShiftRight L}}
       end
    end
    
    fun {OpList Op L1 L2}
       case L1 of H1|T1 then
          case L2 of H2|T2 then
             {Op H1 H2}|{OpList Op T1 T2}
          end
       else nil end
    end
    
    declare Add
    fun {Add X Y} X+Y end
    
    fun {FastPascal N} {GenericPascal Add N} end
    {Browse {FastPascal 3}}
    
    declare Xor
    fun {Xor X Y} if X==Y then 0 else 1 end end
    declare Hoge
    fun {Hoge N} {GenericPascal Xor N} end
    {Browse {Hoge 9}}
    
    
1.10 並列性

    thread P in
       P={Pascal 30}
       {Browse P}
    end
    {Browse 99*99}
    
    declare X in
    thread {Delay 10000} X=99 end
    {Browse start} {Browse X*X}

1.12 明示的状態

メモリセル...多くの言語で変数と呼ばれるもの
状態の変更 `:=`
状態の参照 `@`

    declare
    C={NewCell 0}
    C:=@C+1
    
    declare
    C={NewCell 0}
    fun {FastPascal N}
       C:=@C+1
       {GenericPascal Add N}

内部メモリを持つ関数をオブジェクトと呼ぶ

明示的状態と並列性を一緒に使うのはやめましょう
