input_path = 'D:\Reaearch\Projects\Project_18_ET33 axon labeling\Data\20230931_Tigre_Conv\';
file_name = 'Control_Left.tif';
output_path = 'D:\Reaearch\Projects\Project_18_ET33 axon labeling\Data\20230931_Tigre_Conv\Output\';
if ~exist(out_path,'dir')
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
%
input_path_2 = output_path;
IP = Img_processer(input_path_2,file_name,radius);
IP = IP.select();
IP = IP.normalize;
%
dLGN_pixlist = IP.get_in_pixel(1);
contra_pixlist = IP.get_in_pixel(2);
ipsi_pixlist = IP.get_in_pixel(3);
%
dLGN_value = IP.log_cal(dLGN_pixlist);
contra_value = IP.log_cal(contra_pixlist);
ipsi_value = IP.log_cal(ipsi_pixlist);
%%
F = Fitter(dLGN_value,contra_value,ipsi_value);
F = F.check_histogram(output_path);
%
F = F.Fit_one_peak;
F = F.Fit_two_peak;
F = F.get_fit_curve(output_path);
%%
F = F.get_segregate_index;
save([output_path,'F.mat'],'F');