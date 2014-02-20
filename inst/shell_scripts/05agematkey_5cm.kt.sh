: 
# lagfaert 16.6.1999 fyrir solaris, baett vid ad setja synanr i skra.  ag
# Thetta er agematkey.5cm   2.nov.86 -- breytt 29.jan.1991 fyrir sun.  ag

PATH=$PATH:/usr/local/bin/Stofnmat

# Obtain age-length keys and maturity keys based on otolith samples
# i.e. the number of fish with each age-length-sex
# combination, based on the age-determined data.

# The current directory is something like /u2/fiskar/03
# The raw data Prelude-format otolith samples is in data/kvarnir
# The region descriptions are in s1, s2, ..., i.e. in s?
# The gear descriptions are in v1, v2, ..., i.e. in v?
# The season descriptions are in t1, t2, ..., i.e. in t?
# First loop over regions - svaedi

teg=`cat $HOME/.species`
cd $HOME/$teg
cd keys
rm -f *.key newkey

sk=sk
k=k

ar=`cat $HOME/.year`

khausar=$teg$sk$ar.pre
kvarnir=$teg$k$ar.pre
#echo $khausar
#echo $kvarnir

for i in s?
do

#	For this region, specified in the file $i, pull out
#       month, gear, length and age

	project reit man vf knr < ../data/$khausar | plokk $i |\
		project man vf knr > /tmp/tmp$$i

#	Now do an inner loop over seasons, for this regions

	for j in t?
	do

# 		For this region we have month, gear, length and age in
# 		/tmp/tmp$$i.
# 		Now we want to pluck the season specified in the file $j.
# 		After that we project out only the gear, length and number

		plokk $j < /tmp/tmp$$i | project vf knr > /tmp/tmp$$ij

# 		Finally, an innermost loop over all gears - veidarfaeri

		for k in v?
		do

#			We have the season $j and region $i
#			stored in /tmp/tmp$$ij. Now we need to
#			take the fishing gear specified by the
#			file $k out of the temporary file.

#			Also do 5cm grouping

			plokk $k < /tmp/tmp$$ij | project knr > /tmp/tmp$$ijk
			project knr le aldur kt < ../data/$kvarnir |\
				plokk /tmp/tmp$$ijk |\
				project le aldur kt knr |\
				select 'le != -1' |\
				select 'aldur != -1' |\
				sed 's/^\([0-9]*\)[0-4]	/\12	/
				     s/^\([0-9]*\)[5-9]	/\17	/' \
				> /tmp/tmp1$$ijk

#			Now we are in an innermost loop. We have
#			a specific combination - $i,$j,$k - of
#			region, season and gear. For this
#			combination we have pulled out all
#			the corresponding otolith sample data
#			and put it into /tmp/tmp1$$ijk.
#			We have yet to take the data and make a
#			single age-length table out of it.

			if test `wc -l < /tmp/tmp1$$ijk` != 2
			then

			#echo $k$i$j
			count < /tmp/tmp1$$ijk |\
				addcol kt0 kt1 ktcount |
				compute "kt0 = 0; kt1 = 0 ; \
				  if (kt == 1) kt0=count ; \
				  if (kt >= 2) kt1=count ; \
				  ktcount=kt0+kt1" |\
				project le aldur count kt0 kt1 ktcount |\
				sorttable |\
				subtotal by le aldur on \
				count kt0 kt1 ktcount |\
				sorttable -n >$k$i$j.key
#			cp /tmp/tmp$$ijk $k$i$j.syni
			project knr < /tmp/tmp1$$ijk | count | project knr count > $k$i$j.syni

			else

			echo "      $k$i$j.syni is an empty file" >> $HOME/$teg/LOGFILE
			echo 'count	le	aldur	kt0	kt1	ktcount' \
				> $k$i$j.key
			echo '-----	--	-----	--	--	-----' \
				>> $k$i$j.key
#			cp /tmp/tmp$$ijk $k$i$j.syni
			project knr < /tmp/tmp1$$ijk | count | project knr count > $k$i$j.syni

			fi

			rm -f /tmp/tmp$$ijk /tmp/tmp1$$ijk

		done
		rm -f /tmp/tmp$$ij
	done
	rm -f /tmp/tmp$$i
done

