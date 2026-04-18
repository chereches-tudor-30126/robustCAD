classdef ColorProvider
    methods (Static)
        function col = getBranchColor(index)
            colors = {
                '#378ADD',   
                '#1D9E75',  
                '#D85A30',   
                '#D4537E',   
                '#7F77DD',  
                '#639922'    
            };
            col = colors{mod(index-1, length(colors)) + 1};
        end
    end
end