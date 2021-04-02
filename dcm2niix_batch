#!/bin/bash

##########################################################
# Author: Eva Alonso Ortiz
# Date: April 2021
##########################################################


shopt -s nullglob
subj_list=(*/)
shopt -u nullglob

mkdir nifti
cd nifti/
mkdir ${subj_list[@]}
cd ..

################

for ((i=0; i< ${#subj_list[@]}; i++ )); do
    dcm2niix -o nifti/${subj_list[$i]} -m y ${subj_list[$i]}
    rtSHIM_file=$(ls nifti/${subj_list[$i]}/*.nii | grep rtSHIM)

    # average across echoes
    sct_maths -i $rtSHIM_file -mean t -o nifti/${subj_list[$i]}/mgre_averaged.nii.gz

    # get cord centerline
    sct_get_centerline -i nifti/${subj_list[$i]}/mgre_averaged.nii.gz -c t2 -o nifti/${subj_list[$i]}/mgre_averaged_centerline

    # create a binary cylindrical mask around the centerline
    sct_create_mask -i nifti/${subj_list[$i]}/mgre_averaged.nii.gz -p centerline,nifti/${subj_list[$i]}/mgre_averaged_centerline.nii.gz -size 17mm -f cylinder -o nifti/${subj_list[$i]}/mgre_averaged_seg.nii.gz

    # unzip the image volumes we wish to keep
    gunzip nifti/${subj_list[$i]}/mgre_averaged_seg.nii.gz -df

    # delete the other images
    rm nifti/${subj_list[$i]}/mgre_averaged_centerline.csv
    rm nifti/${subj_list[$i]}/mgre_averaged_centerline.nii.gz
done
