%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stefan Tesanovic, OE, 2016/675
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tacka 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Ucitavamo ulazni signal prvih nekoliko sekundi
Fs=44100; 
samples = [2*Fs, 5*Fs];
[x, fs] = audioread('avalon_44k.wav', samples);  %ucitavanje signala gramofona

t = 1/fs:1/fs:length(x)/fs;
figure;  
plot(t,x); 
title('Ucitan signal');
xlabel('t[s]');ylabel('x(t)[V]');

%Pustamo na zvucnike prvih nekoliko sekundi signala
%sound(x,Fs);

%U ucitan signal dodajemo nule tako da signal bude 11 puta duzi od naseg
%signala, sto znaci da izmedju dva odbiraka treba da dodamo 10 nula. To
%radimo tako sto povecamo duzinu signala za 11 i onda prolazimo kroz for
%petlju onoliko puta koliko je dug signal x i tu vrednost itog x odborka
%dodajemo svakom 11tom odbirku y signala

y = zeros(1,11*length(x));
j=1;
 for i=1:length(x)
     y(j)=x(i);
     j=j+11;
 end

figure;
stem(1:1/fs:(1+39/fs),x(1:40));
xlabel('t[s]'); ylabel('x(t)[V]'); 
title('40 reprezentativnih odbiraka ulaznog signala');

figure;
stem(1:1/fs:(1+99/fs),y(1:100));
xlabel('t[s]'); ylabel('x(t)[V]'); 
title('100 reprezentativnih odbiraka signala kome su dodate nule');

f=Fs/length(x):Fs/length(x):Fs;
top_freg=500; %gornja ucestanost za prikaz spektra
X=(abs(fft(x)));
Y=(abs(fft(y)));

figure;
stem(f(1:top_freg*length(x)/fs),X(1:top_freg*length(x)/fs));
xlabel('F[Hz]'); ylabel('|X(k)|');
title('Amplitudski spektar ulaznog signala');

figure;
stem(f(1:top_freg*length(y)/fs),Y(1:top_freg*length(y)/fs));
xlabel('F[Hz]'); ylabel('|Y(k)|');
title('Amplitudski spektar signala signala kome su dodate nule');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tacka 2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = 1/fs;
Ap = 1;
Aa = 30;
Apfound = Ap;
Aafound = Aa;
Fp = 1500;
Fa = 2600;


% KORAK 1: Racunanje anal. frekvencije i ucestanosti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ts = 1/Fs;
Wp=2*pi*Fp;
Wa=2*pi*Fa;

% KORAK 2: Zadavanje gabarita u digitalnom domenu, transformacija u digitalni domen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wp=Ts*Wp;
wa=Ts*Wa;

% KORAK 3: Zadavanje gabarita analognog prototipa (predistorzija ucestanosti za BIL transformaciju)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Wpap = 2/Ts*tan(wp/2);
Waap = 2/Ts*tan(wa/2);

% KORAK 4: Zadavanje gabarita NF normalizovanog filtra
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Wan=Waap/Wpap;


while(1)

    k=1/Wan;
    
    % KORAK 5: Sinteza normalizovanog NF filtra pomocu aprokcimacija
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    D = (10^(0.1*Aafound)-1)/(10^(0.1*Apfound)-1);
    N = ceil((acosh(sqrt(D)))/(acosh(1/k)));

    [z,p,k] = cheb1ap(N,Apfound);
    ban = k*poly(z); aan = poly(p);

   % KORAK 6: Transformacija normalizovanog NF -> Analogni NF prototip
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ba,aa] = lp2lp(ban,aan,2*pi*Fp);   
    
    
    % KORAK 7: Nule i polovi analognog -> nule i polove digitalnog  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [bd,ad] = impinvar(ba,aa,fs);

    % KORAK 8: Izracunavanje amplitudske karakteristike
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Nfreqz = 512;
    [hd,wd] = freqz(bd,ad,Nfreqz);
    Hd = abs(hd);
    fd = (wd*fs)/(2*pi);
    
    %provera gabarita
    NPOK = 0;
    POOK = 0;
    df = (fs/2)/Nfreqz;

    ia = floor(Fa/df)+1;
    ip = ceil(Fp/df)+1;

    Ha = Hd(ia:length(Hd));  %Amplitudska Karakteristika Nepropusnog Opsega
    Hp = Hd(1:ip);           %Amplitudska Karakteristika Propusnog Opsega

    if (max(20*log10(Ha)) > -Aa)
        Aafound = Aafound+0.1;
    else
        NPOK = 1;
    end
    if (min(20*log10(Hp)) < -Ap)
        Apfound = Apfound-0.1;
    else
        POOK = 1;
    end   
    if ((NPOK == 1)&&(POOK == 1))
        
        disp(['Red funkcije prenosa H(z) je N=',num2str(N)]);
        disp(['Maksimalno dozvoljeno slabljenje u propusnom opsegu je Ap=',num2str(Apfound)]);
        disp(['Minimalno dozvoljeno slabljenje u nepropusnom opsegu je Aa=',num2str(Aafound)]);
        
        break
    end
end

f = (fs/2)*wd/pi;
figure;
semilogx(f,20*log10(Hd),'LineWidth', 2), grid on
title('Amplitudska karakteristika projektovanog filtra');
xlabel('F[Hz]'); ylabel('|Hd[dB]|');


hold on
x_1 = [1 Fp]; y_1 = [-Ap -Ap];
x_2 = [Fp Fp]; y_2 = [0 -Ap];
x_3 = [Fa fs/2]; y_3 = [-Aa -Aa];
x_4 = [Fa Fa]; y_4 = [-Aa min(20*log10(Hd))];
plot(x_1,y_1,'r',x_2,y_2,'r',x_3,y_3,'r',x_4,y_4,'r','LineWidth', 2);
hold off


pHd = phase(hd);
figure;
semilogx(f,pHd,'LineWidth', 2);
title('Fazna karakteristika projektovanog filtra')
xlabel('F[Hz]'); ylabel('phase(Hd)'); grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tacka 3.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = filter(bd,ad,y);

figure
Y = abs(fft(y));
N = length(y);
Y=Y(1:N/2);
n=Fs/N:Fs/N:Fs/2;
stem(n,Y);
xlabel('F[Hz]'); ylabel('|Y(k)|');
title('Amplitudski spektar filtriranog signala'); grid on

z = zeros(1,ceil(length(y)/26));
j=1;
 for i=1:length(z)
     z(i)=y(j);
     j=j+26;
 end

figure
Z = abs(fft(z));
N = length(z);
Z=Z(1:N/2);
n=Fs/N:Fs/N:Fs/2;
stem(n,Z);
xlabel('F[Hz]'); ylabel('|Z(k)|');
title('Amplitudski spektar filtriranog i decimiranog signala'); grid on

z = z/max(z);
audiowrite('avalon_OK.wav',z,fs);
avalon_OK = audioplayer(z,fs);
avalon_OK.play;

% [z, fs] = audioread('avalon_OK.wav');  %ucitavanje signala koji je snimljen
% sound(z,Fs);
 

