
close all; clear all; clc; 

sim('ModelVerification.slx')

EbatRef = [  0 450000 500000 561728.4 600000 640909.1 700000 705000 800000 805000 900000; 
           5e6      0      0      5e6    5e6        0      0    5e6    5e6      0      0];

figure(1)
hold on
plot(EbatRef(1,:), EbatRef(2,:)/1e6, '*r')
plot(Ebat.Time,    Ebat.Data/1e6,    'b')
hold on
xlabel('s')
ylabel('Battery load [MJ]')
legend('Calculated', 'Simulated', 'location', 'southwest')
axis([-0.1e5 9.1e5 -0.1 5.1])




