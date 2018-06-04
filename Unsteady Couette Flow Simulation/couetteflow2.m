clc
clear
close all

% INPUTS
% maximum velocity (m/s)
velmax = 0.1; 
% maximum height (m)
height = 1e-3;
% fluid properties for both fluids in (SI units)
mu = 1.8e-5; 
rho = 1.2047; 
kinvis1 = mu/rho; 
mu = mu*100;
rho = rho*1000; 
kinvis2 = mu/rho; 

% INITIAL CONDITIONS
% time in seconds
tmax = 0.025; 
tstep = 250000; 
ystep = 566;
t = linspace(0,tmax,tstep); 
y = linspace(0,height,ystep); 
vel = zeros(length(y),length(t));
vel(1:length(y),1) = 0;
vel(1,1:length(t)) = 0;
vel(length(y),1:length(t)) = velmax;
changet = tmax/tstep;
changey = height/ystep;
lam = changet*kinvis1/changey^2;

n = 10;
nmovie = 100;
ts = 10;
fprintf('KINEMATIC VISCOSITY = %3.3d in m^2/s \n',kinvis1)
fprintf('LAMBDA = %3.6f \n\n',lam)
vel = couetteflowfunc(vel,lam,y,t);

[m,ignore] = size(vel);
figure(1)
cc = 1;
for time2 = 1:1:n
    plot(vel(1:m,length(t)/n*time2)*1000,y*1000,'Linewidth',2)
    title(['Numerical Solution for multiple velocity profiles up to t = ' num2str(tmax) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    legt{cc} = ['Time: ' num2str(t(length(t)/n*time2)) ' (s)'];
    cc = cc + 1;
    hold on
end
legend(legt,'Location','southeast')
hold off

figure(2)
for z = 1:1:nmovie
    plot(vel(1:m,length(t)/nmovie*z)*1000,y*1000,'Linewidth',2)
    
    title(['Movie for the Numerical Solution up to t = ' num2str(tmax) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    drawnow
end

[m,ignore] = size(vel);
figure(3)
cc = 1;
for time2 = 1:1:n
    vel_fourier = Fouriersol(velmax,ts,y,kinvis1,t,n,time2,height);
    plot(vel_fourier(1:m)*1000,y*1000,'Linewidth',2)
    
    title(['Fourier solution for multiple velocity profiles up to t = ' num2str(tmax) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    legt{cc} = ['Time: ' num2str(t(length(t)/n*time2)) ' (s)'];
    cc = cc + 1;
    hold on
end
legend(legt,'Location','southeast')
hold off

figure(4)
for z = 1:1:nmovie
    vel_fourier = Fouriersol(velmax,ts,y,kinvis1,t,nmovie,z,height);
    plot(vel_fourier(1:m)*1000,y*1000,'Linewidth',2)
    
    title(['Movie for Fourier solution up to t = ' num2str(tmax) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    drawnow
end

tmax = tmax * 10;
t = linspace(0,tmax,tstep); 
y = linspace(0,height,ystep); 
vel = zeros(length(y),length(t));
vel(1:length(y),1) = 0;
vel(1,1:length(t)) = 0;
vel(length(y),1:length(t)) = velmax;
changet = tmax/tstep;
changey = height/ystep;
lam = changet*kinvis2/changey^2;

fprintf('KINEMATIC VISCOSITY = %3.3d in m^2/s \n',kinvis2)
fprintf('LAMBDA = %3.6f \n\n',lam)
vel = couetteflowfunc(vel,lam,y,t);
for it = 1:length(t)-1
    for iy = 2:length(y)-1
        vel(iy,it+1) = vel(iy,it) + lam*(vel(iy+1,it) - 2*vel(iy,it) + vel(iy-1,it));
    end
end

[m,ignore] = size(vel);
figure(5)
cc = 1;
for time2 = 1:1:n
    plot(vel(1:m,length(t)/n*time2)*1000,y*1000,'Linewidth',2)
    
    title(['Numerical Solution for multiple velocity profiles up to t = ' num2str(tmax) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    legt{cc} = ['Time: ' num2str(t(length(t)/n*time2)) ' (s)'];
    cc = cc + 1;
    hold on
end
legend(legt,'Location','southeast')
hold off

figure(6)
for z = 1:1:nmovie
    plot(vel(1:m,length(t)/nmovie*z)*1000,y*1000,'Linewidth',2)
    
    title(['Movie for the Numerical Solution up to t = ' num2str(tmax) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    drawnow
end

[m,ignore] = size(vel);
figure(7)
cc = 1;
for time2 = 1:1:n
    vel_fourier = Fouriersol(velmax,ts,y,kinvis2,t,n,time2,height);
    plot(vel_fourier(1:m)*1000,y*1000,'Linewidth',2)
    
    title(['Fourier solution for multiple velocity profiles up to t = ' num2str(tmax) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    legt{cc} = ['Time: ' num2str(t(length(t)/n*time2)) ' (s)'];
    cc = cc + 1;
    hold on
end
legend(legt,'Location','southeast')
hold off

figure(8)
for z = 1:1:nmovie
    vel_fourier = Fouriersol(velmax,ts,y,kinvis2,t,nmovie,z,height);
    plot(vel_fourier(1:m)*1000,y*1000,'Linewidth',2)
    
    title(['Movie for Fourier solution up to t = ' num2str(tmax) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    drawnow
end
