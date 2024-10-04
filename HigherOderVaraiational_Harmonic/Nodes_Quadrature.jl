function Nodes(s)
    if s == 1 

        nodes = [0 , 1];
        
    elseif s == 2
        
        nodes = [0.0 , 1/2 , 1.0];
        
    
      elseif s == 3 
        
       nodes = [0 , (5-√5)/10 , (5+√5)/10 , 1];
    
end  
     return nodes;
end

function Quadrature(;numQuad,method::String)
    if numQuad == 1 && method == "L"
        
        c = [0.0];
        
        b = [1] ; 
    elseif numQuad == 2 && method == "L"

        c = [0 , 1];
        
        b = [1/2 , 1/2]; 
        
    elseif numQuad == 3 && method == "L"
        
        c = [0.0 , 1/2 , 1.0];
        
        b = [1/6 , 2/3 , 1/6] ; 
      elseif numQuad == 4 && method == "L"
        
         c = [0 , (5-√5)/10 , (5+√5)/10 , 1];
        
         b = [1/12 , 5/12 , 5/12 , 1/12];          

 elseif numQuad == 1 && method == "G"
            
        c = [1/2]; 
        
        b = [1]; 
    
elseif numQuad == 2 && method == "G"
        
     c = [(1/2)-√3/6 , (1/2)+√3/6];
        
     b = [1/2 , 1/2];       
        
elseif numQuad == 3 && method == "G"
    
     c = [(1/2)-√(15)/10 , 1/2 , (1/2)+√(15)/10];
        
     b = [5/18 , 4/9 , 5/18];  
    
end  
     return c, b;
end