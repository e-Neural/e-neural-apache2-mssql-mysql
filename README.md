# e-neural-apache2-mssql-mysql
Container with both databases MySQL and MSSQL


vi Dockerfile
docker build -t eneural/apache2-mssql-mysql .
docker run -it --name teste eneural/apache2-mssql-mysql bash
docker push eneural/apache2-mssql-mysql
