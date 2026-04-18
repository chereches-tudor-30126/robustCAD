classdef ColorProvider
    methods (Static)
        function col = getBranchColor(index)
            colors = {
                '#378ADD',   % albastru
                '#1D9E75',   % verde
                '#D85A30',   % portocaliu
                '#D4537E',   % roz
                '#7F77DD',   % violet
                '#639922'    % verde închis
            };
            col = colors{mod(index-1, length(colors)) + 1};
        end
    end
end