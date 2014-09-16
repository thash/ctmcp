declare Test
proc {Test X}
   case X of f(a Y c) then {Browse 'case'(1)}
   else {Browse 'case'(2)} end
end

declare X Y {Test f(X b Y)}
% Xが未束縛なので待機する. Xを束縛するとcase(2)が出力.

declare X Y {Test f(a Y d)}
% case(2)

declare X Y {Test f(X Y d)}
% 1個目と同じっぽい

declare X Y {Test f(a Y c)}
% case(1). 問題文にはないけど.


declare X Y
if f(X Y d)==f(a Y c) then {Browse 'case'(1)}
else {Browse 'case'(2)} end
% case(2).
