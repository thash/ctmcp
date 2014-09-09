declare MulByN N in
N=3
proc {MulByN X ?Y}
   Y=N*X
end
end

{MulByN A B}

%% 呼び出し時の環境に {A->10, B->x1} が含まれているとする.
%% 手続き本体が実行されると, 写像 N->3 がその環境に追加される.

%% case1: 呼び出し時の環境にNが存在しない例
%% case2: 呼び出し時の環境にNが存在するが, 3以外に束縛されている例
