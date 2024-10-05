% Alberto Dominguez - UWF MAT 6903 Mathematics Research 1 
% This program generated the results for Model 2 of the paper
% Version History:
%   2024-10-04 initial code

clear
clc
close all
tic

% model parameters
sigma = 0.189205;  % volatility of underlying
a = 0.077629;      % physical return on the underlying
r = 0.039;         % 1 Yr Treas Rate on 9/20/2024 was 3.90%
mu = 0.0035;       % jump size mean
sigJ = 0.0854;     % jump size standard deviation

% option parameters
S0 = 5700;         % index on 9/20/2024 was 5702.55
T = 1;             % time to expiry = 1 year

% graph parameters
lo = S0 - 1500;
hi = S0 + 1500;
strike_step = 10;
N = (hi - lo)/strike_step + 1;          
strikes = lo:strike_step:hi;

% calculate and plot call prices
call(N) = 0;
figure(1)
hold on
title('Model 2 with S0 = 5700 / Effect of Increasing Jump Intensity')
xlabel('Strike Price') 
ylabel('Call Option Value')
for lam = 0:0.1:0.7
    str = lo;
    for i = 1:N
        call(i) = MJD(S0,T,str,sigma,r,lam,mu,sigJ,false);
        str = str + strike_step;
    end
    leg = "λ=" + lam;
    plot(strikes,call,'DisplayName',leg)
end
lgd = legend;
lgd.NumColumns = 2;
set(lgd, 'Location', 'Best')
hold off

% calculate and plot put prices
figure(2)
put(N) = 0;
hold on
title('Model 2 with S0 = 5700 / Effect of Increasing Jump Intensity')
xlabel('Strike Price') 
ylabel('Put Option Value')
for lam = 0:0.1:0.7
    str = lo;
    for i = 1:N
        put(i) = MJD(S0,T,str,sigma,r,lam,mu,sigJ,true);
        str = str + strike_step;
    end
    leg = "λ=" + lam;
    plot(strikes,put,'DisplayName',leg)
end
lgd = legend;
lgd.NumColumns = 2;
set(lgd, 'Location', 'Best')
hold off

toc