classdef F_list_plotter
    %Plot combined histogram for Fitters in F_list
    %   --
    
    properties
        F_list;
        Disp_list;
    end
    
    methods
        function obj = F_list_plotter(F_list)
            obj.F_list = F_list;
        end
        
        function obj = hist_align(obj)
            Mu_list = [];
            for i = 1:numel(obj.F_list)
                Mu_list = [Mu_list,obj.F_list(i).Mu2];
            end
            
            obj.Disp_list = Mu_list - min(Mu_list);
            for i = 1:numel(obj.F_list)
                obj.F_list(i).x1 = obj.F_list(i).x1 - obj.Disp_list(i);
                obj.F_list(i).Mu1 = obj.F_list(i).Mu1 - obj.Disp_list(i);
                obj.F_list(i).Mu2 = obj.F_list(i).Mu2 - obj.Disp_list(i);
                obj.F_list(i).Mu3 = obj.F_list(i).Mu3 - obj.Disp_list(i);
            end
            disp('Histogram aligned through all fitter');
        end
        
        function obj = get_hist_fit(obj,outpath)
            %Note:Need to correct Fitter to include the names. 
            figure;hold on;
            for i = 1:numel(obj.F_list)
                plot(obj.F_list(i).x,obj.F_list(i).Y);
            end
            hold off;
            legend show
            savefig([outpath 'Fithist_orig.fig']);
            
            figure;hold on;
            for i = 1:numel(obj.F_list)
                F_temp = obj.F_list(i);
                Y1 = F_temp.A1*exp(-((F_temp.x-F_temp.Mu1)./F_temp.Sig1).^2);
                Y2 = F_temp.A2*exp(-((F_temp.x-F_temp.Mu2)./F_temp.Sig2).^2);
                Y3 = F_temp.A3*exp(-((F_temp.x-F_temp.Mu3)./F_temp.Sig3).^2);
                Y = Y1+Y2+Y3;
                plot(F_temp.x,Y);
            end
            hold off;
            legend show
            savefig([outpath 'Fithist_aligned.fig']);
            disp("Done plot"); 
        end
        
        function obj = get_hist_orig(obj,outpath)
            figure;hold on;
            for i = 1:numel(obj.F_list)
                plot(obj.F_list(i).x1,obj.F_list(i).y1);
            end
            hold off;
            legend show
            savefig([outpath 'Hist_orig.fig']);
        end
        
        function obj = get_hist(obj,outpath)
            
            figure;hold on;
            for i = 1:numel(obj.F_list)
                plot(obj.F_list(i).x1,obj.F_list(i).y1);
            end
            hold off;
            legend show
            savefig([outpath 'Hist_aligned.fig']);
            disp("Done plot"); 
        end
    end
end

