function R_f = Rfine(x,h_f)
%RCOARSE Summary of this function goes here
%   fine cheese-model response
if nargin < 2
    h_f = 1;
end
l_f = x(1);
w_f = x(2);
R_f = (l_f*w_f*h_f)-6;
end

