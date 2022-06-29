SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
DEFAULT_BRANCH="master"

rm -rf $SCRIPT_DIR/res
mkdir -p $SCRIPT_DIR/res

if [ $# -lt 1 ] 
then
 echo "please specify repo path"
 exit -1
fi
cd $1
git checkout $DEFAULT_BRANCH
COMMITS=$(git log --oneline|cut -c 1-7|tac)

for commit in $COMMITS
 do
 git checkout $commit
 if [ -f pom.xml ]; then
    mvn clean package jacoco:report -fn
    EPOCH_LAST_COMMIT=$(git log -1 --format=%ct)
    cp ./target/site/jacoco-ut/jacoco.xml  $SCRIPT_DIR/res/${EPOCH_LAST_COMMIT}-$commit-jacoco.xml
fi    
done
