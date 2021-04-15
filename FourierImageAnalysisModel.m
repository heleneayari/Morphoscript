classdef FourierImageAnalysisModel < handle
    properties (SetAccess = private)
        Image
        Imagew
        modif=0;
        factor
        FftImage
        FftEnergy
        FftTotalEnergy
        Resolution
        SaveDir
        SaveName
        ImageSize
        FftImageSize
        ImageCenter
        FftImageCenter
        Num
        qr
        qth
        Fdir
        MAS
        Mdir
        Mdirm
        Msz
        MainDirection
        OrthogonalDirection
        MainAngle
        MainAngleAmplitude
        OAS
        OrthogonalAngle
        OrthogonalAngleAmplitude
        Cut=4;
        IsotropicWavelength
        IsotropicWavelengthAmplitude
        MainWavelength
        MainWavelengthAmplitude
        OrthogonalWavelength
        OrthogonalWavelengthAmplitude
        OrthogonalWavelengthError
        vec
        std
        Wavelengthmed % median wavelength on area above threshold
        Wavelengthmean % mean wavelength on area above threshold
    end
    methods
        function FIA = FourierImageAnalysisModel(varargin)
            p = inputParser;
            addRequired(p, 'Image', @isnumeric);
            addParameter(p, 'Resolution',[1, 1, 1], @isnumeric);
            addParameter(p, 'SaveDir', pwd, @isstr);
            addParameter(p, 'SaveName', datestr(now, 30), @isstr);
            addParameter(p, 'Mode', 'Auto', @(x) any(validatestring(x, {'Auto','Hand'}))); %FIX
            parse(p, varargin{:});
            
            FIA.Image = p.Results.Image;
            FIA.Resolution = p.Results.Resolution;
            FIA.SaveDir = p.Results.SaveDir;
            FIA.SaveName = p.Results.SaveName;
            FIA.ImageSize = size(FIA.Image);
            FIA.ImageCenter = (FIA.ImageSize + bitget(abs(FIA.ImageSize),1))/2 + ~bitget(abs(FIA.ImageSize),1);
            FIA.Num = FIA.ImageSize(1) + ~bitget(abs(FIA.ImageSize(1)),1);
            
        end
        function FIA = performFft(FIA)
            
            
            FIA.Imagew = windowing(single(FIA.Image)); % this was perdecomp method but
            %FIA.Imagew=FIA.Image;
            %not ok for padding
            %             L=length(FIA.Image);
            %             W=hanning(L);
            %             Wt=W*W';
            %            im_win = FIA.Image.*Wt;
            
            %    im_fft = fftn(im_win,[2^nextpow2(L) 2^nextpow2(L)]); %nD fast fourier transform
            im_fft = fftn(FIA.Imagew);
            im_fft(1)=0;
            im_fft_shift = fftshift(im_fft);%
            
            FIA.FftImage = abs(im_fft_shift).^2 ;
            % FIA.FftImage =FIA.FftImage / length(FIA.FftImage(:));
            FIA.FftImage =FIA.FftImage / sum(FIA.FftImage(:))*100; %SHOULD BE abs(im_fft_shift).^2 / numel(FIA.Image) and threshold^2??
            % FIA.FftEnergy = FIA.FftImage.^2 ;
            
            % FIA.FftTotalEnergy = sum(FIA.FftEnergy(:));
            FIA.FftImageSize = size(FIA.FftImage);
            FIA.FftImageCenter = (FIA.FftImageSize + bitget(abs(FIA.FftImageSize),1))/2 + ~bitget(abs(FIA.FftImageSize),1);
            %IC = num2cell(FIA.ImageCenter);
            
        end
        function FIA = cutOff(FIA)
            ding = 4;
            FIA.FftImage = FIA.FftImage(FIA.ImageCenter(1) - FIA.ImageSize(1)/ding : FIA.ImageCenter(1) + FIA.ImageSize(1)/ding, FIA.ImageCenter(2) - FIA.ImageSize(2)/ding : FIA.ImageCenter(2) + FIA.ImageSize(2)/ding, FIA.ImageCenter(3) - FIA.ImageSize(3)/ding : FIA.ImageCenter(3) + FIA.ImageSize(3)/ding);
            FIA.FftImageSize = size(FIA.FftImage);
            FIA.FftImageCenter = (FIA.FftImageSize + bitget(abs(FIA.FftImageSize),1))/2 + ~bitget(abs(FIA.FftImageSize),1);
        end
        function FIA = performBinmethod(FIA)
            qx = (-(FIA.FftImageSize(2)-1)/2 : 1 : (FIA.FftImageSize(2)-1)/2)/(FIA.FftImageSize(2)*FIA.Resolution(1)); %PAS OP MET DEFINITIE RESOLTUION
            qy = (-(FIA.FftImageSize(1)-1)/2 : 1 : (FIA.FftImageSize(1)-1)/2)/(FIA.FftImageSize(1)*FIA.Resolution(2));
            qz = (-(FIA.FftImageSize(3)-1)/2 : 1 : (FIA.FftImageSize(3)-1)/2)/(FIA.FftImageSize(3)*FIA.Resolution(3));
            
            [QX, QY, QZ] = meshgrid(qx, qy, qz);
            QR = sqrt(QX.^2 + QY.^2 + QZ.^2);
            
            nbins = round(sqrt(FIA.FftImageSize(1)^2 + FIA.FftImageSize(2)^2 + FIA.FftImageSize(3)^2)/2);
            
            [~, edges, bin] = histcounts(QR(:), nbins);
            FIA.qr = (edges(2:end) + edges(1:end-1))/2;
            
            
            for ii = 1 : nbins
                ind = bin == ii;
                FIA.Msz(ii) = sum(FIA.FftEnergy(ind))/FIA.FftTotalEnergy * 100;
            end
        end
        
        function FIA = interpolateFft(FIA)
            FIA.factor=1;
            
            FIA.qth = linspace(0, pi, FIA.Num);
            
            %  FIA.qr = linspace(0,1/FIA.factor* sqrt(1/FIA.Resolution(1)^2 + 1/FIA.Resolution(2)^2)/2, round(FIA.Num/FIA.factor));
            if FIA.Resolution(1)==1
                FIA.qr = linspace(1/2.5*0.06,1.2*0.06, FIA.Num);
            else
                FIA.qr = linspace(1/2.5,1.2, FIA.Num);
            end
            
            
            [QTheta, QRho] = meshgrid(FIA.qth, FIA.qr); % create a grid with radial points
            [QX, QY] = pol2cart(QTheta, QRho);    % the same grid in cartesian coordinates
            
            
            if mod(FIA.FftImageSize(2),2)==1
                fx = (-(FIA.FftImageSize(2)-1)/2 : 1 : (FIA.FftImageSize(2)-1)/2)/(FIA.FftImageSize(2)*FIA.Resolution(1)); %PAS OP MET DEFINITIE RESOLTUION
            else
                fx = (-(FIA.FftImageSize(2))/2 : 1 : (FIA.FftImageSize(2)/2-1))/(FIA.FftImageSize(2)*FIA.Resolution(1));
            end
            if mod(FIA.FftImageSize(1),2)==1
                fy = (-(FIA.FftImageSize(1)-1)/2 : 1 : (FIA.FftImageSize(1)-1)/2)/(FIA.FftImageSize(1)*FIA.Resolution(2));
            else
                fy = (-(FIA.FftImageSize(1))/2 : 1 : (FIA.FftImageSize(1)/2-1))/(FIA.FftImageSize(2)*FIA.Resolution(1));
            end
            
            im=imgaussfilt(FIA.FftImage,1);
            
            FIA.Fdir = interp2(fx, fy,im, QX, QY);
            
            %             ind=isnan(FIA.Fdir);
            %             sum(ind(:))
            %             if sum(ind(:))
            %             FIA.Fdir(ind)=interp2(fx,fy,im,QX(ind),QY(ind),'nearest');
            %             end
            %             sum(ind(:))
            FIA.Mdir = nanmean(FIA.Fdir, 1);
            %             figure
            %             imagesc(FIA.Fdir)
            %             pause
            
            
            
            
            
            
        end
        function calculateDirection(FIA, varargin)
            
            [pszot, lszot, ~, ~] = findpeaks(FIA.Mdir, 'SortStr', 'descend'); 
            pszot(isempty(pszot)) = NaN; lszot(isempty(lszot)) = NaN;
            [~, nn] =  min(abs(FIA.Mdir(1) -  pszot));
            
            
            if FIA.Mdir(1)>pszot(1)/3
                if pszot(1)<FIA.Mdir(1)
                    pszo(1)=FIA.Mdir(1);
                    pszo(2:length(pszot)+1)=pszot;
                    lszo(1)=1;
                    lszo(2:length(pszot)+1)=lszot;
           
                else
                    
                    
                    if pszot(nn)>FIA.Mdir(1)
                        
                        pszo(1:nn)=pszot(1:nn);
                        pszo(nn+1)=FIA.Mdir(1);
                        pszo(nn+2:length(pszot)+1)=pszot(nn+1:end);
                        
                        lszo(1:nn)=lszot(1:nn);
                        lszo(nn+1)=1;
                        lszo(nn+2:length(pszot)+1)=lszot(nn+1:end);
          
                    else
                        
                        pszo(1:nn-1)=pszot(1:nn-1);
                        pszo(nn)=FIA.Mdir(1);
                        pszo(nn+1:length(pszot)+1)=pszot(nn:end);
                        
                        lszo(1:nn)=lszot(1:nn);
                        lszo(nn+1)=1;
                        lszo(nn+2:length(pszot)+1)=lszot(nn+1:end);
    
                    end
                    
                end
            else
                pszo=pszot;
                lszo=lszot;
     
            end
            FIA.Mdirm=pszo(1);
            ldir=lszo(1);
            if isnan(ldir)
                ldir=1;
            end
          
            OIt=round(mod(ldir + FIA.Num/2, FIA.Num));
            
            [~, nn] =  min(abs(lszo -  OIt));
            OI=lszo(nn);
            if isnan(OI)
                OI=1;
            end
            
            %             [FIA.Mdirm, ldir] = max(FIA.Mdir);
            %             OI=round(mod(ldir + FIA.Num/2, FIA.Num));
            
            
            mmi=max(FIA.Fdir(:,ldir)-min(FIA.Fdir(:,ldir)));
            mmoi=max(FIA.Fdir(:,OI)-min(FIA.Fdir(:,OI)));
            
            [~,Si]=polyfit(1:FIA.Num,(FIA.Fdir(:,ldir)-min(FIA.Fdir(:,ldir)))'/mmi,2);
            [~,Soi]=polyfit(1:FIA.Num,(FIA.Fdir(:,OI)-min(FIA.Fdir(:,OI)))'/mmoi,2);
            
            %              fexp=@(a,x)exp(-a.*x);
            %             [f,gof]=fit([1:FIA.Num]',(FIA.Fdir(:,ldir)-min(FIA.Fdir(:,ldir)))/mmi,fexp);
            %                         [g,gog]=fit([1:FIA.Num]',(FIA.Fdir(:,OI)-min(FIA.Fdir(:,OI)))/mmoi,fexp);
            %                         Si.normr=gof.sse;
            %                         Soi.normr=gog.sse;
            %
            %                         figure
            %                         hold on
            %                         plot(1:FIA.Num,(FIA.Fdir(:,ldir)-min(FIA.Fdir(:,ldir)))'/mmi,'b+')
            %                         plot(f,'b')
            %                         plot(1:FIA.Num,(FIA.Fdir(:,OI)-min(FIA.Fdir(:,OI)))'/mmoi,'r+')
            %                         plot(g,'r')
            %             keyboard
            switch nargin
                 case 1
                    if Si.normr<Soi.normr
                        FIA.MainDirection = ldir;
                        FIA.OrthogonalDirection = OI;
                        
                    else
                        FIA.MainDirection = OI;
                        FIA.OrthogonalDirection = ldir;
                        
                        
                    end
                otherwise
                    
                    [~, I] = min(abs(FIA.qth - varargin{1}*pi/180));
                    
                    FIA.Mdirm=FIA.Mdir(I);
                    FIA.MainDirection=I;
                    FIA.OrthogonalDirection=round(mod(I + FIA.Num/2, FIA.Num));
            end
            
            FIA.MainAngle = FIA.qth(FIA.MainDirection);
            FIA.MainAngleAmplitude = FIA.Mdir(FIA.MainDirection);
            FIA.OrthogonalAngle = FIA.qth(FIA.OrthogonalDirection);
            FIA.OrthogonalAngleAmplitude = FIA.Mdir(FIA.OrthogonalDirection);
            
            
            
            
            
            
        end
        function calculateIsotropicSize(FIA, varargin)
            
            FIA.Msz=mean(FIA.Fdir,2);
            [psz, lsz, ~, ~] = findpeaks(FIA.Msz, FIA.qr, 'SortStr', 'descend');
            
            psz(isempty(psz)) = NaN; lsz(isempty(lsz)) = NaN;
            switch nargin
                case 1
                    I = 1;
                otherwise
                    
                    [~, I] =  min(abs(lsz -  1/varargin{1}));
            end
            
            FIA.IsotropicWavelength = 1/lsz(I);
            FIA.IsotropicWavelengthAmplitude = psz(I);
            
            
        end
        function calculateMainAnisotropicSize(FIA, varargin)
            
            FIA.MAS =  FIA.Fdir(:,FIA.MainDirection);
            
            
            [pszm, lszm, ~, ~] = findpeaks(FIA.MAS', FIA.qr, 'SortStr', 'descend'); %WHY NOT IMAGESIZE/2???
            %              figure
            %             findpeaks(MAS, qrt,'Annotate','extent','WidthReference','halfheight');
            %             title('main')
            pszm(isempty(pszm)) = NaN; lszm(isempty(lszm)) = NaN;
            
            switch nargin
                case 1
                    I = 1;
                otherwise
                    [~, I] =  min(abs(lszm -  1/varargin{1}));
            end
            
            FIA.MainWavelength = 1/lszm(I);
            FIA.MainWavelengthAmplitude = pszm(I);
            
            
        end
        function calculateOrthogonalAnisotropicSize(FIA, varargin)
            
            FIA.OAS =  FIA.Fdir(:,FIA.OrthogonalDirection);
            [pszo, lszo, ~, ~] = findpeaks(FIA.OAS', FIA.qr, 'SortStr', 'descend'); %WHY NOT IMAGESIZE/2???
            
            
            %             FIA.vec=flip(linspace(1,2.5,40));
            %         FIA.OAS= dftpolar(FIA.Imagew,1./FIA.vec,FIA.OrthogonalAngle,FIA.Resolution(1));
            %
            
            
            %  [pszo, lszo, ~, ~] = findpeaks(FIA.OAS, 1./FIA.vec, 'SortStr', 'descend');
            
            
            pszo(isempty(pszo)) = NaN; lszo(isempty(lszo)) = NaN;
            
            
            switch nargin
                case 1
                    I = 1;
                otherwise
                    
                    [~, I] =  min(abs(lszo -  1/varargin{1}));
                    
            end
            
            FIA.OrthogonalWavelength = 1/lszo(I);
            FIA.OrthogonalWavelengthAmplitude = pszo(I);
            
        end
        
    end
end