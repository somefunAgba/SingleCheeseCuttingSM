% AGGRESSIVE-RESPONSE RESIDUAL SPACE MAPPING ALGORITHM
% SINGLE-CHEESE CUTTER ILLUSTRATION
%% House keeping
clc; close all;
clearvars;

%% Inits
% desired fine model volume response
Raim = 30;
% candidate designable parameters
% initial guess; length and width
w_c = 3; l = 1;
l_c = optism_coarse(Raim,[l,w_c]);
% l_c = 10;
l_f = l_c; w_f = w_c;

%% Initial Model Guess
%coarse model
R_c = Rcoarse([l_c, w_c]);
%fine model
R_f = Rfine([l_f, w_f]);
% display
fprintf('lc:%g\n', l_c)
fprintf('R_c: %g\n',R_c)
fprintf('lf:%g\n', l_f)
fprintf('R_f: %g\n',R_f)
fprintf('Fine aim: %g\n',Raim)

id = 1;

% Parameter Extraction -> new coarse length mapping
rng default % For reproducibility
fun_x = @(x)norm(R_f-Rcoarse([l_c+x, w_c])); % cost function
options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton');
x = fminunc(fun_x,1,options);
%
l = l_c + x;
f = l-l_c; % error vector
%
h = Inf;
% Mapping Jacobian
B = eye(1,1); % unit mapping
% init. surrogate and residual response
R_s = 0; dR = 0;
%
chck = norm(Raim - R_f); % [] store response error
Rf = R_f; % [] store fine model response
itTab = []; % store parameters per iteration
while norm(h) > 1e-4
    %% Prediction, Evaluate fine length
    % Inverse mapping of coarse length;
    h = -(f) ./ B; % quasi-newton step in fine space
    l_f = l_f + h; % update
    %% Verification
    % coarse model
    R_c = Rcoarse([l_c,w_c]);
    % fine model
    R_f = Rfine([l_f,w_f]);
    Rf = [Rf R_f];
    % save
    itTab= [itTab; [id f B h l_c R_c R_s l_f R_f (chck(id)*100/Raim)]];
    %% Next Iterate Prediction
    fun_x = @(x)norm( R_f - (Rsurrogate([l_c+x, w_c],dR) )); % cost function
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton');
    x = fminunc(fun_x,1,options); % alternative: fminunc, but slower convergence
    %
    l = l_c + x;
    f = l-l_c; % update error vector
    
    if norm(f) < 1e-4
        % update response residual
        dR = R_f - R_c;
        % optimise coarse length-> minimise surrogate
        l_c = optism_sug(Raim,[l_c,w_c],dR);
        f = l - l_c; % update error vector
        % Inverse mapping of coarse length;
        h = -(f) ./ B; % quasi-newton step in fine space
        l_f = l_f + h;
        %
        R_s = Rsurrogate([l_c, w_c],dR);
        B = eye(1,1); % constrain B to an identity mapping
    else
        % broyden rank-one update
        B = B + ((f.*h')/(h'.*h));
    end
    %
    % display
    fprintf('\nIteration.%g\n', id)
    fprintf('f: %g\n',f)
    fprintf('l:%g\n', l_c)
    fprintf('R_c: %g\n',R_c)
    fprintf('R_s: %g\n',R_s)
    fprintf('lf:%g\n', l_f)
    fprintf('R_f: %g\n',R_f)
    fprintf('Fine aim: %g\n',Raim)
    %
    chck = [chck norm(Raim - R_f)]; %#ok<*AGROW>
    % save
    itTab = [itTab; [id f B h l_c R_c R_s l_f R_f (chck(id)*100/Raim)]]; %#ok<*AGROW>
    id = id + 1;   
    % stop if limit cycle attractor reached.
    if (id >= 2)
        if abs(chck(id) - chck(id-1)) <= 1e-6
            break;
        end
    end
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
title('Single Cheese Cutter: Aggressive Space Mapping Optimization',...
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
