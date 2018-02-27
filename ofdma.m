clear; clc; close all;
fe=400e3;% fréquence d'échantillonnage
dt=1/fe;%Pas d'échantillonnage
Nb=256; % nombre de donnée binaires
Ns=12; %nombre de symboles 
NIG= 32; % nombre de bit de l'intervalle de garde
D=5e3;% Débit binaire
fp=20e3;% fréquence de la porteuse
T=1/D;%durée d'un moment
N=T/dt;%taux d'échantillonnage
Nc=20;% facteur d'étalement
Ne= round(N/Nc); % taux d'échantillonnage étalé 
t= 0 : dt : Nb*T-dt;%axe de temps 
c=Nb-NIG+1; % nombre de bits non inclus dans l'intervalle de garde 


%1) ----------Géneration des données ------ 

data1 = rand(Ns,Nb)>0.5;
symbole1= 2*data1-1;
data2 = rand(Ns,Nb)>0.5;
symbole2= 2*data2-1;
symbole3 = symbole1 + j*symbole2;
symboles = symbole3/square(2); 

% Série/Parallèle
symbolest= symboles.'; %transposé 

% Transformée de fourier inverse 
TF = ifft(symbolest);

% Parallèle / Série 
 TFt = TF.'; 
 
 % L'intervalle de garde 
 x1 = TFt(:,c:Nb); % concaténation 
 IG = [x1,TFt]; % intervalle de garde 
 IGV = reshape(IG, 1, Ns*(NIG+Nb)); % vecteur 3456 elements  
 
 % canal awgn 
 
y = awgn(IGV,20); % canal bruité 
%y = IGV;

y1= reshape(y, 12, NIG+Nb); 

% supression de l'intervalle de garde 

SIG = y1(:,33:288); % suppression de l'intervalle de garde 
SIGt= SIG.'; % série parallèle 
z= fft(SIGt);

 
%
constelations=[1+j,1-j,-1+j,-1-j];

for i=1:Nb 

       for j=1:Ns
           
           for k=1:4
               vector=constelations-z (i,j);
            [d,indice]= min(abs(vector));
             tableau(i,j)=constelations(indice);
           end
           
       end
end ;   

% comparaison : errors count

counterror=0;

for i=1:Nb 

       for j=1:Ns
           if abs((tableau(i,j)-symbolest(i,j))>0)
               counterror=counterror+1; 
           end
       end
end

%applyfading 

yfading =ApplyFading(IGV,2,6);

%ajout de bruit 

yfadingnoise=awgn(yfading,40); 
  
%reception
  
SIG = yfadingnoise(:,33:288); % suppression de l'intervalle de garde 
SIGt= SIG.'; % série parallèle 
z= fft(SIGt);

yegaliser=z*conj(y);
stem(real(yegaliser));  grid on; xlim([0 10]);
