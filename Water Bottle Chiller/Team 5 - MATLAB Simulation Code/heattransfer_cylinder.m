function [q,h] = heattransfer_cylinder(width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle)
A_chamber_flow = width_chamber*(D_chamber-D_bottle);
[Pr_s,~,~,~,~,~] = thermalprop(T_bottle+C_to_K);
[Pr,k,rho,mu,~,~] = thermalprop((T_cw+C_to_K+T_bottle+C_to_K)/2);
[Prinf,kinf,rhoinf,muinf,~,~] = thermalprop(T_cw+C_to_K);

syms Re D_h Reinf
eq1 = Re == rho*V_chamber*D_bottle/mu;
eq2 = Reinf == rhoinf*V_chamber*D_bottle/muinf;
eq3 = D_h == 4*A_chamber_flow/(4*width_chamber+2*(D_chamber-D_bottle));
s1 = solve(eq1,eq2,eq3);
Re = eval(s1.Re);
Reinf = eval(s1.Reinf);
D_h = eval(s1.D_h);

if Re >= 0.4 && Re<=4*10^5 && Pr>=0.7
    disp('case 1')
    if Re>=0.4 && Re<4
        C = 0.989;
        m = 0.330;
    elseif Re>=4 && Re<40
        C = 0.911;
        m = 0.385;
    elseif Re>=40 && Re<4000
        C = 0.683;
        m = 0.466;
    elseif Re>=4000 && Re<40000
        C = 0.193;
        m = 0.618;
    elseif Re>=40000 && Re<400000
        C = 0.027;
        m = 0.805;
    end
    Nu_D = C*Re^m*Pr^(1/3);
    syms h q
    eq1 = Nu_D == h*D_bottle/k;
    eq2 = q == h*L_bottle*pi*D_bottle*(T_bottle-T_cw);
    
    s = solve(eq1,eq2);
    q = eval(s.q);
    h = eval(s.h);
elseif Re >= 1 && Re<=10^6 && Pr>=0.7 && Pr<=500
    disp('case 2')
    if Pr <= 10
        n = 0.37;
    else
        n = 0.36;
    end
    if Re>=1 && Re<40
        C = 0.74;
        m = 0.4;
    elseif Re>=40 && Re<1000
        C = 0.51;
        m = 0.5;
    elseif Re>=1000 && Re<2*10^5
        C = 0.26;
        m = 0.6;
    elseif Re>=2*10^5 && Re<10^6
        C = 0.076;
        m = 0.7;
    end
    Nu_D = C*Re^m*Pr^n*(Pr/Pr_s)^(1/4);
    syms h q
    eq1 = Nu_D == h*D_bottle/k;
    eq2 = q == h*L_bottle*pi*D_bottle*(T_bottle-T_cw);
    
    s = solve(eq1,eq2);
    q = eval(s.q);
    h = eval(s.h);
elseif Re*Pr>=0.2
    disp('case 3')
    Nu_Dinf = 0.3+(0.62*Reinf^0.5*Prinf^(1/3)*(1+(0.4/Prinf)^(2/3))^(-1/4))*(1+(Reinf/282000)^(5/8))^(4/5);
    syms h q
    eq1 = Nu_Dinf == h*D_bottle/kinf;
    eq2 = q == h*L_bottle*pi*D_bottle*(T_bottle-T_cw);
    
    s = solve(eq1,eq2);
    q = eval(s.q);
    h = eval(s.h);
end



