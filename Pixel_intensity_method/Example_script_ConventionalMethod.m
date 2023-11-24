clear;clc
input_path = 'D:\Reaearch\Projects\Project_18_ET33 axon labeling\Data\20230931_Tigre_Conv_Conv_method\Input_Images\';
output_path = 'D:\Reaearch\Projects\Project_18_ET33 axon labeling\Data\20230931_Tigre_Conv_Conv_method\';
filename_list = {'Control_Left.tif','Control_right.tif','Epi_left.tif','Epi_right.tif','Control_left_B.tif','Control_right_B.tif','Epi_left_B.tif','Epi_left_C.tif','Epi_left_D.tif','Epi_left_E.tif','Epi_left_F.tif','Epi_right_B.tif','Epi_right_C.tif','Epi_right_D.tif','Epi_right_E.tif','Epi_right_F.tif','Epi_right_G.tif','Epi_right_H.tif'};
%%
for i = 1:numel(filename_list)
    I = Conv_image(input_path,filename_list{i});
    I = I.normalize;
    I = I.select;
    I = I.get_in_pixel;
    I = I.Img_mask;
    
    I = I.get_pixlist(1);
    I = I.get_pixlist(2);
    I = I.find_peak_thre(1,40);
    input('Press any key to continue...');
    I = I.find_peak_thre(2,40);
    input('Press any key to continue...');
    
    I = I.pixel_area(1,output_path);
    input('Press any key to continue...');
    I = I.pixel_area(2,output_path);
    input('Press any key to continue...');
    I = I.pixel_overlap(output_path);
    input('Press any key to continue...');
    
    I.save_info(output_path);
end
%%
i=7;
disp(filename_list{i});
%%
I = Conv_image(input_path,filename_list{i});
I = I.normalize;
I = I.select;
I = I.get_in_pixel;
I = I.Img_mask;

I = I.get_pixlist(1);
I = I.get_pixlist(2);
I = I.find_peak_thre(1,40);
% input('Press any key to continue...');
I = I.find_peak_thre(2,40);
% input('Press any key to continue...');

I = I.pixel_area(1,output_path);
% input('Press any key to continue...');
I = I.pixel_area(2,output_path);
% input('Press any key to continue...');
I = I.pixel_overlap(output_path);
% input('Press any key to continue...');

I.save_info(output_path);
disp(['R ratio: ',num2str(I.Rratio),'.G ratio: ',num2str(I.Gratio),'.Overlapping: ',num2str(I.Oratio)]);
