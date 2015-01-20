%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                              4. 宣言的並列性                               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% まず直列プログラムの例
declare Gen Xs Ys
fun {Gen L H}
   {Delay 100}
   if L>H then nil else L|{Gen L+1 H} end
end
Xs={Gen 1 10}
Ys={Map Xs fun {$ X} X * X end}
{Browse Ys}

% 並列にすると, Ysが順次更新されていく
declare Xs Ys
thread Xs={Gen 1 10} end
thread Ys={Map Xs fun {$ X} X * X end} end
{Browse Ys}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4.1. データ駆動並列モデル
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 4.1.1. 基本概念
% 4.1.2. スレッドの意味

%% 4.1.3. 実行例
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

local B in
   thread B=true end
   if B then {Browse yes} end
end

%% 4.1.4. 宣言的並列性とは何か？
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 部分停止
declare Double

fun {Double Xs}
   case Xs of X|Xr then 2*X|{Double Xr} end
end

Ys={Double Xs}


% 失敗の閉じ込め
declare X Y
local X1 Y1 S1 S2 S3 in
   thread
      try X1=1 S1=ok catch _ then S1=error end
   end
   thread
      try Y1=2 S2=ok catch _ then S2=error end
   end
   thread
      try X1=Y1 S3=ok catch _ then S3=error end
   end
   if S1==error orelse S2==error orelse S3==error then
      X=1 % Xのデフォルト値
      Y=1 % Yのデフォルト値
   else X=X1 Y=Y1 end % エラーがなかったので計算結果を採用
end

% 矛盾するのでデフォルト値が採用される
{Browse X} % => 1
{Browse Y} % => 1
