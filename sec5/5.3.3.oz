%% 5.3.3 コールバックのあるRMI(スレッド使用)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
proc {ServerProc Msg}
   case Msg
   % calcメッセージの引数からクライアントを知る
   of calc(X ?Y Client) then X1 D in
      {Send Client delta(D)}
      X1=X+D
      Y=X1*X1+2.0*X1+2.0
   end
end
Server={NewPortObject2 ServerProc}

% ここでの「コールバック」は， delta
declare
proc {NgClientProc Msg}
   case Msg
   of work(?Z) then Y in
      {Send Server calc(10.0 Y NgClient)}
      % ここでYが束縛されるのを待つ(暗黙のWait)ので，deltaが来ても処理できない
      Z=Y+100.0
   [] delta(?D) then
      D=1.0
   end
end
NgClient={NewPortObject2 NgClientProc}
{Browse {Send NgClient work($)}}
% => {Send NgClient work($)} の呼び出しでデッドロックになる

declare
proc {ClientProc Msg}
   case Msg
   of work(?Z) then Y in
      {Send Server calc(10.0 Y Client)}
      % ここをthreadにしている
      thread Z=Y+100.0 end
   [] delta(?D) then
      D=1.0
   end
end
Client={NewPortObject2 ClientProc}

{Browse {Send Client work($)}}


% 次のように呼び出すと，{Send..}から帰った時点ではZはまだ束縛されていない
declare Z in
{Send Client work(Z)}
% Zを必要とする何らかの処理(ここでは単にWait)があれば束縛される．
{Wait Z}

% 同期の責任をクライアントからアプリケーションに転嫁している．
% NgClientは同期をとる場所が良くなかった．
