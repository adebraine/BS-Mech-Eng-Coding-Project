function [time_total1,temperature1,time_total2,temperature2] = Transient(f_t,L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,h,T_bottle,T_bottle_max,co)
[Pr,k,rho,mu,P,cp] = thermalprop(T_cw+C_to_K);
ii = 1;
zeta_t = 0:0.1:2.4;

ta = rho*D_bottle*cp/(h*4)*log((T_bottle-T_cw)/(T_cw+0.001-T_cw));
time_total1 = nan(1,T_bottle_max);
time_total2 = nan(1,T_bottle_max);
temperature1 = nan(1,T_bottle_max);
temperature2 = nan(1,T_bottle_max);

for j = zeta_t
    [J0,J1] = Bessel_Function(j);
    Bi_test(ii) = j*J1/J0;
    ii = ii + 1;
end
Bi_test = Bi_test(:);
alpha = k/(rho*cp);


xx = 1;
% t_run = linspace(1,5*60,T_bottle_max);
T_run = T_bottle:-1:T_cw+1;
for  T = T_run
    Bi = h*(D_bottle/2)/k;
    for i = 1:length(Bi_test)
        [c,index] = min(abs(Bi_test - Bi));
        zeta = zeta_t(index);
    end
    [J0,J1] = Bessel_Function(zeta);
    [J02,~] = Bessel_Function(zeta*D_bottle/2);
    
%     Fo = t*co*alpha/((D_bottle/2)^2);
%     C = 2/zeta*(J1/(J0^2+J1^2));
%     theta = C*exp(-zeta^2*Fo)*J02;
%     T = theta*(T_bottle - T_cw)+T_cw;
    
    theta = (T - T_cw)/(T_bottle - T_cw);
    C = 2/zeta*(J1/(J0^2+J1^2));
    Fo = (1/(-zeta^2))*log(theta/(C*J02));
    t = Fo*((D_bottle/2)^2)/alpha;
    
    time_total1(xx) = t/co-ta;
    
    temperature1(xx) = T;
    [q,h] = heattransfer_pipe(f_t,L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T);
    xx = xx + 1;
end

xx = 1;
for T = T_run
    Bi = h*(D_bottle/4)/k;
    for i = 1:length(Bi_test)
        [c,index] = min(abs(Bi_test - Bi));
        zeta = zeta_t(index);
    end
    [J0,J1] = Bessel_Function(zeta);
    [J02,~] = Bessel_Function(zeta*0);
%     
%     Fo = t*co*alpha/((D_bottle/2)^2);
%     C = 2/zeta*(J1/(J0^2+J1^2));
%     theta = C*exp(-zeta^2*Fo)*J02;
%     T = theta*(T_bottle - T_cw)+T_cw;
    
    theta = (T - T_cw)/(T_bottle - T_cw);
    C = 2/zeta*(J1/(J0^2+J1^2));
    Fo = (1/(-zeta^2))*log(theta/(C*J02));
    t = Fo*((D_bottle/2)^2)/alpha;
    
    time_total2(xx) = t/co-ta;
    
    temperature2(xx) = T;
    [q,h] = heattransfer_pipe(f_t,L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T);
    xx = xx + 1;
end
time_total1 = time_total1(:);
time_total2 = time_total2(:);
temperature1 = temperature1(:);
temperature2 = temperature2(:);
% plot(time_total1,temperature,time_total2,temperature)


