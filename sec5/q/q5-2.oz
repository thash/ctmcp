% リフト制御システム(5.5)に関する質問

% (a). 5.5節の設計では，リフトごとに制御装置がある．開発者は費用を節約するためにシステム全体に1つの制御装置を設置することにした．各リフトはその制御装置と通信する．制御装置の内部定義は元のままとする．これは良い考えか? リフト制御システムの振る舞いはどのように変わるか?

% もとのままだと制御リフトが複数になるけど動くのだろうか
% => 動かんよね

% (b). 5.5節の設計では，制御装置は1階ずつ昇降する．止まる必要がなくても．これを，要求された階だけに停まるようリフトオブジェクトと制御装置オブジェクトを変更せよ．

% Controllerを，直接目的階にふっとぶようにする
fun {Controller Init}
   Tid={Timer}
   Cid={NewPortObject Init
        fun {$ state(Motor F Lid) Msg}
           case Motor
           of running then
              case Msg
              of stoptimer then
                 {Send Lid 'at'(F)}
                 state(stopped F Lid)
              end
           [] stopped then
              case Msg
              of step(Dest) then
                 if F==Dest then
                    state(stopped F Lid)
                 % elseif F<Dest then
                 %    {Send Tid starttimer(5000 Cid)}
                 %    state(running F+1 Lid)
                 % else % F>Dest
                 %    {Send Tid starttimer(5000 Cid)}
                 %    state(running F-1 Lid)
                 else % F != Dest
                    state(running Dest Lid) % 1階ずつではなく一気にDestへ飛ぶ
                 end
              end
           end
        end}
in Cid end
