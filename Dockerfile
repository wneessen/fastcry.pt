## Dockerfile for fastcry.pt
## 
FROM        archlinux
LABEL       maintainer="wn@neessen.net"
ENV         PERL_VERSION=5.32.0
RUN         pacman -Syu --noconfirm --noprogressbar
RUN         pacman -S --noconfirm --noprogressbar gcc make
RUN         /usr/bin/groupadd -r fastcrypt && /usr/bin/useradd -r -g fastcrypt -c "fastcry.pt user" -m -s /bin/bash -d /opt/fastcrypt fastcrypt
COPY        ["LICENSE", "README.md", "/opt/fastcrypt/"]
COPY        ["bin", "/opt/fastcrypt/bin"]
COPY        ["conf", "/opt/fastcrypt/conf"]
COPY        ["contrib", "/opt/fastcrypt/contrib"]
COPY        ["lib", "/opt/fastcrypt/lib"]
COPY        ["public", "/opt/fastcrypt/public"]
COPY        ["script", "/opt/fastcrypt/script"]
COPY        ["templates", "/opt/fastcrypt/templates"]
RUN         mkdir /opt/fastcrypt/files
RUN         chown -R fastcrypt:fastcrypt /opt/fastcrypt
WORKDIR     /opt/fastcrypt
USER        fastcrypt
RUN         \curl -L http://install.perlbrew.pl | bash
RUN         . /opt/fastcrypt/perl5/perlbrew/etc/bashrc && perlbrew install $PERL_VERSION 
RUN         /bin/bash -c '. /opt/fastcrypt/perl5/perlbrew/etc/bashrc && perlbrew use $PERL_VERSION && \
            ( \curl -L http://cpanmin.us | perl - App::cpanminus )'
RUN         /bin/bash -c '. /opt/fastcrypt/perl5/perlbrew/etc/bashrc && perlbrew use $PERL_VERSION && \
            cpanm Mojolicious Bytes::Random::Secure Crypt::CBC Crypt::Rijndael Digest::SHA File::MMagic::XS \
            MIME::Base64 UUID'
USER        root
RUN         pacman -Rs --noconfirm --noprogressbar gcc make
USER        fastcrypt
VOLUME      ["/opt/fastcrypt/conf", "/opt/fastcrypt/files"]
ENV         PATH=$PATH:/opt/fastcrypt/perl5/perlbrew/perls/perl-$PERL_VERSION/bin
EXPOSE      8080
CMD         ["hypnotoad", "-f", "/opt/fastcrypt/script/fast_crypt"]