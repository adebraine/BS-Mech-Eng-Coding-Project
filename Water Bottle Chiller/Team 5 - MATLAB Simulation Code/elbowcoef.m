function K = elbowcoef(f_T,r,d)

switch nargin
    case 3
        if r/d >= 1 && r/d < 1.25
            K = 20*f_T;
        elseif r/d >= 1.25 && r/d < 1.75
            K = 14*f_T;
        elseif r/d >= 1.75 && r/d < 3.5
            K = 12*f_T;
        elseif r/d >= 3.5 && r/d < 5
            K = 14*f_T;
        elseif r/d >= 5 && r/d < 7
            K = 17*f_T;
        elseif r/d >= 7 && r/d < 9
            K = 24*f_T;
        elseif r/d >= 9 && r/d < 11
            K = 30*f_T;
        elseif r/d >= 11 && r/d < 13
            K = 34*f_T;
        elseif r/d >= 13 && r/d < 15
            K = 38*f_T;
        elseif r/d >= 15 && r/d < 18
            K = 42*f_T;
        elseif r/d >= 18 && r/d <= 20
            K = 50*f_T;
        end
    case 1
        K = 30*f_T;
end

