FROM sovrincore

# Install sovrin-client
USER root
RUN apt-get update -y && apt-get install -y \ 
	sovrin-client
EXPOSE 5000-9799
USER sovrin
