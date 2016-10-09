# See: https://github.com/phusion/passenger-docker
# Latest image versions: https://github.com/phusion/passenger-docker/blob/master/Changelog.md
FROM phusion/passenger-ruby23:0.9.19
MAINTAINER Brent Kearney <brent@netmojo.ca>

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN apt-get update -qq && apt-get install -qy wget curl gnupg ca-certificates imagemagick \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "Europe/Zurich" > /etc/timezone
RUN locale-gen fr_CH.utf8
ENV LANG fr_CH.utf8
ENV LANGUAGE fr_CH:en
ENV LC_ALL fr_CH.utf8

RUN /usr/sbin/usermod -u 999 app
RUN /usr/sbin/groupmod -g 999 app
WORKDIR /home/app
EXPOSE 8080
ADD entrypoint.sh /sbin/
RUN chmod 755 /sbin/entrypoint.sh
RUN mkdir -p /etc/my_init.d
RUN ln -s /sbin/entrypoint.sh /etc/my_init.d/entrypoint.sh
RUN /bin/bash -l -c "rvm get stable && rvm reload && rvm repair all"
ENTRYPOINT ["/sbin/entrypoint.sh"]
