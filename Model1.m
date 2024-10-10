% Alberto Dominguez - UWF MAT 6903 Mathematics Research 1 
% This program generated the results for Model 1 of the paper
% Version History:
%   2024-09-27 initial code

tic; clear; clc; close all

% model parameters
a = 0.077629;      % physical return on the underlying (not used)
sigma = 0.189205;  % volatility of underlying
r = 0.039;         % 1 Yr Treas Rate on 9/20/2024 was 3.90%

% option parameters
S0 = 5700;         % index on 9/20/2024 was 5702.55
T = 1;             % time to expiry = 1 year

% graph parameters
lo = S0 - 1500;
hi = S0 + 1500;
strike_step = 10;
N = (hi - lo)/strike_step + 1;          

% calculate the prices
call(N) = 0; put(N) = 0;
str = lo;
for i = 1:N
    call(i) = BSM(S0,T,str,sigma,r,false);
    put(i) =  BSM(S0,T,str,sigma,r,true);
    str = str + strike_step;
end

% plot the results
strikes = lo:strike_step:hi;
hold on
title('Model 1 with S0 = 5700')
xlabel('Strike Price') 
ylabel('Option Value')
plot(strikes,call,'DisplayName','Call')
plot(strikes,put,'DisplayName','Put')
legend
hold off
toc