%% この問題の目的は, なぜ単一化が興味深いかを説明することである.

declare W X Y Z
X = [a Z]
Y = [W b]
X = Y
{Browse W#X#Y#Z}

declare W X Y Z
X = [a Z]
X = Y
Y = [W b]
{Browse W#X#Y#Z}

declare W X Y Z
Y = [W b]
X = [a Z]
X = Y
{Browse W#X#Y#Z}

declare W X Y Z
Y = [W b]
X = Y
X = [a Z]
{Browse W#X#Y#Z}

declare W X Y Z
X = Y
X = [a Z]
Y = [W b]
{Browse W#X#Y#Z}

declare W X Y Z
X = Y
Y = [W b]
X = [a Z]
{Browse W#X#Y#Z}

%% 全部
%%    a#[a b]#[a b]#b
%% になる