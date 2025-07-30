function [beta,betamax,gamma,gamma_b,eta,projMode] = ini_her(opt)
% This code is written by Andersen Man Shun Ang.
% Initialization of HER parameters
% initial beta  
if isfield(opt,'beta')      beta = opt.beta;        
else                        beta = 0.8; % default 0.5
end
% initial beta max
if isfield(opt,'betamax')    betamax = opt.betamax;  
else                         betamax = 1; % default 1
end
% gamma (growth factor for beta)
if isfield(opt,'gamma')      gamma = opt.gamma;  
else                         gamma = 1.05; % default 1.05
end
% Gamma_b (growth factor for betamax)
if isfield(opt,'gamma_b')    gamma_b = opt.gamma_b;  
else                         gamma_b = 1.01;  % default 1.01
end
% Eta (decay factor for beta)
if isfield(opt,'eta')        eta = opt.eta;  
else                         eta = 1.5; % default 1.5
end
% Projection mode
if isfield(opt,'projMode')   projMode = opt.projMode; % > 1 means proj
else                         projMode = [1,1,1]; % default is all project
end
%% Error checking
if(eta<gamma || gamma<gamma_b)  error('Pick gammabar < gamma < eta'); end 
if(beta>1) && (beta<0)     error('beta must be in within [0,1]');end
end