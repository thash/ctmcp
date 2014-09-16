%% lexically scoped closure

declare Max3 Max5
proc {SpecialMax Value ?SMax}
   fun {SMax X}
      if X>Value then X else Value end
   end
end

{SpecialMax 3 Max3}
{SpecialMax 5 Max5}

{Browse {Max3 4}} % 4
{Browse {Max3 2}} % 3

%% 問題
{Browse [{Max3 4} {Max5 4}]} % [4 5]
