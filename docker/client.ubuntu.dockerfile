FROM sovrincore

ARG ips
ARG nodecnt
ARG clicnt=10

# Install sovrin-client
USER root
RUN apt-get update -y && apt-get install -y \ 
	sovrin-client
EXPOSE 5000-9799
USER sovrin
# Init pool data
RUN if [ ! -z "$ips" ] && [ ! -z "$nodecnt" ]; then generate_sovrin_pool_transactions --nodes $nodecnt --clients $clicnt --ips "$ips"; fi
CMD sovrin
