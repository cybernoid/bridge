FROM ruby:alpine
LABEL Maintainer="Andre Landwehr <andrel@cybernoia.de>" Application_Release_date="2017-03-17" Description="A bridge that tunnels other protocols through HTTP"

RUN ln -s /usr/local/bin/ruby /usr/bin/
RUN apk add --no-cache util-linux
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . .
RUN bundle install

EXPOSE 80

ENTRYPOINT ["/usr/src/app/bridge"]
CMD ["80", "/bridge"]
