%% 5.3.6 エラー報告
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 例外を発生させるサーバ
declare Floats Sqrt
proc {ServerProc Msg}
   case Msg
   of sqrt(X Y E) then
      try
         Y={Floats.Sqrt X}
         E=normal
      catch Exc then
         E=exception(Exc)
      end
   end
end
Server={NewPortObject2 ServerProc}

% 同期的に呼ぶ場合
declare X Y E
{Send Server sqrt(X Y E)}
case E of exception(Exc) then raise Exc end end
