classdef FourierImageAnalysisView < handle
    properties (SetAccess = private)
        FIA
        %Save
    end
    methods
        function view = FourierImageAnalysisView(varargin)
            p = inputParser;
            addRequired(p, 'FIA', @(x) isa(x,'FourierImageAnalysisModel'));
            parse(p, varargin{:});
            
            view.FIA = p.Results.FIA;
        end
        function Image(view)
            figure;
            imshow(view.FIA.Image(:, :, view.FIA.ImageCenter(3)),[]); hold on
            plot(view.FIA.ImageCenter(1), view.FIA.ImageCenter(2), 'o', 'Color', 'r')
            drawnow; set(get(handle(gcf),'JavaFrame'),'Maximized',1);
        end
        function FourierTransform(view)
            figure;
            imshow(log(view.FIA.FftImage(:, :, view.FIA.FftImageCenter(3))),[]); hold on
            plot(view.FIA.FftImageCenter(1), view.FIA.FftImageCenter(2), 'o', 'Color', 'r')
            drawnow; set(get(handle(gcf),'JavaFrame'),'Maximized',1);
        end
        function Wavelength(view)
            figure;
            plot(1./view.FIA.qr, view.FIA.Msz, 'Color',[0.8 0.4 0]); hold on
            plot(view.FIA.Wavelength, view.FIA.WavelengthAmplitude, '^', 'Color', 0.8 * [0.8 0.4 0], 'MarkerFaceColor', [0.8 0.4 0]);
            axis([min(1./view.FIA.qr) max(1./view.FIA.qr) 0 1.1 * view.FIA.WavelengthAmplitude]);
            xlabel('wavelength ($\mu$m)');
            ylabel('magnitude');
            
            figure;
            plot(view.FIA.qr, view.FIA.Msz, 'Color',[0.8 0.4 0]); hold on
            plot(1/view.FIA.Wavelength, view.FIA.WavelengthAmplitude, '^', 'Color', 0.8 * [0.8 0.4 0], 'MarkerFaceColor', [0.8 0.4 0]);
            axis([min(view.FIA.qr) max(view.FIA.qr) 0 1.1 * view.FIA.WavelengthAmplitude]);
            xlabel('frequency ($1/\mu$m)');
            ylabel('magnitude');
        end
    end
end