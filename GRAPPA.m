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
%% under-sampled
ACS=32;
kernel=4;
R=4;
kspace_us=zeros(a,b,c);
kspace_us(1:R:a,:,:)=kspace(1:R:a,:,:);
kspace_us((a-ACS)/2+1:a,:,:)=kspace((a-ACS)/2+1:a,:,:);
%figure('Name','under sampled k-space');
%montage(reshape(log(abs(kspace_us)),a,b,1,c),'DisplayRange',[]);%ԭʼk-space
im_us=ifft2(fftshift(kspace_us,2));%kspace
imax_us=max(max(max(abs(im_us))));%�����Ǹ���
figure('Name', 'under sampled images from phase array channels');
montage(reshape(abs(im_us),256,256,1,8),[0 imax_us]);%under-sampled���ͼ��
recon_us=sqrt(sum(abs(im_us).*abs(im_us),3));%SOS
figure('Name','under sampled Multiple coil combination with SOS');
imshow(mat2gray(abs(recon_us))),title 'SOS';
%% GRAPPA
kspace_gr=kspace_us;
%ÿ��ͼ4������1��δ֪�㣬8��ͼ��32�����1����
%���n
n_pre=zeros(ACS-kernel,32,c);%ÿһ��slice�Ͽ��Խ��28��n��ÿ��n��32������
n=zeros(32,c);%n_pre��С���˵õ�
S=zeros(32,b);%32���㣬��kx����
for k=1:8%8��ͼ��ÿ��ͼ��n_pre
    for m=(a-ACS)/2+1+2:(a+ACS)/2-2%28����֪�ߣ����28��n
        y=squeeze(kspace_gr(m,:,k));
        for ll=1:256
            for kk=1:8%8��ͼ
                %for nn=1:4%ÿ��ͼ4����
                    S(4*kk-3,ll)=kspace_gr(m-2,ll,kk);
                    S(4*kk-2,ll)=kspace_gr(m-1,ll,kk);
                    S(4*kk-1,ll)=kspace_gr(m+1,ll,kk);
                    S(4*kk,ll)=kspace_gr(m+2,ll,kk);
                %end
            end
        end
        n_pre(m-114,:,k)=transpose(S)\transpose(y);
    end
end
n=squeeze(n_pre(14,:,:));
for k=1:8
    for m=4:R:113
        for ll=1:256
            for kk=1:8%8��ͼ
                %for nn=1:4%ÿ��ͼ4����
                    S(4*kk-3,ll)=kspace_gr(m-2,ll,kk);
                    S(4*kk-2,ll)=kspace_gr(m-1,ll,kk);
                    S(4*kk-1,ll)=kspace_gr(m+1,ll,kk);
                    S(4*kk,ll)=kspace_gr(m+2,ll,kk);
                %end
            end
        end
        kspace_gr(m,:,k)=transpose(n(:,k))*S;
    end
end
im_gr=ifft2(fftshift(kspace_gr,2));%kspace
imax_gr=max(max(max(abs(im_gr))));%�����Ǹ���
figure('Name', 'GRAPPA images from phase array channels');
montage(reshape(abs(im_gr),256,256,1,8),[0 imax_gr]);%under-sampled���ͼ��
recon_gr=sqrt(sum(abs(im_gr).*abs(im_gr),3));%SOS
figure('Name','GRAPPA Multiple coil combination with SOS');
imshow(mat2gray(abs(recon_gr))),title 'SOS';
RMSE=norm(abs(recon_gr)-abs(recon1),'fro')/norm(abs(recon1),'fro');
%% g factor
MM=100
for i=1:MM
    for coil=1:c
        noise(:,:,coil)=wgn(a,b,20);
    end
    noise1=noise*0;noise1(1:2:end,:,:)=noise(1:2:end,:,:);
    knoise=GRAPPA(noise1);%�˴��ǽ�ǰ��GRAPPA�δ����ɺ���
    for coil=1:c
        noiseim(:,:,i)=ifft2(fftshift(knoise(:,:,coil),2));
    end
    d=(res)-sos(noiseim);
end
gmap=d;
figure,imshow(matgray(abs(gmap)));
        