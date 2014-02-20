:
# Program to print Catch statistic. - breytt fyrir sun  21. jan. 1991  ag
# The region descriptions are in s1,s2, ..., i.e. in s?
# The gear descriptions are in v1,v2,..., i.e. in v?
# The season descriptions are in t1,t2, ..., i.e. in t?

PATH=$PATH:/usr/local/bin/Stofnmat
slist=`makelslist.sh`
vlist=`makelvlist.sh`
tlist=`makeltlist.sh`

teg=`cat $HOME/.species`
cd $HOME/$teg
cd catch_no
ar=`cat $HOME/.year`

for j in $tlist
do
 timabil=$j
  export timabil
  for i in $slist
  do
    svaedi=$i
    export svaedi
    for k in $vlist
    do
        veidarfaeri=$k
        export veidarfaeri

	if test `wc -l < $k$i$j.catch` != 2
	then

	echo "$k$i$j"
	header.sh  tmp$$

	cd ../ldist
	fnafn=`project tegund < nafn | tail +3 | sed 's/^/      /'`
	prehead.sh > ../catch_no/temp
	cd ../catch_no

	preprint.head "Catch statistic for $fnafn" < temp >> tmp$$
	totallina=`total_lina.sh $k$i$j.catch`
	export totallina
	afruning_catch.sh $k$i$j.catch | preprint.catch.body >> tmp$$
	echo ".bp" >> tmp$$

	else
	echo ".bp" >> tmp$$
	echo "$k$i$j.catch er tom skra" >> tmp$$

	fi
    done 	

    header.sh  tmp$$
    cd ../ldist
    prehead.sh > ../catch_no/temp
    cd ../catch_no
    sed '/gear:/,$s/	.*/	all/p
         /^	all/d' < temp > temp1

    preprint.head "Catch statistic for $fnafn" < temp1 >> tmp$$
    totallina=`total_lina.sh $i$j.catch`
    export totallina
    afruning_catch.sh $i$j.catch | preprint.catch.body >> tmp$$
    echo ".bp" >> tmp$$

  done
header.sh  tmp$$
cd ../ldist
prehead.sh > ../catch_no/temp
cd ../catch_no
sed '/area:/,$s/	.*/	all/p
     /^	all/d' < temp > temp1

preprint.head "Catch statistic for $fnafn" < temp1 >> tmp$$
totallina=`total_lina.sh $j.catch`
export totallina
afruning_catch.sh $j.catch | preprint.catch.body >> tmp$$
echo ".bp" >> tmp$$

done

header.sh  tmp$$
cd ../ldist
prehead.sh > ../catch_no/temp
cd ../catch_no

sed '/season:/,$s/	.*/	all/p
     /^	all/d' < temp > temp1

preprint.head "Catch statistic for $fnafn" < temp1 >> tmp$$
totallina=`total_lina.sh all.catch`
export totallina
afruning_catch.sh all.catch | preprint.catch.body >> tmp$$
echo ".bp" >> tmp$$

# flaggid -rN0 segir ad prenta eigi "header" a allar bladsidurnar.
#echo "Prenta a $LPDEST"
#lprenta8 -rN0 -d`dispinfo -p` tmp$$
lprenta8 -rN0 -dmarbendill tmp$$


