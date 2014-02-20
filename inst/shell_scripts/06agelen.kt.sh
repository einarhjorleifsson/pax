:
# Thetta er agelen.sh 2.nov.86 -- breytt 22. jan. 1991 fyrir sun.  ag
# Shell script for making age-length-kt tables 
# based on maturity and length dists,
# and for making age-length tables there from.

# The current directory is something like /u2/fiskar/03
# The region descriptions are in s1, s2, ..., i.e. in s?
# The gear descriptions are in v1, v2, ..., i.e. in v?
# The season descriptions are in t1, t2, ..., i.e. in t?

#PATH=$PATH:/usr/local/bin/Stofnmat

#llist=`06makellist.sh`



teg=`cat $HOME/.species`
#cd $HOME/$teg
cd ldist

for i in v?
do
for j in s?
do
for k in t?
do
llist="$llist $i$j$k"
done
done
done
#echo $llist
cd ..









teg=`cat $HOME/.species`
#cd $HOME/$teg
#if [ ! -d agelen ]
#then
#	cp -r /home/haf/einarhj/src/Setup/agelen agelen
#fi

cd keys
rm -f ../agelen/*.a_l_k

for i in $llist
do

#	Pull out the length and count and rename count Kl
#	and then calculate total frequency for specific length of fish
#	from age_length keys.

	if test `wc -l < $i.key` != 2
	then

	#echo $i
	preproject le count < $i.key |\
		plokk lengths |\
		prerename count Kl |\
		/usr/local/bin/sorttable |\
		subtotal by le on Kl > /tmp/tmpKl$$

#	Pull out the length, age, kt0, kt1, and count and rename count as Kalk
#	from agelength maturitykeys.

	preproject aldur le kt0 kt1 count < $i.key |\
		plokk ages |\
		preproject le aldur kt0 kt1 count |\
		/usr/local/bin/select 'aldur > 0' |\
		prerename count Kalk |\
		/usr/local/bin/sorttable > /tmp/tmpKalk$$
	
#	Pull out length and frequency from ldist files and rename
#	frequency as Cl
	
	preproject le fj  < ../ldist/$i.len |\
		prerename fj Cl | /usr/local/bin/sorttable > /tmp/tmp1$$

#	For the maturitykeys
  echo "Waldo in line 87"
  echo $i
	jointable /tmp/tmp1$$ /tmp/tmpKl$$ > /tmp/tmp2$$
	jointable /tmp/tmp2$$ /tmp/tmpKalk$$ > /tmp/tmp3$$
	preproject le aldur kt0 kt1 Kl Cl Kalk < /tmp/tmp3$$ |\
		addcol Calk Calkt0 Calkt1 > /tmp/tmp4$$

	compute "Calk=0; Calkt0=0; Calkt1=0;\
	 if(Kl>0){Calk=(Kalk/Kl)*Cl;\
	 if((kt0+kt1) > 0) {Calkt0=(kt0/(kt0+kt1))*(Kalk/Kl)*Cl;\
	 		  Calkt1=(kt1/(kt0+kt1))*(Kalk/Kl)*Cl;}}"\
		 </tmp/tmp4$$ >/tmp/tmp5$$  
	/usr/local/bin/sorttable -n  < /tmp/tmp5$$ > ../agelen/$i.a_l_k

	rm -f /tmp/tmp*$$

	else

	echo "$i.a_l_k : An empty file, can not create catch at age for this metier "
	echo "le	aldur	kt0	kt1	Kl	Cl	Kalk	Calk" \
		> ../agelen/$i.a_l_k
	echo "--	-----	---	---	--	--	----	----" \
		>> ../agelen/$i.a_l_k

	fi

done

