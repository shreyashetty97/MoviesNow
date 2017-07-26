#!/bin/bash

#url from which we want to extract data
url="http://www.imdb.com/"

#-------------------------------------------------------

usage()
{
        bold=`tput bold`                                #bold can be used to set the text to bold
        reset=`tput sgr0`                               #reset can be used to reset the text back to standard format
        tput setaf 3                                    #used to set color to yellow
			echo "${bold}HELP${reset}"
			echo -e "This command is used to scrape trending movies.\n\nOPTIONS\n-d\tview complete description of the command"
}

#--------------------------------------------------------

description()
{
	bold=`tput bold`   				#bold can be used to set the text to bold
	reset=`tput sgr0`				#reset can be used to reset the text back to standard format
	tput setaf 3					#used to set color to yellow
	echo "${bold}DESCRIPTION${reset}"
	echo "This command scrapes movie names from http://www.imdb.com of different categories namely Coming Soon, Now Playing and Openinng This Week. You can also view the summary of any particular movie. Enjoy!!!"
}

#-------------------------------------------------------

movies()
{

	#creating new files
	touch movie_names
	touch op
	touch cs
	touch np
	touch opening_this_week
	touch links_opening_this_week
	touch now_playing
	touch links_now_playing
	touch coming_soon
	touch links_coming_soon
	touch temp


	#fetching the webpage of the given url and storing it in movies_names
	wget -O movie_names $url



	#matching 'Opening This Week' in the .html source code and piping it to match the title of the movie and storing it in a file
	cat movie_names|grep 'Opening This Week'|grep -oP '<a.+?>\K.+?(?=</a>[^<][^\][^p])'|grep -P '^[^<]'|tr -d "\t" > op

	#deleting extra spaces from the beginning of each line
        sed '/^\s*$/d' < op > opening_this_week

	#deleting the first line of the file
        sed -i -e "1d" opening_this_week



        cat movie_names|grep 'Now Playing'|grep -oP '<a.+?>\K.+?(?=</a>[^<][^\][^p])'|grep -P '^[^<]'|tr -d "\t" > np
        sed '/^\s*$/d' < np > now_playing
	sed -i -e "1d" now_playing



        cat movie_names|grep 'Coming Soon'|grep -oP '<a.+?>\K.+?(?=</a>[^<][^\][^p])'|grep -P '^[^<]'|tr -d "\t" > cs
        sed '/^\s*$/d' < cs > coming_soon
	sed -i -e "1d" coming_soon



        #used to save links to their desired file
        cat movie_names|grep 'Opening This Week'|grep -oP '<a href="\K\S+(?=")'>links_opening_this_week

	#deleting the first line of the file
        sed -i -e "1d" links_opening_this_week



	cat movie_names|grep 'Now Playing'|grep -oP '<a href="\K\S+(?=")'>links_now_playing
        sed -i -e "1d" links_now_playing



	cat movie_names|grep 'Coming Soon'|grep -oP '<a href="\K\S+(?=")'>links_coming_soon
        sed -i -e "1d" links_coming_soon



	bold=`tput bold`
	reset=`tput sgr0`
	ch=1


	#menu driven program

	while [ $ch = 1 ]
	do
		echo -e "${bold}MENU${reset}:\n1)Opening This Week\n2)Now Playing\n3)Coming Soon\n4)Exit\nEnter your choice"
		read choice
		case $choice in
		1)
			#displaying the contents of the file along with associated given numbers
			awk 'BEGIN{print "Opening This Week\n";i=1;}{print i++,$0;print "\n";}' opening_this_week


			echo -e "Do you want to view details of any movie??(1/0)"
			read ans

			if [ $ans -eq 1 ]
			then
				echo Enter the movie number to get more details
				read num

				#used for gettiing the desired line and storing it in variable link
				link="`sed "${num}q;d" links_opening_this_week`"

				#used to check if link is absolute link or not
				#if its a relative link then use python urlparse module to get the absolute url address of the link

				if [ "${link:0:4}" != "http" ]
				then
					export url link
					export abs_link=`python -c 'import os; base=os.environ["url"]; rel=os.environ["link"]; from urlparse import urljoin; print urljoin(str(base).strip(),str(rel).strip())'`
				else
					abs_link=$link
				fi

				#used to open the link and store it in movie_names
				wget -O movie_names $abs_link
				#used to remove all the tabs in the staring of all the lines i.e align to the left
				sed "s/^[ \t]*//" -i movie_names
				#used to display content between lines excluding the first line and the last line
				#note that -a is essential as we have to work on the actual file
				#note that ? should be given before matching the end to make grep lazy and not search for further occurences
				tput setaf 3
				echo -e "\n${bold}SUMMARY${reset}\n"
				grep -Pzoa "(?<=^<div class=\"summary_text\" itemprop=\"description\">$\n)(.|>|\n)*?(?=\n^</div>$)" movie_names
				#below command is used to display content between lines including the first and last line
				#grep -Pzo "^begin\$(.|\n)*^end$" file
			fi
			;;
		2)
                        awk 'BEGIN{print "Now Playing\n";i=1;}{print i++,$0;print "\n";}' now_playing

                        echo -e "Do you want to view details of any movie??(1/0)"
                        read ans

                        if [ $ans -eq 1 ]
                        then
                        	echo Enter the movie number to get more details
	                        read num
        	                link="`sed "${num}q;d" links_now_playing`"
                	        if [ "${link:0:4}" != "http" ]
                        	then
	        	                export url link
        	        	        export abs_link=`python -c 'import os; base=os.environ["url"]; rel=os.environ["link"]; from urlparse import urljoin; print urljoin(str(base).strip(),str(rel).strip())'`
                        	else
	        	                abs_link=$link
        	                fi
                        	wget -O movie_names $abs_link
	                        sed "s/^[ \t]*//" -i movie_names
        	                tput setaf 3
                	        echo -e "\n${bold}SUMMARY${reset}\n"
                        	grep -Pzoa "(?<=^<div class=\"summary_text\" itemprop=\"description\">$\n)(.|>|\n)*?(?=\n^</div>$)" movie_names
			fi
			;;
		3)
                        awk 'BEGIN{print "Coming Soon\n";i=1;}{print i++,$0;print "\n";}' coming_soon

                        echo -e "Do you want to view details of any movie??(1/0)"
                        read ans

                        if [ $ans -eq 1 ]
                        then
				echo Enter the movie number to get more details
        	                read num
                        	link="`sed "${num}q;d" links_coming_soon`"
                	        if [ "${link:0:4}" != "http" ]
	                        then
        	        	        export url link
                	        	export abs_link=`python -c 'import os; base=os.environ["url"]; rel=os.environ["link"]; from urlparse import urljoin; print urljoin(str(base).strip(),str(rel).strip())'`
	                        else
        	                abs_link=$link
                	        fi
                        	wget -O movie_names $abs_link
                        	sed "s/^[ \t]*//" -i movie_names
	                        tput setaf 3
        	                echo -e "\n${bold}SUMMARY${reset}\n"
                	        grep -Pzoa "(?<=^<div class=\"summary_text\" itemprop=\"description\">$\n)(.|>|\n)*?(?=\n^</div>$)" movie_names
			fi
			;;

		4) exit;;

		*) echo "Enter a valid option"

		esac

		echo -e "\n"

		echo "Enter 1 to continue"
		read ch
	done
}

#-------------------------------------------------------


while getopts ':hd' var
do
	case $var in
	h)usage;
	exit;;
	d)description;
	exit;;
	*)echo "invalid option"
	esac
done

#-------------------------------------------------------

#used to call movies function
movies;

#-------------------------------------------------------


