clc
clear
close all
format short
format compact

% size of the figures
xwidth = 1400; % [pixels]
ywidth = 800; % [pixels]

% top plate velocity
Umax = 0.1; % [m/s]

% Length
L = 1e-3; % [m]

% Fluid properties for case 1
mu = 1.8e-5; % [kg/m.s]
rho = 1.2047; % [kg/m^3]
upsilon(1) = mu/rho; % [m^2/s]

% Fluid properties for case 2
mu = mu*100; % [kg/m.s]
rho = rho*1000; % [kg/m^3]
upsilon(2) = mu/rho; % [m^2/s]

% number of curves on the plots
nn = 50;
factor = 5;
% number of curves on the animation
n_animation = 100;
factor_movie = 4;
% repeats
repeat = 5;
% Steps for the sum of equation 2
total_steps = 100;

% Running conditions
max_time = 0.025; % [s]
step_time = 100000; % steps for the time
step_y = 100; % steps between 0 and 1mm

time = linspace(0,max_time,step_time); % [s]
y = linspace(0,L,step_y); % [m]

% Calculating Lambda factor
dt = max_time/step_time;
dy = L/step_y;
lambda1 = dt*upsilon(1)/dy^2
lambda2 = dt*upsilon(2)/dy^2
lambda_vec = [lambda1,lambda2];

% Boundary conditions
U = zeros(length(y),length(time));
U(1:length(y),1) = 0;
U(1,1:length(time)) = 0;
U(length(y),1:length(time)) = Umax;

fig = 1;
for lambda = lambda_vec
    fprintf('STUDY OF FLUID WITH KINEMATIC VISCOSITY = %3.3d [m^2/s] \n\n',upsilon(fig))
    for it = 1:length(time)-1
        for iy = 2:length(y)-1
            U(iy,it+1) = U(iy,it) + lambda*(U(iy+1,it) - 2*U(iy,it) + U(iy-1,it));
        end
    end
    
    [m,n] = size(U);
    hFig = figure(fig);
    set(hFig, 'Position', [100 100 xwidth ywidth])
    subplot(2,2,1)
    count = 1;
    for time2 = 1:factor:nn
        plot(U(1:m,length(time)/nn*time2)*1000,y*1000,'Linewidth',2)
        xlabel('Velocity (mm/s)')
        ylabel('y-position (mm)')
        title(['Velocity Profile at Different Times for the Numerical Solution up to t = ' num2str(max_time) ' s'])
        legend_time{count} = ['Time: ' num2str(time(length(time)/nn*time2)) ' (s)'];
        count = count + 1;
        hold on
    end
    legend(legend_time,'Location','southeast')
    hold off
    
    subplot(2,2,2)
    loops = n_animation;
    F(loops) = struct('cdata',[],'colormap',[]);
    for j = 1:factor_movie:loops
        plot(U(1:m,length(time)/n_animation*j)*1000,y*1000,'Linewidth',2)
        xlabel('Velocity (mm/s)')
        ylabel('y-position (mm)')
        title(['Velocity Profile Animation for the Numerical Solution up to t = ' num2str(max_time) ' s'])
        drawnow
        F(j) = getframe;
    end
    
    [m,n] = size(U);
    hFig = figure(fig);
    set(hFig, 'Position', [100 100 xwidth ywidth])
    subplot(2,2,3)
    count = 1;
    for time2 = 1:factor:nn
        ycount = 1;
        for y1 = y
            for nstep = 1:total_steps
                sum_term(nstep) = 2*Umax/(nstep*pi)*(-1)^nstep*exp(-upsilon(fig)*nstep^2*pi^2*(time(length(time)/nn*time2))/L^2)*sin(nstep*pi*y1/L);
            end
            U_real(ycount) = Umax.*y1./L + sum(sum_term);
            ycount = ycount + 1;
        end
        plot(U_real(1:m)*1000,y*1000,'Linewidth',2)
        xlabel('Velocity (mm/s)')
        ylabel('y-position (mm)')
        title(['Velocity Profile at Different Times for Equation 2 up to t = ' num2str(max_time) ' s'])
        legend_time{count} = ['Time: ' num2str(time(length(time)/nn*time2)) ' (s)'];
        count = count + 1;
        hold on
    end
    legend(legend_time,'Location','southeast')
    hold off
    
    clear sum_term
    clear U_real
    subplot(2,2,4)
    loops = n_animation;
    F(loops) = struct('cdata',[],'colormap',[]);
    for j = 1:factor_movie:loops
        ycount = 1;
        for y1 = y
            for nstep = 1:total_steps
                sum_term(nstep) = 2*Umax/(nstep*pi)*(-1)^nstep*exp(-upsilon(fig)*nstep^2*pi^2*(time(length(time)/n_animation*j))/L^2)*sin(nstep*pi*y1/L);
            end
            U_real(ycount) = Umax.*y1./L + sum(sum_term);
            ycount = ycount + 1;
        end
        plot(U_real(1:m)*1000,y*1000,'Linewidth',2)
        xlabel('Velocity (mm/s)')
        ylabel('y-position (mm)')
        title(['Velocity Profile Animation for Equation 2 up to t = ' num2str(max_time) ' s'])
        drawnow
        F(j) = getframe;
    end
    clear sum_term
    clear U_real
    fig = fig + 1;
end