#!/bin/bash

##########################################################
# Author: Eva Alonso Ortiz
# Date: April 2021
##########################################################

# TODO: introduce global var for QC

# TODO: this PATH_DATA will become an input of this script at some point
PATH_DATA=`pwd`
FILE_PATTERNS=(
  NOSHIM*run1
  NOSHIM*run2
  NOSHIM*run3
  staticzSHIM*run1
  staticzSHIM*run2
  staticzSHIM*run3
  rtSHIM*run1
  rtSHIM*run2
  rtSHIM*run3
)
# TODO: subj_list will be replaced by $SUBJECT with sct_run_batch
subj_list=(acdc_135_high_res acdc_135_low_res)
ext=nii.gz

mkdir nifti
cd nifti
for ((i=0; i< ${#subj_list[@]}; i++ )); do
  # Introduce variables that are following conventions of sct_run_batch
  SUBJECT=${subj_list[$i]}
  # create dir, go in it
  # Note: in future refactoring, processing will be done in each subject folder
  mkdir $SUBJECT
  cd $SUBJECT
  # convert dicoms to nifti
  dcm2niix -o . -z y -m y $PATH_DATA/$SUBJECT
  # get file name
  file_t1w=$(ls *.$ext | grep T1w | cut -d. -f1)
  # segment the spinal cord
  sct_deepseg_sc -i $file_t1w.$ext -c t1 -o spinal_seg.$ext -qc qc
  # create mask for more robust registration
  sct_create_mask -i $file_t1w.$ext -p centerline,spinal_seg.$ext -size 45mm -f cylinder -o mask_cord.$ext
  for file_pattern in ${FILE_PATTERNS[@]}; do
    # get file name without extension
    file=$(ls *$file_pattern*.$ext | cut -d. -f1)
    # average MGRE across echoes
    sct_maths -i $file.$ext -mean t -o ${file}_mean.$ext
    # register mean GRE to T1w scan
    sct_register_multimodal -i ${file}_mean.$ext -d $file_t1w.$ext -dseg spinal_seg.$ext -m mask_cord.$ext -param step=1,type=im,metric=cc,algo=slicereg,poly=2,smooth=1 -qc qc
    # apply transformation to spinal cord segmentation
    sct_apply_transfo -i spinal_seg.$ext -d ${file}_mean.$ext -w warp_${file_t1w}2${file}_mean.$ext -o spinal_seg_reg_$file.$ext
    # split multiecho file, this is required for sct_extract_metric
    sct_image -i ${file}.$ext -split t
    # extract the mean across slices and average across slices
    fnamesplits=$(ls ${file}_T*.$ext)
    for fnamesplit in ${fnamesplits[@]}; do
      sct_extract_metric -i $fnamesplit -f spinal_seg_reg_$file.$ext -method wa -o $file.csv -perslice 0 -append 1
    done
  done
  cd ..
done
