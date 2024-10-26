% Alberto Dominguez - UWF MAT 6903 Mathematics Research 1 
% This program was used to generate the calibration results in the paper
% Version History:
%   2024-10-18 model 1
%   2024-10-20 model 2 exact
%   2024-10-22 model 2 simulation
%   2024-10-23 model 3

tic; clear; clc; close all

% option parameters
r = 0.0421;          % 1 Yr Treas Rate on 10/17/2024 
S0 = 5841.47;        % S&P500 index on 10/17/2024 
T = 1;               % time to expiry = 1 year

% graph parameters
lo = 5600;
hi = 6075;
strike_step = 25;
N = (hi - lo)/strike_step + 1;          
call1(N) = 0; call2(N) = 0; call2s(N) = 0; call3(N) = 0; 
put1(N) = 0; put2(N) = 0; put2s(N) = 0; put3(N) = 0;

% discretization and simulation parameters
steps = 251;         % time steps (approx. 251 trading days in a year)
dt = T/steps;
nPath = 10000;       % number of paths to simulate

% market prices for 1 year options expiring 10/17/2025
call_actual = [662.15 643.6 625.1 606.65 588.7 570.25 553.35 535.75 ...
    518.25 500.95 483.35 467.3 450.65 434.2 418.15 402.3 386.3 371 ...
    355.8 340.65];
put_actual = [217.9 223.75 229.35 234.9 240.85 246.85 253.05 259.75 ...
    266.45 272.9 279.76 286.75 294.45 302 309.75 317.6 325.9 334.4 ...
    342.95 352];J

% model 1 (BSM) parameters
sigma1 = 0.1627432;  % volatility of underlying
str = lo;
for i = 1:N
    call1(i) = BSM(S0,T,str,sigma1,r,false);
    put1(i) = BSM(S0,T,str,sigma1,r,true);
    str = str + strike_step;
end

% model 2 (MJD, Exact Solution) parameters, separate for puts and calls
sigma2 = sigma1;     % volatility of underlying
mu2 = 0.0001;        % jump size mean 
sigJ2 = 0.0576;      % jump size standard deviation 
lambda2P = 0.0055;   % jump intensity for puts
lambda2C = 0;        % jump intensity for calls
str = lo;
for i = 1:N
    call2(i) = MJD(S0,T,str,sigma2,r,lambda2C,mu2,sigJ2,false);
    put2(i) = MJD(S0,T,str,sigma2,r,lambda2P,mu2,sigJ2,true);
    str = str + strike_step;
end

% model 2 (MJD, Simulation) parameters
lambda2s = 0.3719;   % jump intensity
mu2s = 0;            % jump size mean
sigJ2s = 0.1073;     % jump size standard deviation
a2sc = 0.0331;       % drift of underlying for calls
a2sp = 0.0425;       % drift of underlying for puts
mjdObj2sc = merton(a2sc,sigma2,lambda2s,mu2s,sigJ2s,StartState=S0);
mjdObj2sp = merton(a2sp,sigma2,lambda2s,mu2s,sigJ2s,StartState=S0);
% TODO - need to seed for reproducibility
[pathsc,timesc] = simByMilstein2(mjdObj2sc, steps, Ntrials=nPath,...
    DeltaTime=dt, MonteCarloMethod="quasi", QuasiSequence="sobol",...
    BrownianMotionMethod="principal-components", StorePaths=true);
[pathsp,timesp] = simByMilstein2(mjdObj2sp, steps, Ntrials=nPath,...
    DeltaTime=dt, MonteCarloMethod="quasi", QuasiSequence="sobol",...
    BrownianMotionMethod="principal-components", StorePaths=true);
str = lo;
for i = 1:N
    call2s(i) = prices(str,steps+1,pathsc,1,pathsp,0,false);
    put2s(i) = prices(str,steps+1,pathsc,0,pathsp,1,true);
    str = str + strike_step;
end

% model 3 (RS) regime-switching parameters
p12 = 0.2323;
p21 = 1 - p12;
% model 3 (RS) regime 1 parameters
sigma31 = 0.158;     % volatility of underlying
lambda31 = 0.8278;   % jump intensity
mu31 = 0.0234;       % jump size mean
sigJ31 = 0.0687;     % jump size standard deviation
% model 3 (RS) regime 2 parameters
sigma32 = 0.187;     % volatility of underlying
lambda32 = 1.0941;   % jump intensity
mu32 = -0.0175;      % jump size mean
sigJ32 = 0.1091;     % jump size standard deviation

% optimization for model 3
a31 = 0.026;
a32 = -0.009;
mjdObj31 = merton(a31,sigma31,lambda31,mu31,sigJ31,StartState=S0);
mjdObj32 = merton(a32,sigma32,lambda32,mu32,sigJ32,StartState=S0);
[paths1,times1] = simByMilstein2(mjdObj31,steps,Ntrials=nPath,...
    DeltaTime=dt,MonteCarloMethod="quasi",QuasiSequence="sobol",...
    BrownianMotionMethod="principal-components",StorePaths=true);
[paths2,times2] = simByMilstein2(mjdObj32,steps,Ntrials=nPath,...
    DeltaTime=dt,MonteCarloMethod="quasi",QuasiSequence="sobol",...
    BrownianMotionMethod="principal-components",StorePaths=true);
str = lo;
for i = 1:N
    call3(i) = prices(str,steps+1,paths1,p21,paths2,p12,false);
    put3(i) = prices(str,steps+1,paths1,p21,paths2,p12,true);
    str = str + strike_step;
end

% plot the call model results against market prices
close all
figure(1)
strikes = lo:strike_step:hi;
hold on
title('Model Prices vs Market Prices')
xlabel('Strike Price') 
ylabel('Call Option Value')
plot(strikes,call1,'DisplayName','BSM / MJD Exact')
plot(strikes,call2s,'DisplayName','MJD Simul')
plot(strikes,call3,'DisplayName','RS')
plot(strikes,call_actual,'DisplayName','Market')
legend
hold off

% plot the put model results against market prices
figure(2)
hold on
title('Model Prices vs Market Prices')
xlabel('Strike Price') 
ylabel('Put Option Value')
plot(strikes,put1,'DisplayName','BSM')
plot(strikes,put2,'DisplayName','MJD Exact')
plot(strikes,put2s,'DisplayName','MJD Simul')
plot(strikes,put3,'DisplayName','RS')
plot(strikes,put_actual,'DisplayName','Market')
legend('Location','northwest')
hold off
toc