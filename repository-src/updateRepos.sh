#!/bin/bash
java -jar obrTool.jar -i felix.txt -o felix.repository
java -jar obrTool.jar -i jaxrs.txt -o jaxrs.repository
java -jar obrTool.jar -i slf4j.txt -o slf4j.repository
