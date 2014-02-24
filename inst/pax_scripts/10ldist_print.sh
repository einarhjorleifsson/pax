:
# breytt 15.6.1999 fra sunos ---> solaris og baett vid prentskipun
# th.a. synis_id prentist ut.   ag.
# Program to print all the length distributions
# The region descriptions are in s1,s2, ..., i.e. in s?
# The gear descriptions are in v1,v2,..., i.e. in v?
# The season descriptions are in t1,t2, ..., i.e. in t?

PATH=$PATH:/usr/local/bin/Stofnmat

if [ ! -f $HOME/.species ]
then
	echo "Must select species first" 1>&2
	sleep 10
	xmessage -message "The script $0 has finished" -buttons "Continue" -geometry 200x70+300+100 -borderwidth 3 -bordercolor black
	exit 1
fi
teg=`cat $HOME/.species`

if [ ! -d $HOME/$teg ]
then
	mkdir $HOME/$teg
fi
cd $HOME/$teg



if [ ! -d ldist ]
then
	cp -r /usr/local/reikn/src/Stofnmat/setup/$teg/ldist ldist
fi
cd ldist


if [ ! -f $HOME/.year ]
then
	echo "Must select year first" 1>&2
	sleep 10
	xmessage -message "The script $0 has finished" -buttons "Continue" -geometry 200x70+300+100 -borderwidth 3 -bordercolor black
	exit 1
fi
ar=`cat $HOME/.year`

header.sh tmp
fnafn=`project tegund < nafn | tail +3 | sed 's/^/	/'`

for i in s?
do
  svaedi=$i
  export svaedi
  for j in t?
  do
    timabil=$j
    export timabil
    for k in v?
    do
	veidarfaeri=$k
	export veidarfaeri

        if test `wc -l < $k$i$j.len` != 2
        then

	echo "$k$i$j"

	prehead.sh > temp
	preprint.head "Length distribution for $fnafn" < temp >> tmp

# reiknum heildarfjolda og medallengd og prosentudreifingu.

	addcol one < $k$i$j.len | compute 'one=1' |\
		project one fj lemultfj |\
		subtotal by one on fj lemultfj |\
		compute "lemultfj=int(lemultfj*10/fj+0.5)/10" > temp1

	allsfjoldi=`project fj < temp1 | tail +3`
	meanle=`project lemultfj < temp1 | tail +3`
	export allsfjoldi
	export meanle
	addcol pros < $k$i$j.len |\
		compute "pros=int(fj*1000/$allsfjoldi+0.5)/10" |\
		project le fj pros |\
		rename le Length fj Number pros Percent > temp2

# ef um 5cm flokkun er ad raeda, tha er bara 2 og 7 i skranni temp3 og hun
# hefur 4 linur.  Se hins vegar um 1cm flokkun ad raeda hefur skrain 
# temp3 fleiri en 4 linur.

	project le < $k$i$j.len | sed 's/\(.\)$/	\1/p' |\
		 project e | sorttable | uniq > temp3

	if test `wc -l < temp3` -gt 4
	then	
		preprint.ldist.body < temp2 >>tmp
		echo ".sp 2" >> tmp
		echo "\\\fBSample used: \\\fP" >> tmp
		tail +3 < $k$i$j.syni >> tmp
		echo ".bp" >> tmp
	else
		sed 's/^\([0-9]*\)2	/\10-\14	/' < temp2 |\
	        sed 's/^\([0-9]*\)7	/\15-\19	/' |\
		preprint.ldist.body >>tmp
		echo ".sp 2" >> tmp
		echo "\\\fBSample used: \\\fP" >> tmp
		tail +3 < $k$i$j.syni >> tmp
		echo ".bp" >> tmp
	fi

        else
        echo ".bp" >> tmp
	echo "$k$i$j.len er tom skra" >> tmp
        echo ".bp" >> tmp

        fi
	done 
    done
done


# flaggid -rN0 segir ad prenta eigi "header" a allar bladsidurnar.

#lprenta8 -rN0 -d`dispinfo -p` tmp
lprenta8 -rN0 -dmarbendill tmp

rm tmp
rm temp temp1 temp2 temp3
sleep 10
xmessage -message "The script $0 has finished" -buttons "Continue" -geometry 500x70+300+100 -borderwidth 3 -bordercolor black
	exit

