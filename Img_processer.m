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
%             figure;imshow(obj.Img_red);title("Original_red");
%             figure;imshow(obj.Img_rescale_red);title("Rescaled_red");
            
            obj.Img_rescale_green = rescale(obj.Img_green,1,255);
%             figure;imshow(obj.Img_green);title("Original_green");
%             figure;imshow(obj.Img_rescale_green);title("Rescaled_green");
        end
        
        function obj = select(obj,saturat)
            if nargin < 2
                saturat = 0.03;
            end
            A = imread([obj.Inpath,obj.Img_name,'_original_green.tif']);
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
        end
    end
end

