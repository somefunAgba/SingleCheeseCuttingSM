% IMPLICIT SPACE MAPPING ALGORITHM
% SINGLE-CHEESE CUTTER ILLUSTRATION
%% House keeping
clc; close all;
clearvars;

%% Inits

% desired fine model volume response
Raim = 30;
% candidate designable parameters
% initial guess; length and width
w_c = 3;
l = 1;
l_c = optism_coarse(Raim,[l,w_c]);
% l_c = 10;
l_f = l_c; w_f = w_c;


%% Initial Model Guess
%coarse model
R_c = Rcoarse([l_c, w_c]);
%fine model
R_f = Rfine([l_f, w_f]);
% display
fprintf('l:%g\n', l_c)
fprintf('w:%g\n', w_c)
fprintf('R_c: %g\n',R_c)
fprintf('R_f: %g\n',R_f)
fprintf('Fine aim: %g\n',Raim)

id = 1; 
chck = norm(Raim - R_f); % [] store error
Rf = R_f; % [] store fine model response
itTab = []; % store parameters per iteration
while norm(Raim - R_f) > 1e-6
    %% Parameter Extraction -> width
    rng default % For reproducibility
    fun_x = @(x)norm(R_f-Rcoarse([l_c, w_c+x])); % cost function
    % options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton')
    % options = optimoptions(@simulannealbnd, 'HybridFcn', 'fminunc')
    % options = optimoptions(@particleswarm, 'SwarmSize',64,'HybridFcn', @fminsearch)
    % fminsearch - derivative free- simplex method.
    x = fminsearch(fun_x,1); % alternative: fminunc, but slower convergence
    %
    w_c = w_c+x;
    %% Verification 1
    % coarse model
    R_c = Rcoarse([l_c,w_c]);
    % fine model
    R_f = Rfine([l_f,w_f]);
    % display
    fprintf('\nIteration.%g\n', id)
    fprintf('q1: %g\n',x)
    fprintf('l:%g\n', l_c)
    fprintf('w:%g\n', w_c)
    fprintf('R_c: %g\n',R_c)
    fprintf('R_f: %g\n',R_f)
    fprintf('Fine aim: %g\n',Raim)
    itTab= [itTab; [id x l_c w_c R_c R_f (chck(id)*100/Raim)]];
    %% Prediction -> PE length
    l_c = optism_coarse(Raim,[l_c,w_c]);
    l_f = l_c;
    %% Verification 2
    % coarse model
    R_c = Rcoarse([l_c,w_c]);
    % fine model
    R_f = Rfine([l_f,w_f]);
    Rf = [Rf R_f];
    % display
    fprintf('l:%g\n', l_c)
    fprintf('w:%g\n', w_c)
    fprintf('R_c: %g\n',R_c)
    fprintf('R_f: %g\n',R_f)
    fprintf('Fine aim: %g\n',Raim)
  
    %% Iterate
    chck = [chck norm(Raim - R_f)]; %#ok<*AGROW>  
    itTab = [itTab; [id x l_c w_c R_c R_f (chck(id+1)*100)/Raim]];
    id = id + 1;
end
fprintf('Fine Model Parameters are: l=%g, w=%g, h=%g, volume=%g\n',...
    l_f,w_f,1,R_f)

%% Visualization
figure(1);
% subplot 1
subplot(211)
plot(chck,'-.sr','LineWidth',1.25)
grid on;
xlabel('Iteration','Interpreter','latex')
ylabel('Error, $$||R_{f}-{R_{f}}^{\ast}||$$',...
    'FontSize',12,'Interpreter','latex')
title('Single Cheese Cutter: Implicit Space Mapping Optimization',...
    'FontSize',10,'Interpreter','latex')
% subplot 2
subplot(212)
plot(Rf,'-.ok','LineWidth',1.25)
grid on;
xlabel('Iteration','Interpreter','latex')
ylabel('$$R_{f}$$',...
    'FontSize',12,'Interpreter','latex')
title('Single Cheese Cutter: Fine-Model Response',...
    'FontSize',10,'Interpreter','latex')
