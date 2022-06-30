.DEFAULT_GOAL:=all
DEXTORM_PATH:="./bin/dextorm.jar"
CONF_PATH:="./dextorm.yaml"
REPORT_PATH:="res"
TARGET_REPO_PATH:="tmp"

clean:
	rm -f *.json
	#rm -f *.yaml
	rm -f *.log
	rm -rf res
	rm -rf tmp
	rm -rf bin

gui:
	docker-compose up 
gui-detached:
	docker-compose up -d

gui-stop:
	docker-compose down -d

bootstrap: clean
	mvn -DstripClassifier=true -DstripVersion=true -DoutputAbsoluteArtifactFilename=true -DoutputDirectory=. -Dtransitive=false -Dartifact=fr.pantheonsorbonne.cri:dextorm:LATEST -DremoteRepositories=miage::default::https://maven.miage.def/releases dependency:copy
	mkdir bin
	mv *.jar bin/dextorm.jar
	git clone --branch $(shell python get_repo_addr.py -b) https://github.com/$(shell python get_repo_addr.py) tmp 

gather:
	./generate_jacoco_history.sh  ${TARGET_REPO_PATH} 100 $(shell python get_repo_addr.py -b)
compile: 
	./compile.py ${DEXTORM_PATH} ${CONF_PATH} ${REPORT_PATH}

send: 
	./send.py ${CONF_PATH} ${REPORT_PATH}

all: clean gui-detached bootstrap gather compile send 

