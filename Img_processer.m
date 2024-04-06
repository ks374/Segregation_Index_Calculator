classdef Img_processer
    %Calculate overlapping and positive ratio of CTB labeling within dLGN
    %   --
    
    properties
        Inpath;
        Img_name;
        SearchRadius;
        Img_red;
        Img_green;
        
        Img_rescale_red;
        Img_rescale_green;
        Img_rescale_both;
        
        Selection_map_contra;
        Selection_map_ipsi;
        dLGN_ROI;
        contra_ROI;
        ipsi_ROI;
    end
    
    methods
        function obj = Img_processer(input_path,filename,radius)
            obj.Inpath = input_path;
            obj.Img_name = filename;
            obj.SearchRadius = radius;
            obj.Img_red = imread([input_path filename '_Reduced_red_' num2str(radius) '.tif']);
            obj.Img_green = imread([input_path filename '_Reduced_green_' num2str(radius) '.tif']);
        end
        
        function obj = normalize(obj)
            %Normalize the image from 1 - 255
            obj.Img_rescale_red = rescale(obj.Img_red,1,255);
            obj.Img_rescale_red = uint8(obj.Img_rescale_red);
%             figure;imshow(obj.Img_red);title("Original_red");
%             figure;imshow(obj.Img_rescale_red);title("Rescaled_red");
            
            obj.Img_rescale_green = rescale(obj.Img_green,1,255);
            obj.Img_rescale_green = uint8(obj.Img_rescale_green);
%             figure;imshow(obj.Img_green);title("Original_green");
%             figure;imshow(obj.Img_rescale_green);title("Rescaled_green");
            
            empty_image = obj.Img_rescale_green - obj.Img_rescale_green;
            obj.Img_rescale_both = cat(3,empty_image,obj.Img_rescale_green,obj.Img_rescale_red);
        end
        
        function obj = select(obj,saturat)
            if nargin < 2
                saturat = 0.03;
            end
            A = obj.Img_rescale_both;
            A = imadjust(A,stretchlim(A,saturat));
            figure;imshow(A);
            disp("Select dLGN ROI...")
            currpoly=impoly;
            obj.dLGN_ROI = currpoly.getPosition;
            disp("ROI saved. ");
            close;
            disp("Select contra ROI...")
            figure;imshow(A);
            currpoly=impoly;
            obj.contra_ROI = currpoly.getPosition;
            disp("ROI saved. ");
            close;
            disp("Select ipsi ROI...")
            figure;imshow(A);
            currpoly=impoly;
            obj.ipsi_ROI = currpoly.getPosition;
            disp("ROI saved. ");
            close;
        end
        
        function Pix_list_logic = get_in_pixel(obj,type)
            %Get all pixels within the specified ROI. 
            %1-dLGN, 2-contra, 3-ipsi
            y_axis = 1:size(obj.Img_red,1);
            x_axis = 1:size(obj.Img_red,2);
            [x_axis,y_axis] = meshgrid(x_axis,y_axis);
            switch type
                case 1
                    In_matrix = inpolygon(x_axis,y_axis,obj.dLGN_ROI(:,1),obj.dLGN_ROI(:,2));
                    Pix_list_logic = find(In_matrix);
                case 2
                    In_matrix = inpolygon(x_axis,y_axis,obj.contra_ROI(:,1),obj.contra_ROI(:,2));
                    Pix_list_logic = find(In_matrix);
                case 3
                    In_matrix = inpolygon(x_axis,y_axis,obj.ipsi_ROI(:,1),obj.ipsi_ROI(:,2));
                    Pix_list_logic = find(In_matrix);
            end
        end  
        
        function value_list = log_cal(obj,PixelList)
            %Calculate log10(I/C)
            %PixelList from function: Pix_list_logic
            value_list = log10(double(obj.Img_rescale_green(PixelList))./double(obj.Img_rescale_red(PixelList)));
            Invalid_ratio = numel(find(isnan(value_list))) / numel(value_list) + numel(find(isinf(value_list))) / numel(value_list);
            disp(['Invalide pixel ratio = ',num2str(Invalid_ratio)]);
            value_list = value_list(~isnan(value_list));
            value_list = value_list(~isinf(value_list));
        end
        
        %Update for log(A/B) heatmap generation. 
        function check_log_heatmap(obj,Is_sel,color_map)
            %Generate a log(A/B) heatmap. If Is_sel is true, the heatmap
            %will be limited to previously selected dLGN region. Otherwise
            %it will be for the whole input image. 
            %The function should be run after selection and normalization. 
            
            %Image: Img_rescale_red, Img_rescale_green. 
            if nargin < 3
                color_map = 'parula';
            end
            value_map = log10(double(obj.Img_rescale_green)./double(obj.Img_rescale_red));
            y_axis = 1:size(obj.Img_red,1);
            x_axis = 1:size(obj.Img_red,2);
            [x_axis,y_axis] = meshgrid(x_axis,y_axis);
            if Is_sel == 1
                In_matrix = inpolygon(x_axis,y_axis,obj.dLGN_ROI(:,1),obj.dLGN_ROI(:,2));
                value_map = value_map.*double(In_matrix);
            end
            figure;
            imagesc(value_map);
            colorbar;
            eval(['colormap ' color_map]);
        end
    end
end

