#!/bin/bash

##########################################################
# Author: Eva Alonso Ortiz
# Date: April 2021
##########################################################


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

################

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
  # save filename variables
  file_t1w=$(ls *.nii | grep T1w)
  # segment the spinal cord
  sct_deepseg_sc -i $file_t1w -c t1 -o spinal_seg.nii.gz -qc qc
  for file_pattern in ${FILE_PATTERNS[@]}; do
    # get file name without extension
    file=$(ls *$file_pattern*.nii | cut -d. -f1)
    # average MGRE across echoes
    sct_maths -i $file.$ext -mean t -o nifti/${subj_list[$i]}/noSHIM_averaged.nii.gz

  done
    # NOSHIM_file=$(ls nifti/${subj_list[$i]}/*.nii | grep NOSHIM )
    # 
    # staticzSHIM_RUN1_file=$(ls nifti/${subj_list[$i]}/*.nii | grep staticzSHIM | grep run1)
    # staticzSHIM_RUN2_file=$(ls nifti/${subj_list[$i]}/*.nii | grep staticzSHIM | grep run2)
    # staticzSHIM_RUN3_file=$(ls nifti/${subj_list[$i]}/*.nii | grep staticzSHIM | grep run3)
    # 
    # rtSHIM_RUN1_file=$(ls nifti/${subj_list[$i]}/*.nii | grep rtSHIM | grep run1)
    # rtSHIM_RUN2_file=$(ls nifti/${subj_list[$i]}/*.nii | grep rtSHIM | grep run2)
    # rtSHIM_RUN3_file=$(ls nifti/${subj_list[$i]}/*.nii | grep rtSHIM | grep run3)

    # average MGRE across echoes
    sct_maths -i $NOSHIM_file -mean t -o nifti/${subj_list[$i]}/noSHIM_averaged.nii.gz

    sct_maths -i $staticzSHIM_RUN1_file -mean t -o nifti/${subj_list[$i]}/staticzSHIM_run1_averaged.nii.gz
    sct_maths -i $staticzSHIM_RUN2_file -mean t -o nifti/${subj_list[$i]}/staticzSHIM_run2_averaged.nii.gz
    sct_maths -i $staticzSHIM_RUN3_file -mean t -o nifti/${subj_list[$i]}/staticzSHIM_run3_averaged.nii.gz

    sct_maths -i $rtSHIM_RUN1_file -mean t -o nifti/${subj_list[$i]}/rtSHIM_run1_averaged.nii.gz
    sct_maths -i $rtSHIM_RUN2_file -mean t -o nifti/${subj_list[$i]}/rtSHIM_run2_averaged.nii.gz
    sct_maths -i $rtSHIM_RUN3_file -mean t -o nifti/${subj_list[$i]}/rtSHIM_run3_averaged.nii.gz

    sct_create_mask -i nifti/${subj_list[$i]}/spinal_seg.nii.gz -p centerline,nifti/${subj_list[$i]}/spinal_seg.nii.gz -size 45mm -f gaussian -o nifti/${subj_list[$i]}/mask_cord.nii.gz 

    # register mean GRE to T1w scan
    sct_register_multimodal -i nifti/${subj_list[$i]}/noSHIM_averaged.nii.gz -d $file_t1w -dseg nifti/${subj_list[$i]}/spinal_seg.nii.gz -m nifti/${subj_list[$i]}/mask_cord.nii.gz -param step=1,type=im,metric=cc,algo=slicereg,poly=2,smooth=1 -ofolder nifti/${subj_list[$i]}/warp_noSHIM_averaged -qc nifti/${subj_list[$i]}/qc
    
    
    # sct_register_multimodal -i nifti/${subj_list[$i]}/noSHIM_averaged.nii.gz -d $file_t1w -dseg nifti/${subj_list[$i]}/spinal_seg.nii.gz -ofolder nifti/${subj_list[$i]}/warp_noSHIM_averaged -qc nifti/${subj_list[$i]}/qc
    # TODO: do a loop
    # TODO: do not output in specific folder (not needed)
    sct_register_multimodal -i nifti/${subj_list[$i]}/staticzSHIM_run1_averaged.nii.gz -d $file_t1w -dseg nifti/${subj_list[$i]}/spinal_seg.nii.gz -m nifti/${subj_list[$i]}/mask_cord.nii.gz -param step=1,type=im,metric=cc,algo=slicereg,poly=2,smooth=1 -ofolder nifti/${subj_list[$i]}/warp_staticzSHIM_run1_averaged -qc nifti/${subj_list[$i]}/qc
    sct_register_multimodal -i nifti/${subj_list[$i]}/staticzSHIM_run2_averaged.nii.gz -d $file_t1w -dseg nifti/${subj_list[$i]}/spinal_seg.nii.gz -m nifti/${subj_list[$i]}/mask_cord.nii.gz -param step=1,type=im,metric=cc,algo=slicereg,poly=2,smooth=1 -ofolder nifti/${subj_list[$i]}/warp_staticzSHIM_run2_averaged -qc nifti/${subj_list[$i]}/qc
    sct_register_multimodal -i nifti/${subj_list[$i]}/staticzSHIM_run3_averaged.nii.gz -d $file_t1w -dseg nifti/${subj_list[$i]}/spinal_seg.nii.gz -m nifti/${subj_list[$i]}/mask_cord.nii.gz -param step=1,type=im,metric=cc,algo=slicereg,poly=2,smooth=1 -ofolder nifti/${subj_list[$i]}/warp_staticzSHIM_run3_averaged -qc nifti/${subj_list[$i]}/qc

    sct_register_multimodal -i nifti/${subj_list[$i]}/rtSHIM_run1_averaged.nii.gz -d $file_t1w -dseg nifti/${subj_list[$i]}/spinal_seg.nii.gz -m nifti/${subj_list[$i]}/mask_cord.nii.gz -param step=1,type=im,metric=cc,algo=slicereg,poly=2,smooth=1 -ofolder nifti/${subj_list[$i]}/warp_rtSHIM_run1_averaged -qc nifti/${subj_list[$i]}/qc
    sct_register_multimodal -i nifti/${subj_list[$i]}/rtSHIM_run2_averaged.nii.gz -d $file_t1w -dseg nifti/${subj_list[$i]}/spinal_seg.nii.gz -m nifti/${subj_list[$i]}/mask_cord.nii.gz -param step=1,type=im,metric=cc,algo=slicereg,poly=2,smooth=1 -ofolder nifti/${subj_list[$i]}/warp_rtSHIM_run2_averaged -qc nifti/${subj_list[$i]}/qc
    sct_register_multimodal -i nifti/${subj_list[$i]}/rtSHIM_run3_averaged.nii.gz -d $file_t1w -dseg nifti/${subj_list[$i]}/spinal_seg.nii.gz -m nifti/${subj_list[$i]}/mask_cord.nii.gz -param step=1,type=im,metric=cc,algo=slicereg,poly=2,smooth=1 -ofolder nifti/${subj_list[$i]}/warp_rtSHIM_run3_averaged -qc nifti/${subj_list[$i]}/qc

    # apply inverse transformation to bring seg to the space of the GRE T2*
    # sct_apply_transfo -i nifti/${subj_list[$i]}/spinal_seg.nii.gz -w nifti/${subj_list[$i]}/warp_noSHIM_averaged/warp_spinal_seg2noSHIM_averaged.nii.gz -x linear -d nifti/${subj_list[$i]}/noSHIM_averaged.nii.gz -o nifti/${subj_list[$i]}/spinal_seg_reg.nii.gz

    #sct_apply_transfo -i nifti/${subj_list[$i]}/spinal_seg.nii.gz -w nifti/${subj_list[$i]}/warp_staticzSHIM_run1_averaged2T1w -x linear -o nifti/${subj_list[$i]}/spinal_seg2staticzSHIM_run1.nii.gz
    #sct_apply_transfo -i nifti/${subj_list[$i]}/spinal_seg.nii.gz -w nifti/${subj_list[$i]}/warp_staticzSHIM_run2_averaged2T1w -x linear -o nifti/${subj_list[$i]}/spinal_seg2staticzSHIM_run2.nii.gz
    #sct_apply_transfo -i nifti/${subj_list[$i]}/spinal_seg.nii.gz -w nifti/${subj_list[$i]}/warp_staticzSHIM_run3_averaged2T1w -x linear -o nifti/${subj_list[$i]}/spinal_seg2staticzSHIM_run3.nii.gz

    #sct_apply_transfo -i nifti/${subj_list[$i]}/spinal_seg.nii.gz -w nifti/${subj_list[$i]}/warp_rtSHIM_run1_averaged2T1w -x linear -o nifti/${subj_list[$i]}/spinal_seg2rtSHIM_run1.nii.gz
    #sct_apply_transfo -i nifti/${subj_list[$i]}/spinal_seg.nii.gz -w nifti/${subj_list[$i]}/warp_rtSHIM_run2_averaged2T1w -x linear -o nifti/${subj_list[$i]}/spinal_seg2rtSHIM_run2.nii.gz
    #sct_apply_transfo -i nifti/${subj_list[$i]}/spinal_seg.nii.gz -w nifti/${subj_list[$i]}/warp_rtSHIM_run3_averaged2T1w -x linear -o nifti/${subj_list[$i]}/spinal_seg2rtSHIM_run3.nii.gz


    # split multiecho file, this is required for sct_extract_metric
    fslsplit $NOSHIM_file -t

    # save file names to variable once
    shopt -s nullglob
    filenames=(vol*)
    shopt -u nullglob

    # extract the mean across slices
    for ((j=0; j< ${#filenames[@]}; j++ )); do
      sct_extract_metric -i ${filenames[$j]} -f nifti/${subj_list[$i]}/warp_noSHIM_averaged/spinal_seg_reg.nii.gz -method wa -o nifti/${subj_list[$i]}/no_shim_extract_metric.csv -append 1
    done
    rm vol*

    # split multiecho file, this is required for sct_extract_metric
    fslsplit $staticzSHIM_RUN1_file -t

    # extract the mean across slices
    for ((j=0; j< ${#filenames[@]}; j++ )); do
      sct_extract_metric -i ${filenames[$j]} -f nifti/${subj_list[$i]}/warp_staticzSHIM_run1_averaged/spinal_seg_reg.nii.gz -method wa -o nifti/${subj_list[$i]}/staticzSHIM_run1_extract_metric.csv -append 1
    done
    rm vol*

    # split multiecho file, this is required for sct_extract_metric
    fslsplit $staticzSHIM_RUN2_file -t

    # extract the mean across slices
    for ((j=0; j< ${#filenames[@]}; j++ )); do
      sct_extract_metric -i ${filenames[$j]} -f nifti/${subj_list[$i]}/warp_staticzSHIM_run2_averaged/spinal_seg_reg.nii.gz -method wa -o nifti/${subj_list[$i]}/staticzSHIM_run2_extract_metric.csv -append 1
    done
    rm vol*

    # split multiecho file, this is required for sct_extract_metric
    fslsplit $staticzSHIM_RUN3_file -t

    # extract the mean across slices
    for ((j=0; j< ${#filenames[@]}; j++ )); do
      sct_extract_metric -i ${filenames[$j]} -f nifti/${subj_list[$i]}/warp_staticzSHIM_run3_averaged/spinal_seg_reg.nii.gz -method wa -o nifti/${subj_list[$i]}/staticzSHIM_run3_extract_metric.csv -append 1
    done
    rm vol*

    # split multiecho file, this is required for sct_extract_metric
    fslsplit $rtSHIM_RUN1_file -t

    # extract the mean across slices
    for ((j=0; j< ${#filenames[@]}; j++ )); do
      sct_extract_metric -i ${filenames[$j]} -f nifti/${subj_list[$i]}/warp_rtSHIM_run1_averaged/spinal_seg_reg.nii.gz -method wa -o nifti/${subj_list[$i]}/rtSHIM_run1_extract_metric.csv -append 1
    done
    rm vol*

    # split multiecho file, this is required for sct_extract_metric
    fslsplit $rtSHIM_RUN2_file -t

    # extract the mean across slices
    for ((j=0; j< ${#filenames[@]}; j++ )); do
      sct_extract_metric -i ${filenames[$j]} -f nifti/${subj_list[$i]}/warp_rtSHIM_run2_averaged/spinal_seg_reg.nii.gz -method wa -o nifti/${subj_list[$i]}/rtSHIM_run2_extract_metric.csv -append 1
    done
    rm vol*

    # split multiecho file, this is required for sct_extract_metric
    fslsplit $rtSHIM_RUN3_file -t

    # extract the mean across slices
    for ((j=0; j< ${#filenames[@]}; j++ )); do
      sct_extract_metric -i ${filenames[$j]} -f nifti/${subj_list[$i]}/warp_rtSHIM_run3_averaged/spinal_seg_reg.nii.gz -method wa -o nifti/${subj_list[$i]}/rtSHIM_run3_extract_metric.csv -append 1
    done
    rm vol*
    
    cd ..

done

# run matlab script to plot the data
matlab -nodisplay -nodesktop -r "run('./plot_data.m');exit;"
