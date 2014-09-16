%% if文とcase文
%% (a) case文を使ってif文を定義せよ
%% 関数として追加するんだろうか?
declare MyIf
fun {MyIf P T F}
   case P
   of true then T
   else F
   end
end
declare V
{Browse {MyIf {10 > 5} 1 0}}
%% Browse に表示されない...

{Browse 123}
%% これはちゃんと出る

V={MyIf {10 > 5} 1 0}
{Browse V}
% _, が表示されるなんだこれ


%% (b) if文とLabel, Arity, および`.`(フィールドの選択)の諸操作を使ってcase文を定義せよ.
%%     これによりif文は本質的にcase文より原始的であることがわかる

declare X A B
A=1
B=2
X=label(a:1 b:2)
case X of label(a:A b:B) then {Browse B} else {Browse f} end

declare X A B
A=1
B=2
X=label(a:1 b:2)
if {Label X} == label andthen {Arity X} == [a b] then
   local B in B = X.b
      {Browse B}
   end
else {Browse f} end

%% ??