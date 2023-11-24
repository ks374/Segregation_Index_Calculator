classdef Conv_image
    %A class to identify the region area in dLGN
    %   Threshold is defined by the half maximum peak after a fitting. 
    
    properties
        Inpath;
        Img_name;
        Img_red;
        Img_green;
        Img_rescale_red;
        Img_rescale_green;
        Img_rescale_both;
        Img_thred_red;
        Img_thred_green;
        dLGN_ROI;
        ipsi_ROI;
        
        Rpix;
        Gpix;
        Rthre;
        Gthre;
        
        logical_mask;
        logical_mask_ipsi;
        
        Total_area;
        Rarea;
        Rratio;
        Garea;
        Gratio;
        Oarea;
        Oratio;
    end
    
    methods
        function obj = Conv_image(input_path,input_name)
            %Read the images
            obj.Inpath = input_path;
            temp = split(input_name,'.');
            obj.Img_name = temp{1};
            Img = imread([input_path,obj.Img_name,'.tif']);
            obj.Img_green = Img(:,:,2);
            obj.Img_red = Img(:,:,3);
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
            
            figure;imshow(A);
            disp("Select ipsi ROI...")
            currpoly=impoly;
            obj.ipsi_ROI = currpoly.getPosition;
            disp("ROI saved. ");
            close;
        end
        
        function obj = get_in_pixel(obj)
            y_axis = 1:size(obj.Img_red,1);
            x_axis = 1:size(obj.Img_red,2);
            [x_axis,y_axis] = meshgrid(x_axis,y_axis);
            obj.logical_mask = inpolygon(x_axis,y_axis,obj.dLGN_ROI(:,1),obj.dLGN_ROI(:,2));
            obj.logical_mask_ipsi = inpolygon(x_axis,y_axis,obj.ipsi_ROI(:,1),obj.ipsi_ROI(:,2));
        end
        
        function obj=Img_mask(obj)
            %mask the image with the Pix_list (dLGN ROI selection) for
            %better illustration. 
            obj.Img_rescale_red = obj.Img_rescale_red.*uint8(obj.logical_mask);
            obj.Img_rescale_green = obj.Img_rescale_green.*uint8(obj.logical_mask);
%             figure;imshow(obj.Img_rescale_red);
%             figure;imshow(obj.Img_rescale_green);
        end
        
        function obj = get_pixlist(obj,channel)
            %channel-1 for red and channel-2 for green
            switch channel
                case 1
                    obj.Rpix = obj.Img_rescale_red(:);
                    obj.Rpix = obj.Rpix(logical(obj.Rpix));
                case 2
                    temp = obj.Img_rescale_green .* uint8(obj.logical_mask_ipsi);
                    obj.Gpix = temp(:);
                    obj.Gpix = obj.Gpix(logical(obj.Gpix));
            end
            obj.Total_area = numel(find(obj.logical_mask));
            disp(['Total Area: ' num2str(obj.Total_area)]);
        end
        
        function obj=find_peak_thre(obj,channel,bin_num)
            if nargin < 3
                bin_num = 80;
            end
            switch channel
                case 1
                    All_pix = obj.Rpix;
                    [y,x] = hist(double(All_pix),bin_num);
                    f = fit(x',y','gauss1');
                    figure;bar(x,y);
                    hold on;
                    plot(f);
                    hold off;
                    threshold = f.b1 - f.c1;
                    obj.Rthre = threshold;
                    disp(['R_Thre: ' num2str(obj.Rthre)]);
                case 2
                    All_pix = obj.Gpix;
                    [y,x] = hist(double(All_pix),bin_num);
                    f = fit(x',y','gauss1');
                    figure;bar(x,y);
                    hold on;
                    plot(f);
                    hold off;
                    threshold = f.b1 - f.c1;
                    obj.Gthre = threshold;
                    disp(['G_Thre: ' num2str(obj.Gthre)]);
            end
        end
        
        function obj = pixel_area(obj,channel,outpath)
            switch channel
                case 1
                    obj.Img_thred_red = uint8(obj.Img_rescale_red>obj.Rthre)*uint8(255);
                    figure;imshow(obj.Img_thred_red);
                    imwrite(obj.Img_thred_red,[outpath obj.Img_name '_red.tiff']);
                    
                    obj.Rarea = numel(find(obj.Img_thred_red));
                    obj.Rratio = obj.Rarea/obj.Total_area;
                    disp(['R area: ' num2str(obj.Rarea)]);
                    disp(['R ratio: ' num2str(obj.Rratio)]);
                case 2
                    obj.Img_thred_green = uint8(obj.Img_rescale_green>obj.Gthre)*uint8(255);
                    figure;imshow(obj.Img_thred_green);
                    imwrite(obj.Img_thred_green,[outpath obj.Img_name '_green.tiff']);
                    
                    obj.Garea = numel(find(obj.Img_thred_green));
                    obj.Gratio = obj.Garea/obj.Total_area;
                    disp(['G area: ' num2str(obj.Garea)]);
                    disp(['G ratio: ' num2str(obj.Gratio)]);
            end
        end
        
        function obj = pixel_overlap(obj,outpath)
            temp = logical(obj.Img_thred_red)&logical(obj.Img_thred_green);
            temp = uint8(temp) * uint8(255);
            figure;imshow(temp);
            imwrite(temp,[outpath obj.Img_name '_overlap.tiff']);
            
            obj.Oarea = numel(find(temp));
            obj.Oratio = obj.Oarea / obj.Total_area;
            disp(['Overlapping area: ' num2str(obj.Oarea)]);
            disp(['Overlapping ratio: ' num2str(obj.Oratio)]);
        end
        
        function save_info(obj,outpath)
            save([outpath obj.Img_name '.mat'],'obj');
        end
    end
end

