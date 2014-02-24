#!/bin/sh
#
#avelewt.kt.sh
#
# avelewt.sh.new 2.nov.86 -- breytt 22. jan. 1991 fyrir sun.  ag
# A shell script for calculating average length of perticular
# age_group of the fish and to calculate standard deviation of 
# the length in that age group.  The script depends upon age_
# _length tables.
# The current directory is something like /u2/fiskar/03
# The region descriptions are in s1, s2, ..., i.e. in s?
# The gear descriptions are in v1, v2, ..., i.e. in v?
# The season descriptions are in t1, t2, ..., i.e. in t?

#PATH=$PATH:/usr/local/bin/Stofnmat
llist=`/home/einarhj/r/x86_64/library/pax/shell_scripts/06makellist.sh`


teg=`cat $HOME/.species`
#cd $HOME/$teg

#echo "I am here!"

#if [ ! -d avelewt ]
#then
#	cp -r /home/haf/einarhj/src/Setup/avelewt avelewt
#fi
cd agelen
rm -f ../avelewt/*.lewt


for i in $llist
do

# read in the condition factor and power, but first skip
# 2 Prelude header lines

CONDF=`grep $i < ../keys/cond | sed 's/.*	\([0-9\.]*\)	.*/\1/'`
POWER=`grep $i < ../keys/cond | sed 's/.*	.*	\(.*\)/\1/'`
#echo "
#============================================================"
#echo "Condition factor for $i : $CONDF , power : $POWER"

	if test `wc -l < $i.a_l_k` != 2
	then

	preproject le aldur Calk < $i.a_l_k |\
		prerename Calk Cal |\
		/usr/local/bin/sorttable |\
		/usr/local/bin/subtotal by le aldur on Cal |\
		preproject aldur Cal le |\
		/usr/local/bin/addcol wbara lbara |\
		/usr/local/bin/sorttable > /tmp/tmp1$$
#echo "$i - I am here now"
#	Calculate the total length 

	/usr/local/bin/compute "wbara = Cal * $CONDF * exp( $POWER * log(le)); \
	       	 lbara = (le * Cal);" \
		 < /tmp/tmp1$$  > /tmp/tmp2$$

	totfre=`preproject Cal < /tmp/tmp2$$ | math | grep Sum |\
		sed -n 's/	.*//p'`
	totwt=`preproject wbara < /tmp/tmp2$$ | math | grep Sum |\
		sed -n 's/	.*//p'`

	#echo 'Next for the percentages'
	preproject aldur Cal wbara  < /tmp/tmp2$$ |\
	/usr/local/bin/addcol per_wt per_no |\
	/usr/local/bin/compute "per_wt = (wbara / $totwt); \
		per_no = (Cal / $totfre)" >/tmp/tmp3$$

	/usr/local/bin/subtotal by aldur on Cal wbara per_wt per_no \
		< /tmp/tmp3$$ >/tmp/tmp4$$
	preproject aldur  per_wt per_no </tmp/tmp4$$ \
	  >/tmp/tmp5$$

#	Calculate the subtotals according to age-groups for  frequency,
#	total length.Also create new columns for average length

	#echo 'Got percentages'
	preproject aldur Cal wbara lbara < /tmp/tmp2$$ |\
		/usr/local/bin/subtotal by aldur on Cal wbara lbara |\
		/usr/local/bin/compute 'wbara = (wbara / Cal); lbara = (lbara / Cal);' \
			> /tmp/tmp6$$

#	Calculate standard deviation if frequency is greater than one,
#	else assign zero value to the standard deviation.
#	
	preproject aldur Cal le < /tmp/tmp1$$ > /tmp/tmpstdev$$
	preproject aldur lbara < /tmp/tmp6$$ > /tmp/tmpstdev1$$
	/usr/local/bin/jointable /tmp/tmpstdev$$ /tmp/tmpstdev1$$ > /tmp/tmpstdev2$$
	/usr/local/bin/addcol stdev < /tmp/tmpstdev2$$ |\
		/usr/local/bin/compute "stdev=Cal*(le-lbara)*(le-lbara)"|\
		/usr/local/bin/subtotal by aldur on Cal stdev |\
		/usr/local/bin/compute "{if(Cal>1){stdev=sqrt(stdev/(Cal-1))}else{stdev=0}}" |\
		preproject aldur stdev > /tmp/tmp7$$
#
#	Delete the temporary files tmpstdev*
#	(gunnaro 2. feb. 1994)

	/bin/rm -f /tmp/tmpstdev$$ /tmp/tmpstdev1$$ /tmp/tmpstdev2$$

	#echo 'Numbering' 
	/usr/local/bin/jointable /tmp/tmp5$$ /tmp/tmp6$$ > /tmp/tmp8$$
	/usr/local/bin/jointable /tmp/tmp8$$ /tmp/tmp7$$ > /tmp/tmp9$$
	preproject aldur wbara lbara stdev per_no per_wt \
		< /tmp/tmp9$$ > /tmp/tmp10$$

	#echo 'Computing the maturity percentage, per_mat'

	preproject aldur Calkt0 Calkt1 < $i.a_l_k |\
		prerename Calkt0 kt0 Calkt1 kt1 | /usr/local/bin/sorttable |\
		/usr/local/bin/subtotal by aldur on kt0 kt1 > /tmp/tmp11$$

		/usr/local/bin/addcol per_mat < /tmp/tmp11$$ |\
		/usr/local/bin/compute "per_mat=-1; if((kt0+kt1) > 0) per_mat=kt1/(kt0+kt1)" \
		 > /tmp/tmp12$$

		preproject aldur per_mat < /tmp/tmp12$$ > /tmp/tmp13$$

	/usr/local/bin/jointable /tmp/tmp10$$ /tmp/tmp13$$ > /tmp/tmp14$$
	/usr/local/bin/addcol meanwt < /tmp/tmp14$$ |\
		/usr/local/bin/compute "meanwt=$totwt/$totfre" |\
		/usr/local/bin/sorttable -n > ../avelewt/$i.lewt

	rm -f /tmp/tmp*$$

	else

	echo "$i empty file -for calculating avg length and weights"
echo 'aldur	wbara	meanwt	lbara	stdev	per_no	per_wt	per_mat' \
	> ../avelewt/$i.lewt
echo '-----	-----	------	-----	-----	---------	---------	-------' \
	>> ../avelewt/$i.lewt

	fi

done


