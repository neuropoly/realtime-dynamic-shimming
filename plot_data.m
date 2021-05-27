
dir_list = dir('nifti');
dir_list=dir_list(~ismember({dir_list.name},{'.','..'}));


for k = 1:size(dir_list,1)
    fname = dir(['nifti/',dir_list(k).name,'/*NOSHIM*run1*.csv']);
    NOshim = readtable(fullfile(fname.folder, fname.name));
    fname = dir(['nifti/',dir_list(k).name,'/*staticzSHIM*run1*.csv']);
    STATICzshim_run1 = readtable(fullfile(fname.folder, fname.name));
    fname = dir(['nifti/',dir_list(k).name,'/*staticzSHIM*run2*.csv']);
    STATICzshim_run2 = readtable(fullfile(fname.folder, fname.name));
    fname = dir(['nifti/',dir_list(k).name,'/*staticzSHIM*run3*.csv']);
    STATICzshim_run3 = readtable(fullfile(fname.folder, fname.name));
    fname = dir(['nifti/',dir_list(k).name,'/*rtSHIM*run1*.csv']);
    rtshim_run1 = readtable(fullfile(fname.folder, fname.name));
    fname = dir(['nifti/',dir_list(k).name,'/*rtSHIM*run2*.csv']);
    rtshim_run2 = readtable(fullfile(fname.folder, fname.name));
    fname = dir(['nifti/',dir_list(k).name,'/*rtSHIM*run3*.csv']);
    rtshim_run3 = readtable(fullfile(fname.folder, fname.name));

    for i = 1:size(NOshim,1)
        mean_STATICzshim(i) = mean([STATICzshim_run1.WA__(i), STATICzshim_run2.WA__(i), STATICzshim_run3.WA__(i)]);
    end
    mean_STATICzshim = mean_STATICzshim';

    for i = 1:size(NOshim,1)
        mean_rtshim(i) = mean([rtshim_run1.WA__(i), rtshim_run2.WA__(i), rtshim_run3.WA__(i)]);
    end
    mean_rtshim = mean_rtshim';


    marker = {'-o';'-x';'-s';'-d';'-*';'-+'};
    % TODO: get number of slices automatically
    n_slices = 12;
    nTE = size(NOshim.WA__,1)/n_slices;
    
    figure1 = figure; hold on; j=1;    
    for i = 1:n_slices:size(NOshim,1)
        
        NOshim_std_across_slices(j) = std(NOshim.WA__(i:i+n_slices-1));
        mean_STATICzshim_std_across_slices(j) = std(mean_STATICzshim(i:i+n_slices-1));
        mean_rtshim_std_across_slices(j) = std(mean_rtshim(i:i+n_slices-1));
        
        subplot(nTE,1,j); 
        hold on;
        
        plot(100*NOshim.WA__(i:i+n_slices-1)./mean(NOshim.WA__(i:i+n_slices-1)),char(marker(j)),'Color','b', 'MarkerFaceColor', 'b')
        plot(100*mean_STATICzshim(i:i+n_slices-1)./mean(mean_STATICzshim(i:i+n_slices-1)),char(marker(j)),'Color','r', 'MarkerFaceColor', 'r')
        plot(100*mean_rtshim(i:i+n_slices-1)./mean(mean_rtshim(i:i+n_slices-1)),char(marker(j)),'Color','g', 'MarkerFaceColor', 'g')
        
        ylimits = ylim;
        ymax = ylimits(2);
        text(0, ymax, ['no shim std = ',num2str(NOshim_std_across_slices(j))]);
        text(0, 0.9*ymax, ['static z-shim std = ',num2str(mean_STATICzshim_std_across_slices(j))]);
        text(0, 0.8*ymax, ['rt shim std = ',num2str(mean_rtshim_std_across_slices(j))]);
        
        title(strcat('TE',num2str(j)));
        xlabel('slice number');
        ylabel('% of mean across slices');
        hold off;
        j=(j+1); 
    end
    legend('no shim','static z-shim', 'rt shim');
    saveas(figure1, ['fig1_',char(dir_list(k).name),'.fig'])
   
    
    figure2 = figure; hold on;    
    for i = 1:n_slices
        subplot(6,2,i); 
        hold on;
        plot(100*NOshim.WA__(i:n_slices:end)./NOshim.WA__(i),'-o','Color','b', 'MarkerFaceColor', 'b')
        plot(100*mean_STATICzshim(i:n_slices:end)./mean_STATICzshim(i),'-x','Color','r', 'MarkerFaceColor', 'r')
        plot(100*mean_rtshim(i:n_slices:end)./mean_rtshim(i),'-s','Color','g', 'MarkerFaceColor', 'g')
        title(strcat('slice',num2str(i)));
        xlabel('echo number');
        ylabel('signal normalized to TE1');
        hold off; 
    end
    legend('no shim','static z-shim', 'rt shim');
    %sgtitle('Signal decay vs. echo number for slices 1 - 12'); 
    saveas(figure2, ['fig2_',char(dir_list(k).name),'.fig'])

end