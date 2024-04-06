clear;clc
input_path = 'D:\Reaearch\Projects\Project_18_ET33 axon labeling\Data\20230931_Tigre_Conv_Conv_method\Segregation_Index_Calculator\Image_Example\Input\';
%file_name = 'Control_Left.tif';
%filename_list = {'Control_right.tif','Epi_left.tif','Epi_right.tif'};
filename_list = {'Control_left.tif','Control_right.tif','Epi_left.tif','Epi_right.tif'};
% filename_list = ['Epi_right.tif'];
F_list = [];
for i = 1:numel(filename_list)
    file_name = filename_list{i};
    temp_name = split(file_name,'.');
    output_path = [input_path 'output_' temp_name{1} '\'];
    if ~exist(output_path,'dir')
        mkdir(output_path);
    end
    radius = 0;

    CL = Background_reduction(input_path,file_name,3,2);
    CL = CL.Avg_map_cal(radius);
    % %%
    % CL.check_Img_red;
    % CL.check_Img_green;
    %
    CL = CL.Apply_reduction;
    CL.Write_Img(output_path);

    input_path_2 = output_path;
    IP = Img_processer(input_path_2,file_name,radius);
    IP = IP.normalize;
    %
    IP = IP.select();
    %
    dLGN_pixlist = IP.get_in_pixel(1);
    contra_pixlist = IP.get_in_pixel(2);
    ipsi_pixlist = IP.get_in_pixel(3);
    %
    dLGN_value = IP.log_cal(dLGN_pixlist);
    contra_value = IP.log_cal(contra_pixlist);
    ipsi_value = IP.log_cal(ipsi_pixlist);
    %
    F = Fitter(temp_name{1},dLGN_value,contra_value,ipsi_value);
%     F = F.delete_zeros;
    F = F.check_histogram(output_path);
    %
    F = F.Fit_one_peak;
    F = F.Fit_two_peak;
    F = F.get_fit_curve(output_path);
    %
    F = F.get_segregate_index;
    F = F.get_variance;
    F = F.get_variance_norm;
    
    F_list = [F_list,F];
    save([output_path,'F.mat'],'F');
    
end
disp('Process done');
%%
%Move the output folders to Output_*
outpath = [input_path 'Output_6\'];
FL = F_list_plotter(F_list);
FL = FL.get_hist_orig(outpath);
FL = FL.hist_align;
FL = FL.get_hist_fit(outpath);
FL = FL.get_hist(outpath);