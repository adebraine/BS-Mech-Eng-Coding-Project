function vel_fourier = Fouriersol(velmax,tstep,y,kinvis,t,n,t2,height)

count = 1;
for yy = y
    for nstep = 1:tstep
        sum_term(nstep) = 2*velmax/(nstep*pi)*(-1)^nstep*exp(-kinvis*nstep^2*pi^2*(t(length(t)/n*t2))/height^2)*sin(nstep*pi*yy/height);
    end
    vel_fourier(count) = velmax.*yy./height + sum(sum_term);
    count = count + 1;
end

end