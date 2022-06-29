.DEFAULT_GOAL:=all
DEXTORM_PATH:="/home/nherbaut/workspace/dextorm/DEXTORM/target/dextorm.jar"
CONF_PATH:="./dextorm.yaml"
REPORT_PATH:="res"
TARGET_REPO_PATH:="/home/nherbaut/tmp/dnsjava"

clean:
	rm -f *.json
	rm -f *.yaml
	rm -f *.log
	rm -rf res

gather:
	./generate_jacoco_history.sh  ${TARGET_REPO_PATH}
compile: 
	./compile.py ${DEXTORM_PATH} ${CONF_PATH} ${REPORT_PATH}

send: 
	./send.py ${CONF_PATH} ${REPORT_PATH}

all: clean gather compile send 
