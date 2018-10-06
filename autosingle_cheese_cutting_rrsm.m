% RRSM-IMPLICIT SPACE MAPPING ALGORITHM
% SINGLE-CHEESE CUTTER ILLUSTRATION
%% House keeping
clc; close all;
clearvars;

%% Inits
% desired fine model volume response
Raim = 80;
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
% surrogate coarse model
R_s = Rsurrogate([l_c, w_c],dR);
% display
fprintf('\nIteration.%g\n', 0)
fprintf('l:%g\n', l_c)
fprintf('w:%g\n', w_c)
fprintf('R_s: %g\n',R_s)
fprintf('R_f: %g\n',R_f)
fprintf('Fine aim: %g\n',Raim)


itTab = [];% store parameters per iteration
chck = norm(Raim - R_f); % [] store error
itTab = [itTab; [0 dR l_c w_c R_s R_f (chck*100)/Raim]];
Rf = R_f; % [] store fine model response
id = 1; 
while norm(Raim - R_f) > 1e-6
    %% Prediction -> PE length
    l_c = optism_sug(Raim,[l_c,w_c],dR);
    l_f = l_c;
    %% Verification/ Evaluation
    % coarse model
    R_c = Rcoarse([l_c,w_c]);
    % fine model
    R_f = Rfine([l_f,w_f]);
    Rf = [Rf R_f];
    % residual
    dR = R_f - R_c;
    R_s = Rsurrogate([l_c, w_c],dR);
    % display
    fprintf('\nIteration.%g\n', id)
    fprintf('l:%g\n', l_c)
    fprintf('w:%g\n', w_c)
    fprintf('R_s: %g\n',R_s)
    fprintf('R_f: %g\n',R_f)
    fprintf('Fine aim: %g\n',Raim)
  
    %% Iterate
    chck = [chck norm(Raim - R_f)]; %#ok<*AGROW>
    itTab = [itTab; [id dR l_c w_c R_s R_f (chck(id+1)*100)/Raim]];
    if (id >= 2)
        if abs(chck(id) - chck(id-1)) <= 1e-6
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
title('Single Cheese Cutter: Response-Residual Space Mapping Optimization',...
    'FontSize',10,'Interpreter','latex')
% subplot 2
subplot(212)
plot(Rf,'-.ok','LineWidth',1.25)
grid on;
xlabel('Iteration','Interpreter','latex')
ylabel('$$R_{f}$$',...
    'FontSize',12,'Interpreter','latex')
title('Single Cheese Cutter: Fine-Model RRSM Response',...
    'FontSize',10,'Interpreter','latex')
