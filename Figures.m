%%              CoRa Dynamics ANALYSIS              %%
%%% DATA: Import output files from CoRaDyn_Main.jl %%%
%%%       to Matlab to generate figures.           %%%
% Mariana Gómez-Schiavon
% November, 2020

clear;
sim.mm = 'ATFv1';       % Label for motif file
sim.ex = 'Ex01';        % Label for parameters file
sim.pp = 'mY';          % Label for perturbation type
sim.ax = 'mY';          % Label for condition/range
sim.an = 'msDyn';       % Chose analysis type (Options: ExDyn, msDyn)

%% Load & parse data
x = importdata(cat(2,'OUT_',sim.an,'_',sim.mm,'_',sim.ex,'_',sim.pp,'_',sim.ax,'.txt'),'\t',1);
if(strcmp(sim.an,'ExDyn'))
    t    = x.data(:,1);
    Yf   = x.data(:,2);
    Yn   = x.data(:,3);
    CoRa = x.data(:,4);
    clear x
    
    tSS = length(t) - max(sum([abs(Yf-Yf(end))/Yf(end)<1e-8]),sum([abs(Yn-Yn(end))/Yn(end)<1e-8]));
    tSS = t(tSS);
    
    fig = figure();
    fig.Units = 'inches';
    fig.PaperPosition = [2 1 3 4.5];
    fig.Position = fig.PaperPosition;
    subplot(2,1,1)
    hold on;
        plot(t,Yf,'LineWidth',2,'Color',[1 0.6 0.78])
        plot(t,Yn,'LineWidth',2,'LineStyle','--','Color',[0 0 0])
        plot([tSS,tSS],[Yf(end),Yn(end)],...
            'LineStyle','none','Marker','.','MarkerSize',12,...
            'Color',[0.6 0.6 0.6])
            xlabel('Time (min)')
            xlim([0 tSS])
            ylabel('Output')
            title(cat(2,'CoRa_{\mu_Y\in\Theta}(\mu_Y)=',...
                num2str(log10(Yf(end)/Yf(1))/log10(Yn(end)/Yn(1)),2)))
            set(gca,'YTick','','YMinorTick','Off')
            set(gca,'YScale','log','XGrid','on','YGrid','on')
            box on
    subplot(2,1,2)
    hold on;
        plot(t,CoRa,'LineWidth',2,'Color',[1 0.6 0.78])
        plot(tSS,CoRa(end),...
            'LineStyle','none','Marker','.','MarkerSize',12,...
            'Color',[0.6 0.6 0.6])
            xlabel('Time (min)')
            xlim([0 tSS])
            ylim([0 1])
            ylabel('Dynamic CoRa')
            set(gca,'XGrid','on','YGrid','on')
            box on
elseif(strcmp(sim.an,'msDyn'))
    theta = x.data(:,1);
    t     = x.data(:,2);
    Yf    = x.data(:,3);
    Yn    = x.data(:,4);
    CoRa  = x.data(:,5);
    clear x
    
    fig = figure();
    fig.Units = 'inches';
    fig.PaperPosition = [2 1 3 2.5];
    fig.Position = fig.PaperPosition;
    hold on;
        plot(t,CoRa,...
            'LineStyle','none','Marker','.','MarkerSize',3,...
            'Color',[0.6 0.6 0.6])
        plot(t([CoRa<0]),CoRa([CoRa<0]),...
            'LineStyle','none','Marker','.','MarkerSize',3,...
            'Color','r')
            xlabel('Time (min)')
            ylim([-0.1 1])
            ylabel('Dynamic CoRa')
            set(gca,'XGrid','on','YGrid','on')
            box on
else
    'ERROR: Undetermined analysis. Options: ExDyn'
end
print(gcf,cat(2,'RAW_',sim.an,'_',sim.mm,'_',sim.ex,'_',sim.pp,'_',sim.ax),'-dpng','-r300')

%% END