function [] = ShowProgress(OptParm, Grid, Pattern, iter, MaxIterations, AbsoluteEfficiency, RelativeEfficiency, Figs)
    Display = OptParm.Display;
    if isfield(Figs, 'FigGeo')
        FigGeo = Figs.FigGeo;
    end
    if Display.PlotGeometry % Plot geometry
        set(groot,'CurrentFigure',FigGeo);
        imagesc(Grid{1}, Grid{2},Pattern'); colorbar; daspect([1 1 1]);
        drawnow; 
    end
    
    if Display.ShowText % Print efficiencies
        if (size(AbsoluteEfficiency,2)==1) && (size(AbsoluteEfficiency,3)==2)
            fprintf('Iteration: %d of %d \n',iter,MaxIterations);
            disp([sprintf('Absolute Efficiencies (TE,TM): '),sprintf('%.4f   ',AbsoluteEfficiency(iter,1,:))]);
            disp([sprintf('Relative Efficiencies (TE,TM): '),sprintf('%.4f   ',RelativeEfficiency(iter,1,:))]);
        elseif (size(AbsoluteEfficiency,2)==1) && (size(AbsoluteEfficiency,3)==1)
            fprintf('Iteration: %d of %d \n',iter,MaxIterations);
            disp([sprintf('Absolute Efficiencies: '),sprintf('%.4f   ',AbsoluteEfficiency(iter,1))]);
            disp([sprintf('Relative Efficiencies: '),sprintf('%.4f   ',RelativeEfficiency(iter,1))]);
        else
            fprintf('Iteration: %d of %d \n',iter,MaxIterations);
            disp([sprintf('Absolute Efficiencies: '),sprintf('%.4f   ',mean(AbsoluteEfficiency(iter,:,:),3))]);
            disp([sprintf('Relative Efficiencies: '),sprintf('%.4f   ',mean(RelativeEfficiency(iter,:,:),3))]);
        end
    end
    
    % Plot efficiency trend over optimziation
    if isfield(Figs, 'FigEff')
        FigEff = Figs.FigEff;
    end
    if Display.PlotEfficiency
        set(groot, 'CurrentFigure', FigEff);
        if iter>1
            plot(1:iter, [mean(AbsoluteEfficiency(1:iter,:,:),3)'], 'linewidth',2)
            legend(cellstr(num2str(OptParm.Optimization.Robustness.EndDeviation')))
            xlabel('Iteration')
            ylabel('Absolute Efficiency')
            set(gca, 'linewidth',2, 'fontsize', 20);
            drawnow
        end
    end
    
end