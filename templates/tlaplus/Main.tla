---- MODULE Main ----
EXTENDS Naturals

CONSTANT Max

VARIABLE x

Init == x = 0
Next == /\ x < Max
        /\ x' = x + 2

TypeOK == x \in 0..Max
Inv == x % 2 = 0

Spec == Init /\ [][Next]_x

==== 
