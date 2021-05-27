# dynamic-realtime-shimming

Processing pipeline for realtime shimming experiment. 

This pipeline co-registers the GRE scans, compute the spinal cord segmentation 
and extract the mean signal inside the spinal cord. An additional (Matlab) 
script plots results.

## How to use
Clone this repository:
~~~
git clone https://github.com/evaalonsoortiz/dynamic-realtime-shimming.git
~~~

Run the processing script:
~~~
cd dynamic-realtime-shimming
./batch_process.sh
~~~

Plot results
~~~
matlab -nodisplay -nodesktop -r "run('./plot_data.m');exit;"
~~~
