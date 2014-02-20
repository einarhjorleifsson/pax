:
# breytt 16.3.2000, lnr og fjoldi sett i skra.  ag.
# Breytt 15.6.1999 frá sunos --> solaris.  ag.
# Breytt 12.11.1990 fyrir sun-velar fra pro.  ag.

PATH=$PATH:/usr/local/bin/Stofnmat

# The current directory is something like /usr/fiskar/03
# The raw data Prelude-format length samples is in data/lengdir
# The region descriptions are in s1, s2, ..., i.e. in s?
# The gear descriptions are in v1, v2, ..., i.e. in v?
# The season descriptions are in t1, t2, ..., i.e. in t?
# First loop over regions - svaedi



teg=`cat $HOME/.species`
ar=`cat $HOME/.year`

cd $HOME/$teg
cd ldist
rm *.len

sl=sl
l=l


hausar=$teg$sl$ar.pre
lengdir=$teg$l$ar.pre

#echo $hausar
#echo $lengdir

for i in s?
do

#	For this region, specified in the file $i, pull out
#       month, gear, length and count

	project reit man vf lnr < ../data/$hausar | plokk $i|\
				project man vf lnr > /tmp/tmp$$i
#	Now do an inner loop over seasons, for this regions

	for j in t?
	do

# 		For this region we have month, gear, length and count in
# 		/tmp/tmp$$i.
# 		Now we want to pluck the season specified in the file $j.
# 		After that we project out only the gear, length and number

		plokk $j < /tmp/tmp$$i | project vf lnr > /tmp/tmp$$ij

# 		Finally, an innermost loop over all gears - veidarfaeri

		for k in v?
		do

#			We have the season $j and region $i
#			stored in /tmp/tmp$$ij. Now we need to
#			take the fishing gear specified by the
#			file $k out of the temporary file.

			plokk $k < /tmp/tmp$$ij | project lnr > /tmp/tmp$$ijk

# 			We have the sample numbers of interest
#			in the file /tmp/tmp$$ijk and need to obtain the
#			corresponding length distributions.

#			Also do 5cm grouping

			plokk /tmp/tmp$$ijk < ../data/$lengdir |\
				project le fj |\
				addcol lemultfj |\
				compute 'lemultfj=le*fj' |\
				sed 's/^\([0-9]*\)[0-4]	/\12	/
				     s/^\([0-9]*\)[5-9]	/\17	/' \
				> /tmp/tmp1$$ijk

# naum i synin og reiknum hversu margir fiskar eru i theim.

                        plokk /tmp/tmp$$ijk < ../data/$lengdir |\
                                project lnr fj | sorttable | subtotal by lnr on fj > $k$i$j.syni

#			Now we are in an innermost loop. We have
#			a specific combination - $i,$j,$k -  of
#			region, season and gear. For this
#			combination we have pulled out all
#			the corresponding length sample data
#			and put it into /tmp/tmp1$$ijk.
#			We have yet to take the data and make a
#			single length distribution out of it.

			if test `wc -l < /tmp/tmp1$$ijk` != 2
			then

			#echo $k$i$j
			sorttable < /tmp/tmp1$$ijk |\
			subtotal by le on fj lemultfj  |\
				sorttable -n > $k$i$j.len
#			cp /tmp/tmp$$ijk $k$i$j.syni

			else

			echo "     $k$i$j.len  is and empty file" >> $HOME/$teg/LOGFILE
			cp /tmp/tmp1$$ijk $k$i$j.len
#			cp /tmp/tmp$$ijk $k$i$j.syni

			fi

#			rm /tmp/tmp$$ijk /tmp/tmp1$$ijk
#			Now the file $k$i$j.len contains the
#			length distribution for gear $k,
#			region $i and season $j and $k$i$j.syni
#			the synis_id.

		done
		rm /tmp/tmp$$ij
	done
	rm /tmp/tmp$$i
done


