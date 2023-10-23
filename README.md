# Segregation_Index_Calculator
MATLAB code: calculate the eye-specific segregation index using a threshold-independent algorithm. 

## Introduction ##
This repository contains several simple classes to calculate the degree of segregation using a threshold-independent in the dorsal lateral geniculate nucleus (dLGN) after dye injection into both eyes. 
Details of the method can be found in the following article: Unbiased analysis of bulk axonal segregation pattern. 

## How to use ##
Follow the Script_exmaple.m file. All classes and function are named as what they do. 

## Brief workflow ##
Load the images and substract the background. (Use radius = 0 to skip this step). 
Normalize image intensity. 
Select dLGN, contra, and ipsi regions. 
Calculate Log10(Fi/Fc) for each pixel. 
Do Gaussian peak fitting for the contra, ipsi, and all dLGN. 
Calculate the segregation index. 

## Image_1: Log10 value distribution of dLGN pixels, contra-pixels, and ipsi-pixels ##
![Fit_Raw](https://github.com/ks374/Segregation_Index_Calculator/assets/35774140/f4f39295-9956-491b-a48a-35f48ede4b6c)

## Image_2: Gaussian fitting for the distribution above. ##
![Fit_Result](https://github.com/ks374/Segregation_Index_Calculator/assets/35774140/2fe0429e-1288-45bc-a1eb-29f6255b52a7)
