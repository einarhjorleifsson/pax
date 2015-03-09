:
paxpath=`cat .pax_path`
paxbin=`cat .pax_bin`
PATH=$PATH:$paxpath

teg=`cat .species`
ar=`cat .year`

cd ldist

sl=sl
l=l

hausar=$teg$sl$ar.pre
lengdir=$teg$l$ar.pre


for i in s?
do
#	For this region, specified in the file $i, pull out
#       month, gear, length and count
	$paxbin/preproject reit man vf lnr < ../data/$hausar | $paxbin/plokk $i|\
				$paxbin/preproject man vf lnr > /tmp/tmp$$i
#	Now do an inner loop over seasons, for this regions
	for j in t?
	do
# 		For this region we have month, gear, length and count in
# 		/tmp/tmp$$i.
# 		Now we want to pluck the season specified in the file $j.
# 		After that we project out only the gear, length and number
		$paxbin/plokk $j < /tmp/tmp$$i | $paxbin/preproject vf lnr > /tmp/tmp$$ij
# 		Finally, an innermost loop over all gears - veidarfaeri
		for k in v?
		do
#			We have the season $j and region $i
#			stored in /tmp/tmp$$ij. Now we need to
#			take the fishing gear specified by the
#			file $k out of the temporary file.
			$paxbin/plokk $k < /tmp/tmp$$ij | $paxbin/preproject lnr > /tmp/tmp$$ijk
# 			We have the sample numbers of interest
#			in the file /tmp/tmp$$ijk and need to obtain the
#			corresponding length distributions.
#			Also do 5cm grouping
			$paxbin/plokk /tmp/tmp$$ijk < ../data/$lengdir |\
				$paxbin/preproject le fj |\
				$paxbin/addcol lemultfj |\
				$paxbin/compute 'lemultfj=le*fj' |\
				sed 's/^\([0-9]*\)[0-4]	/\12	/
				     s/^\([0-9]*\)[5-9]	/\17	/' \
				> /tmp/tmp1$$ijk
# naum i synin og reiknum hversu margir fiskar eru i theim.
                        $paxbin/plokk /tmp/tmp$$ijk < ../data/$lengdir |\
                                $paxbin/preproject lnr fj | $paxbin/sorttable | $paxbin/subtotal by lnr on fj > $k$i$j.syni
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
			$paxbin/sorttable < /tmp/tmp1$$ijk |\
			$paxbin/subtotal by le on fj lemultfj  |\
				$paxbin/sorttable -n > $k$i$j.len
#			cp /tmp/tmp$$ijk $k$i$j.syni
			else
			echo "     $k$i$j.len  is and empty file" >> ../LOGFILE
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
