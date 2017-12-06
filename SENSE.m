load mprage_8ch_k-space_577203641.mat;
[a,b,c]=size(kspace);
%% 
%չʾԭʼ��k-space��ԭʼ��ͼ��
figure('Name','Original k-space');
montage(reshape(log(abs(kspace)),a,b,1,c),'DisplayRange',[]);%ԭʼk-space
im=ifft2(fftshift(kspace,2));%ԭʼͼ��
imax1=max(max(max(abs(im))));%�����Ǹ���
figure('Name', 'Images from phase array channels');
montage(reshape(abs(im),256,256,1,8),[0 imax1]);%ԭʼͼ��
recon1=sqrt(sum(abs(im).*abs(im),3));%SOS
figure('Name','Multiple coil combination with SOS');
imshow(mat2gray(abs(recon1))),title 'SOS';

%% sensitivity map

%�ͷֱ���
kspacenew=zeros(a,b,c);
for i=1:8
    for j=1:20
        for k=1:20
            %kspacenew
            kspacenew(a/2-10+j,b/2-10+k,i)=kspace(a/2-10+j,b/2-10+k,i);
        end
    end
end
imnew=ifft2(fftshift(kspacenew,2));%�ͷֱ��ʵ�ͼ��
imax2=max(max(max(abs(imnew))));%�����Ǹ���
%figure('Name', 'Low resolution images from phase array channels');
%montage(reshape(abs(imnew),256,256,1,8),[0 imax2]);
recon2=sqrt(sum(abs(imnew).*abs(imnew),3));%�ͷֱ��ʵ�SOS
%figure('Name','Low resolution multiple coil combination with SOS');
%imshow(mat2gray(abs(recon2))),title 'SOS';
%��sensitivity map
for i=1:8
    map(:,:,i)=imnew(:,:,i)./recon2;
end
maxmap=max(max(max(abs(map))));
figure('Name', 'Maps from phase array channels');
montage(reshape(abs(map),256,256,1,8),[0 maxmap]);

%
%% Generate aliased images
R=2;
subsamplekspace=zeros(floor(a/R),b,c);
for i=1:floor(a/R)
    subsamplekspace(i,:,:)=kspace(R*i-1,:,:);
end
for i=1:c
    imaliased(:,:,i)=ifft2(fftshift(subsamplekspace(:,:,i)));
end
recon3=sqrt(sum(abs(imaliased).*abs(imaliased),3));
figure('Name','Aliased images');
imshow(mat2gray(abs(recon3))),title 'Aliased images SOS';

%Sense reconstruction
imsense=zeros(a,b);
gfactor=zeros(a,b);
%��M�����ù�ʽ��S��Ma(r)Ҳ����imaliased
%S=zeros(8,1);
gfactor=zeros(256,256);
%for i=1:a/R
%    for j=1:b
%        S=squeeze(map(i:a/R:a,j,:));
%        SH=transpose(S);
%        y=squeeze(imaliased(i,j,:));
        %if (i>128)
        %    m=i-128;
        %else
        %    m=i;
        %end
        %M(i,j)=inv((S'*S))*(S')*squeeze(imaliased(m,j,:));%������ͼ��
        %M(i,j)=inv(transpose(S)*S)*transpose(S)*squeeze(imaliased(m,j,:));
%        M(i:a/R:a,j)=SH\y;
%        gfactor(i:256/R:256,j)=diag(inv(SH*S)).*diag(SH*S);%sqrt((S'*S)\(S'*S));%g factor
%    end
%end
for pe = 1:b/R,
   for fe = 1:a,
       AT = squeeze(map(pe:256/R:256, fe, :));
       A = transpose(AT);
       y = squeeze(imaliased(pe, fe, :));
       x = A\y;
       %x = pinv(A)*y;
       imsense(pe:256/R:256, fe) = x;
       CC = AT*A;
       invCC = inv(CC);
       gfactor(pe:256/R:256, fe) = [diag(invCC()).*diag(CC)];
   end
end
figure; imshow(abs(imsense),[]);
imcontrast;
figure; imshow(abs(gfactor),[]);
imcontrast;
dif=abs(imsense)./max(max(abs(imsense)))-abs(recon1)./max(max(abs(recon1)));
figure;imshow(abs(dif),[]);
rmse=sqrt(sum(sum(dif.^2))./(a*b));
%recon4=sqrt(sum(abs(M).*abs(M),3));%SENSE���SOS
%figure('Name','SENSE SOS');
%imshow(mat2gray(abs(recon4))),title 'SENSE SOS';
%for i=1:floor(a/R)
%    for j=1:b
%        S=[];
%        for k=1:R
%            S=[S,squeeze(map(i+(k-1)*floor(a/R),j,:))];
%        end
%        X=(S'*S)\(S');
%        M=X*
%    end
%end

