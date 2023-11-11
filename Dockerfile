FROM IMAGE

ENV NODE_TLS_REJECT_UNAUTHORIZED='0'
COPY etc/ /etc/
COPY root/ /root/
COPY usr/ /usr/
COPY --chown=1000 root/.npmrc /home/node/
COPY --chown=33 root/.composer /var/www/
RUN lsp-install
