function Rc = Rcoarse(x,h_c)
%RCOARSE Summary of this function goes here
%   coarse cheese model response
if nargin < 2
    h_c = 1;
end
l_c = x(1);
w_c = x(2);
Rc = l_c*w_c*h_c;
end

