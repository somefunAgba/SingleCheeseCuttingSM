function opt_lc = optism_sug(aim,xin,dr)
%OPTIMCOARSE Summary of this function goes here
%   optimize coarse model w.r.t the length parameter
if nargin < 3
    dr = 0;
end

if nargin == 0
    % test-values
    xin = [11 2 0.8473];
    aim = [10 10 10];
end

% cost
fun = @(l)abs((aim - Rsurrogate([l,xin(2)],dr)));
% numel fun
% Minimize absolute values
%% minimax method
options = optimoptions('fminimax','AbsoluteMaxObjectiveCount',numel(fun));
opt_lc = fminimax(fun,xin(1),[],[],[],[],[],[],[],options);

%% quasi-newton method
% opt_lc = fminunc(fun,xin(1));
%% simulatedannealing
% opt_lc = simulannealbnd(fun,xin(1),[],[]);
%% pso
% opt_lc = particleswarm(fun,1,[],[]);

end

