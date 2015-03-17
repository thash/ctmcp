%% 5.3.6 エラー報告
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 例外を発生させるサーバ
declare
proc {ServerProc Msg}
   case Msg
   of sqrt(X Y E) then
      {Browse hoge}
      %try
         Y={Float.sqrt X}
         E=normal
      %catch Exc then
      %   E=exception(Exc)
      %end
   end
end
Server={NewPortObject2 ServerProc}
% {Browse {Float.sqrt 2.0}}
% {Browse 1}

% 同期的に呼ぶ場合
declare Y E
{Send Server sqrt(2.0 Y E)}

case E
of exception(Exc) then raise Exc end
else
   {Browse Y}
end
