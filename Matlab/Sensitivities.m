%% CoRaDyn Sensitivities
clear; clc; close all;

b = [-10:0.2:20];
% b = [-2:0.02:2];

%% bP
data = readtable('bP_15.txt');
s_t15 = data.Var1;
data = readtable('bP_50.txt');
s_t50 = data.Var1;
data = readtable('bP_250.txt');
s_t250 = data.Var1;
clear data;

h15 = hist(s_t15,b);
h50 = hist(s_t50,b);
h250 = hist(s_t250,b);
h15 = h15/sum(h15);
h50 = h50/sum(h50);
h250 = h250/sum(h250);

figure();
hold on;
% plot(b,h15,'LineWidth',2,'DisplayName','\beta_P t_n=15')
% plot(b,h50,'LineWidth',2,'DisplayName','\beta_P t_n=50')
plot(b,h250,'LineWidth',2,'DisplayName','\beta_P t_n=250')

%% bD
data = readtable('bD_15.txt');
s_t15 = data.Var1;
data = readtable('bD_50.txt');
s_t50 = data.Var1;
data = readtable('bD_250.txt');
s_t250 = data.Var1;
clear data;

h15 = hist(s_t15,b);
h50 = hist(s_t50,b);
h250 = hist(s_t250,b);
h15 = h15/sum(h15);
h50 = h50/sum(h50);
h250 = h250/sum(h250);

%figure();
hold on;
% plot(b,h15,'LineWidth',2,'LineStyle','--','DisplayName','\beta_D t_n=15')
% plot(b,h50,'LineWidth',2,'LineStyle','--','DisplayName','\beta_D t_n=50')
plot(b,h250,'LineWidth',2,'LineStyle','--','DisplayName','\beta_D t_n=250')
