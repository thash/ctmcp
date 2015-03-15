%% 5.2.2 ポートオブジェクト例
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
fun {NewPortObject2 Proc}
Sin in
    thread for Msg in Sin do {Proc Msg} end end
    {NewPort Sin}
end

fun {Player Others}
   {NewPortObject2
    proc {$ Msg}
       case Msg of ball then
          Ran={OS.rand} mod {Width Others} + 1
       in
          {Browse pass}
          {Browse Ran} % 1 or 2
          {Delay 1000}
          {Send Others.Ran ball}
       end
   end}
end

declare
P1={Player others(P2 P3)}
P2={Player others(P1 P3)}
P3={Player others(P2 P2)}

{Send P1 ball}
