% 順序一定並列性
declare A B C D in
thread D=C+1 end % 1
thread C=B+1 end % 2
thread A=1   end % 3
thread B=A+1 end % 4
{Browese D}

% スレッドが生成される順
%   => 頭から順. 1,2,3,4.
% 加算が行われる順
%   => 3,4,2,1

declare A B C D in
A=1
B=A+1
C=B+1
D=C+1
{Browese D}
