function epsilon = rough(n)
% Material:
% 1 = drawn tubing
% 2 = commercial steel or wrought iron
% 3 = asphalted cast iron
% 4 = galvanized iron
% 5 = cast iron

roughvec = [0.00015, 0.0046, 0.12, 0.15, 0.26];
roughvec = roughvec(:)*10^(-2);
epsilon = roughvec(n);