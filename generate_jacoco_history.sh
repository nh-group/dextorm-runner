# $1 = the path of the repo
# $2 = number of commit to keep
# $3 = the optional branch name (otherwise, we pick master)

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

rm -rf $SCRIPT_DIR/res
mkdir -p $SCRIPT_DIR/res

if [ $# -lt 1 ] 
then
 echo "please specify repo path"
 exit -1
fi
cd $1
if [ $# -ge 2 ]
then
  COMMIT_COUNT=$(git log --oneline |wc -l)
  COMMITS_TO_SKIP=$(( $(( $COMMIT_COUNT -$2 )) < 0 ? 0 : $(( $COMMIT_COUNT -$2 )) ))
else
  COMMITS_TO_SKIP=0
fi
if [ $# -ge 3 ]
then
  DEFAULT_BRANCH=$3
else
  DEFAULT_BRANCH="master"
fi

git checkout $DEFAULT_BRANCH
COMMITS=$(git log --oneline --skip=$COMMITS_TO_SKIP|cut -c 1-7|tac)

for commit in $COMMITS
 do
	 echo "##################### deadling with commit $commit $(git show -s --oneline $commit)"
 git checkout $commit
 if [ -f pom.xml ]; then
    mvn -Dmaven.repo.remote=https://maven.miage.dev/snapshots fr.pantheonsorbonne.cri:dextorm-enforcer-plugin:1.0.0-SNAPSHOT:enforce
    mvn clean package jacoco:report -fn -f dextorm-effective-pom.xml
    #echo "press enter to gather jacoco report"
    #read "dummy "
    EPOCH_LAST_COMMIT=$(git log -1 --format=%ct)
    JACOCO_REPORT="$(find . |grep jacoco.xml)"
    echo jacoco report file : $JACOCO_REPORT
    if [ -z "$JACOCO_REPORT" ]; then
      echo "empty report, skipping"
    else
      cp $(find . |grep jacoco.xml)  $SCRIPT_DIR/res/${EPOCH_LAST_COMMIT}-$commit-jacoco.xml
    fi
fi    
done
