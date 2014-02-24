:
# 16.3.2000, tekid ut ad prenta synis_id.  ag
# 18.6.1999, baett vid ad prenta ut synis_id. ag.
# Program to print Age-Length-Maturity-tables
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



if [ ! -f $HOME/.year ]
then
	echo "Must select year first" 1>&2
	sleep 10
	xmessage -message "The script $0 has finished" -buttons "Continue" -geometry 200x70+300+100 -borderwidth 3 -bordercolor black
	exit 1
fi
ar=`cat $HOME/.year`

if [ ! -d keys ]
then
	cp -r /usr/local/reikn/src/Stofnmat/setup/$teg/keys keys
fi
cd keys

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

	if test `wc -l < $k$i$j.key` != 2
	then

	echo "$k$i$j"
        header.sh tmp
        fnafn=`project tegund < nafn | tail +3 | sed 's/^/      /'`
        prehead.sh > temp
        preprint.head "Age-length-maturity-keys for $fnafn" < temp >> tmp

        project le < $k$i$j.key | sed 's/\(.\)$/	\1/p' |\
                 project e | sorttable | uniq > temp1

        if test `wc -l < temp1` -gt 4
        then
# 1cm flokkun
# stuss vegna matrix:
# hlutf== -1 thydir ad ekki er kynthroskagreint, thvi er sidan breytt i .
# hlutf== -2 thydir ad hlutf==0, en ekki thydir ad bjoda matrix
#		   thad, svo thvi er breytt i -2 og sidam i 0 med sed.

		addcol sum hlutf < $k$i$j.key | select 'le != -1' |\
		select 'aldur > 0' |\
		compute 'sum = kt0 + kt1' |\
	compute '{if(sum > 0){hlutf=int(kt1*1000/sum+0.5)}else{hlutf=-1}}'|\
		compute 'if(hlutf == 0) hlutf=-2' |\
		project hlutf aldur le |\
		rename le Length |\
		matrix -m '	%5.0f' |\
		sed 's/ -2	/ 0	/g' |\
		sed 's/ -2$/ 0/g' |\
		sed 's/   -1	/.	/g' |\
		sed 's/   -1$/./g' |\
		sed 's/aldur//g' | preprint.keys.body >> tmp
#                echo ".sp 2" >> tmp
#                echo "\\\fBSamples used:\\\fP  " >> tmp
#                tail +3 < $k$i$j.syni >> tmp
                echo ".bp" >> tmp  
        else

# 5cm flokkun
		addcol sum hlutf < $k$i$j.key | select 'le != -1' |\
		select 'aldur > 0' |\
		compute 'sum = kt0 + kt1' |\
	compute '{if(sum > 0){hlutf=int(kt1*1000/sum+0.5)}else{hlutf=-1}}'|\
		compute 'if(hlutf == 0) hlutf=-2' |\
		project hlutf aldur le |\
		rename le Length |\
		matrix -m '	%5.0f' |\
		sed 's/ -2	/ 0	/g' |\
		sed 's/ -2$/ 0/g' |\
		sed 's/   -1	/.	/g' |\
		sed 's/   -1$/./g' |\
                sed 's/^\([0-9]*\)2	/\10-\14	/' |\
                sed 's/^\([0-9]*\)7	/\15-\19	/' |\
		sed 's/aldur//g' | preprint.keys.body >> tmp
#                echo ".sp 2" >> tmp
#                echo "\\\fBSamples used:\\\fP  " >> tmp
#                tail +3 < $k$i$j.syni >> tmp
                echo ".bp" >> tmp  
        fi

	else
	echo ".bp" >> tmp
	echo "$k$i$j.key er tom skra" >> tmp

	fi
	done 
    done
done

# -rN0 segir troffinu, ad haus eigi ad koma a allar sidur, lika tha fyrstu!
#lprenta8 -rN0 -d`dispinfo -p` tmp
lprenta8 -rN0 -dmarbendill tmp
rm tmp temp temp1
sleep 10
xmessage -message "The script $0 has finished" -buttons "Continue" -geometry 500x70+300+100 -borderwidth 3 -bordercolor black
	exit

