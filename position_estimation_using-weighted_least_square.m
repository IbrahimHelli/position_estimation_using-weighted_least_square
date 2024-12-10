clear
clc
close all

%% Vericilerin Konumlarını Belirle:
verici_konumlar = [30, -50; 5 100; 50 40; 15, 10; -20, 30];

%% Vektörleri oluştur
H = zeros(length(verici_konumlar), 2);
Y = zeros(1, length(verici_konumlar));
W = eye(length(verici_konumlar));

%% Gerçek Konumu Belirle:
gercek_konum = [40, 40];

%% Pseudo-rangelerin doldurulacağı vektörü oluştur:
prs          = [];

%% Vericilerden ulaşan pseudo-range değerlerini oluştur:
for i = 1 : length(verici_konumlar)
    a = 1;
    b = 5;
    gurultu = a + (b-a)*rand();
    prs(end+1) = sqrt((verici_konumlar(i, 1) - gercek_konum(1))^2 + ...
        (verici_konumlar(i, 2) - gercek_konum(2))^2) + gurultu;
end

%% İlk Konum Tahminini Belirle:
konum_tahmin = [1e6, -2e6];
d            = 100000;
konum_cell   = {};

sayici = 0;
while (d > 1e-4)
    
    %% Her bir uydu  için pseudo-range hesapla ve 
    %  H matrisini oluştur:
    for i = 1 : length(verici_konumlar)
        uzaklik = sqrt((verici_konumlar(i, 1) - konum_tahmin(1))^2 + ...
        (verici_konumlar(i, 2) - konum_tahmin(2))^2); 

        H(i, 1) = (konum_tahmin(1) - verici_konumlar(i, 1)) / uzaklik;
        H(i, 2) = (konum_tahmin(2) - verici_konumlar(i, 2)) / uzaklik;
        
        %% y vektörünü oluştur:
        Y(i) = prs(i) - uzaklik;
    end
    
    %% En Küçük Kareler Çözümünü Yap:
    dx = inv(H' * W * H) * H' * W * Y';

    d = norm(dx);

    konum_tahmin = konum_tahmin + dx';
    konum_cell{end+1} = konum_tahmin;

    sayici = sayici + 1;

end

fprintf("%d adımda En Küçük Kareler Algoritması çözüme ulaştı.\n", sayici);
fprintf("Gerçek Konum: %f, %f \n", gercek_konum(1), gercek_konum(2));
fprintf("Kestirilen Konum: %f, %f \n", konum_tahmin(1), konum_tahmin(2));
fprintf("Kestirim Hatası: %f metre.\n", norm(gercek_konum - konum_tahmin));

figure;
grid on
xlabel("X ekseni (m)")
ylabel("Y ekseni (m)")
for i = 1 : length(verici_konumlar)
    hold on
    plot(verici_konumlar(i, 1), verici_konumlar(i, 2), 'ro', 'LineWidth', 4, 'DisplayName', 'Verici Konum')
    legend("Verici Konum")
end

hold on 
plot(gercek_konum(1), gercek_konum(2), 'bx', 'LineWidth', 4, 'DisplayName', 'Gerçek Konum')
hold on
plot(konum_tahmin(1), konum_tahmin(2), 'g*', 'LineWidth', 4, 'DisplayName', 'Kestirilen Konum')
title("Alıcı Konum Kestirimi (2-D)")

cozum_x_arr = [];
cozum_y_arr = [];
for i = 1 : length(konum_cell)
    temp = konum_cell{i};
    cozum_x_arr(end + 1) = temp(1);
    cozum_y_arr(end + 1) = temp(2);
end
 
figure;
subplot(2, 1, 1)
plot(cozum_x_arr, 'LineWidth', 3);
grid on
ylabel("X Ekseni Konum (m)")
xlabel("İterasyon Sayısı")
title("Çözüm X Ekseni Analiz")
subplot(2, 1, 2)
plot(cozum_y_arr, 'LineWidth', 3);
grid on
ylabel("Y Ekseni Konum (m)")
xlabel("İterasyon Sayısı")
title("Çözüm Y Ekseni Analiz")