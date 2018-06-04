function [J0new,J1new] = Bessel_Function(x)

% Bessel functions of the first kind for x = 0 to x = 2.4

J0 = [1,0.9975,0.99,0.9776,0.9604,0.9385,0.9120,0.8812,0.8463,0.8075,...
    0.7652,0.7196,0.6711,0.6201,0.5669,0.5118,0.4554,0.3980,...
    0.34,0.2818,0.2239,0.1666,0.1104,0.0555,0.0025];
J0 = J0(:);

J1 = [0,0.0499,0.0995,0.1483,0.1960,0.2423,0.2867,0.3290,0.3688,0.4059,...
    0.44,0.4709,0.4983,0.522,0.5419,0.5579,0.5699,0.5778,0.5815,...
    0.5812,0.5767,0.5683,0.556,0.5399,0.5202];
J1 = J1(:);

xtable = 0:0.1:2.4;
xtable = xtable(:);

if x < xtable(1) || x > xtable(length(xtable))
    error('The x input needs to range from 0 to 2.4')
end

i = 1;
xold = xtable(1);
J0new = 0;
while (1)
    if x > xold && x < xtable(i+1)
        J0new = ((x-xtable(i))*(J0(i+1)-J0(i)))/(xtable(i+1)-xtable(i))+J0(i);
    elseif x == xtable(i)
        J0new = J0(i);
    elseif x == xtable(i+1) && i+1 == length(xtable)
        J0new = ((x-xtable(i))*(J0(i+1)-J0(i)))/(xtable(i+1)-xtable(i))+J0(i);
    end
    xold = xtable(i);
    i = i+1;
    if J0new > 0,break,end
end

i = 1;
xold = xtable(1);
J1new = -1;
while (1)
    if x > xold && x < xtable(i+1)
        J1new = ((x-xtable(i))*(J1(i+1)-J1(i)))/(xtable(i+1)-xtable(i))+J1(i);
    elseif x == xtable(i)
        J1new = J1(i);
    elseif x == xtable(i+1) && i+1 == length(xtable)
        J1new = ((x-xtable(i))*(J1(i+1)-J1(i)))/(xtable(i+1)-xtable(i))+J1(i);
    end
    xold = xtable(i);
    i = i+1;
    if J1new > -1,break,end
end

end
