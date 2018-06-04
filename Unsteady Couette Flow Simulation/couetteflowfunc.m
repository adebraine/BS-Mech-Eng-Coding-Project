function [vel] = couetteflowfunc(vel,lam,y,t)

for it = 1:length(t)-1
    for iy = 2:length(y)-1
        vel(iy,it+1) = vel(iy,it) + lam*(vel(iy+1,it) - 2*vel(iy,it) + vel(iy-1,it));
    end
end

end