a = [1:1000]';
b(1:1000,1) = sin(2*pi*15*a) + 3*sin(2*pi*25*a);
b(:,2) = rand(1000,1);
b(:,3) = b(:,2)+b(:,1);
b(:,4:5) = zeros(1000,2);
b(101:1000,4) = b(1:900,3);
b(1:800,5) = b(201:1000,3);