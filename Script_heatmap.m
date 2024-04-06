clear;clc
base_path = 'D:\Reaearch\Projects\Project_18_ET33 axon labeling\Data\20230931_Tigre_Conv_Conv_method\Segregation_Index_Calculator\Image_Example\';
input_path = [base_path 'Input\'];
output_path = [base_path 'Output\'];
file_name = 'Control_left.tif';
radius = 0;

CL = Background_reduction(input_path,file_name,3,2);
CL = CL.Avg_map_cal(radius);
%
%CL.check_Img_green;
CL = CL.Apply_reduction;
CL.Write_Img(output_path);
%
input_path_2 = output_path;
IP = Img_processer(input_path_2,file_name,radius);
IP = IP.normalize;
%%
IP = IP.select();
%%
IP.check_log_heatmap(0,'jet');
IP.check_log_heatmap(1,'jet');
IP.check_log_heatmap(1,'hot');