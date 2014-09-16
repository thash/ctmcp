%% 制御抽象

%% (a) AndThen
declare AndThen
fun {AndThen BP1 BP2}
   if {BP1} then {BP2} else false end
end

%% {AndThen fun {$} <exp1> end fun {$} <exp2> end}
%% という呼び出しは,
%% <exp1> andthen <exp2>
%% と同じ結果になるか? <exp2>の計算をしないで済むか? => 同じだよ


%% (b) OrElse
declare OrElse
fun {OrElse BP1 BP2}
   if {BP1} then true else {BP2} end
end