FROM ruby:2.0.0-p648

#RUN echo "deb [check- http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
RUN echo "deb [allow-insecure=yes] http://archive.debian.org/debian stretch main" > /etc/apt/sources.list
RUN echo "deb [allow-insecure=yes] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN sed -i '/deb http:\/\/\(deb\|httpredir\).debian.org\/debian jessie.* main/d' /etc/apt/sources.list
#RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update

RUN apt-get update -y --force-yes \
  && apt-get -y --force-yes --no-install-recommends install nodejs \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/mowoli
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
RUN mkdir -p var/mwl var/db var/hl7
VOLUME /opt/mowoli/var/mwl /opt/mowoli/var/db /opt/mowoli/var/hl7
# Export directory for the Modality Worklist (MWL).
ENV MWL_DIR="/opt/mowoli/var/mwl"
# Export directory for HL7 files:
ENV HL7_EXPORT_DIR="/opt/mowoli/var/hl7"
# Name of your hospital / office (max. 64 characters)
ENV SCHEDULED_PERFORMING_PHYSICIANS_NAME="Simpson^Bart"
# Identifier of the Assigning Authority (system, organization, agency, or
# department) that issued the Patient ID.
# This sets DICOM-Tag (0010,0021).
ENV ISSUER_OF_PATIENT_ID="MOWOLI"
ENV RAILS_ENV=development
RUN bin/rake db:migrate RAILS_ENV=development
EXPOSE 3000
CMD ["bundle","exec","puma","--config","config/puma.rb"]
