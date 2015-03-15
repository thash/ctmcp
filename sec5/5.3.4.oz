%% 5.3.4 RMI with callback (using record continuation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
proc {ServerProc Msg}
   case Msg
   of calc(X Client Cont) then X1 D Y in
      {Send Client delta(D)}
      X1=X+D
      Y=X1*X1+2.0*X1+2.0
      {Send Client Cont#Y} % クライアントは付与されたYを使う
   end
end
Server={NewPortObject2 ServerProc}

proc {ClientProc Msg}
   case Msg
   of work(?Z) then
      % サーバを呼んだ後にすべき仕事の一部Zを含めcont(Z)を渡す
      % 待たない．コールバックで何をするかは一旦忘れて，次に戻ってきたら処理する
      {Send Server calc(10.0 Client cont(Z))}
   [] cont(Z)#Y then
      % サーバはYを計算してクライアントにcont(Z)#Yを返すのでYを使ってZを完成する
      % やりかけの仕事"Z"は手元に残らないので状態を記憶しないで済む
      Z=Y+100.0
   [] delta(?D) then
      D=1.0
   end
end
Client={NewPortObject2 ClientProc}

{Browse {Send Client work($)}}
% => 245.0
% X  = 10
% X1 = 10 + 1 = 11
% Y  = 11*11 + 11*2 + 2 = 145
% Z  = 145 + 100 = 245

% 5.3.3 の場合と同じく，同期の責任をクライアントからアプリケーションに転嫁するのが正解．
