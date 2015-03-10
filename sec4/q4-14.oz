% 宣言的モデルにおけるデータフロー変数の利点の1つは，
% Appendの単刀直入の定義が反復的になること．

% 4.5.7節で定義した「データフロー変数を使わないAppend単刀直入版」を考えよ．
% Q: これは反復的か?

fun lazy {LAppend As Bs}
   case As
   of nil then Bs
   [] A|Ar then A|{LAppend Ar Bs}
   end
end

% これを核言語に翻訳すると

proc {LAppend As Bs ?RetVal}
   case As
   of nil then Bs
   [] A|Ar then
      local Next in
         RetVal=A|Next
         {LAppend Ar Bs Next}
      end
   end
end

% したがって，lazyつけても性急実行の時と同じく反復的である．