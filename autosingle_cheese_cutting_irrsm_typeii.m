% IMPLICIT-RESPONSE RESIDUAL- SPACE MAPPING, I-RRSM-T2 ALGORITHM
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

%% Initial Surrogate
% coarse model
R_c = Rcoarse([l_c, w_c]);
% fine model
R_f = Rfine([l_f, w_f]);
% Residual
dR = R_f - R_c;
% R_s = R_c + dR;
R_s = Rsurrogate([l_c, w_c],dR);

% display
fprintf('\nIteration.%g\n', 0)
fprintf('l:%g\n', l_c)
fprintf('w:%g\n', w_c)
fprintf('R_c: %g\n',R_c)
fprintf('R_f: %g\n',R_f)
fprintf('Fine aim: %g\n',Raim)

itTab = [];  % store parameters per iteration
chck = norm(Raim - R_f); % [] store error
itTab = [itTab; [0 0 dR l_c w_c R_c R_s R_f (chck*100)/Raim]];
Rf = R_f; % [] store fine model response
id = 1;
while chck > 1e-6
    %% Parameter Extraction -> width
    fun_x = @(x)norm(R_f-(Rcoarse([l_c, w_c+x]))); % cost function
    x = fminsearch(fun_x,1); % alternative: fminunc, but slower convergence
    %
    w_c = w_c+x;
     
    %% Verification 1
    % coarse model
    R_c = Rcoarse([l_c,w_c]); 
    Rsurrogate([l_c, w_c],dR);
    % fine model
    R_f = Rfine([l_f,w_f]);
    % display
    fprintf('\nIteration.%g\n', id)
    fprintf('q1: %g\n',x)
    fprintf('l:%g\n', l_c)
    fprintf('w:%g\n', w_c)
    fprintf('R_c: %g\n',R_c)
    fprintf('R_s: %g\n',R_s)
    fprintf('R_f: %g\n',R_f)
    fprintf('Fine aim: %g\n',Raim)
    itTab= [itTab; [id x dR l_c w_c R_c R_s R_f (chck(id)*100/Raim)]];
    %% Prediction -> PE length
    l_c = optism_sug(Raim,[l_c,w_c],dR);
    l_f = l_c;
    %% Verification 2
    % coarse model
    R_c = Rcoarse([l_c,w_c]);
    Rsurrogate([l_c, w_c],dR);
    % fine model
    R_f = Rfine([l_f,w_f]);
    Rf = [Rf R_f];
    % display
    fprintf('l:%g\n', l_c)
    fprintf('w:%g\n', w_c)
    fprintf('R_s: %g\n',R_s)
    fprintf('R_c: %g\n',R_c)
    fprintf('R_f: %g\n',R_f)
    fprintf('Fine aim: %g\n',Raim)
  
    %% Iterate
    dR = R_f - R_c;
    chck = [chck norm(Raim - R_f)]; %#ok<*AGROW>  
    itTab = [itTab; [id x dR l_c w_c R_s R_c R_f (chck(id+1)*100)/Raim]];
    if (id >= 2)
        if abs(chck(id) - chck(id-1)) <= 1e-8
            break;
        end
    end
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
title('Single Cheese Cutter: Implicit Response Residual Space Mapping Optimization-Type2',...
    'FontSize',10,'Interpreter','latex')
axis([1,inf,min(chck)-0.01,inf])
% subplot 2
subplot(212)
plot(Rf,'-.ok','LineWidth',1.25)
grid on;
xlabel('Iteration','Interpreter','latex')
ylabel('$$R_{f}$$',...
    'FontSize',12,'Interpreter','latex')
title('Single Cheese Cutter: Fine-Model Response',...
    'FontSize',10,'Interpreter','latex')
axis([1,inf,min(Rf)-0.01,inf])
