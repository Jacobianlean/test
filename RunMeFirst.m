% Importations, current path: root of script.m
addpath('ncpd_algos/') % algorithms for NNCPD
addpath('utils/')
addpath('utils_result/')
%addpath('data/')

% Set interpreter as latex
set(groot,'defaultAxesTickLabelInterpreter','latex'); 
set(groot,'defaultLegendInterpreter','latex');

% Set default figure colormap as gray
set(groot,'DefaultFigureColormap',gray)
set(0,'DefaultFigureColormap',feval('gray'));

% reset Random number generator
rng('shuffle');
%%
clear all, close all, clc