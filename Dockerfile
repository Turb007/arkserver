FROM cm2network/steamcmd:steam

USER root

RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests bzip2 curl cron lsof libc6-i386 lib32gcc1 perl-modules sudo \
	&& apt-get remove --purge -y \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

# Setup ArkManager
RUN curl -sL http://git.io/vtf5N | bash -s steam \
	&& update-rc.d -f arkmanager remove \
	&& ln -s /usr/local/bin/arkmanager /usr/bin/arkmanager

COPY arkmanager/arkmanager.cfg /etc/arkmanager/arkmanager.cfg
COPY arkmanager/instance.cfg /etc/arkmanager/instances/main.cfg
COPY run.sh /home/steam/run.sh
COPY log.sh /home/steam/log.sh

RUN mkdir /ark \
    && chown -R steam:steam /home/steam/ /ark

RUN echo "%sudo   ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers \
    && usermod -a -G sudo steam \
    && touch /home/steam/.sudo_as_admin_successful

WORKDIR /home/steam
USER steam

# Start steamcmd to force it to update itself
RUN ./steamcmd/steamcmd.sh +quit

ENV am_ark_SessionName="Ark Server" \
    am_serverMap="TheIsland" \
    am_ark_ServerAdminPassword="k3yb04rdc4t" \
    am_ark_MaxPlayers=70 \
    am_ark_QueryPort=27016 \
    am_ark_Port=7778 \
    am_ark_RCONPort=32330 \
    am_arkwarnminutes=15

VOLUME /ark

EXPOSE 7778/tcp 7778/udp 27016/tcp 27016/udp 32330/tcp

CMD [ "./run.sh" ]
