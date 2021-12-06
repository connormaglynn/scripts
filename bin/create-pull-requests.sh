for file in $(cat apps); 
do 
    cd ~/git/$file 
    git checkout -b pgp-DT-2218-fix-unavailable
    git commit -m "DT-2218: :bug: Fix max unavailable to prevent loss of service"
    git push --set-upstream origin pgp-DT-2218-fix-unavailable
    cd ~/
done