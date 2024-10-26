% Alberto Dominguez - UWF MAT 6903 Mathematics Research 1 
% This program generated the results for Model 3 of the paper
% Version History:
%   2024-10-09 initial code

tic; clear; clc; close all

% option parameters
r = 0.039;          % 1 Yr Treas Rate on 9/20/2024 was 3.90%
S0 = 5700;          % index on 9/20/2024 was 5702.55
T = 1;              % time to expiry = 1 year

% regime-switching parameters
p12 = 0.2323;
p21 = 1 - p12;

% Create a merton object with the appropriate regime 1 model parameters
a1 = 0.2385565;     % physical return on the underlying
sigma1 = 0.156144;  % volatility of underlying
lambda1 = 0.8278;   % jump intensity
mu1 = 0.0234;       % jump size mean
sigJ1 = 0.0687;     % jump size standard deviation
mjdObj1 = merton(a1,sigma1,lambda1,mu1,sigJ1,StartState=S0);

% Create a merton object with the appropriate regime 2 model parameters
a2 = -0.470671;     % physical return on the underlying
sigma2 = 0.271172;  % volatility of underlying
lambda2 = 1.0941;   % jump intensity
mu2 = -0.0175;      % jump size mean
sigJ2 = 0.1091;     % jump size standard deviation
mjdObj2 = merton(a2,sigma2,lambda2,mu2,sigJ2,StartState=S0);

% discretization
steps = 251;        % time steps (approx. 251 trading days in a year)
dt = T/steps;

% simulation
% TODO - need to seed for reproducibility
nPath = 10000;      % number of paths to simulate
[paths1,times1] = simByMilstein2(mjdObj1, steps, Ntrials=nPath,...
    DeltaTime=dt, MonteCarloMethod="quasi", QuasiSequence="sobol",...
    BrownianMotionMethod="principal-components", StorePaths=true);
[paths2,times2] = simByMilstein2(mjdObj2, steps, Ntrials=nPath,...
    DeltaTime=dt, MonteCarloMethod="quasi", QuasiSequence="sobol",...
    BrownianMotionMethod="principal-components", StorePaths=true);

% plot 10 sample paths for each regime
figure(1)
hold on
for i=1:10
    plot(times1,paths1(:,:,i*1000))
end
hold off
figure(2)
hold on
for i=1:10
    plot(times2,paths2(:,:,i*1000))
end
hold off

% price the European call and put options at various strike prices
lo = S0 - 1500;
hi = S0 + 1500;
strike_step = 10;
N = (hi - lo)/strike_step + 1;          
call(N) = 0; put(N) = 0;
str = lo;
for i = 1:N
    call(i) = prices(str,steps+1,paths1,p21,paths2,p12,false);
    put(i) = prices(str,steps+1,paths1,p21,paths2,p12,true);
    str = str + strike_step;
end

% plot the results
close all
strikes = lo:strike_step:hi;
hold on
title('Model 3 with S0 = 5700')
xlabel('Strike Price') 
ylabel('Option Value')
plot(strikes,call,'DisplayName','Call')
plot(strikes,put,'DisplayName','Put')
legend
hold off
toc