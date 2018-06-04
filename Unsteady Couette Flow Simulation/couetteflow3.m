clc
clear
close all

% INPUTS
% maximum velocity (m/s)
maximum_velocity = 0.1;
% maximum height (m)
maximum_y = 1e-3;
% fluid properties for both fluids in (SI units)
mu = 1.8e-5;
rho = 1.2047;
kinematic_vis1 = mu/rho;
mu = mu*100;
rho = rho*1000;
kinematic_vis2 = mu/rho;

% INITIAL CONDITIONS
% time in seconds
maximum_time = 0.021;
step_time = 290000;
step_y = 600;
t = linspace(0,maximum_time,step_time);
y = linspace(0,maximum_y,step_y);
velocity_profile = zeros(step_y,step_time);
velocity_profile(1,:) = 0;
velocity_profile(step_y,:) = maximum_velocity;
velocity_profile(:,1) = 0;
delta_t = maximum_time/step_time;
delta_y = maximum_y/step_y;
lambda_factor = delta_t*kinematic_vis1/delta_y^2;

number_curves = 10;
number_curves_movie = 100;
fourier_steps = 10;
graph_t = 1:1:number_curves;

fprintf('KINEMATIC VISCOSITY = %3.3d in m^2/s \n',kinematic_vis1)
fprintf('LAMBDA = %3.6f \n\n',lambda_factor)
for ti = 1:step_time-1
    for yi = 2:step_y-1
        velocity_profile(yi,ti+1) = velocity_profile(yi,ti) + lambda_factor*(velocity_profile(yi+1,ti) - 2*velocity_profile(yi,ti) + velocity_profile(yi-1,ti));
    end
end

figure(1)
legend_counter = 1;
for graph_t_step = graph_t
    plot(velocity_profile(:,step_time/number_curves*graph_t_step-step_time/number_curves/2)*1000,y*1000,'Linewidth',2)
    title(['Numerical Solution for multiple velocity profiles up to t = ' num2str(t(step_time*max(graph_t)/number_curves)) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    legend_time{legend_counter} = ['Time: ' num2str(t(step_time/number_curves*graph_t_step-step_time/number_curves/2)) ' (s)'];
    legend_counter = legend_counter + 1;
    hold on
end
legend(legend_time,'Location','southeast')
hold off


figure(2)
legend_counter = 1;
for graph_t_step = graph_t
    count_fourier = 1;
    for yi = y
        for ifourier = 1:fourier_steps
            sum_fourier(ifourier) = 2*maximum_velocity/(ifourier*pi)*(-1)^ifourier*exp(-kinematic_vis1*ifourier^2*pi^2*(t(step_time/number_curves*graph_t_step-step_time/number_curves/2))/maximum_y^2)*sin(ifourier*pi*yi/maximum_y);
        end
        velocity_profile_fourier(count_fourier) = maximum_velocity.*yi./maximum_y + sum(sum_fourier);
        count_fourier = count_fourier + 1;
    end
    plot(velocity_profile_fourier*1000,y*1000,'Linewidth',2)

    title(['Fourier solution for multiple velocity profiles up to t = ' num2str(t(step_time*max(graph_t)/number_curves)) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    legend_time{legend_counter} = ['Time: ' num2str(t(step_time/number_curves*graph_t_step-step_time/number_curves/2)) ' (s)'];
    legend_counter = legend_counter + 1;
    hold on
end
legend(legend_time,'Location','southeast')
hold off

figure(3)
for graph_movie_step = 1:1:number_curves_movie
    plot(velocity_profile(:,step_time/number_curves_movie*graph_movie_step)*1000,y*1000,'Linewidth',2)
    title(['Movie for the Numerical Solution up to t = ' num2str(t(step_time*max(graph_t)/number_curves)) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    drawnow
end

number_curves_movie = 200;
hFig = figure(23);
set(hFig, 'Units','normalized','Position', [0.1 0.1 0.8 0.8])
[xx, yy] = meshgrid(linspace(0,maximum_time,number_curves_movie),linspace(0,maximum_y,number_curves_movie));
surf(velocity_profile(1:step_y/number_curves_movie:step_y,1:step_time/number_curves_movie:step_time),xx,yy)
axis('tight')
xlabel('V in m/s')
zlabel('Y in m')
ylabel('t in s')

maximum_time = maximum_time * 10;
t = linspace(0,maximum_time,step_time);
y = linspace(0,maximum_y,step_y);
velocity_profile = zeros(step_y,step_time);
velocity_profile(1,:) = 0;
velocity_profile(step_y,:) = maximum_velocity;
velocity_profile(:,1) = 0;
delta_t = maximum_time/step_time;
delta_y = maximum_y/step_y;
lambda_factor = delta_t*kinematic_vis2/delta_y^2;

fprintf('KINEMATIC VISCOSITY = %3.3d in m^2/s \n',kinematic_vis2)
fprintf('LAMBDA = %3.6f \n\n',lambda_factor)
for mt = 1:step_time-1
    for my = 2:step_y-1
        velocity_profile(my,mt+1) = velocity_profile(my,mt) + lambda_factor*(velocity_profile(my+1,mt) - 2*velocity_profile(my,mt) + velocity_profile(my-1,mt));
    end
end

figure(4)
legend_counter = 1;
for graph_t_step = graph_t
    plot(velocity_profile(:,step_time/number_curves*graph_t_step-step_time/number_curves/2)*1000,y*1000,'Linewidth',2)

    title(['Numerical Solution for multiple velocity profiles up to t = ' num2str(t(step_time*max(graph_t)/number_curves)) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    legend_time{legend_counter} = ['Time: ' num2str(t(step_time/number_curves*graph_t_step-step_time/number_curves/2)) ' (s)'];
    legend_counter = legend_counter + 1;
    hold on
end
legend(legend_time,'Location','southeast')
hold off

figure(5)
legend_counter = 1;
for graph_t_step = graph_t
    count_fourier = 1;
    for yi = y
        for ifourier = 1:fourier_steps
            sum_fourier(ifourier) = 2*maximum_velocity/(ifourier*pi)*(-1)^ifourier*exp(-kinematic_vis2*ifourier^2*pi^2*(t(step_time/number_curves*graph_t_step-step_time/number_curves/2))/maximum_y^2)*sin(ifourier*pi*yi/maximum_y);
        end
        velocity_profile_fourier(count_fourier) = maximum_velocity.*yi./maximum_y + sum(sum_fourier);
        count_fourier = count_fourier + 1;
    end
    plot(velocity_profile_fourier*1000,y*1000,'Linewidth',2)

    title(['Fourier solution for multiple velocity profiles up to t = ' num2str(t(step_time*max(graph_t)/number_curves)) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    legend_time{legend_counter} = ['Time: ' num2str(t(step_time/number_curves*graph_t_step-step_time/number_curves/2)) ' (s)'];
    legend_counter = legend_counter + 1;
    hold on
end
legend(legend_time,'Location','southeast')
hold off

figure(6)
for graph_movie_step = 1:1:number_curves_movie
    plot(velocity_profile(:,step_time/number_curves_movie*graph_movie_step)*1000,y*1000,'Linewidth',2)

    title(['Movie for the Numerical Solution up to t = ' num2str(t(step_time*max(graph_t)/number_curves)) ' (s)'])
    xlabel('V in mm/s')
    ylabel('Y in mm')
    drawnow
end

number_curves_movie = 200;
hFig = figure(24);
set(hFig, 'Units','normalized','Position', [0.1 0.1 0.8 0.8])
[xx, yy] = meshgrid(linspace(0,maximum_time,number_curves_movie),linspace(0,maximum_y,number_curves_movie));
surf(velocity_profile(1:step_y/number_curves_movie:step_y,1:step_time/number_curves_movie:step_time),xx,yy)
axis('tight')
xlabel('V in m/s')
zlabel('Y in m')
ylabel('t in s')
