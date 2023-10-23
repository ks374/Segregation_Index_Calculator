classdef Background_reduction
    %A method class used to reduct background of dLGN for R overlapping
    %calculation. 
    % Note: will not perform background reduction if the radius <= 0. 
    
    properties
        Img_name;
        Img_red;
        Img_green;
        Avg_map_red;
        Avg_map_green
        Filter_size;
        Reduced_img_red;
        Reduced_img_green;
    end
    
    methods
        function obj = Background_reduction(inpath,Img_name,contra_channel,ipsi_channel)
            %Initialize the class by read the image stack. 
            Img = imread([inpath,Img_name]);
            obj.Img_red = Img(:,:,contra_channel);
            obj.Img_green = Img(:,:,ipsi_channel);
            obj.Img_name = Img_name;
        end
        
        function obj = Avg_map_cal(obj,radius)
            %Reduce the background based on the defined radius
            %   Detailed explanation goes here
            
            obj.Avg_map_red = zeros(size(obj.Img_red,1),size(obj.Img_red,2),'uint8');
            obj.Avg_map_green = zeros(size(obj.Img_green,1),size(obj.Img_green,2),'uint8');
            disp("Applying average filter...")
            if radius > 0
                H = fspecial('disk',radius);
                obj.Avg_map_red = imfilter(obj.Img_red,H,'replicate');
                obj.Avg_map_green = imfilter(obj.Img_green,H,'replicate');
                obj.Filter_size = radius;
            else
                obj.Filter_size = radius;
            end
        end
        
        function obj = Apply_reduction(obj)
            obj.Reduced_img_red = abs(obj.Img_red - obj.Avg_map_red);
            obj.Reduced_img_green = abs(obj.Img_green - obj.Avg_map_green);
        end
        
        function check_Img_red(obj)
            figure;imshow(obj.Img_red);
            title("Original Image");
            if size(obj.Avg_map_red,1) >0
                figure;imshow(obj.Avg_map_red);
                title(["Average Filter " num2str(obj.Filter_size)]);
            end
            if size(obj.Reduced_img_red,1) >0
                figure;imshow(obj.Reduced_img_red);
                title(["Subtracted image" num2str(obj.Filter_size)]);
            end
        end
        
        function check_Img_green(obj)
            figure;imshow(obj.Img_green);
            title("Original Image");
            if size(obj.Avg_map_green,1) >0
                figure;imshow(obj.Avg_map_green);
                title(["Average Filter " num2str(obj.Filter_size)]);
            end
            if size(obj.Reduced_img_green,1) >0
                figure;imshow(obj.Reduced_img_green);
                title(["Subtracted image" num2str(obj.Filter_size)]);
            end
        end
        
        function Write_Img(obj,output_path)
            %Images are written as "Img_name_xxx_color_radius.tif"
            imwrite(obj.Img_red,[output_path obj.Img_name '_original_red.tif']);
            if size(obj.Avg_map_red,1) >0
                imwrite(obj.Avg_map_red,[output_path obj.Img_name '_AverageFilter_red_' num2str(obj.Filter_size) '.tif']);
            end
            if size(obj.Reduced_img_red,1) >0
                imwrite(obj.Reduced_img_red,[output_path obj.Img_name '_Reduced_red_' num2str(obj.Filter_size) '.tif']);
            end
            imwrite(obj.Img_green,[output_path obj.Img_name '_original_green.tif']);
            if size(obj.Avg_map_green,1) >0
                imwrite(obj.Avg_map_green,[output_path obj.Img_name '_AverageFilter_green_' num2str(obj.Filter_size) '.tif']);
            end
            if size(obj.Reduced_img_green,1) >0
                imwrite(obj.Reduced_img_green,[output_path obj.Img_name '_Reduced_green_' num2str(obj.Filter_size) '.tif']);
            end
            disp("Done write images. ")
            disp("Done write images. ")
        end
    end
end

