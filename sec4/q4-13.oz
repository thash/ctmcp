% 遅延性と一枚岩関数

declare Reverse1 Reverse2 Res1 Res2
fun lazy {Reverse1 S}
   fun {Rev S R}
      case S of nil then R
      [] X|S2 then {Rev S2 X|R} end
   end
in {Rev S nil} end

fun lazy {Reverse2 S}
   fun lazy {Rev S R} % 注: 中のRevもlazyになってる
      case S of nil then R
      [] X|S2 then {Rev S2 X|R} end
   end
in {Rev S nil} end

Res1={Reverse1 [a b c]} {Browse Res1}
Res2={Reverse2 [a b c]} {Browse Res2}
% なんも出ない

% (A). 両者の振る舞いの違いはなにか
% (B). 結果は同じか
% (C). 遅延の振る舞いは同じか
% (D). 実行効率が良いのはどちらか
