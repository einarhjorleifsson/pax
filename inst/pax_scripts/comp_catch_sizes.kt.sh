# compcatch.sh.kt 
# thad reiknar ut ymsar staerdir fyrir catchnum.sh.

   /usr/local/bin/sorttable < $1 |\
   /usr/local/bin/subtotal by aldur on catch_no tons lbara stdev per_mat tmp_permat mat_catch \
	> tmp$$	

   totcatch=`preproject catch_no < tmp$$ | math | grep Sum |\
	     sed -n 's/	.*//p'`
   tottons=`preproject tons < tmp$$ | math | grep Sum |\
	     sed -n 's/	.*//p'`
   
   /usr/local/bin/addcol per_no per_wt wbara  < tmp$$ |\
   /usr/local/bin/compute "per_no=catch_no/$totcatch;
	    per_wt=tons/$tottons;
	    wbara=tons/catch_no;
	    lbara=lbara/catch_no;
	    stdev=stdev/catch_no;
	    per_mat=-1;
	    if(mat_catch > 0) per_mat=tmp_permat/mat_catch;" |\
   preproject aldur catch_no per_no tons per_wt wbara lbara \
	    stdev per_mat | sorttable -n > $2

rm tmp$$
