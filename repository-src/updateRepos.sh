#!/bin/bash
java -jar obrTool.jar -i felix.txt -o felix.repository -a -s
java -jar obrTool.jar -i jaxrs.txt -o jaxrs.repository -a -s
java -jar obrTool.jar -i swagger.txt -o swagger.repository 
java -jar obrTool.jar -i slf4j.txt -o slf4j.repository 
sed -e '28d' slf4j.repository > slf4j.repository.tmp
mv slf4j.repository.tmp slf4j.repository
