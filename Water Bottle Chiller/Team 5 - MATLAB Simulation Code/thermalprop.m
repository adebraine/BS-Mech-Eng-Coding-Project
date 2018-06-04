function [Prnew,knew,rhonew,munew,Pnew,cpnew] = thermalprop(T)

% Thermal properties of water for temperatures ranging from 273.15K to
% 373.15K
% Units are: Pr [], k [W/m.K], rho [kg/m^3], mu [N.s/m^2], P [Pa], cp [J/kg-K]

Pr = [12.99,12.22,10.26,8.81,7.56,6.62,5.83,5.2,4.62,4.16,...
    3.77,3.42,3.15,2.88,2.66,2.45,2.29,2.14,2.02,1.91,1.8,1.76];
Pr = Pr(:);

k = [569,574,582,590,598,606,613,620,628,634,...
    640,645,650,656,660,664,668,671,674,677,679,680];
k = k(:)*10^(-3);

rho = [1,1,1,1,1.001,1.002,1.003,1.005,1.007,1.009,1.011,...
    1.013,1.016,1.018,1.021,1.024,1.027,1.03,1.034,1.038,1.041,1.044];
rho = (rho(:)*10^(-3)).^(-1);

mu = [1750,1652,1422,1225,1080,959,855,769,695,631,577,...
    528,489,453,420,389,365,343,324,306,289,279];
mu = mu(:)*10^(-6);

P = [0.00611,0.00697,0.00990,0.01387,0.01917,0.02617,0.03531,...
    0.04712,0.06221,0.08132,0.1053,0.1351,0.1719,0.2167,0.2713,...
    0.3372,0.4163,0.51,0.6209,0.7514,0.9040,1.0133];
P = P(:)*10^5;

cp = [4.217,4.211,4.198,4.189,4.184,4.181,4.179,4.178,4.178,4.179,...
    4.180,4.182,4.184,4.186,4.188,4.191,4.195,4.199,4.203,4.209,...
    4.214,4.217];
cp = cp(:)*10^3;

Ttablestart = 273.15;
Ttableend = 373.15;
Ttablemid = 275:5:370;
Ttable = [Ttablestart,Ttablemid,Ttableend];
Ttable = Ttable(:);

if T < Ttable(1) || T > Ttable(length(Ttable))
    error('The temperature input needs to range from 273.15K to 373.15K')
end
i = 1;
Told = Ttable(1);
Prnew = 0;
while (1)
    if T > Told && T < Ttable(i+1)
        Prnew = ((T-Ttable(i))*(Pr(i+1)-Pr(i)))/(Ttable(i+1)-Ttable(i))+Pr(i);
    elseif T == Ttable(i)
        Prnew = Pr(i);
    elseif T == Ttable(i+1) && i+1 == length(Ttable)
        Prnew = ((T-Ttable(i))*(Pr(i+1)-Pr(i)))/(Ttable(i+1)-Ttable(i))+Pr(i);
    end
    Told = Ttable(i);  
    i = i+1;
    if Prnew > 0,break,end
end

i = 1;
Told = Ttable(1);
knew = 0;
while (1)
    if T > Told && T < Ttable(i+1)
        knew = ((T-Ttable(i))*(k(i+1)-k(i)))/(Ttable(i+1)-Ttable(i))+k(i);
    elseif T == Ttable(i)
        knew = k(i);
    elseif T == Ttable(i+1) && i+1 == length(Ttable)
        knew = ((T-Ttable(i))*(k(i+1)-k(i)))/(Ttable(i+1)-Ttable(i))+k(i);
    end
    Told = Ttable(i);  
    i = i+1;
    if knew > 0,break,end
end

i = 1;
Told = Ttable(1);
rhonew = 0;
while (1)
    if T > Told && T < Ttable(i+1)
        rhonew = ((T-Ttable(i))*(rho(i+1)-rho(i)))/(Ttable(i+1)-Ttable(i))+rho(i);
    elseif T == Ttable(i)
        rhonew = rho(i);
    elseif T == Ttable(i+1) && i+1 == length(Ttable)
        rhonew = ((T-Ttable(i))*(rho(i+1)-rho(i)))/(Ttable(i+1)-Ttable(i))+rho(i);
    end
    Told = Ttable(i);  
    i = i+1;
    if rhonew > 0,break,end
end

i = 1;
Told = Ttable(1);
munew = 0;
while (1)
    if T > Told && T < Ttable(i+1)
        munew = ((T-Ttable(i))*(mu(i+1)-mu(i)))/(Ttable(i+1)-Ttable(i))+mu(i);
    elseif T == Ttable(i)
        munew = mu(i);
    elseif T == Ttable(i+1) && i+1 == length(Ttable)
        munew = ((T-Ttable(i))*(mu(i+1)-mu(i)))/(Ttable(i+1)-Ttable(i))+mu(i);
    end
    Told = Ttable(i);  
    i = i+1;
    if munew > 0,break,end
end

i = 1;
Told = Ttable(1);
Pnew = 0;
while (1)
    if T > Told && T < Ttable(i+1)
        Pnew = ((T-Ttable(i))*(P(i+1)-P(i)))/(Ttable(i+1)-Ttable(i))+P(i);
    elseif T == Ttable(i)
        Pnew = P(i);
    elseif T == Ttable(i+1) && i+1 == length(Ttable)
        Pnew = ((T-Ttable(i))*(P(i+1)-P(i)))/(Ttable(i+1)-Ttable(i))+P(i);
    end
    Told = Ttable(i);  
    i = i+1;
    if Pnew > 0,break,end
end

i = 1;
Told = Ttable(1);
cpnew = 0;
while (1)
    if T > Told && T < Ttable(i+1)
        cpnew = ((T-Ttable(i))*(cp(i+1)-cp(i)))/(Ttable(i+1)-Ttable(i))+cp(i);
    elseif T == Ttable(i)
        cpnew = cp(i);
    elseif T == Ttable(i+1) && i+1 == length(Ttable)
        cpnew = ((T-Ttable(i))*(cp(i+1)-cp(i)))/(Ttable(i+1)-Ttable(i))+cp(i);
    end
    Told = Ttable(i);  
    i = i+1;
    if cpnew > 0,break,end
end
