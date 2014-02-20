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
llist=`06makellist.sh`


teg=`cat $HOME/.species`
cd $HOME/$teg

#echo "I am here!"

if [ ! -d avelewt ]
then
	cp -r /home/haf/einarhj/src/Setup/avelewt avelewt
fi
cd agelen
rm -f ../avelewt/*.lewt


#echo "now I am here"
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

	project le aldur Calk < $i.a_l_k |\
		rename Calk Cal |\
		sorttable |\
		subtotal by le aldur on Cal |\
		project aldur Cal le |\
		addcol wbara lbara |\
		sorttable > /tmp/tmp1$$
#echo "$i - I am here now"
#	Calculate the total length 

	compute "wbara = Cal * $CONDF * exp( $POWER * log(le)); \
	       	 lbara = (le * Cal);" \
		 < /tmp/tmp1$$  > /tmp/tmp2$$

	totfre=`project Cal < /tmp/tmp2$$ | math | grep Sum |\
		sed -n 's/	.*//p'`
	totwt=`project wbara < /tmp/tmp2$$ | math | grep Sum |\
		sed -n 's/	.*//p'`

	#echo 'Next for the percentages'
	project aldur Cal wbara  < /tmp/tmp2$$ |\
	addcol per_wt per_no |\
	compute "per_wt = (wbara / $totwt); \
		per_no = (Cal / $totfre)" >/tmp/tmp3$$

	subtotal by aldur on Cal wbara per_wt per_no \
		< /tmp/tmp3$$ >/tmp/tmp4$$
	project aldur  per_wt per_no </tmp/tmp4$$ \
	  >/tmp/tmp5$$

#	Calculate the subtotals according to age-groups for  frequency,
#	total length.Also create new columns for average length

	#echo 'Got percentages'
	project aldur Cal wbara lbara < /tmp/tmp2$$ |\
		subtotal by aldur on Cal wbara lbara |\
		compute 'wbara = (wbara / Cal); lbara = (lbara / Cal);' \
			> /tmp/tmp6$$

#	Calculate standard deviation if frequency is greater than one,
#	else assign zero value to the standard deviation.
#	
	project aldur Cal le < /tmp/tmp1$$ > /tmp/tmpstdev$$
	project aldur lbara < /tmp/tmp6$$ > /tmp/tmpstdev1$$
	jointable /tmp/tmpstdev$$ /tmp/tmpstdev1$$ > /tmp/tmpstdev2$$
	addcol stdev < /tmp/tmpstdev2$$ |\
		compute "stdev=Cal*(le-lbara)*(le-lbara)"|\
		subtotal by aldur on Cal stdev |\
		compute "{if(Cal>1){stdev=sqrt(stdev/(Cal-1))}else{stdev=0}}" |\
		project aldur stdev > /tmp/tmp7$$
#
#	Delete the temporary files tmpstdev*
#	(gunnaro 2. feb. 1994)

	/bin/rm -f /tmp/tmpstdev$$ /tmp/tmpstdev1$$ /tmp/tmpstdev2$$

	#echo 'Numbering' 
	jointable /tmp/tmp5$$ /tmp/tmp6$$ > /tmp/tmp8$$
	jointable /tmp/tmp8$$ /tmp/tmp7$$ > /tmp/tmp9$$
	project aldur wbara lbara stdev per_no per_wt \
		< /tmp/tmp9$$ > /tmp/tmp10$$

	#echo 'Computing the maturity percentage, per_mat'

	project aldur Calkt0 Calkt1 < $i.a_l_k |\
		rename Calkt0 kt0 Calkt1 kt1 | sorttable |\
		subtotal by aldur on kt0 kt1 > /tmp/tmp11$$

		addcol per_mat < /tmp/tmp11$$ |\
		compute "per_mat=-1; if((kt0+kt1) > 0) per_mat=kt1/(kt0+kt1)" \
		 > /tmp/tmp12$$

		project aldur per_mat < /tmp/tmp12$$ > /tmp/tmp13$$

	jointable /tmp/tmp10$$ /tmp/tmp13$$ > /tmp/tmp14$$
	addcol meanwt < /tmp/tmp14$$ |\
		compute "meanwt=$totwt/$totfre" |\
		sorttable -n > ../avelewt/$i.lewt

	rm -f /tmp/tmp*$$

	else

	echo "$i empty file -for calculating avg length and weights"
echo 'aldur	wbara	meanwt	lbara	stdev	per_no	per_wt	per_mat' \
	> ../avelewt/$i.lewt
echo '-----	-----	------	-----	-----	---------	---------	-------' \
	>> ../avelewt/$i.lewt

	fi

done


