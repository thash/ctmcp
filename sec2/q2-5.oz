declare Test
proc {Test X}
   case X
   of a|Z  then {Browse 'case'(1)}
   [] f(a) then {Browse 'case'(2)}
   [] Y|Z andthen Y==Z then {Browse 'case'(3)}
   [] Y|Z  then {Browse 'case'(4)}
   [] f(Y) then {Browse 'case'(5)}
   else {Browse 'case'(6)} end
end

%% 上から順にマッチする

{Test [b c a]}    % 'case'(4)
{Test f(b(3))}    % 'case'(5)
{Test f(a)}       % 'case'(2)
{Test f(a(3))}    % 'case'(5)
{Test f(d)}       % 'case'(5)
{Test [a b c]}    % 'case'(1)
{Test [c a b]}    % 'case'(4)
{Test a|a}        % 'case'(1)
{Test '|'(a b c)} % 'case'(6)