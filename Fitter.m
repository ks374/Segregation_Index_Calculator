classdef Fitter
    %FITTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        dLGN_values;
        contra_values;
        ipsi_values;
        
        seg_index;
        Vari;
        Vari_norm;
        
        x1;x2;x3;
        y1;y2;y3;
        A1;Mu1;Sig1;
        A2;Mu2;Sig2;
        A3;Mu3;Sig3;
        x;Y;Y1;Y2;Y3;
    end
    
    methods
        function obj = Fitter(name,dLGN_values,contra_values,ipsi_values)
            obj.name = name;
            if size(dLGN_values,1) == 1
                dLGN_values = dLGN_values';
                contra_values = contra_values';
                ipsi_values = ipsi_values';
            end
            obj.dLGN_values = dLGN_values;
            obj.contra_values = contra_values;
            obj.ipsi_values = ipsi_values;
        end
        
        function obj = check_histogram(obj,outpath,bin_num)
            %Check current histogram of the three value lists
            if nargin < 3
                bin_num = 80;
            end
            [obj.y1,obj.x1] = hist(obj.dLGN_values,bin_num);
            [obj.y2,obj.x2] = hist(obj.contra_values,bin_num);
            [obj.y3,obj.x3] = hist(obj.ipsi_values,bin_num);
            figure;
            plot(obj.x1,obj.y1,'black');
            hold on;plot(obj.x2,obj.y2,'red');
            hold on;plot(obj.x3,obj.y3,'green');
            obj.y1 = obj.y1';
            obj.x1 = obj.x1';
            obj.y2 = obj.y2';
            obj.x2 = obj.x2';
            obj.y3 = obj.y3';
            obj.x3 = obj.x3';
            if nargin > 1
                savefig([outpath 'hist_all.fig']);
            end
        end
                
        function obj = Fit_one_peak(obj)
            f = fit(obj.x2,obj.y2,'gauss1');
            obj.Mu2 = f.b1;
            obj.Sig2 = f.c1;
            disp('Done fit');
            f = fit(obj.x3,obj.y3,'gauss1');
            obj.Mu3 = f.b1;
            obj.Sig3 = f.c1;
            disp('Done fit')
        end
        function obj = Fit_two_peak(obj)
            options = fitoptions('gauss3');
            options.Lower = [0,obj.Mu2,0,0,obj.Mu2,obj.Sig2,0,obj.Mu3,obj.Sig3];
            options.Upper = [Inf,obj.Mu3,Inf,Inf,obj.Mu2,obj.Sig2,Inf,obj.Mu3,obj.Sig3];
            f = fit(obj.x1,obj.y1,'gauss3',options);
            obj.A1 = f.a1;obj.A2=f.a2;obj.A3 = f.a3;
            obj.Mu1=f.b1;obj.Sig1=f.c1;
            disp("Done fitting")
        end
        function obj = get_fit_curve(obj,outpath)
            disp("Parameters for contra:");
            disp([num2str(obj.A2),' ',num2str(obj.Mu2),' ',num2str(obj.Sig2)]);
            disp("Parameters for ipsi:");
            disp([num2str(obj.A3),' ',num2str(obj.Mu3),' ',num2str(obj.Sig3)]);
            disp("Parameters for mixed:");
            disp([num2str(obj.A1),' ',num2str(obj.Mu1),' ',num2str(obj.Sig1)]);
            obj.x = linspace(-3,3,1000);
            obj.Y1 = obj.A1*exp(-((obj.x-obj.Mu1)./obj.Sig1).^2);
            obj.Y2 = obj.A2*exp(-((obj.x-obj.Mu2)./obj.Sig2).^2);
            obj.Y3 = obj.A3*exp(-((obj.x-obj.Mu3)./obj.Sig3).^2);
            obj.Y = obj.Y1+obj.Y2+obj.Y3;
            figure;
            plot(obj.x,obj.Y,'black');
            hold on;plot(obj.x,obj.Y2,'red');
            hold on;plot(obj.x,obj.Y3,'green');
            hold on;plot(obj.x,obj.Y1,'blue');
            if nargin >1
                savefig([outpath,'fit_result.fig']);
            end
        end
        function obj = get_segregate_index(obj)
            A_contra = sum(obj.Y2);
            A_ipsi = sum(obj.Y3);
            A_total = sum(obj.Y);
            obj.seg_index = (A_contra + A_ipsi)/A_total;
            disp(['Segregation index equals: ' num2str(obj.seg_index)]);
        end
        
        function obj = get_variance(obj)
            obj.Vari = var(obj.dLGN_values);
            disp(['Variacne: ' num2str(obj.Vari)]);
        end
        
        function obj = get_variance_norm(obj)
            temp = obj.dLGN_values / max(obj.dLGN_values);
            obj.Vari_norm = var(temp);
            disp(['Normalized variacne: ' num2str(obj.Vari_norm)]);
        end
        
        function obj = delete_zeros(obj)
            obj.dLGN_values = obj.dLGN_values(obj.dLGN_values~=0);
            obj.contra_values = obj.contra_values(obj.contra_values~=0);
            obj.ipsi_values = obj.ipsi_values(obj.ipsi_values~=0);
        end
    end
end

