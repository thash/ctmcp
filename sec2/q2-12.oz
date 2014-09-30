
try <s1> finally <s2> end

%% を別の形で書け.

local IsE E in
   try
      <s1>
      IsE = false
   catch X then
      E = X      % catchした例外を上位レイヤーのEに束縛して外へ出す
      IsE = true % 例外が起こったことを記憶
   end
   <s2>          % かならず<s2>は実行されて,
   if IsE then   % さっきエラーが起こっていれば改めてraise.
      raise X end
   end
end