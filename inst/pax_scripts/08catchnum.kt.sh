#!/bin/sh
#
# catchnum.kt.sh
#
# catchnum.sh  - breytt 29. jan. 1991 fyrir sun.  ag
# Compute catch in numbers

PATH=$PATH:/usr/local/bin/Stofnmat

tlist=`/home/einarhj/r/Pakkar/pax/inst/pax_scripts/makeltlist.sh`
slist=`/home/einarhj/r/Pakkar/pax/inst/pax_scripts/makelslist.sh`
vlist=`/home/einarhj/r/Pakkar/pax/inst/pax_scripts/makelvlist.sh`


teg=`cat $HOME/.species`

#cd $HOME/$teg

#if [ ! -d catch_no ]
#then
#	cp -r /home/haf/einarhj/src/Setup/catch_no catch_no
#fi
cd avelewt
rm -f ../catch_no/*.catch

echo "aldur	catch_no	tons	lbara	stdev	per_mat	tmp_permat	mat_catch" > haus
echo "-----	--------	----	-----	-----	-------	----------	---------" >> haus

/home/einarhj/r/Pakkar/pax/inst/pax_scripts/gethead < haus > all.tmp

for j in $tlist
do
  /home/einarhj/r/Pakkar/pax/inst/pax_scripts/gethead < haus > $j.tmp

  for i in $slist
  do
    /home/einarhj/r/Pakkar/pax/inst/pax_scripts/gethead < haus > $i$j.tmp

    for k in $vlist
    do	

	if test `wc -l < $k$i$j.lewt` != 2
	then

	wt=`grep $k$i$j < ../par/wts | sed -n 's/.*	//p'`
	#echo " $k$i$j ---> $wt "
	#echo 'Prepare mean lengths'
	preproject aldur per_wt per_no wbara meanwt \
		per_mat lbara stdev < $k$i$j.lewt > /tmp/tmp1$$

	#echo 'Computing catch in numbers'
	addcol totnum catch_no tons < /tmp/tmp1$$ |\
		compute "totnum = $wt / meanwt" |\
		compute 'catch_no = totnum * per_no' |\
		compute 'tons = catch_no * wbara' >/tmp/tmp2$$

	preproject aldur catch_no per_no tons \
		per_wt wbara lbara stdev \
		per_mat < /tmp/tmp2$$ > ../catch_no/$k$i$j.catch

	#echo "Aggregating data over seasons, area and gears"
	preproject aldur catch_no tons lbara stdev per_mat \
		< ../catch_no/$k$i$j.catch |\
	addcol tmp_permat mat_catch |\
	compute 'lbara=lbara*catch_no;
		 stdev=stdev*catch_no;
		 tmp_permat=0;
		 mat_catch=0; 
		 if(per_mat > -1){tmp_permat=per_mat*catch_no;
				  mat_catch=catch_no}' |\
		 tail -n +3 >> $i$j.tmp

	else

	echo "$k$i$j.catch empty file"
	/home/einarhj/r/Pakkar/pax/inst/pax_scripts/gethead < haus > ../catch_no/$k$i$j.catch
	fi

     done

# reiknum saman allt fyrir eitt timabil, eitt svaedi og oll
# veidarfaeri.

   /home/einarhj/r/Pakkar/pax/inst/pax_scripts/comp_catch_sizes.kt.sh $i$j.tmp  ../catch_no/$i$j.catch

   #echo "Aggregating data for one season, one region and all gears"

   preproject aldur catch_no tons lbara stdev per_mat tmp_permat mat_catch \
	< $i$j.tmp | tail -n +3 >> $j.tmp

  rm -f $i$j.tmp
  done
echo "line 93"
# reiknum sama allt fyrir eitt timabil og oll svaedi og oll vf

  /home/einarhj/r/Pakkar/pax/inst/pax_scripts/comp_catch_sizes.kt.sh $j.tmp ../catch_no/$j.catch	

  #echo "Aggregating over all seasons"
   
  preproject aldur catch_no tons lbara stdev per_mat tmp_permat mat_catch \
	< $j.tmp | tail -n +3 >> all.tmp
  rm -f $j.tmp
done

# allur aflinn!

/home/einarhj/r/Pakkar/pax/inst/pax_scripts/comp_catch_sizes.kt.sh  all.tmp ../catch_no/all.catch

rm -f /tmp/tmp?$$ all.tmp

#xmessage -message "The script $0 has finished" -buttons "Continue" -geometry 500x70+300+100 -borderwidth 3 -bordercolor black
#exit

