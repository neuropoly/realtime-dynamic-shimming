
dir_list = dir('nifti');
dir_list=dir_list(~ismember({dir_list.name},{'.','..'}));


for k = 1:size(dir_list,1)
    fname = dir('nifti/acdc_135_high_res/*NOSHIM*run1*.csv')
    NOshim = readtable(fullfile(fname.folder, fname.name));
    fname = dir('nifti/acdc_135_high_res/*staticzSHIM*run1*.csv')
    STATICzshim_run1 = readtable(fullfile(fname.folder, fname.name));
    fname = dir('nifti/acdc_135_high_res/*staticzSHIM*run2*.csv')
    STATICzshim_run2 = readtable(fullfile(fname.folder, fname.name));
    fname = dir('nifti/acdc_135_high_res/*staticzSHIM*run3*.csv')
    STATICzshim_run3 = readtable(fullfile(fname.folder, fname.name));
    fname = dir('nifti/acdc_135_high_res/*rtSHIM*run1*.csv')
    rtshim_run1 = readtable(fullfile(fname.folder, fname.name));
    fname = dir('nifti/acdc_135_high_res/*rtSHIM*run2*.csv')
    rtshim_run2 = readtable(fullfile(fname.folder, fname.name));
    fname = dir('nifti/acdc_135_high_res/*rtSHIM*run3*.csv')
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
    nTE = size(NOshim.WA__,1)/12;
    
    figure1 = figure; hold on; j=1;
    for i = 1:12:size(NOshim,1)
        subplot(nTE,1,j); 
        hold on;
        plot(NOshim.WA__(i:i+11),char(marker(j)),'Color','b', 'MarkerFaceColor', 'b')
        plot(mean_STATICzshim(i:i+11),char(marker(j)),'Color','r', 'MarkerFaceColor', 'r')
        plot(mean_rtshim(i:i+11),char(marker(j)),'Color','g', 'MarkerFaceColor', 'g')
        title(strcat('TE',num2str(j)));
        xlabel('slice number');
        ylabel('signal [arb]');
        hold off;
        j=(j+1);
    end
    legend('no shim','static z-shim', 'rt shim');
    saveas(figure1, ['fig1_',char(dir_list(k).name),'.fig'])
   
    
    figure2 = figure; hold on;    
    for i = 1:12
        subplot(6,2,i); 
        hold on;
        plot(NOshim.WA__(i:12:end),'-o','Color','b', 'MarkerFaceColor', 'b')
        plot(mean_STATICzshim(i:12:end),'-x','Color','r', 'MarkerFaceColor', 'r')
        plot(mean_rtshim(i:12:end),'-s','Color','g', 'MarkerFaceColor', 'g')
        title(strcat('slice',num2str(i)));
        xlabel('echo number');
        ylabel('signal [arb]');
        hold off;
    end
    legend('no shim','static z-shim', 'rt shim');
    %sgtitle('Signal decay vs. echo number for slices 1 - 12'); 
    saveas(figure2, ['fig2_',char(dir_list(k).name),'.fig'])

end