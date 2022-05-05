clear all;clc;

%read a RGB image
I=imread('img6.jpg');
% I=imread('img1.jpg');
% I=imread('img2.jpg');
% I=imread('img3.jpg');
% I=imread('img4.jpg');
% I=imread('img5.jpg');
% I=imread('img7.jpg');
% I=imread('img8.jpg');

%components of rgb image
R=I(:,:,1);
G=I(:,:,2);
B=I(:,:,3);

%show the image and select area of interest
d=imcrop(I);

%Apply tresholding
mir=sort(min(d(:,:,1)));
mar=sort(max(d(:,:,1)),'descend');%the biggest value comes the first order
mig=sort(min(d(:,:,2)));
mag=sort(max(d(:,:,2)),'descend');%the biggest value comes the first order
mib=sort(min(d(:,:,3)));
mab=sort(max(d(:,:,3)),'descend');%the biggest value comes the first order

%Convert to RGB to grayscale so that we can work on image and see if we
%can transfer it to a color image!
GS=rgb2gray(I);

%get the size of the image
[p,q]=size(GS);

%apply transformation
CI=uint8(zeros(p,q,3));
for i=1:1:p
    for j=1:1:q
        if ((R(i,j)>=mir(1)&&R(i,j)<=mar(1)) && (G(i,j)>=mig(1)&&G(i,j)<=mag(1)) && (B(i,j)>=mib(1)&&B(i,j)<=mab(1)))
                CI(i,j,:)=[255,140,0];%color code of dark orange
        else
            CI(i,j,:)=[0,0,0];%black
        end
    end
end

figure(1);imshow(CI,[]); 
%convert from RGB to grayscale
GCI=rgb2gray(CI);
figure(2);imshow(GCI);

%if we wonder the intensity, we can look easily.
figure(3);imtool(GCI);

%binary image
BW=im2bw(CI,graythresh(CI));
%show the original image and binary image
figure(4);
subplot(1,2,1);imshow(I);title('Original Image');
subplot(1,2,2);imshow(BW);title('Binary Image');

%use morphology
[A, AB]=mystery(BW);

%shows the logical operators
figure(5);
subplot(2,5,1);imshow(A);title('A');
subplot(2,5,2);imshow(AB);title('AB');
subplot(2,5,6);imshow(not(A));title('NOT A');
subplot(2,5,7);imshow(not(AB));title('NOT AB');
subplot(2,5,8);imshow(and(A,AB));title('A and AB');
subplot(2,5,9);imshow(or(A,AB));title('A or AB');
subplot(2,5,10);imshow(xor(A,AB));title('XOR A');

%show steps of morphology
figure(6);
subplot(1,4,1);imshow(I);title('Original image');
subplot(1,4,2);imshow(BW);title('Binary image');
subplot(1,4,3);imshow(A);title('Remove noise');
subplot(1,4,4);imshow(AB);title('Boundary');

%structuring elements
S1=strel('disk',10);
S1.Neighborhood
S2=strel('disk',5);
S2.Neighborhood

%Closing = Dilation + Erosion, seperately.
%Dilation(fills smal holes and cracks)
BW=imdilate(BW,S2);
BW
%Erosion (removes small objects)
BW=imerode(BW,S1); 
BW

%NOT(BW) means white areas are converted to black and black areas are
%converted to white
BW=not(BW);
figure(7);imshow(BW);

%find the boundary of each black area
bound=bwboundaries(BW);
figure(8);imshow(BW);
%shows the number of black areas' boundaries (orange numbers)
text(30,30,strcat('\color{blue}Orange Number:',num2str(length(bound))));
hold on;

%draw bounded areas with the blue lines
for k = 1:length(bound)
    boundary = bound{k};
    plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2);
end

function [A, AB]=mystery(BW)
    %remove small pixel noises
    B=strel('disk',1);
    A=imerode(BW,B);
    %that remove some parts so fill those part
    A=imfill(A,'holes');
    %obtain boundary by subtracting eroded image from the original image
    B=strel('disk',4);
    E=imerode(A,B);
    AB=A-E;
end

%BW=thresholding(GCI,110);
% function [Ithresh]=thresholding(I,threshold)
%     Ithresh=zeros(size(I));
%     Ithresh(I>threshold)=1;
% end
