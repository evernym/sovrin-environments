FROM sovrincore

# Install sovrin-node
USER root
RUN apt-get update -y && apt-get install -y \ 
	sovrin-node
USER sovrin
