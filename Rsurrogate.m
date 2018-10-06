function Rs = Rsurrogate(x,dR,h_c)
%RSURROGATE Summary of this function goes here
%   coarse cheese model response
if nargin < 3
    h_c = 1;
end
l_c = x(1);
w_c = x(2);
Rc = (l_c*w_c*h_c);
Rs = Rc + dR;
end

