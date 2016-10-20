#!/bin/bash
rm -f code_extracts/*
for dir in _posts _drafts; do
	  for i in $(cd $dir; ls * | sort); do
        echo "# Code from blog post at azumanga.org" > code_extracts/$i.g
        echo "#" >> code_extracts/$i.g
        ./grab_code.py < $dir/$i >> code_extracts/$i.g

		    echo "Read(\"$i.g\");" >> code_extracts/read_all.g
		    for category in Algorithm GAP; do
			      if grep "category:" $dir/$i | grep ${category} > /dev/null; then
				        echo "Read(\"$i.g\");" >> code_extracts/read_${category}.g
			      fi
		    done

	  done
done
