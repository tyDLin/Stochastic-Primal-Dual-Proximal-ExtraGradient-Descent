% PEGSADM
function outputs = PEGSADM_Uniform(samples, labels, opts)
time_min_run = opts.min_t;
F = opts.F; mu = opts.mu; beta = opts.beta; gamma = opts.gamma; C = opts.L3;
max_it = opts.max_it; checki = opts.checki;
if isfield(opts,'scaling')
    scaling = opts.scaling;
else
    scaling = 1;
end

% initialization
t = cputime; time_solving = 0;
xs = []; times = []; iters = []; Num_i  = 0; [d,N] = size(samples);  rnd_pm = randperm(N);
x = zeros(d,1); lambda = zeros(d,1); xbar = zeros(d,1);

done = false; k = 0;
while ~done
    % randomly choose a sample
    idx = rnd_pm(mod(k,N)+1);
    sample = samples(:,idx);
    label  = labels(idx);
    
    % PEGSADM
    eta = 2*scaling/(gamma*(k+1)+2*C);
  
    y = wthresh(F*x + lambda/beta,'s',mu/beta);
    t_exp  = exp(-label*sample'*x);
    if isnan(t_exp) || isinf(t_exp)
        d = 0;
    else
        d = 1/(1+t_exp);
    end
    x_hat = (x - eta*((d-1)*label*sample + F'*lambda))/(1+gamma*eta);
    lambda_hat = lambda - beta*(y-F*x);
    
    t_exp  = exp(-label*sample'*x);
    if isnan(t_exp) || isinf(t_exp)
        d = 0;
    else
        d = 1/(1+t_exp);
    end
    x = (x - eta*((d-1)*label*sample + F'*lambda_hat))/(1+gamma*eta);
    lambda = lambda - beta*(y-F*x_hat);
    xbar = (k*xbar + x_hat)/(k+1); 
    
    % log
    Num_i  = Num_i+1;
    if (Num_i >= checki)
        xs = [xs xbar];
        iters = [iters k];
        time_solving = cputime - t;
        times = [times time_solving];
        Num_i    = 0;
    end    
    
    %terminate condition check
    k = k + 1;
    if k>max_it && time_solving>time_min_run; done = true; end;
end

trace = []; 
trace.checki = checki; 
trace.xs     = xs;
trace.times  = times;
trace.iters  = iters;

outputs.x      = xbar;
outputs.iter   = k; 
outputs.trace  = trace;
end